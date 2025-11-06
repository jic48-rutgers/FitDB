-- 5) Triggers

DELIMITER $$

-- 5.1 member access card auto create
-- automatically generates access card when new member is added
-- can be disabled by setting @DISABLE_AUTO_TRIGGERS = 1 (used during bulk loading)
CREATE TRIGGER trg_member_access_card_auto_create
AFTER INSERT ON MEMBER
FOR EACH ROW
BEGIN
    DECLARE v_active_card_status_id BIGINT;
    DECLARE v_card_uid VARCHAR(128);
    
    -- skip trigger execution if bulk loading
    IF @DISABLE_AUTO_TRIGGERS IS NULL OR @DISABLE_AUTO_TRIGGERS = 0 THEN
        -- get active card status ID
        SELECT id INTO v_active_card_status_id FROM ACCESS_CARD_STATUS_IND WHERE code = 'ACTIVE';
        
        -- generate unique card UID
        SET v_card_uid = CONCAT('CARD_', LPAD(NEW.id, 8, '0'), '_', UNIX_TIMESTAMP());
        
        -- create access card automatically
        INSERT INTO ACCESS_CARD (member_id, gym_id, card_uid, status_id, issued_at)
        VALUES (NEW.id, NEW.home_gym_id, v_card_uid, v_active_card_status_id, NOW());
    END IF;
END$$

-- 5.2 member access card unique
-- prevents duplicate active access cards per member
CREATE TRIGGER trg_member_access_card_unique
BEFORE INSERT ON ACCESS_CARD
FOR EACH ROW
BEGIN
    DECLARE v_existing_count INT DEFAULT 0;
    
    -- check if member already has an active access card
    SELECT COUNT(*) INTO v_existing_count
    FROM ACCESS_CARD ac
    JOIN ACCESS_CARD_STATUS_IND acsi ON ac.status_id = acsi.id
    WHERE ac.member_id = NEW.member_id AND acsi.code = 'ACTIVE';
    
    -- if member already has an active access card, signal an error
    IF v_existing_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member already has an active access card';
    END IF;
END$$

-- 5.3 user password updated
-- updates timestamp when password is changed
CREATE TRIGGER trg_user_password_updated
BEFORE UPDATE ON USER
FOR EACH ROW
BEGIN
    IF NEW.password_hash != OLD.password_hash THEN
        SET NEW.password_updated_at = NOW();
    END IF;
END$$

-- 5.4 user deletion guard
-- prevents deletion of users with active memberships or staff roles
CREATE TRIGGER trg_user_deletion_guard
BEFORE DELETE ON USER
FOR EACH ROW
BEGIN
    DECLARE v_active_member_count INT DEFAULT 0;
    DECLARE v_active_staff_count INT DEFAULT 0;
    
    -- check for active memberships
    SELECT COUNT(*) INTO v_active_member_count
    FROM MEMBER m
    JOIN ACCOUNT_STATUS_IND asi ON m.status_id = asi.id
    WHERE m.user_id = OLD.id AND asi.code = 'ACTIVE';
    
    -- check for active staff roles
    SELECT COUNT(*) INTO v_active_staff_count
    FROM STAFF s
    JOIN ACCOUNT_STATUS_IND asi ON s.status_id = asi.id
    WHERE s.user_id = OLD.id AND asi.code = 'ACTIVE';
    
    -- if user has active memberships or staff roles, signal an error
    IF v_active_member_count > 0 OR v_active_staff_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete user with active memberships or staff roles';
    END IF;
END$$

-- 5.5 member status user consistency
-- ensures member status aligns with user status
CREATE TRIGGER trg_member_status_user_consistency
BEFORE UPDATE ON MEMBER
FOR EACH ROW
BEGIN
    DECLARE v_user_status_code VARCHAR(64);
    
    -- get user status
    SELECT asi.code INTO v_user_status_code
    FROM USER u
    JOIN ACCOUNT_STATUS_IND asi ON u.status_id = asi.id
    WHERE u.id = NEW.user_id;
    
    -- if user is locked or inactive, member should be suspended
    IF v_user_status_code IN ('LOCKED', 'INACTIVE') AND NEW.status_id != (
        SELECT id FROM ACCOUNT_STATUS_IND WHERE code = 'SUSPENDED'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member status must be SUSPENDED when user is LOCKED or INACTIVE';
    END IF;
END$$

-- 5.6 check-in validation
-- validates access card status and gym access permissions
CREATE TRIGGER trg_checkin_validation
BEFORE INSERT ON CHECK_IN
FOR EACH ROW
BEGIN
    DECLARE v_card_status_code VARCHAR(64);
    DECLARE v_member_status_code VARCHAR(64);
    DECLARE v_member_plan_tier VARCHAR(32);
    DECLARE v_member_home_gym_id BIGINT;
    
    -- if access card is provided, validate its status
    IF NEW.access_card_id IS NOT NULL THEN
        SELECT acsi.code INTO v_card_status_code
        FROM ACCESS_CARD ac
        JOIN ACCESS_CARD_STATUS_IND acsi ON ac.status_id = acsi.id
        WHERE ac.id = NEW.access_card_id;
        
        -- if access card is lost or revoked, signal an error
        IF v_card_status_code IN ('LOST', 'REVOKED') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot check in with lost or revoked access card';
        END IF;
        
        -- if access card does not belong to the member, signal an error
        IF NOT EXISTS (
            SELECT 1 FROM ACCESS_CARD WHERE id = NEW.access_card_id AND member_id = NEW.member_id
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access card does not belong to the member';
        END IF;
    END IF;
    
    -- check member status
    SELECT asi.code INTO v_member_status_code
    FROM MEMBER m
    JOIN ACCOUNT_STATUS_IND asi ON m.status_id = asi.id
    WHERE m.id = NEW.member_id;
    
    -- if member is not active, signal an error
    IF v_member_status_code != 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only active members can check in';
    END IF;
    
    -- check gym access based on membership plan
    SELECT mp.tier, m.home_gym_id INTO v_member_plan_tier, v_member_home_gym_id
    FROM MEMBER m
    JOIN MEMBERSHIP_PLAN mp ON m.membership_plan_id = mp.id
    WHERE m.id = NEW.member_id;
    
    -- if trial or basic members are trying to check in at a different gym, signal an error
    IF v_member_plan_tier IN ('trial', 'basic') AND NEW.gym_id != v_member_home_gym_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trial and basic members can only check in at their home gym';
    END IF;
END$$

-- 5.7 user login update
-- maintains last login timestamp consistency
CREATE TRIGGER trg_user_login_update
BEFORE UPDATE ON USER
FOR EACH ROW
BEGIN
    -- prevent accidental clearing of last login timestamp
    IF NEW.last_login_at IS NULL AND OLD.last_login_at IS NOT NULL THEN
        SET NEW.last_login_at = OLD.last_login_at;
    END IF;
END$$

-- 5.8 booking plus only --
-- restricts session booking to plus tier members
CREATE TRIGGER trg_booking_plus_only
BEFORE INSERT ON BOOKING
FOR EACH ROW
BEGIN
    DECLARE v_member_plan_tier VARCHAR(32);
    DECLARE v_session_open_for_booking BOOLEAN;
    
    -- get member's plan tier
    SELECT mp.tier INTO v_member_plan_tier
    FROM MEMBER m
    JOIN MEMBERSHIP_PLAN mp ON m.membership_plan_id = mp.id
    WHERE m.id = NEW.member_id;
    
    -- check if session is open for booking
    SELECT open_for_booking INTO v_session_open_for_booking
    FROM CLASS_SESSION
    WHERE id = NEW.session_id;
    
    -- if member's plan tier is not plus, signal an error
    IF v_member_plan_tier != 'plus' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only plus members can book sessions';
    END IF;
    
    -- if session is not open for booking, signal an error
    IF NOT v_session_open_for_booking THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Session is not open for booking';
    END IF;
END$$

DELIMITER ;