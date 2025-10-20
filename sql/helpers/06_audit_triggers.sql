-- 6) Audit Triggers ----
-- Pattern: AFTER INSERT/UPDATE/DELETE on base table → INSERT into corresponding *_AUD
-- We only store `after_json` (no before_json), plus `action` and actor if available.
-- TODO actor_user_id is NULL until we decide on a way to track who is doing the action (SUSER_SNAME() vs. CURRENT_USER)

DELIMITER $$

---- 6.1 USER → USER_AUD ----
CREATE TRIGGER trg_aud_user_insert
AFTER INSERT ON USER
FOR EACH ROW
BEGIN
  INSERT INTO USER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'username', NEW.username,
      'email', NEW.email,
      'status_id', NEW.status_id,
      'profile_photo_path', NEW.profile_photo_path
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_user_update
AFTER UPDATE ON USER
FOR EACH ROW
BEGIN
  INSERT INTO USER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'username', NEW.username,
      'email', NEW.email,
      'status_id', NEW.status_id,
      'profile_photo_path', NEW.profile_photo_path
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_user_delete
AFTER DELETE ON USER
FOR EACH ROW
BEGIN
  INSERT INTO USER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'username', OLD.username,
      'email', OLD.email,
      'status_id', OLD.status_id,
      'profile_photo_path', OLD.profile_photo_path
    ),
    NULL
  );
END$$

---- 6.2 MEMBER → MEMBER_AUD ----
CREATE TRIGGER trg_aud_member_insert
AFTER INSERT ON MEMBER
FOR EACH ROW
BEGIN
  INSERT INTO MEMBER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'user_id', NEW.user_id,
      'membership_plan_id', NEW.membership_plan_id,
      'home_gym_id', NEW.home_gym_id,
      'status_id', NEW.status_id,
      'joined_on', NEW.joined_on
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_member_update
AFTER UPDATE ON MEMBER
FOR EACH ROW
BEGIN
  INSERT INTO MEMBER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'user_id', NEW.user_id,
      'membership_plan_id', NEW.membership_plan_id,
      'home_gym_id', NEW.home_gym_id,
      'status_id', NEW.status_id,
      'joined_on', NEW.joined_on
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_member_delete
AFTER DELETE ON MEMBER
FOR EACH ROW
BEGIN
  INSERT INTO MEMBER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'user_id', OLD.user_id,
      'membership_plan_id', OLD.membership_plan_id,
      'home_gym_id', OLD.home_gym_id,
      'status_id', OLD.status_id,
      'joined_on', OLD.joined_on
    ),
    NULL
  );
END$$

---- 6.3 ACCESS_CARD → ACCESS_CARD_AUD ----
CREATE TRIGGER trg_aud_access_card_insert
AFTER INSERT ON ACCESS_CARD
FOR EACH ROW
BEGIN
  INSERT INTO ACCESS_CARD_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'member_id', NEW.member_id,
      'gym_id', NEW.gym_id,
      'card_uid', NEW.card_uid,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_access_card_update
AFTER UPDATE ON ACCESS_CARD
FOR EACH ROW
BEGIN
  INSERT INTO ACCESS_CARD_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'member_id', NEW.member_id,
      'gym_id', NEW.gym_id,
      'card_uid', NEW.card_uid,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_access_card_delete
AFTER DELETE ON ACCESS_CARD
FOR EACH ROW
BEGIN
  INSERT INTO ACCESS_CARD_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'member_id', OLD.member_id,
      'gym_id', OLD.gym_id,
      'card_uid', OLD.card_uid,
      'status_id', OLD.status_id
    ),
    NULL
  );
END$$

---- 6.4 CHECK_IN → CHECK_IN_AUD ----
CREATE TRIGGER trg_aud_check_in_insert
AFTER INSERT ON CHECK_IN
FOR EACH ROW
BEGIN
  INSERT INTO CHECK_IN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'member_id', NEW.member_id,
      'gym_id', NEW.gym_id,
      'access_card_id', NEW.access_card_id,
      'method', NEW.method,
      'checked_in_at', NEW.checked_in_at
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_check_in_update
AFTER UPDATE ON CHECK_IN
FOR EACH ROW
BEGIN
  INSERT INTO CHECK_IN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'member_id', NEW.member_id,
      'gym_id', NEW.gym_id,
      'access_card_id', NEW.access_card_id,
      'method', NEW.method,
      'checked_in_at', NEW.checked_in_at
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_check_in_delete
AFTER DELETE ON CHECK_IN
FOR EACH ROW
BEGIN
  INSERT INTO CHECK_IN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'member_id', OLD.member_id,
      'gym_id', OLD.gym_id,
      'access_card_id', OLD.access_card_id,
      'method', OLD.method,
      'checked_in_at', OLD.checked_in_at
    ),
    NULL
  );
END$$

---- 6.5 STAFF → STAFF_AUD ----
CREATE TRIGGER trg_aud_staff_insert
AFTER INSERT ON STAFF
FOR EACH ROW
BEGIN
  INSERT INTO STAFF_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'user_id', NEW.user_id,
      'gym_id', NEW.gym_id,
      'status_id', NEW.status_id,
      'notes', NEW.notes
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_staff_update
AFTER UPDATE ON STAFF
FOR EACH ROW
BEGIN
  INSERT INTO STAFF_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'user_id', NEW.user_id,
      'gym_id', NEW.gym_id,
      'status_id', NEW.status_id,
      'notes', NEW.notes
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_staff_delete
AFTER DELETE ON STAFF
FOR EACH ROW
BEGIN
  INSERT INTO STAFF_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'user_id', OLD.user_id,
      'gym_id', OLD.gym_id,
      'status_id', OLD.status_id,
      'notes', OLD.notes
    ),
    NULL
  );
END$$

---- 6.6 TRAINER → TRAINER_AUD ----
CREATE TRIGGER trg_aud_trainer_insert
AFTER INSERT ON TRAINER
FOR EACH ROW
BEGIN
  INSERT INTO TRAINER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'certification', NEW.certification,
      'bio', NEW.bio
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_trainer_update
AFTER UPDATE ON TRAINER
FOR EACH ROW
BEGIN
  INSERT INTO TRAINER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'certification', NEW.certification,
      'bio', NEW.bio
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_trainer_delete
AFTER DELETE ON TRAINER
FOR EACH ROW
BEGIN
  INSERT INTO TRAINER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'staff_id', OLD.staff_id,
      'certification', OLD.certification,
      'bio', OLD.bio
    ),
    NULL
  );
END$$

---- 6.7 MANAGER → MANAGER_AUD ----
CREATE TRIGGER trg_aud_manager_insert
AFTER INSERT ON MANAGER
FOR EACH ROW
BEGIN
  INSERT INTO MANAGER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'scope', NEW.scope
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_manager_update
AFTER UPDATE ON MANAGER
FOR EACH ROW
BEGIN
  INSERT INTO MANAGER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'scope', NEW.scope
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_manager_delete
AFTER DELETE ON MANAGER
FOR EACH ROW
BEGIN
  INSERT INTO MANAGER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'staff_id', OLD.staff_id,
      'scope', OLD.scope
    ),
    NULL
  );
END$$

---- 6.8 FLOOR_MANAGER → FLOOR_MANAGER_AUD ----
CREATE TRIGGER trg_aud_floor_manager_insert
AFTER INSERT ON FLOOR_MANAGER
FOR EACH ROW
BEGIN
  INSERT INTO FLOOR_MANAGER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'scope', NEW.scope
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_floor_manager_update
AFTER UPDATE ON FLOOR_MANAGER
FOR EACH ROW
BEGIN
  INSERT INTO FLOOR_MANAGER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'scope', NEW.scope
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_floor_manager_delete
AFTER DELETE ON FLOOR_MANAGER
FOR EACH ROW
BEGIN
  INSERT INTO FLOOR_MANAGER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'staff_id', OLD.staff_id,
      'scope', OLD.scope
    ),
    NULL
  );
END$$

---- 6.9 FRONT_DESK → FRONT_DESK_AUD ----
CREATE TRIGGER trg_aud_front_desk_insert
AFTER INSERT ON FRONT_DESK
FOR EACH ROW
BEGIN
  INSERT INTO FRONT_DESK_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'capabilities', NEW.capabilities
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_front_desk_update
AFTER UPDATE ON FRONT_DESK
FOR EACH ROW
BEGIN
  INSERT INTO FRONT_DESK_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'capabilities', NEW.capabilities
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_front_desk_delete
AFTER DELETE ON FRONT_DESK
FOR EACH ROW
BEGIN
  INSERT INTO FRONT_DESK_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'staff_id', OLD.staff_id,
      'capabilities', OLD.capabilities
    ),
    NULL
  );
END$$

---- 6.10 ADMIN → ADMIN_AUD ----
CREATE TRIGGER trg_aud_admin_insert
AFTER INSERT ON ADMIN
FOR EACH ROW
BEGIN
  INSERT INTO ADMIN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'scope', NEW.scope
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_admin_update
AFTER UPDATE ON ADMIN
FOR EACH ROW
BEGIN
  INSERT INTO ADMIN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'staff_id', NEW.staff_id,
      'scope', NEW.scope
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_admin_delete
AFTER DELETE ON ADMIN
FOR EACH ROW
BEGIN
  INSERT INTO ADMIN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'staff_id', OLD.staff_id,
      'scope', OLD.scope
    ),
    NULL
  );
END$$

---- 6.11 SUPER_ADMIN → SUPER_ADMIN_AUD ----
CREATE TRIGGER trg_aud_super_admin_insert
AFTER INSERT ON SUPER_ADMIN
FOR EACH ROW
BEGIN
  INSERT INTO SUPER_ADMIN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'user_id', NEW.user_id,
      'scope', NEW.scope
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_super_admin_update
AFTER UPDATE ON SUPER_ADMIN
FOR EACH ROW
BEGIN
  INSERT INTO SUPER_ADMIN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'user_id', NEW.user_id,
      'scope', NEW.scope
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_super_admin_delete
AFTER DELETE ON SUPER_ADMIN
FOR EACH ROW
BEGIN
  INSERT INTO SUPER_ADMIN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'user_id', OLD.user_id,
      'scope', OLD.scope
    ),
    NULL
  );
END$$

---- 6.12 GYM → GYM_AUD ----
CREATE TRIGGER trg_aud_gym_insert
AFTER INSERT ON GYM
FOR EACH ROW
BEGIN
  INSERT INTO GYM_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'name', NEW.name,
      'address', NEW.address,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_gym_update
AFTER UPDATE ON GYM
FOR EACH ROW
BEGIN
  INSERT INTO GYM_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'name', NEW.name,
      'address', NEW.address,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_gym_delete
AFTER DELETE ON GYM
FOR EACH ROW
BEGIN
  INSERT INTO GYM_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'name', OLD.name,
      'address', OLD.address,
      'status_id', OLD.status_id
    ),
    NULL
  );
END$$

---- 6.13 EQUIP_KIND → EQUIP_KIND_AUD ----
CREATE TRIGGER trg_aud_equip_kind_insert
AFTER INSERT ON EQUIP_KIND
FOR EACH ROW
BEGIN
  INSERT INTO EQUIP_KIND_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'name', NEW.name,
      'mode', NEW.mode
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_equip_kind_update
AFTER UPDATE ON EQUIP_KIND
FOR EACH ROW
BEGIN
  INSERT INTO EQUIP_KIND_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'name', NEW.name,
      'mode', NEW.mode
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_equip_kind_delete
AFTER DELETE ON EQUIP_KIND
FOR EACH ROW
BEGIN
  INSERT INTO EQUIP_KIND_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'name', OLD.name,
      'mode', OLD.mode
    ),
    NULL
  );
END$$

---- 6.14 EQUIPMENT_ITEM → EQUIPMENT_ITEM_AUD ----
CREATE TRIGGER trg_aud_equipment_item_insert
AFTER INSERT ON EQUIPMENT_ITEM
FOR EACH ROW
BEGIN
  INSERT INTO EQUIPMENT_ITEM_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'gym_id', NEW.gym_id,
      'equip_kind_id', NEW.equip_kind_id,
      'status_id', NEW.status_id,
      'serial_no', NEW.serial_no,
      'uses_count', NEW.uses_count,
      'rated_uses', NEW.rated_uses,
      'last_serviced_at', NEW.last_serviced_at,
      'last_cleaned_at', NEW.last_cleaned_at,
      'cleaning_interval_uses', NEW.cleaning_interval_uses,
      'cleaning_interval_days', NEW.cleaning_interval_days,
      'next_clean_due_at', NEW.next_clean_due_at,
      'service_required', NEW.service_required,
      'cleaning_required', NEW.cleaning_required
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_equipment_item_update
AFTER UPDATE ON EQUIPMENT_ITEM
FOR EACH ROW
BEGIN
  INSERT INTO EQUIPMENT_ITEM_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'gym_id', NEW.gym_id,
      'equip_kind_id', NEW.equip_kind_id,
      'status_id', NEW.status_id,
      'serial_no', NEW.serial_no,
      'uses_count', NEW.uses_count,
      'rated_uses', NEW.rated_uses,
      'last_serviced_at', NEW.last_serviced_at,
      'last_cleaned_at', NEW.last_cleaned_at,
      'cleaning_interval_uses', NEW.cleaning_interval_uses,
      'cleaning_interval_days', NEW.cleaning_interval_days,
      'next_clean_due_at', NEW.next_clean_due_at,
      'service_required', NEW.service_required,
      'cleaning_required', NEW.cleaning_required
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_equipment_item_delete
AFTER DELETE ON EQUIPMENT_ITEM
FOR EACH ROW
BEGIN
  INSERT INTO EQUIPMENT_ITEM_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'gym_id', OLD.gym_id,
      'equip_kind_id', OLD.equip_kind_id,
      'status_id', OLD.status_id,
      'serial_no', OLD.serial_no,
      'uses_count', OLD.uses_count,
      'rated_uses', OLD.rated_uses,
      'last_serviced_at', OLD.last_serviced_at,
      'last_cleaned_at', OLD.last_cleaned_at,
      'cleaning_interval_uses', OLD.cleaning_interval_uses,
      'cleaning_interval_days', OLD.cleaning_interval_days,
      'next_clean_due_at', OLD.next_clean_due_at,
      'service_required', OLD.service_required,
      'cleaning_required', OLD.cleaning_required
    ),
    NULL
  );
END$$

---- 6.15 INVENTORY_COUNT → INVENTORY_COUNT_AUD ----
CREATE TRIGGER trg_aud_inventory_count_insert
AFTER INSERT ON INVENTORY_COUNT
FOR EACH ROW
BEGIN
  INSERT INTO INVENTORY_COUNT_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'gym_id', NEW.gym_id,
      'equip_kind_id', NEW.equip_kind_id,
      'qty_on_floor', NEW.qty_on_floor,
      'qty_in_storage', NEW.qty_in_storage,
      'reorder_needed', NEW.reorder_needed,
      'updated_snapshot_at', NEW.updated_snapshot_at
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_inventory_count_update
AFTER UPDATE ON INVENTORY_COUNT
FOR EACH ROW
BEGIN
  INSERT INTO INVENTORY_COUNT_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'gym_id', NEW.gym_id,
      'equip_kind_id', NEW.equip_kind_id,
      'qty_on_floor', NEW.qty_on_floor,
      'qty_in_storage', NEW.qty_in_storage,
      'reorder_needed', NEW.reorder_needed,
      'updated_snapshot_at', NEW.updated_snapshot_at
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_inventory_count_delete
AFTER DELETE ON INVENTORY_COUNT
FOR EACH ROW
BEGIN
  INSERT INTO INVENTORY_COUNT_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'gym_id', OLD.gym_id,
      'equip_kind_id', OLD.equip_kind_id,
      'qty_on_floor', OLD.qty_on_floor,
      'qty_in_storage', OLD.qty_in_storage,
      'reorder_needed', OLD.reorder_needed,
      'updated_snapshot_at', OLD.updated_snapshot_at
    ),
    NULL
  );
END$$

---- 6.16 SERVICE_LOG → SERVICE_LOG_AUD ----
CREATE TRIGGER trg_aud_service_log_insert
AFTER INSERT ON SERVICE_LOG
FOR EACH ROW
BEGIN
  INSERT INTO SERVICE_LOG_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'equipment_item_id', NEW.equipment_item_id,
      'serviced_at', NEW.serviced_at,
      'action', NEW.action,
      'notes', NEW.notes,
      'staff_id', NEW.staff_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_service_log_update
AFTER UPDATE ON SERVICE_LOG
FOR EACH ROW
BEGIN
  INSERT INTO SERVICE_LOG_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'equipment_item_id', NEW.equipment_item_id,
      'serviced_at', NEW.serviced_at,
      'action', NEW.action,
      'notes', NEW.notes,
      'staff_id', NEW.staff_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_service_log_delete
AFTER DELETE ON SERVICE_LOG
FOR EACH ROW
BEGIN
  INSERT INTO SERVICE_LOG_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'equipment_item_id', OLD.equipment_item_id,
      'serviced_at', OLD.serviced_at,
      'action', OLD.action,
      'notes', OLD.notes,
      'staff_id', OLD.staff_id
    ),
    NULL
  );
END$$

---- 6.17 CLASS_SESSION → CLASS_SESSION_AUD ----
CREATE TRIGGER trg_aud_class_session_insert
AFTER INSERT ON CLASS_SESSION
FOR EACH ROW
BEGIN
  INSERT INTO CLASS_SESSION_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'gym_id', NEW.gym_id,
      'title', NEW.title,
      'description', NEW.description,
      'starts_at', NEW.starts_at,
      'ends_at', NEW.ends_at,
      'capacity', NEW.capacity,
      'max_trainers', NEW.max_trainers,
      'open_for_booking', NEW.open_for_booking,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_class_session_update
AFTER UPDATE ON CLASS_SESSION
FOR EACH ROW
BEGIN
  INSERT INTO CLASS_SESSION_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'gym_id', NEW.gym_id,
      'title', NEW.title,
      'description', NEW.description,
      'starts_at', NEW.starts_at,
      'ends_at', NEW.ends_at,
      'capacity', NEW.capacity,
      'max_trainers', NEW.max_trainers,
      'open_for_booking', NEW.open_for_booking,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_class_session_delete
AFTER DELETE ON CLASS_SESSION
FOR EACH ROW
BEGIN
  INSERT INTO CLASS_SESSION_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'gym_id', OLD.gym_id,
      'title', OLD.title,
      'description', OLD.description,
      'starts_at', OLD.starts_at,
      'ends_at', OLD.ends_at,
      'capacity', OLD.capacity,
      'max_trainers', OLD.max_trainers,
      'open_for_booking', OLD.open_for_booking,
      'status_id', OLD.status_id
    ),
    NULL
  );
END$$

---- 6.18 TRAINER_AVAIL_DATE → TRAINER_AVAIL_DATE_AUD ----
CREATE TRIGGER trg_aud_trainer_avail_date_insert
AFTER INSERT ON TRAINER_AVAIL_DATE
FOR EACH ROW
BEGIN
  INSERT INTO TRAINER_AVAIL_DATE_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'trainer_id', NEW.trainer_id,
      'gym_id', NEW.gym_id,
      'for_date', NEW.for_date,
      'period', NEW.period,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_trainer_avail_date_update
AFTER UPDATE ON TRAINER_AVAIL_DATE
FOR EACH ROW
BEGIN
  INSERT INTO TRAINER_AVAIL_DATE_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'trainer_id', NEW.trainer_id,
      'gym_id', NEW.gym_id,
      'for_date', NEW.for_date,
      'period', NEW.period,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_trainer_avail_date_delete
AFTER DELETE ON TRAINER_AVAIL_DATE
FOR EACH ROW
BEGIN
  INSERT INTO TRAINER_AVAIL_DATE_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'trainer_id', OLD.trainer_id,
      'gym_id', OLD.gym_id,
      'for_date', OLD.for_date,
      'period', OLD.period,
      'status_id', OLD.status_id
    ),
    NULL
  );
END$$

---- 6.19 SESSION_TRAINER → SESSION_TRAINER_AUD ----
CREATE TRIGGER trg_aud_session_trainer_insert
AFTER INSERT ON SESSION_TRAINER
FOR EACH ROW
BEGIN
  INSERT INTO SESSION_TRAINER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'session_id', NEW.session_id,
      'trainer_id', NEW.trainer_id,
      'role', NEW.role,
      'assigned_at', NEW.assigned_at
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_session_trainer_update
AFTER UPDATE ON SESSION_TRAINER
FOR EACH ROW
BEGIN
  INSERT INTO SESSION_TRAINER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'session_id', NEW.session_id,
      'trainer_id', NEW.trainer_id,
      'role', NEW.role,
      'assigned_at', NEW.assigned_at
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_session_trainer_delete
AFTER DELETE ON SESSION_TRAINER
FOR EACH ROW
BEGIN
  INSERT INTO SESSION_TRAINER_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'session_id', OLD.session_id,
      'trainer_id', OLD.trainer_id,
      'role', OLD.role,
      'assigned_at', OLD.assigned_at
    ),
    NULL
  );
END$$

---- 6.20 SESSION_EQUIP_RESERVATION → SESSION_EQUIP_RES_AUD ----
CREATE TRIGGER trg_aud_session_equip_res_insert
AFTER INSERT ON SESSION_EQUIP_RESERVATION
FOR EACH ROW
BEGIN
  INSERT INTO SESSION_EQUIP_RES_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'session_id', NEW.session_id,
      'equip_kind_id', NEW.equip_kind_id,
      'quantity', NEW.quantity
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_session_equip_res_update
AFTER UPDATE ON SESSION_EQUIP_RESERVATION
FOR EACH ROW
BEGIN
  INSERT INTO SESSION_EQUIP_RES_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'session_id', NEW.session_id,
      'equip_kind_id', NEW.equip_kind_id,
      'quantity', NEW.quantity
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_session_equip_res_delete
AFTER DELETE ON SESSION_EQUIP_RESERVATION
FOR EACH ROW
BEGIN
  INSERT INTO SESSION_EQUIP_RES_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'session_id', OLD.session_id,
      'equip_kind_id', OLD.equip_kind_id,
      'quantity', OLD.quantity
    ),
    NULL
  );
END$$

---- 6.21 MEMBERSHIP_PLAN → MEMBERSHIP_PLAN_AUD ----
CREATE TRIGGER trg_aud_membership_plan_insert
AFTER INSERT ON MEMBERSHIP_PLAN
FOR EACH ROW
BEGIN
  INSERT INTO MEMBERSHIP_PLAN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'name', NEW.name,
      'tier', NEW.tier,
      'billing_cycle', NEW.billing_cycle,
      'price', NEW.price,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_membership_plan_update
AFTER UPDATE ON MEMBERSHIP_PLAN
FOR EACH ROW
BEGIN
  INSERT INTO MEMBERSHIP_PLAN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'name', NEW.name,
      'tier', NEW.tier,
      'billing_cycle', NEW.billing_cycle,
      'price', NEW.price,
      'status_id', NEW.status_id
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_membership_plan_delete
AFTER DELETE ON MEMBERSHIP_PLAN
FOR EACH ROW
BEGIN
  INSERT INTO MEMBERSHIP_PLAN_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'name', OLD.name,
      'tier', OLD.tier,
      'billing_cycle', OLD.billing_cycle,
      'price', OLD.price,
      'status_id', OLD.status_id
    ),
    NULL
  );
END$$

---- 6.22 BOOKING → BOOKING_AUD ----
CREATE TRIGGER trg_aud_booking_insert
AFTER INSERT ON BOOKING
FOR EACH ROW
BEGIN
  INSERT INTO BOOKING_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'insert',
    JSON_OBJECT(
      'id', NEW.id,
      'session_id', NEW.session_id,
      'member_id', NEW.member_id,
      'status_id', NEW.status_id,
      'booked_at', NEW.booked_at,
      'cancellation_reason', NEW.cancellation_reason,
      'notes', NEW.notes
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_booking_update
AFTER UPDATE ON BOOKING
FOR EACH ROW
BEGIN
  INSERT INTO BOOKING_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    NEW.id, 'update',
    JSON_OBJECT(
      'id', NEW.id,
      'session_id', NEW.session_id,
      'member_id', NEW.member_id,
      'status_id', NEW.status_id,
      'booked_at', NEW.booked_at,
      'cancellation_reason', NEW.cancellation_reason,
      'notes', NEW.notes
    ),
    NULL
  );
END$$

CREATE TRIGGER trg_aud_booking_delete
AFTER DELETE ON BOOKING
FOR EACH ROW
BEGIN
  INSERT INTO BOOKING_AUD(base_entity_id, action, after_json, actor_user_id)
  VALUES (
    OLD.id, 'delete',
    JSON_OBJECT(
      'id', OLD.id,
      'session_id', OLD.session_id,
      'member_id', OLD.member_id,
      'status_id', OLD.status_id,
      'booked_at', OLD.booked_at,
      'cancellation_reason', OLD.cancellation_reason,
      'notes', OLD.notes
    ),
    NULL
  );
END$$

DELIMITER ;