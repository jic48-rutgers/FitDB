# Entity Relationship Diagrams

This file contains four Mermaid ERDs:
1. **Overview (no audit tables)**
2. **Gym & Equipment (+ audits)**
3. **Staff, Classes & Trainer Availability (+ audits)**
4. **Members, Plans, Bookings & Check-ins (+ audits)**

---

## 1) Overview — no audit tables

```mermaid
---
config:
  theme: redux-color
  look: neo
  layout: elk
  elk:
    mergeEdges: True
    nodePlacementStrategy: LINEAR_SEGMENTS
---
erDiagram
    %% overview - entities & relationships only (no audit tables)

    %% user specializations
    USER ||--o| MEMBER : may_be_member
    USER ||--o| STAFF  : may_be_staff
    STAFF ||--|| TRAINER     : is_trainer
    STAFF ||--|| MANAGER     : is_manager
    STAFF ||--|| FRONT_DESK  : is_front_desk

    %% gym "ownership"
    GYM ||--o{ STAFF           : employs
    GYM ||--o{ CLASS_SESSION   : hosts
    GYM ||--o{ CHECK_IN        : records
    GYM ||--o{ EQUIPMENT_ITEM  : owns
    GYM ||--o{ INVENTORY_COUNT : stocks
    GYM ||--o{ MEMBER          : home_gym_for_trial_basic

    %% equipment & maintenance
    EQUIP_KIND   ||--o{ EQUIPMENT_ITEM  : instances
    EQUIP_KIND   ||--o{ INVENTORY_COUNT : bulk_counts
    EQUIPMENT_ITEM ||--o{ SERVICE_LOG   : service_clean_history

    %% availability & class staffing
    TRAINER ||--o{ TRAINER_AVAIL_DATE : provides_availability
    CLASS_SESSION ||--o{ SESSION_TRAINER : has_trainers
    TRAINER ||--o{ SESSION_TRAINER : teaches_session

    %% memberships, bookings, and attendance
    MEMBERSHIP_PLAN ||--o{ MEMBER : subscribes
    CLASS_SESSION   ||--o{ BOOKING : has_bookings
    MEMBER          ||--o{ BOOKING : makes_booking
    MEMBER          ||--o{ CHECK_IN: checks_in
```

---

## 2) Gym & Equipment (+ audits)

```mermaid
---
config:
  theme: redux-color
  look: neo
  layout: elk
  elk:
    mergeEdges: True
    nodePlacementStrategy: LINEAR_SEGMENTS
---
erDiagram
    %% gym & equipment (+ audits)

    %% relationships
    GYM ||--o{ EQUIPMENT_ITEM  : owns
    GYM ||--o{ INVENTORY_COUNT : stocks
    EQUIP_KIND ||--o{ EQUIPMENT_ITEM  : instances
    EQUIP_KIND ||--o{ INVENTORY_COUNT : bulk_counts
    EQUIPMENT_ITEM ||--o{ SERVICE_LOG : service_and_clean_logs

    %% audits
    GYM ||--o{ GYM_AUD : audited_by
    EQUIP_KIND ||--o{ EQUIP_KIND_AUD : audited_by
    EQUIPMENT_ITEM ||--o{ EQUIPMENT_ITEM_AUD : audited_by
    INVENTORY_COUNT ||--o{ INVENTORY_COUNT_AUD : audited_by
    SERVICE_LOG ||--o{ SERVICE_LOG_AUD : audited_by

    %% entities
    GYM {
        bigint id PK "gym id"
        string name  "display"
        string address "street city state"
        datetime created_at "utc"
        string status "active inactive"
    }
    EQUIP_KIND {
        bigint id PK "kind"
        string name UK "treadmill yoga_mat"
        string mode "per_item bulk"
    }
    EQUIPMENT_ITEM {
        bigint id PK "machine"
        bigint gym_id FK "-> GYM.id"
        bigint equip_kind_id FK "-> EQUIP_KIND.id"
        string serial_no UK "optional"
        int uses_count "increments"
        int rated_uses "service threshold"
        datetime last_serviced_at "utc"
        datetime last_cleaned_at "utc"
        int cleaning_interval_uses "by uses"
        int cleaning_interval_days "by days"
        datetime next_clean_due_at "computed"
        boolean service_required "flag"
        boolean cleaning_required "flag"
        string status "ok needs_service out_of_order"
    }
    INVENTORY_COUNT {
        bigint id PK
        bigint gym_id FK "-> GYM.id"
        bigint equip_kind_id FK "-> EQUIP_KIND.id"
        int qty_on_floor
        int qty_in_storage
        boolean reorder_needed
        datetime updated_at "utc"
    }
    SERVICE_LOG {
        bigint id PK
        bigint equipment_item_id FK "-> EQUIPMENT_ITEM.id"
        datetime serviced_at "utc"
        string action "inspect repair replace clean"
        string notes  "detail"
        bigint staff_id FK "optional"
    }

    %% audit tables
    GYM_AUD {
        bigint id PK
        bigint gym_id FK
        datetime occurred_at
        string action
        json before_json
        json after_json
        bigint actor_user_id
    }
    EQUIP_KIND_AUD {
        bigint id PK
        bigint equip_kind_id FK
        datetime occurred_at
        string action
        json before_json
        json after_json
        bigint actor_user_id
    }
    EQUIPMENT_ITEM_AUD {
        bigint id PK
        bigint equipment_item_id FK
        datetime occurred_at
        string action
        json before_json
        json after_json
        bigint actor_user_id
    }
    INVENTORY_COUNT_AUD {
        bigint id PK
        bigint inventory_count_id FK
        datetime occurred_at
        string action
        json before_json
        json after_json
        bigint actor_user_id
    }
    SERVICE_LOG_AUD {
        bigint id PK
        bigint service_log_id FK
        datetime occurred_at
        string action
        json before_json
        json after_json
        bigint actor_user_id
    }
```

---

## 3) Staff, Classes & Trainer Availability (+ audits)

```mermaid
---
config:
  theme: redux-color
  look: neo
  layout: elk
  elk:
    mergeEdges: True
    nodePlacementStrategy: LINEAR_SEGMENTS
---
erDiagram
    %% staff, classes, and trainer availability (+ audits)

    %% relationships
    GYM ||--o{ STAFF : employs
    USER ||--o| STAFF : may_be_staff
    STAFF ||--|| TRAINER : is_trainer
    STAFF ||--|| MANAGER : is_manager
    STAFF ||--|| FRONT_DESK : is_front_desk

    GYM ||--o{ CLASS_SESSION : hosts
    TRAINER ||--o{ TRAINER_AVAIL_DATE : provides_availability
    CLASS_SESSION ||--o{ SESSION_TRAINER : has_trainers
    TRAINER ||--o{ SESSION_TRAINER : teaches

    %% audits
    USER ||--o{ USER_AUD : audited_by
    STAFF ||--o{ STAFF_AUD : audited_by
    TRAINER ||--o{ TRAINER_AUD : audited_by
    MANAGER ||--o{ MANAGER_AUD : audited_by
    FRONT_DESK ||--o{ FRONT_DESK_AUD : audited_by
    CLASS_SESSION ||--o{ CLASS_SESSION_AUD : audited_by
    SESSION_TRAINER ||--o{ SESSION_TRAINER_AUD : audited_by
    TRAINER_AVAIL_DATE ||--o{ TRAINER_AVAIL_DATE_AUD : audited_by

    %% entities
    USER {
        bigint id PK
        string username UK
        string email UK
        string password_hash
        string password_algo
        datetime password_updated_at
        datetime last_login_at
        int failed_login_count
        datetime created_at
        string status
    }
    STAFF {
        bigint id PK
        bigint user_id FK, UK "-> USER.id"
        bigint gym_id FK "-> GYM.id"
        string status
        string notes
    }
    TRAINER {
        bigint id PK
        bigint staff_id FK, UK "-> STAFF.id"
        string certification
        string bio
    }
    MANAGER {
        bigint id PK
        bigint staff_id FK, UK "-> STAFF.id"
        string scope "gym-level"
    }
    FRONT_DESK {
        bigint id PK
        bigint staff_id FK, UK "-> STAFF.id"
        string capabilities "check-in register"
    }
    TRAINER_AVAIL_DATE {
        bigint id PK
        bigint trainer_id FK "-> TRAINER.id"
        bigint gym_id FK "-> GYM.id"
        date for_date
        string period "AM PM"
        string status "available unavailable"
    }
    CLASS_SESSION {
        bigint id PK
        bigint gym_id FK "-> GYM.id"
        string title
        string description
        datetime starts_at
        datetime ends_at
        int capacity
        int max_trainers
        boolean open_for_booking
        string status
        string cancellation_reason
    }
    SESSION_TRAINER {
        bigint session_id PK, FK "-> CLASS_SESSION.id"
        bigint trainer_id PK, FK "-> TRAINER.id"
        string role "lead assistant"
        datetime assigned_at
    }
    GYM {
        bigint id PK
        string name
        string address
        datetime created_at
        string status
    }

    %% audit tables
    USER_AUD { bigint id PK  bigint user_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    STAFF_AUD { bigint id PK  bigint staff_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    TRAINER_AUD { bigint id PK  bigint trainer_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    MANAGER_AUD { bigint id PK  bigint manager_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    FRONT_DESK_AUD { bigint id PK  bigint front_desk_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    CLASS_SESSION_AUD { bigint id PK  bigint class_session_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    SESSION_TRAINER_AUD { bigint id PK  bigint session_id FK  bigint trainer_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    TRAINER_AVAIL_DATE_AUD { bigint id PK  bigint trainer_avail_date_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
```

---

## 4) Members, Plans, Bookings & Check-ins (+ audits)

```mermaid
---
config:
  theme: redux-color
  look: neo
  layout: elk
  elk:
    mergeEdges: True
    nodePlacementStrategy: LINEAR_SEGMENTS
---
erDiagram
    %% members, plans, bookings, and check-ins (+ audits)

    %% relationships
    USER ||--o| MEMBER : may_be_member
    MEMBERSHIP_PLAN ||--o{ MEMBER : subscribes
    MEMBER ||--o{ BOOKING : makes
    CLASS_SESSION ||--o{ BOOKING : has
    MEMBER ||--o{ CHECK_IN : checks_in
    GYM ||--o{ CHECK_IN : records
    GYM ||--o{ MEMBER : home_gym_for_trial_basic

    %% audits
    USER ||--o{ USER_AUD : audited_by
    MEMBER ||--o{ MEMBER_AUD : audited_by
    MEMBERSHIP_PLAN ||--o{ MEMBERSHIP_PLAN_AUD : audited_by
    BOOKING ||--o{ BOOKING_AUD : audited_by
    CHECK_IN ||--o{ CHECK_IN_AUD : audited_by

    %% entities
    USER {
        bigint id PK
        string username UK
        string email UK
        string password_hash
        string password_algo
        datetime password_updated_at
        datetime last_login_at
        int failed_login_count
        datetime created_at
        string status
    }
    MEMBERSHIP_PLAN {
        bigint id PK
        string name UK
        string tier "trial basic plus"
        string billing_cycle "monthly annual"
        decimal price
        string status "active retired"
    }
    MEMBER {
        bigint id PK
        bigint user_id FK, UK "-> USER.id"
        bigint membership_plan_id FK "-> MEMBERSHIP_PLAN.id"
        bigint home_gym_id FK "-> GYM.id (trial/basic only)"
        date joined_on
        date trial_expires_on
        blob photo_ciphertext
        binary photo_iv
        string photo_algo
        string status
    }
    CLASS_SESSION {
        bigint id PK
        bigint gym_id FK "-> GYM.id"
        string title
        datetime starts_at
        datetime ends_at
        int capacity
        boolean open_for_booking
        string status
    }
    BOOKING {
        bigint id PK
        bigint session_id FK "-> CLASS_SESSION.id"
        bigint member_id FK "-> MEMBER.id"
        string status "confirmed canceled_member canceled_system"
        datetime booked_at
        string cancellation_reason
        string notes "enforce plus plan"
    }
    CHECK_IN {
        bigint id PK
        bigint member_id FK "-> MEMBER.id"
        bigint gym_id FK "-> GYM.id"
        datetime checked_in_at
        string method "scan manual"
    }
    GYM {
        bigint id PK
        string name
        string address
        datetime created_at
        string status
    }

    %% audit tables
    USER_AUD { bigint id PK  bigint user_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    MEMBER_AUD { bigint id PK  bigint member_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    MEMBERSHIP_PLAN_AUD { bigint id PK  bigint membership_plan_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    BOOKING_AUD { bigint id PK  bigint booking_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
    CHECK_IN_AUD { bigint id PK  bigint check_in_id FK  datetime occurred_at string action json before_json json after_json bigint actor_user_id }
```