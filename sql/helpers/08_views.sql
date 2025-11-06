-- 8) Views

-- 8.1 create views
-- 8.2.1 user account info view
-- view for complete user account information with member details and access card
CREATE VIEW vw_user_account_info AS
SELECT 
    u.id as user_id,
    u.username,
    u.email,
    u.last_login_at,
    u.profile_photo_path,
    u.created_at as user_created_at,
    u.updated_at as user_updated_at,
    asi.code as user_status,
    asi.label as user_status_label,
    m.id as member_id,
    m.joined_on,
    m.trial_expires_on,
    m.created_at as member_created_at,
    m.updated_at as member_updated_at,
    msi.code as member_status,
    msi.label as member_status_label,
    mp.id as plan_id,
    mp.name as plan_name,
    mp.tier as plan_tier,
    mp.billing_cycle,
    mp.price as plan_price,
    mpsi.code as plan_status,
    mpsi.label as plan_status_label,
    g.id as home_gym_id,
    g.name as home_gym_name,
    g.address as home_gym_address,
    gsi.code as gym_status,
    gsi.label as gym_status_label,
    ac.id as access_card_id,
    ac.card_uid,
    ac.issued_at,
    ac.revoked_at,
    ac.created_at as card_created_at,
    ac.updated_at as card_updated_at,
    acsi.code as card_status,
    acsi.label as card_status_label,
    -- computed fields
    CASE 
        WHEN mp.tier = 'trial' AND m.trial_expires_on < CURDATE() THEN 'EXPIRED'
        WHEN mp.tier = 'trial' AND m.trial_expires_on >= CURDATE() THEN 'ACTIVE'
        ELSE msi.code
    END as effective_member_status,
    CASE 
        WHEN mp.tier = 'trial' THEN DATEDIFF(m.trial_expires_on, CURDATE())
        ELSE NULL
    END as trial_days_remaining
FROM USER u
JOIN ACCOUNT_STATUS_IND asi ON u.status_id = asi.id
LEFT JOIN MEMBER m ON u.id = m.user_id
LEFT JOIN ACCOUNT_STATUS_IND msi ON m.status_id = msi.id
LEFT JOIN MEMBERSHIP_PLAN mp ON m.membership_plan_id = mp.id
LEFT JOIN PLAN_STATUS_IND mpsi ON mp.status_id = mpsi.id
LEFT JOIN GYM g ON m.home_gym_id = g.id
LEFT JOIN GYM_STATUS_IND gsi ON g.status_id = gsi.id
LEFT JOIN ACCESS_CARD ac ON m.id = ac.member_id
LEFT JOIN ACCESS_CARD_STATUS_IND acsi ON ac.status_id = acsi.id;

-- 8.2.2 active members view
-- view for active members with their access cards
CREATE VIEW vw_active_members AS
SELECT 
    m.id as member_id,
    u.username,
    u.email,
    u.profile_photo_path,
    m.joined_on,
    m.trial_expires_on,
    mp.name as plan_name,
    mp.tier as plan_tier,
    mp.price as plan_price,
    g.name as home_gym_name,
    g.address as home_gym_address,
    ac.id as access_card_id,
    ac.card_uid,
    ac.issued_at,
    ac.revoked_at,
    acsi.code as card_status,
    CASE 
        WHEN mp.tier = 'trial' AND m.trial_expires_on < CURDATE() THEN 'EXPIRED'
        WHEN mp.tier = 'trial' AND m.trial_expires_on >= CURDATE() THEN 'ACTIVE'
        ELSE msi.code
    END as effective_status
FROM MEMBER m
JOIN USER u ON m.user_id = u.id
JOIN ACCOUNT_STATUS_IND msi ON m.status_id = msi.id
JOIN MEMBERSHIP_PLAN mp ON m.membership_plan_id = mp.id
LEFT JOIN GYM g ON m.home_gym_id = g.id
LEFT JOIN ACCESS_CARD ac ON m.id = ac.member_id
LEFT JOIN ACCESS_CARD_STATUS_IND acsi ON ac.status_id = acsi.id
WHERE msi.code = 'ACTIVE' AND u.status_id = (SELECT id FROM ACCOUNT_STATUS_IND WHERE code = 'ACTIVE');

-- 8.2.3 access card management view
-- view for access card management
CREATE VIEW vw_access_card_management AS
SELECT 
    ac.id as access_card_id,
    ac.card_uid,
    ac.issued_at,
    ac.revoked_at,
    ac.created_at,
    ac.updated_at,
    acsi.code as card_status,
    acsi.label as card_status_label,
    m.id as member_id,
    u.username as member_username,
    u.email as member_email,
    mp.name as plan_name,
    mp.tier as plan_tier,
    g.id as gym_id,
    g.name as gym_name,
    g.address as gym_address,
    -- computed fields
    CASE 
        WHEN ac.revoked_at IS NOT NULL THEN 'REVOKED'
        WHEN acsi.code = 'LOST' THEN 'LOST'
        WHEN acsi.code = 'ACTIVE' THEN 'ACTIVE'
        ELSE acsi.code
    END as effective_card_status,
    DATEDIFF(NOW(), ac.issued_at) as days_since_issued,
    CASE 
        WHEN ac.revoked_at IS NOT NULL THEN DATEDIFF(ac.revoked_at, ac.issued_at)
        ELSE DATEDIFF(NOW(), ac.issued_at)
    END as card_lifetime_days
FROM ACCESS_CARD ac
JOIN ACCESS_CARD_STATUS_IND acsi ON ac.status_id = acsi.id
JOIN MEMBER m ON ac.member_id = m.id
JOIN USER u ON m.user_id = u.id
JOIN MEMBERSHIP_PLAN mp ON m.membership_plan_id = mp.id
JOIN GYM g ON ac.gym_id = g.id;

-- 8.2.4 member check-in history view
-- view for member check-in history with access card usage
CREATE VIEW vw_member_checkin_history AS
SELECT 
    ci.id as checkin_id,
    ci.checked_in_at,
    ci.method as checkin_method,
    ci.created_at,
    m.id as member_id,
    u.username as member_username,
    u.email as member_email,
    g.id as gym_id,
    g.name as gym_name,
    g.address as gym_address,
    ac.id as access_card_id,
    ac.card_uid,
    acsi.code as card_status,
    mp.tier as member_plan_tier,
    -- computed fields
    DATE(ci.checked_in_at) as checkin_date,
    TIME(ci.checked_in_at) as checkin_time,
    CASE 
        WHEN ci.access_card_id IS NOT NULL THEN 'CARD_SCAN'
        ELSE 'MANUAL'
    END as checkin_type
FROM CHECK_IN ci
JOIN MEMBER m ON ci.member_id = m.id
JOIN USER u ON m.user_id = u.id
JOIN GYM g ON ci.gym_id = g.id
LEFT JOIN ACCESS_CARD ac ON ci.access_card_id = ac.id
LEFT JOIN ACCESS_CARD_STATUS_IND acsi ON ac.status_id = acsi.id
JOIN MEMBERSHIP_PLAN mp ON m.membership_plan_id = mp.id;

-- 8.2.5 front desk staff view
-- view for staff with front desk capabilities
CREATE VIEW vw_front_desk_staff AS
SELECT 
    fd.id as front_desk_id,
    s.id as staff_id,
    u.id as user_id,
    u.username,
    u.email,
    u.last_login_at,
    g.id as gym_id,
    g.name as gym_name,
    g.address as gym_address,
    fd.capabilities,
    asi.code as staff_status,
    asi.label as staff_status_label,
    usi.code as user_status,
    usi.label as user_status_label,
    -- computed fields
    CASE 
        WHEN FIND_IN_SET('register', fd.capabilities) > 0 THEN TRUE 
        ELSE FALSE 
    END as can_register,
    CASE 
        WHEN FIND_IN_SET('check_in', fd.capabilities) > 0 THEN TRUE 
        ELSE FALSE 
    END as can_check_in
FROM FRONT_DESK fd
JOIN STAFF s ON fd.staff_id = s.id
JOIN USER u ON s.user_id = u.id
JOIN GYM g ON s.gym_id = g.id
JOIN ACCOUNT_STATUS_IND asi ON s.status_id = asi.id
JOIN ACCOUNT_STATUS_IND usi ON u.status_id = usi.id
WHERE asi.code = 'ACTIVE' AND usi.code = 'ACTIVE';

-- 8.2.6 membership plan details view
-- view for membership plan details with member counts
CREATE VIEW vw_membership_plan_details AS
SELECT 
    mp.id as plan_id,
    mp.name as plan_name,
    mp.tier as plan_tier,
    mp.billing_cycle,
    mp.price as plan_price,
    mp.created_at as plan_created_at,
    mp.updated_at as plan_updated_at,
    psi.code as plan_status,
    psi.label as plan_status_label,
    -- member statistics
    COUNT(m.id) as total_members,
    COUNT(CASE WHEN msi.code = 'ACTIVE' THEN m.id END) as active_members,
    COUNT(CASE WHEN msi.code = 'SUSPENDED' THEN m.id END) as suspended_members,
    COUNT(CASE WHEN msi.code = 'CANCELED' THEN m.id END) as canceled_members,
    -- trial specific statistics
    COUNT(CASE WHEN mp.tier = 'trial' AND m.trial_expires_on < CURDATE() THEN m.id END) as expired_trials,
    COUNT(CASE WHEN mp.tier = 'trial' AND m.trial_expires_on >= CURDATE() THEN m.id END) as active_trials,
    -- revenue estimation (for active plans)
    CASE 
        WHEN mp.billing_cycle = 'monthly' THEN mp.price * COUNT(CASE WHEN msi.code = 'ACTIVE' THEN m.id END)
        WHEN mp.billing_cycle = 'annual' THEN (mp.price / 12) * COUNT(CASE WHEN msi.code = 'ACTIVE' THEN m.id END)
        ELSE 0
    END as estimated_monthly_revenue
FROM MEMBERSHIP_PLAN mp
JOIN PLAN_STATUS_IND psi ON mp.status_id = psi.id
LEFT JOIN MEMBER m ON mp.id = m.membership_plan_id
LEFT JOIN ACCOUNT_STATUS_IND msi ON m.status_id = msi.id
GROUP BY mp.id, mp.name, mp.tier, mp.billing_cycle, mp.price, mp.created_at, mp.updated_at, psi.code, psi.label;

-- 8.2.7 gym access permissions view
-- view for gym access permissions by membership tier
CREATE VIEW vw_gym_access_permissions AS
SELECT 
    g.id as gym_id,
    g.name as gym_name,
    g.address as gym_address,
    gsi.code as gym_status,
    gsi.label as gym_status_label,
    mp.tier as membership_tier,
    mp.name as plan_name,
    COUNT(m.id) as members_with_access,
    -- access rules
    CASE 
        WHEN mp.tier = 'trial' THEN 'HOME_GYM_ONLY'
        WHEN mp.tier = 'basic' THEN 'HOME_GYM_ONLY'
        WHEN mp.tier = 'plus' THEN 'ALL_GYMS'
        ELSE 'NO_ACCESS'
    END as access_rule
FROM GYM g
JOIN GYM_STATUS_IND gsi ON g.status_id = gsi.id
CROSS JOIN MEMBERSHIP_PLAN mp
JOIN PLAN_STATUS_IND psi ON mp.status_id = psi.id
LEFT JOIN MEMBER m ON mp.id = m.membership_plan_id 
    AND ((mp.tier IN ('trial', 'basic') AND m.home_gym_id = g.id) OR mp.tier = 'plus')
    AND m.status_id = (SELECT id FROM ACCOUNT_STATUS_IND WHERE code = 'ACTIVE')
WHERE gsi.code = 'ACTIVE' AND psi.code = 'ACTIVE'
GROUP BY g.id, g.name, g.address, gsi.code, gsi.label, mp.tier, mp.name;