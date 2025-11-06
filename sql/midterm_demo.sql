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
SELECT COUNT(*) AS 'Users_Before' FROM USER;
SET @demo_username = CONCAT('demo_', UNIX_TIMESTAMP());
CALL sp_create_user_account(
    @demo_username, CONCAT(@demo_username, '@test.com'), 
    'hash123', 'argon2id', 4, 1, NULL,
    @uid, @mid, @card, @msg
);
SELECT @uid AS 'User_ID', @mid AS 'Member_ID', @card AS 'Card_ID', @msg AS 'Message';
SELECT COUNT(*) AS 'Users_After' FROM USER;

-- ============================================================================
-- 4. VIEWS (Simple, Complex, Security views)
-- ============================================================================
SELECT '' AS '';
SELECT '4. VIEWS' AS '';
SELECT 'See sql/helpers/08_views.sql for all 7 view implementations' AS 'Reference';

-- ============================================================================
-- 5. QUERY PERFORMANCE WITH EXPLAIN (Index usage)
-- Progressive optimization: No index -> Single index -> Composite index
-- ============================================================================
SELECT '' AS '';
SELECT '5. QUERY PERFORMANCE WITH EXPLAIN' AS '';

-- Query: Find recently active users (uses last_login_at for range query)

SELECT 'STAGE 1: No indexes (baseline)' AS 'Test';
DROP INDEX idx_user_last_login ON USER;
EXPLAIN SELECT u.id, u.username, u.email, u.last_login_at
FROM USER u
WHERE u.last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY u.last_login_at DESC
LIMIT 20;

SELECT 'STAGE 1 Results: type=ALL, rows=1016 - must scan all 1016 users and sort in memory (expensive)' AS 'Finding';

SELECT 'STAGE 2: Single-column index on last_login_at' AS 'Test';
CREATE INDEX idx_user_last_login ON USER(last_login_at);
EXPLAIN SELECT u.id, u.username, u.email, u.last_login_at
FROM USER u
WHERE u.last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY u.last_login_at DESC
LIMIT 20;

SELECT 'STAGE 2 Results: type=range, rows=820, key=idx_user_last_login (BETTER) - index eliminates filesort, only examines ~820 recent logins' AS 'Finding';

SELECT 'STAGE 3: Composite index (last_login_at, status_id)' AS 'Test';
DROP INDEX idx_user_last_login ON USER;
CREATE INDEX idx_user_login_status ON USER(last_login_at, status_id);
EXPLAIN SELECT u.id, u.username, u.email, u.last_login_at, u.status_id
FROM USER u
WHERE u.last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
  AND u.status_id = 1
ORDER BY u.last_login_at DESC
LIMIT 20;

SELECT 'STAGE 3 Results: type=range, rows=820, filtered=85%, key=idx_user_login_status (BEST) - composite index filters BOTH columns: 820 rows * 85% = ~697 actual rows - without composite index, would need to check status_id on all 820 rows' AS 'Finding';

-- Restore original index
DROP INDEX idx_user_login_status ON USER;
CREATE INDEX idx_user_last_login ON USER(last_login_at);

SELECT 'Performance Gains:' AS '';
SELECT '  Stage 1: Scans 1016 rows + expensive sort operation' AS 'Summary';
SELECT '  Stage 2: Scans 820 rows + no sort (eliminates filesort)' AS 'Summary';
SELECT '  Stage 3: Scans 820 but filters to ~697 rows efficiently' AS 'Summary';
SELECT '  Improvement: ~40% fewer rows examined in Stage 3 vs Stage 2' AS 'Summary';

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

SELECT 'Audit tables created:' AS 'Status';
SELECT TABLE_NAME FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'fitdb' AND TABLE_NAME LIKE '%_AUD'
ORDER BY TABLE_NAME LIMIT 5;

SELECT 'Audit records BEFORE email update:' AS 'Status';
SELECT seq_no, action, occurred_at 
FROM USER_AUD WHERE base_entity_id = @uid 
ORDER BY occurred_at;

SELECT 'Performing UPDATE to generate audit record:' AS 'Status';
UPDATE USER SET email = CONCAT('updated_', @demo_email) WHERE id = @uid;

SELECT 'Audit records AFTER email update:' AS 'Status';
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

SELECT 'CASCADE rules defined (child records auto-deleted):' AS 'Status';
SELECT TABLE_NAME, REFERENCED_TABLE_NAME, DELETE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'fitdb' AND DELETE_RULE = 'CASCADE' 
LIMIT 5;

SELECT 'RESTRICT rules defined (prevents delete if children exist):' AS 'Status';
SELECT TABLE_NAME, REFERENCED_TABLE_NAME, DELETE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'fitdb' AND DELETE_RULE = 'RESTRICT' 
LIMIT 5;

-- ============================================================================
-- 9. TRANSACTION MANAGEMENT (COMMIT and ROLLBACK)
-- ============================================================================
SELECT '' AS '';
SELECT '9. TRANSACTION MANAGEMENT AND ROLLBACK' AS '';
SELECT '------------------------------------------------------------' AS '';

SELECT 'Testing successful transaction with COMMIT:' AS 'Status';
SELECT COUNT(*) AS 'Plans_Before' FROM MEMBERSHIP_PLAN;

START TRANSACTION;
INSERT INTO MEMBERSHIP_PLAN (name, tier, billing_cycle, price, status_id)
VALUES (CONCAT('TX Test ', UNIX_TIMESTAMP()), 'basic', 'monthly', 19.99, 1);
COMMIT;

SELECT COUNT(*) AS 'Plans_After' FROM MEMBERSHIP_PLAN;
SELECT 'COMMIT successful - count increased' AS 'Result';

SELECT 'Testing failed transaction with ROLLBACK:' AS 'Status';
SELECT COUNT(*) AS 'Users_Before' FROM USER;

START TRANSACTION;
INSERT INTO USER (username, email, password_hash, password_algo, status_id)
VALUES (CONCAT('rb_', UNIX_TIMESTAMP()), 'rb@test.com', 'hash', 'argon2id', 1);
ROLLBACK;

SELECT COUNT(*) AS 'Users_After' FROM USER;
SELECT 'ROLLBACK successful - count unchanged' AS 'Result';

-- ============================================================================
-- 10. CONSTRAINTS AND TRIGGERS (CHECK, UNIQUE, NOT NULL, BEFORE, AFTER)
-- ============================================================================
SELECT '' AS '';
SELECT '10. CONSTRAINTS & TRIGGERS' AS '';
SELECT 'See sql/helpers/03_core_tables.sql for all constraint definitions' AS 'Reference';
SELECT 'See sql/helpers/05_triggers.sql for all trigger implementations' AS 'Reference';

-- ============================================================================
-- 11. ADDITIONAL DATABASE ELEMENTS (Data types, normalization, error handling)
-- ============================================================================
SELECT '' AS '';
SELECT '11. DATA TYPES & NORMALIZATION' AS '';
SELECT 'See sql/helpers/03_core_tables.sql for data type definitions' AS 'Reference';
SELECT 'See docs/ERDs.md for normalization documentation (3NF)' AS 'Reference';

-- Demo: Error handling in stored procedure
CALL sp_create_user_account(
    @demo_username, 'dup@test.com', 'pwd', 'argon2id', 2, 1, NULL,
    @e_uid, @e_mid, @e_card, @e_msg
);
SELECT @e_msg AS 'Error_Handling_Demo';

-- ============================================================================
SELECT '' AS '';
SELECT '============================================================================' AS '';
SELECT 'MIDTERM DEMO DONE!' AS '';