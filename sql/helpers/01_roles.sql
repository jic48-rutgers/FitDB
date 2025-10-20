-- 1) Roles ----

---- 1.1 drop roles ----
DROP ROLE IF EXISTS
  r_member, r_plus_member, r_trainer, r_manager, r_front_desk, r_floor_manager,
  r_admin_gym, r_super_admin;

---- 1.2 create roles ----
CREATE ROLE r_member;         -- basic reads public views
CREATE ROLE r_plus_member;    -- member that can book
CREATE ROLE r_trainer;        -- availability + rosters
CREATE ROLE r_manager;        -- publish sessions, assign trainers
CREATE ROLE r_front_desk;     -- check-in & card issuing
CREATE ROLE r_floor_manager;  -- equipment service/cleaning
CREATE ROLE r_admin_gym;      -- gym-scoped admin
CREATE ROLE r_super_admin;    -- global-scoped admin