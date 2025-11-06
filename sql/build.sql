-- 0) Init

-- 0.1 DB Init
-- create the DB only if it doesn't already exist (will use Makefile to clean DB)
-- "CHARACTER SET utf8mb4" allows full Unicode, including emoji
-- "COLLATE utf8mb4_0900_ai_ci" sets comparison/sorting rules
CREATE DATABASE IF NOT EXISTS `fitdb` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- switches the session to use the new DB
USE `fitdb`;

-- 0.2 DB Users Init
-- 'fitdb_admin' is an admin account for dev stuff
-- 'fitdb_app' is the application account (how the app can interface with the DB)
-- The pattern 'user'@'host' controls where a user can connect from; '@%' means "from any host"
CREATE USER IF NOT EXISTS 'fitdb_admin'@'%' IDENTIFIED BY 'change-me-admin';
CREATE USER IF NOT EXISTS 'fitdb_app'@'%'   IDENTIFIED BY 'change-me';

-- 0.3 safety stuff
-- set data to be full Unicode + emoji and comparison/sorting rules
SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- turn off foreign key validation checks while building
SET FOREIGN_KEY_CHECKS = 0;

-- 0.4 load helpers

-- 0.4.1 roles (definitions; grants happen at the end)
SOURCE ./helpers/01_roles.sql;

-- 0.4.2 indicator (status) tables (8 total)
SOURCE ./helpers/02_indicator_tables.sql;

-- 0.4.3 core tables (22 total)
SOURCE ./helpers/03_core_tables.sql;

-- 0.4.4 audit tables (22 total)
SOURCE ./helpers/04_audit_tables.sql;

-- 0.4.5 triggers
SOURCE ./helpers/05_triggers.sql;

-- 0.4.6 audit triggers
SOURCE ./helpers/06_audit_triggers.sql;

-- 0.4.7 indexes
SOURCE ./helpers/07_indexes.sql;

-- 0.4.8 views
SOURCE ./helpers/08_views.sql;

-- 0.4.9 stored procedures
SOURCE ./helpers/09_procedures.sql;

-- 0.5 Role grants
-- 0.5.1 grant admin user full privileges
GRANT ALL PRIVILEGES ON `fitdb`.* TO 'fitdb_admin'@'%';
FLUSH PRIVILEGES;

-- 0.5.2 attach base role to app user 
GRANT r_member TO 'fitdb_app'@'%';
SET DEFAULT ROLE r_member TO 'fitdb_app'@'%';

-- 0.5.3 roles set for app user
GRANT r_plus_member, r_trainer, r_manager, r_front_desk, r_floor_manager, r_admin_gym TO 'fitdb_app'@'%';

-- 0.5.4 SELECT permissions on views
-- MVP views (currently implemented in 08_views.sql)
GRANT SELECT ON `fitdb`.vw_user_account_info          TO r_member, r_front_desk, r_manager, r_admin_gym;
GRANT SELECT ON `fitdb`.vw_active_members             TO r_front_desk, r_manager, r_admin_gym;
GRANT SELECT ON `fitdb`.vw_access_card_management     TO r_front_desk, r_manager, r_admin_gym;
GRANT SELECT ON `fitdb`.vw_member_checkin_history     TO r_member, r_front_desk, r_manager;
GRANT SELECT ON `fitdb`.vw_front_desk_staff           TO r_manager, r_admin_gym;
GRANT SELECT ON `fitdb`.vw_membership_plan_details    TO r_manager, r_admin_gym;
GRANT SELECT ON `fitdb`.vw_gym_access_permissions     TO r_manager, r_admin_gym;

-- Post-MVP: Session/booking views (not yet implemented)
-- GRANT SELECT ON `fitdb`.vw_sessions_open            TO r_member;
-- GRANT SELECT ON `fitdb`.vw_bookable_sessions        TO r_plus_member;
-- GRANT SELECT ON `fitdb`.vw_member_profile           TO r_member;
-- GRANT SELECT ON `fitdb`.vw_member_bookings          TO r_member;
-- GRANT SELECT ON `fitdb`.vw_member_checkins          TO r_member;
-- GRANT SELECT ON `fitdb`.vw_trainer_schedule         TO r_trainer;
-- GRANT SELECT ON `fitdb`.vw_trainer_class_rosters    TO r_trainer, r_manager;
-- GRANT SELECT ON `fitdb`.vw_class_utilization        TO r_manager, r_admin_gym, r_super_admin;
-- GRANT SELECT ON `fitdb`.vw_all_rosters              TO r_manager, r_admin_gym;

-- Post-MVP: Equipment management views (not yet implemented)
-- GRANT SELECT ON `fitdb`.vw_equipment_status         TO r_floor_manager, r_manager;
-- GRANT SELECT ON `fitdb`.vw_cleaning_due             TO r_floor_manager;
-- GRANT SELECT ON `fitdb`.vw_service_due              TO r_floor_manager;
-- GRANT SELECT ON `fitdb`.vw_equipment_demand         TO r_manager, r_admin_gym;

-- Post-MVP: Front desk views (not yet implemented)
-- GRANT SELECT ON `fitdb`.vw_cards_by_gym             TO r_front_desk, r_manager;
-- GRANT SELECT ON `fitdb`.vw_member_lookup_minimal    TO r_front_desk;

-- 0.5.5 EXECUTE permissions on procedures
-- MVP procedures (currently implemented in 09_procedures.sql)
GRANT EXECUTE ON PROCEDURE `fitdb`.sp_create_user_account              TO r_member;  -- self-registration
GRANT EXECUTE ON PROCEDURE `fitdb`.sp_front_desk_create_user_account   TO r_front_desk, r_manager, r_admin_gym;
GRANT EXECUTE ON PROCEDURE `fitdb`.sp_get_user_account_info            TO r_member, r_front_desk, r_manager, r_admin_gym;

-- Post-MVP: Booking procedures (not yet implemented)
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_book_session        TO r_plus_member;
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_cancel_booking      TO r_plus_member, r_manager, r_admin_gym;

-- Post-MVP: Check-in procedures (not yet implemented)
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_check_in            TO r_member, r_front_desk, r_manager;

-- Post-MVP: Member registration procedures (not yet implemented)
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_member_register     TO r_front_desk, r_manager, r_admin_gym;

-- Post-MVP: Trainer availability procedures (not yet implemented)
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_set_availability    TO r_trainer;
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_remove_availability TO r_trainer;

-- Post-MVP: Session management procedures (not yet implemented)
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_publish_sessions    TO r_manager, r_admin_gym;
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_assign_trainer      TO r_manager, r_admin_gym;
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_unassign_trainer    TO r_manager, r_admin_gym;
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_reserve_session_equipment TO r_manager, r_admin_gym;

-- Post-MVP: Access card procedures (not yet implemented)
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_access_card_issue   TO r_front_desk, r_manager, r_admin_gym;
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_access_card_revoke  TO r_front_desk, r_manager, r_admin_gym;

-- Post-MVP: Equipment management procedures (not yet implemented)
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_log_equipment_service TO r_floor_manager, r_manager, r_admin_gym;
-- GRANT EXECUTE ON PROCEDURE `fitdb`.sp_snapshot_inventory    TO r_floor_manager, r_manager, r_admin_gym;

-- 0.5.6 admin roles
GRANT SELECT, INSERT, UPDATE, DELETE ON `fitdb`.* TO r_admin_gym;
GRANT ALL PRIVILEGES ON `fitdb`.*                 TO r_super_admin;

-- re-enable FKs
-- turns on foreign key validation checks since done building
SET FOREIGN_KEY_CHECKS = 1;