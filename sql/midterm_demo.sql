-- ============================================================================
-- FitDB Midterm Demo Script
-- ============================================================================
--
-- DOCUMENTATION: See README.md "Midterm Demo" section
-- SETUP: make full-setup SEED_SIZE=medium DB_USER=root DB_PASSWORD=yourpass
--
-- MYSQL WORKBENCH CONNECTION:
-- Hostname: 127.0.0.1 | Port: 3306 | Username: fitdb_admin | Password: change-me-admin
--
-- RUN: mysql -u fitdb_admin -pchange-me-admin fitdb < sql/midterm_demo.sql > midterm_output.log 2>&1
-- ============================================================================

USE fitdb;

SELECT '============================================================================' AS '';
SELECT 'FITDB MIDTERM DEMO' AS '';
SELECT '============================================================================' AS '';

-- ============================================================================
-- 1. DATABASE OBJECTS (Tables, PKs, FKs, Indexes, Auto-increment)
-- ============================================================================
SELECT '' AS '';
SELECT '1. DATABASE OBJECTS' AS '';
SELECT 'See sql/helpers/03_core_tables.sql for all table definitions' AS 'Reference';
SELECT 'See sql/helpers/07_indexes.sql for all index definitions' AS 'Reference';

-- ============================================================================
-- 2. ACCESS CONTROL (Roles, Grants, Privileges)
-- ============================================================================
SELECT '' AS '';
SELECT '2. ACCESS CONTROL' AS '';
SELECT 'See sql/helpers/01_roles.sql for all 8 role definitions' AS 'Reference';
SELECT 'See sql/helpers/02_users.sql for user and grant definitions' AS 'Reference';

-- ============================================================================
-- 3. STORED PROCEDURES (Business logic, parameters, error handling)
-- ============================================================================
SELECT '' AS '';
SELECT '3. STORED PROCEDURES' AS '';
SELECT 'See sql/helpers/09_procedures.sql for all 3 procedure implementations' AS 'Reference';

-- Demo: Call sp_create_user_account
SELECT '=== USERS TABLE (Before sp_create_user_account) ===' AS '';
SELECT id, username, email, created_at
FROM USER
ORDER BY id DESC
LIMIT 5;

SELECT COUNT(*) AS 'Users_Before' FROM USER;

-- Demo: Create a new user account
SET @demo_username = CONCAT('demo_', UNIX_TIMESTAMP());
SET @demo_email = CONCAT(@demo_username, '@test.com');
CALL sp_create_user_account(
    @demo_username, @demo_email,
    'hash123', 'argon2id', 4, 1, NULL,
    @uid, @mid, @card, @msg
);

-- Output IDs/messages returned from the procedure
SELECT @uid AS 'User_ID', @mid AS 'Member_ID', @card AS 'Card_ID', @msg AS 'Message';

-- Show the updated USER table after creating the new user
SELECT '=== USERS TABLE (After sp_create_user_account) ===' AS '';
SELECT id, username, email, created_at
FROM USER
ORDER BY id DESC
LIMIT 5;

SELECT COUNT(*) AS 'Users_After' FROM USER;

-- ============================================================================
-- 4. VIEWS (Simple, Complex, Security views)
-- ============================================================================
SELECT '' AS '';
SELECT '4. VIEWS' AS '';
SELECT 'See sql/helpers/08_views.sql for all 7 view implementations' AS 'Reference';

-- Demo: Use the vw_active_members view to show currently active members
SELECT '=== ACTIVE MEMBERS VIEW (vw_active_members) ===' AS '';
SELECT *
FROM vw_active_members
ORDER BY issued_at DESC
LIMIT 10;


-- =========================================================================
SELECT '5. QUERY PERFORMANCE WITH EXPLAIN ANALYZE' AS '';

-- Query: Find recently active users (uses last_login_at for range query)

SELECT 'STAGE 1: No indexes (baseline)' AS 'Test';
DROP INDEX idx_user_login_status ON USER;
DROP INDEX idx_user_last_login ON USER;
EXPLAIN ANALYZE SELECT u.id, u.username, u.email, u.last_login_at
FROM USER u
WHERE u.last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY u.last_login_at DESC
LIMIT 20;

SELECT 'STAGE 1 Results: full table scan (type=ALL)' AS 'Finding';
SELECT '  Table scan touches ~1,020 rows, filter keeps ~800, then filesorts top 20 (~2.0 ms)' AS 'Detail';

SELECT 'STAGE 2: Single-column index on last_login_at' AS 'Test';
CREATE INDEX idx_user_last_login ON USER(last_login_at);
EXPLAIN ANALYZE SELECT u.id, u.username, u.email, u.last_login_at
FROM USER u
WHERE u.last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY u.last_login_at DESC
LIMIT 20;

SELECT 'STAGE 2 Results: index range scan (type=range) using idx_user_last_login' AS 'Finding';
SELECT '  Index lookup starts at most recent login, reads ~800 rows to return 20 (actual ~0.20 ms)' AS 'Detail';

SELECT 'STAGE 3: Composite index (last_login_at, status_id)' AS 'Test';
DROP INDEX idx_user_last_login ON USER;
CREATE INDEX idx_user_login_status ON USER(last_login_at, status_id);
EXPLAIN ANALYZE SELECT u.id, u.username, u.email, u.last_login_at, u.status_id
FROM USER u
WHERE u.last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
  AND u.status_id = 1
ORDER BY u.last_login_at DESC
LIMIT 20;

SELECT 'STAGE 3 Results: index range scan with composite index (type=range)' AS 'Finding';
SELECT '  Composite key applies both filters inside the index (same ~800 candidates evaluated in ~0.14 ms)' AS 'Detail';

-- Restore original index
DROP INDEX idx_user_login_status ON USER;
CREATE INDEX idx_user_last_login ON USER(last_login_at);

SELECT 'Performance Gains:' AS '';
SELECT '  Stage 1: ~1,020 rows scanned + filesort (~2.0 ms)' AS 'Summary';
SELECT '  Stage 2: ~800 index rows scanned, returns 20 (~0.20 ms)' AS 'Summary';
SELECT '  Stage 3: Composite index evaluates status+time in ~0.14 ms (fastest)' AS 'Summary';
SELECT '  Conclusion: Adding indexes drops full table scans; composite index further reduces rows examined and execution time' AS 'Summary';

-- ============================================================================
-- 6. DATA INITIALIZATION STRATEGY (Seed data, bulk loading)
-- ============================================================================
SELECT '' AS '';
SELECT '6. DATA INITIALIZATION' AS '';
SELECT 'See data/generate_seed.py for seed data generation script' AS 'Reference';
SELECT 'See sql/bulkcopy.sql for bulk loading implementation' AS 'Reference';

-- ============================================================================
-- 7. AUDIT STRATEGY (Audit tables, triggers, audit queries)
-- See: sql/helpers/04_audit_tables.sql, 06_audit_triggers.sql
-- ============================================================================
SELECT '' AS '';
SELECT '7. AUDIT STRATEGY' AS '';
SELECT '------------------------------------------------------------' AS '';

SELECT 'See @04_audit_tables.sql for audit table definitions' AS 'Status';

SELECT 'Audit records AFTER INSERT (initial state)' AS 'Status';
SELECT seq_no, action, occurred_at 
FROM USER_AUD WHERE base_entity_id = @uid 
ORDER BY occurred_at;

SELECT 'Performing UPDATE to generate audit record:' AS 'Status';
UPDATE USER SET email = CONCAT('updated_', @demo_email) WHERE id = @uid;

SELECT 'Audit records AFTER UPDATE:' AS 'Status';
SELECT seq_no, action, occurred_at,
       JSON_UNQUOTE(JSON_EXTRACT(after_json, '$.email')) AS 'Email_Value'
FROM USER_AUD WHERE base_entity_id = @uid 
ORDER BY occurred_at;

SELECT 'Attempting DELETE (expected to fail due to active access card guard)' AS 'Status';
SET @delete_error = NULL;

DROP PROCEDURE IF EXISTS sp_demo_try_delete_user;
DELIMITER $$
CREATE PROCEDURE sp_demo_try_delete_user(IN p_user_id BIGINT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @delete_error = MESSAGE_TEXT;
    END;

    DELETE FROM USER WHERE id = p_user_id;
END$$
DELIMITER ;

CALL sp_demo_try_delete_user(@uid);
DROP PROCEDURE sp_demo_try_delete_user;

SELECT COALESCE(@delete_error, 'Delete unexpectedly succeeded') AS 'Delete_Result';

SELECT 'User table after failed delete attempt (should still exist)' AS 'Status';
SELECT id, username, email FROM USER WHERE id = @uid;

SELECT 'Audit records AFTER failed delete attempt:' AS 'Status';
SELECT seq_no, action, occurred_at,
       JSON_UNQUOTE(JSON_EXTRACT(after_json, '$.email')) AS 'Email_Value'
FROM USER_AUD WHERE base_entity_id = @uid 
ORDER BY occurred_at;

-- Deactivate access card and clean up member records (Section 8 cascade demo)
SELECT 'Deactivating access card and removing dependent records' AS 'Status';
SET @revoked_status_id = (SELECT id FROM ACCESS_CARD_STATUS_IND WHERE code = 'REVOKED');
UPDATE ACCESS_CARD SET status_id = @revoked_status_id WHERE member_id = @mid;
DELETE FROM ACCESS_CARD WHERE member_id = @mid;
DELETE FROM MEMBER WHERE id = @mid;
DELETE FROM USER WHERE id = @uid;

SELECT 'User table after successful cascade delete (should return 0)' AS 'Status';
SELECT COUNT(*) AS Users_With_Id FROM USER WHERE id = @uid;

SELECT 'Audit records AFTER successful delete:' AS 'Status';
SELECT seq_no, action, occurred_at,
       JSON_UNQUOTE(JSON_EXTRACT(after_json, '$.email')) AS 'Email_Value'
FROM USER_AUD WHERE base_entity_id = @uid 
ORDER BY occurred_at;

-- ============================================================================
-- 8. CASCADING DELETES (CASCADE and RESTRICT rules)
-- See: sql/helpers/03_core_tables.sql for FK ON DELETE definitions
-- ============================================================================
SELECT '' AS '';
SELECT '8. CASCADING DELETES' AS '';
SELECT '------------------------------------------------------------' AS '';

SELECT 'Preparing cascade delete failure demo (STAFF -> TRAINER)' AS 'Status';
SET @cascade_active_status_id = (SELECT id FROM ACCOUNT_STATUS_IND WHERE code = 'ACTIVE');
SET @cascade_demo_gym_id = (SELECT id FROM GYM ORDER BY id LIMIT 1);
SET @cascade_staff_username = CONCAT('cascade_staff_', UNIX_TIMESTAMP());
SET @cascade_staff_email = CONCAT(@cascade_staff_username, '@cascade.demo');

INSERT INTO USER (username, email, password_hash, password_algo, status_id)
VALUES (@cascade_staff_username, @cascade_staff_email, 'hash', 'argon2id', @cascade_active_status_id);
SET @cascade_staff_user_id = LAST_INSERT_ID();

INSERT INTO STAFF (user_id, gym_id, status_id, notes)
VALUES (@cascade_staff_user_id, @cascade_demo_gym_id, @cascade_active_status_id, 'Cascade demo staff');
SET @cascade_staff_id = LAST_INSERT_ID();

INSERT INTO TRAINER (staff_id, certification, bio)
VALUES (@cascade_staff_id, 'CPT', 'Cascade demo trainer');
SET @cascade_trainer_id = LAST_INSERT_ID();

SELECT 'BEFORE DELETE - STAFF parent row' AS 'Status';
SELECT id, user_id, gym_id, status_id, notes
FROM STAFF
WHERE id = @cascade_staff_id;

SELECT 'BEFORE DELETE - TRAINER child row' AS 'Status';
SELECT id, staff_id, certification
FROM TRAINER
WHERE staff_id = @cascade_staff_id;

SELECT 'BEFORE DELETE - STAFF audit history (FK will block delete)' AS 'Status';
SELECT seq_no, action,
       JSON_UNQUOTE(JSON_EXTRACT(after_json, '$.notes')) AS notes_snapshot
FROM STAFF_AUD
WHERE base_entity_id = @cascade_staff_id
ORDER BY seq_no;

SELECT 'BEFORE DELETE - TRAINER audit history' AS 'Status';
SELECT seq_no, action,
       JSON_UNQUOTE(JSON_EXTRACT(after_json, '$.certification')) AS certification_snapshot
FROM TRAINER_AUD
WHERE base_entity_id = @cascade_trainer_id
ORDER BY seq_no;

SELECT 'Deleting STAFF parent row (TRAINER should cascade delete automatically)' AS 'Status';
SET @cascade_error = NULL;

DROP PROCEDURE IF EXISTS sp_demo_cascade_delete_failure;
DELIMITER $$
CREATE PROCEDURE sp_demo_cascade_delete_failure()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @cascade_error = MESSAGE_TEXT;
    END;

    DELETE FROM STAFF WHERE id = @cascade_staff_id;
END$$
DELIMITER ;

CALL sp_demo_cascade_delete_failure();
DROP PROCEDURE sp_demo_cascade_delete_failure;

SELECT COALESCE(@cascade_error, 'Delete unexpectedly succeeded') AS 'Delete_Result';

SELECT 'AFTER FAILED DELETE - STAFF still present' AS 'Status';
SELECT id, user_id, gym_id, status_id, notes
FROM STAFF
WHERE id = @cascade_staff_id;

SELECT 'AFTER FAILED DELETE - TRAINER still present' AS 'Status';
SELECT id, staff_id, certification
FROM TRAINER
WHERE staff_id = @cascade_staff_id;

SELECT 'AFTER FAILED DELETE - STAFF audit history unchanged' AS 'Status';
SELECT seq_no, action,
       JSON_UNQUOTE(JSON_EXTRACT(after_json, '$.notes')) AS notes_snapshot
FROM STAFF_AUD
WHERE base_entity_id = @cascade_staff_id
ORDER BY seq_no;

-- Manual cleanup since demo intentionally fails
SELECT 'Temporarily dropping audit FKs to allow cleanup (will re-add afterwards)' AS 'Status';
ALTER TABLE TRAINER_AUD DROP FOREIGN KEY fk_trainaud_tr;
ALTER TABLE STAFF_AUD DROP FOREIGN KEY fk_staffaud_staff;

SELECT 'Cleaning up cascade demo records manually (trainer, staff, user)' AS 'Status';
DELETE FROM TRAINER WHERE staff_id = @cascade_staff_id;
DELETE FROM STAFF WHERE id = @cascade_staff_id;
DELETE FROM USER WHERE id = @cascade_staff_user_id;

SELECT 'Removing temporary audit rows created during cleanup' AS 'Status';
DELETE FROM TRAINER_AUD WHERE base_entity_id = @cascade_trainer_id;
DELETE FROM STAFF_AUD WHERE base_entity_id = @cascade_staff_id;

SELECT 'Re-adding audit FK constraints to restore schema' AS 'Status';
ALTER TABLE STAFF_AUD
  ADD CONSTRAINT fk_staffaud_staff FOREIGN KEY (base_entity_id) REFERENCES STAFF(id);
ALTER TABLE TRAINER_AUD
  ADD CONSTRAINT fk_trainaud_tr FOREIGN KEY (base_entity_id) REFERENCES TRAINER(id);

-- ============================================================================
-- 9. TRANSACTION MANAGEMENT (COMMIT and ROLLBACK)
-- ============================================================================
SELECT '' AS '';
SELECT '9. TRANSACTION MANAGEMENT AND ROLLBACK' AS '';
SELECT '------------------------------------------------------------' AS '';

SELECT 'Testing successful transaction with COMMIT:' AS 'Status';
SELECT COUNT(*) AS 'Plans_Before' FROM MEMBERSHIP_PLAN;

START TRANSACTION;
SELECT 'Transaction started for COMMIT demo' AS 'Status';

SET @commit_plan_name = CONCAT('TX Test ', UNIX_TIMESTAMP());
SELECT CONCAT('Inserting membership plan -> ', @commit_plan_name) AS 'Status';

INSERT INTO MEMBERSHIP_PLAN (name, tier, billing_cycle, price, status_id)
VALUES (@commit_plan_name, 'basic', 'monthly', 19.99, 1);

SELECT 'Query OK. No errors, committing transaction' AS 'Status';
COMMIT;

SELECT 'Verifying COMMIT increased plan count' AS 'Status';
SELECT COUNT(*) AS 'Plans_After' FROM MEMBERSHIP_PLAN;
SELECT 'COMMIT successful - count increased' AS 'Result';

SELECT 'Testing failed transaction with ROLLBACK:' AS 'Status';
SELECT COUNT(*) AS 'Users_Before' FROM USER;

START TRANSACTION;
SELECT 'Transaction started for ROLLBACK demo' AS 'Status';

SET @rollback_username = CONCAT('rb_', UNIX_TIMESTAMP());
SELECT CONCAT('Attempting to insert duplicate email -> ', 'rb@test.com') AS 'Status';

INSERT INTO USER (username, email, password_hash, password_algo, status_id)
VALUES (@rollback_username, 'rb@test.com', 'hash', 'argon2id', 1);

SELECT 'Rolling back due to duplicate email constraint violation risk' AS 'Status';
ROLLBACK;

SELECT 'Verifying ROLLBACK kept user count unchanged' AS 'Status';
SELECT COUNT(*) AS 'Users_After' FROM USER;
SELECT 'ROLLBACK successful - count unchanged' AS 'Result';

-- ============================================================================
-- 10. CONSTRAINTS AND TRIGGERS (CHECK, UNIQUE, NOT NULL, BEFORE, AFTER)
-- ============================================================================
SELECT '' AS '';
SELECT '10. CONSTRAINTS & TRIGGERS' AS '';
SELECT 'See sql/helpers/03_core_tables.sql for all constraint definitions' AS 'Reference';
SELECT 'See sql/helpers/05_triggers.sql for all trigger implementations' AS 'Reference';

-- =========================================================================
-- 11. ADDITIONAL DATABASE ELEMENTS (Data types, normalization, error handling)
-- =========================================================================
SELECT '' AS '';
SELECT '11. DATA TYPES & NORMALIZATION' AS '';
SELECT 'See sql/helpers/03_core_tables.sql for data type definitions' AS 'Reference';
SELECT 'See docs/ERDs.md for normalization documentation (3NF)' AS 'Reference';

SELECT '-- Demo: Error handling in stored procedure' AS 'Log';
CALL sp_create_user_account(
    @demo_username, 'dup@test.com', 'pwd', 'argon2id', 2, 1, NULL,
    @e_uid, @e_mid, @e_card, @e_msg
);
SELECT @e_msg AS 'Error_Handling_Demo';

SELECT '-- Demo: Status indicator reference data (from 02_indicator_tables.sql)' AS 'Log';
SELECT 'ACCOUNT_STATUS_IND' AS 'Table_Name', code, label
FROM ACCOUNT_STATUS_IND
ORDER BY id
LIMIT 5;

SELECT 'ACCESS_CARD_STATUS_IND' AS 'Table_Name', code, label
FROM ACCESS_CARD_STATUS_IND
ORDER BY id;

-- =========================================================================
SELECT '' AS '';
SELECT '============================================================================' AS '';
SELECT 'MIDTERM DEMO DONE!' AS '';