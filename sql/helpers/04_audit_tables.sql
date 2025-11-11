-- 4) Audit Tables (22)
-- made sure to not have before_json (append-only history lets us reconstruct to a point in time)
-- seq_no provides strict ordering in case timestamps collide/get messed up

-- 4.1 create user audit table
CREATE TABLE USER_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_useraud_entity_seq (base_entity_id, seq_no),
  KEY k_useraud_actor_seq (actor_user_id, seq_no),
  -- note: we intentionally omit FK to USER to allow historical audit records after deletion
  CONSTRAINT fk_useraud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

-- 4.2 create other audit tables
CREATE TABLE STAFF_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_staffaud_entity_seq (base_entity_id, seq_no),
  KEY k_staffaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_staffaud_staff FOREIGN KEY (base_entity_id) REFERENCES STAFF(id),
  CONSTRAINT fk_staffaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE TRAINER_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_trainaud_entity_seq (base_entity_id, seq_no),
  KEY k_trainaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_trainaud_tr FOREIGN KEY (base_entity_id) REFERENCES TRAINER(id),
  CONSTRAINT fk_trainaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE MANAGER_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_manaud_entity_seq (base_entity_id, seq_no),
  KEY k_manaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_manaud_mgr FOREIGN KEY (base_entity_id) REFERENCES MANAGER(id),
  CONSTRAINT fk_manaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE FLOOR_MANAGER_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_fmaud_entity_seq (base_entity_id, seq_no),
  KEY k_fmaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_fmaud_fm FOREIGN KEY (base_entity_id) REFERENCES FLOOR_MANAGER(id),
  CONSTRAINT fk_fmaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE FRONT_DESK_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_fdaud_entity_seq (base_entity_id, seq_no),
  KEY k_fdaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_fdaud_fd FOREIGN KEY (base_entity_id) REFERENCES FRONT_DESK(id),
  CONSTRAINT fk_fdaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE ADMIN_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_adminaud_entity_seq (base_entity_id, seq_no),
  KEY k_adminaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_adminaud_admin FOREIGN KEY (base_entity_id) REFERENCES ADMIN(id),
  CONSTRAINT fk_adminaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE SUPER_ADMIN_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_supaud_entity_seq (base_entity_id, seq_no),
  KEY k_supaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_supaud_sa FOREIGN KEY (base_entity_id) REFERENCES SUPER_ADMIN(id),
  CONSTRAINT fk_supaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

-- 4.3 create gym audit tables
CREATE TABLE GYM_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_gymaud_entity_seq (base_entity_id, seq_no),
  KEY k_gymaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_gym_aud FOREIGN KEY (base_entity_id) REFERENCES GYM(id),
  CONSTRAINT fk_gymaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE EQUIP_KIND_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_ekindaud_entity_seq (base_entity_id, seq_no),
  KEY k_ekindaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_ekind_aud FOREIGN KEY (base_entity_id) REFERENCES EQUIP_KIND(id),
  CONSTRAINT fk_ekindaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE EQUIPMENT_ITEM_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_eitemaud_entity_seq (base_entity_id, seq_no),
  KEY k_eitemaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_eitem_aud FOREIGN KEY (base_entity_id) REFERENCES EQUIPMENT_ITEM(id),
  CONSTRAINT fk_eitemaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE INVENTORY_COUNT_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_invcaud_entity_seq (base_entity_id, seq_no),
  KEY k_invcaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_invc_aud FOREIGN KEY (base_entity_id) REFERENCES INVENTORY_COUNT(id),
  CONSTRAINT fk_invcaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE SERVICE_LOG_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_slogaud_entity_seq (base_entity_id, seq_no),
  KEY k_slogaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_slog_aud FOREIGN KEY (base_entity_id) REFERENCES SERVICE_LOG(id),
  CONSTRAINT fk_slogaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

-- 4.4 create class session audit tables
CREATE TABLE CLASS_SESSION_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_csaud_entity_seq (base_entity_id, seq_no),
  KEY k_csaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_csaud_cs FOREIGN KEY (base_entity_id) REFERENCES CLASS_SESSION(id),
  CONSTRAINT fk_csaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE TRAINER_AVAIL_DATE_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_tavaud_entity_seq (base_entity_id, seq_no),
  KEY k_tavaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_tavaud_ta FOREIGN KEY (base_entity_id) REFERENCES TRAINER_AVAIL_DATE(id),
  CONSTRAINT fk_tavaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE SESSION_TRAINER_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_straaud_entity_seq (base_entity_id, seq_no),
  KEY k_straaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_stra_aud FOREIGN KEY (base_entity_id) REFERENCES SESSION_TRAINER(id),
  CONSTRAINT fk_straaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE SESSION_EQUIP_RES_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_sereqaud_entity_seq (base_entity_id, seq_no),
  KEY k_sereqaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_sereq_aud FOREIGN KEY (base_entity_id) REFERENCES SESSION_EQUIP_RESERVATION(id),
  CONSTRAINT fk_sereqaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

-- 4.5 create membership plan audit tables
CREATE TABLE MEMBERSHIP_PLAN_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_mplaud_entity_seq (base_entity_id, seq_no),
  KEY k_mplaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_mplaud_mp FOREIGN KEY (base_entity_id) REFERENCES MEMBERSHIP_PLAN(id),
  CONSTRAINT fk_mplaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE MEMBER_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_memberaud_entity_seq (base_entity_id, seq_no),
  KEY k_memberaud_actor_seq (actor_user_id, seq_no),
  -- no FK to MEMBER to preserve history after delete
  CONSTRAINT fk_memberaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE BOOKING_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_bookaud_entity_seq (base_entity_id, seq_no),
  KEY k_bookaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_bookaud_booking FOREIGN KEY (base_entity_id) REFERENCES BOOKING(id),
  CONSTRAINT fk_bookaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE CHECK_IN_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_ckinaud_entity_seq (base_entity_id, seq_no),
  KEY k_ckinaud_actor_seq (actor_user_id, seq_no),
  CONSTRAINT fk_ckinaud_checkin FOREIGN KEY (base_entity_id) REFERENCES CHECK_IN(id),
  CONSTRAINT fk_ckinaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;

CREATE TABLE ACCESS_CARD_AUD (
  seq_no BIGINT PRIMARY KEY AUTO_INCREMENT,
  base_entity_id BIGINT NOT NULL,
  occurred_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  action ENUM('insert','update','delete') NOT NULL,
  after_json JSON NULL,
  actor_user_id BIGINT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY k_acardaud_entity_seq (base_entity_id, seq_no),
  KEY k_acardaud_actor_seq (actor_user_id, seq_no),
  -- no FK to ACCESS_CARD so we can retain audit rows after card deletion
  CONSTRAINT fk_acardaud_actor FOREIGN KEY (actor_user_id) REFERENCES USER(id)
) ENGINE=InnoDB;