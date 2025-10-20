-- 9) Stored Procedures ----

DELIMITER $$

---- 9.1 create user account procedure ----
---- procedure to create a new user account with member record and access card
CREATE PROCEDURE sp_create_user_account(
    IN p_username VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_password_hash VARCHAR(255),
    IN p_password_algo VARCHAR(32),
    IN p_membership_plan_id BIGINT,
    IN p_home_gym_id BIGINT,
    IN p_created_by_user_id BIGINT,  -- NULL for self-registration
    OUT p_user_id BIGINT,
    OUT p_member_id BIGINT,
    OUT p_access_card_id BIGINT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_active_status_id BIGINT;
    DECLARE v_plan_tier VARCHAR(32);
    DECLARE v_active_card_status_id BIGINT;
    DECLARE v_card_uid VARCHAR(128);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1
            p_result_message = MESSAGE_TEXT;
        SET p_user_id = NULL;
        SET p_member_id = NULL;
        SET p_access_card_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Get active status ID
    SELECT id INTO v_active_status_id FROM ACCOUNT_STATUS_IND WHERE code = 'ACTIVE';
    IF v_active_status_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Active status not found';
    END IF;
    
    -- Get active card status ID
    SELECT id INTO v_active_card_status_id FROM ACCESS_CARD_STATUS_IND WHERE code = 'ACTIVE';
    IF v_active_card_status_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Active card status not found';
    END IF;
    
    -- Validate membership plan exists and is active
    SELECT tier INTO v_plan_tier FROM MEMBERSHIP_PLAN mp
    JOIN PLAN_STATUS_IND psi ON mp.status_id = psi.id
    WHERE mp.id = p_membership_plan_id AND psi.code = 'ACTIVE';
    
    IF v_plan_tier IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid or inactive membership plan';
    END IF;
    
    -- Validate home gym for trial/basic plans
    IF v_plan_tier IN ('trial', 'basic') AND p_home_gym_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Home gym required for trial and basic plans';
    END IF;
    
    -- Validate gym exists and is active
    IF p_home_gym_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM GYM g 
            JOIN GYM_STATUS_IND gsi ON g.status_id = gsi.id 
            WHERE g.id = p_home_gym_id AND gsi.code = 'ACTIVE'
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid or inactive gym';
        END IF;
    END IF;
    
    -- Create user account
    INSERT INTO USER (username, email, password_hash, password_algo, status_id, profile_photo_path)
    VALUES (p_username, p_email, p_password_hash, p_password_algo, v_active_status_id, NULL);
    
    SET p_user_id = LAST_INSERT_ID();
    
    -- Create member record
    INSERT INTO MEMBER (user_id, membership_plan_id, home_gym_id, joined_on, trial_expires_on, status_id)
    VALUES (
        p_user_id, 
        p_membership_plan_id, 
        p_home_gym_id, 
        CURDATE(),
        CASE WHEN v_plan_tier = 'trial' THEN DATE_ADD(CURDATE(), INTERVAL 14 DAY) ELSE NULL END,
        v_active_status_id
    );
    
    SET p_member_id = LAST_INSERT_ID();
    
    -- Generate unique card UID
    SET v_card_uid = CONCAT('CARD_', LPAD(p_member_id, 8, '0'), '_', UNIX_TIMESTAMP());
    
    -- Create access card
    INSERT INTO ACCESS_CARD (member_id, gym_id, card_uid, status_id, issued_at)
    VALUES (p_member_id, p_home_gym_id, v_card_uid, v_active_card_status_id, NOW());
    
    SET p_access_card_id = LAST_INSERT_ID();
    
    SET p_result_message = CONCAT('Account created successfully. User ID: ', p_user_id, 
                                 ', Member ID: ', p_member_id, 
                                 ', Access Card ID: ', p_access_card_id);
    
    COMMIT;
END$$

---- 9.2 front desk create user account procedure ----
---- procedure for front desk staff to create accounts for others
CREATE PROCEDURE sp_front_desk_create_user_account(
    IN p_username VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_password_hash VARCHAR(255),
    IN p_password_algo VARCHAR(32),
    IN p_membership_plan_id BIGINT,
    IN p_home_gym_id BIGINT,
    IN p_staff_user_id BIGINT,  -- front desk staff user ID
    OUT p_user_id BIGINT,
    OUT p_member_id BIGINT,
    OUT p_access_card_id BIGINT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_staff_exists BOOLEAN DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1
            p_result_message = MESSAGE_TEXT;
        SET p_user_id = NULL;
        SET p_member_id = NULL;
        SET p_access_card_id = NULL;
    END;
    
    -- Validate that the staff member has front desk privileges
    SELECT COUNT(*) > 0 INTO v_staff_exists
    FROM FRONT_DESK fd
    JOIN STAFF s ON fd.staff_id = s.id
    JOIN USER u ON s.user_id = u.id
    WHERE u.id = p_staff_user_id AND u.status_id = (
        SELECT id FROM ACCOUNT_STATUS_IND WHERE code = 'ACTIVE'
    );
    
    IF NOT v_staff_exists THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized: Staff member does not have front desk privileges';
    END IF;
    
    -- Call the main account creation procedure
    CALL CreateUserAccount(p_username, p_email, p_password_hash, p_password_algo, 
                          p_membership_plan_id, p_home_gym_id, p_staff_user_id,
                          p_user_id, p_member_id, p_access_card_id, p_result_message);
END$$

---- 9.3 get user account info procedure ----
---- procedure to get user account information with member details and access card
CREATE PROCEDURE sp_get_user_account_info(
    IN p_user_id BIGINT
)
BEGIN
    SELECT 
        u.id as user_id,
        u.username,
        u.email,
        u.last_login_at,
        u.profile_photo_path,
        asi.code as user_status,
        m.id as member_id,
        m.joined_on,
        m.trial_expires_on,
        msi.code as member_status,
        mp.name as plan_name,
        mp.tier as plan_tier,
        mp.billing_cycle,
        mp.price,
        g.name as home_gym_name,
        g.address as home_gym_address,
        ac.id as access_card_id,
        ac.card_uid,
        ac.issued_at,
        ac.revoked_at,
        acsi.code as card_status
    FROM USER u
    JOIN ACCOUNT_STATUS_IND asi ON u.status_id = asi.id
    LEFT JOIN MEMBER m ON u.id = m.user_id
    LEFT JOIN ACCOUNT_STATUS_IND msi ON m.status_id = msi.id
    LEFT JOIN MEMBERSHIP_PLAN mp ON m.membership_plan_id = mp.id
    LEFT JOIN GYM g ON m.home_gym_id = g.id
    LEFT JOIN ACCESS_CARD ac ON m.id = ac.member_id
    LEFT JOIN ACCESS_CARD_STATUS_IND acsi ON ac.status_id = acsi.id
    WHERE u.id = p_user_id;
END$$

DELIMITER ;