# Technical Design Document

## 1. Document Control
- **Version:** 1.1
- **Authors:** Henry Huerta, Jared Cordova
- **Date:** 9/22/25
- **Reviewers:**  Prof. Arnold Lau, T.A. Sneh Bhandari

## 2. Introduction
This TDD specifies the technical implementation details for the Gym Membership Management System (“FitDB”). The design emphasizes the database layer: RBAC (SQL roles), auditable transactions, and denormalized reporting views.

(See [`README.md`](./docs/README.md) for MVP and roadmap.)

## 3. High‑Level Architecture
- Services: Auth/RBAC, Membership, Scheduling, Equipment, Reporting, Audit.
- Backend: Flask
- Database: MySQL as the system of record
- Dev: static assets and member photos stored locally in dev

(create visual diagram)

## 4. Detailed Design

### 4.1 Data Model
**ER Diagram (WIP)**
_Overview with audit tables. For separated diagrams (overview **without** audits, plus three clearer ERDs), see **[ERDs.md](./ERDs.md)**._

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
    %% overview WITH audit tables

    %% user specializations
    USER ||--o| MEMBER : may_be_member
    USER ||--o{ USER_AUD : audited_by
    USER ||--o| STAFF  : may_be_staff

    STAFF ||--o{ STAFF_AUD : audited_by
    STAFF ||--|| TRAINER     : is_trainer
    STAFF ||--|| MANAGER     : is_manager
    STAFF ||--|| FRONT_DESK  : is_front_desk

    TRAINER ||--o{ TRAINER_AUD : audited_by
    MANAGER ||--o{ MANAGER_AUD : audited_by
    FRONT_DESK ||--o{ FRONT_DESK_AUD : audited_by

    %% gym "ownership"
    GYM ||--o{ GYM_AUD         : audited_by
    GYM ||--o{ STAFF           : employs
    GYM ||--o{ CLASS_SESSION   : hosts
    GYM ||--o{ CHECK_IN        : records
    GYM ||--o{ EQUIPMENT_ITEM  : owns
    GYM ||--o{ INVENTORY_COUNT : stocks
    GYM ||--o{ MEMBER          : home_gym_for_trial_basic

    %% equipment & maintenance
    EQUIP_KIND   ||--o{ EQUIP_KIND_AUD : audited_by
    EQUIP_KIND   ||--o{ EQUIPMENT_ITEM : instances
    EQUIP_KIND   ||--o{ INVENTORY_COUNT: bulk_counts
    EQUIPMENT_ITEM ||--o{ EQUIPMENT_ITEM_AUD : audited_by
    EQUIPMENT_ITEM ||--o{ SERVICE_LOG   : service_clean_history
    INVENTORY_COUNT ||--o{ INVENTORY_COUNT_AUD : audited_by
    SERVICE_LOG ||--o{ SERVICE_LOG_AUD  : audited_by

    %% availability & class staffing
    TRAINER ||--o{ TRAINER_AVAIL_DATE : provides_availability
    TRAINER_AVAIL_DATE ||--o{ TRAINER_AVAIL_DATE_AUD : audited_by
    CLASS_SESSION ||--o{ CLASS_SESSION_AUD : audited_by
    CLASS_SESSION ||--o{ SESSION_TRAINER : has_trainers
    SESSION_TRAINER ||--o{ SESSION_TRAINER_AUD : audited_by
    TRAINER ||--o{ SESSION_TRAINER : teaches_session

    %% memberships, bookings, and attendance
    MEMBERSHIP_PLAN ||--o{ MEMBERSHIP_PLAN_AUD : audited_by
    MEMBERSHIP_PLAN ||--o{ MEMBER : subscribes
    CLASS_SESSION   ||--o{ BOOKING : has_bookings
    BOOKING ||--o{ BOOKING_AUD : audited_by
    MEMBER          ||--o{ BOOKING : makes_booking
    CHECK_IN ||--o{ CHECK_IN_AUD : audited_by
    MEMBER          ||--o{ CHECK_IN: checks_in
```
**Key Tables (summary) (WIP)**

**Constraints & Indexes (WIP)**
- Global uniqueness: `USER.username`, `USER.email`
- One-to-one uniqueness: `MEMBER.user_id`, `STAFF.user_id`, `TRAINER.staff_id`, `MANAGER.staff_id`, `FRONT_DESK.staff_id`
- Booking dedupe: `UNIQUE(BOOKING.session_id, BOOKING.member_id)`
- Session staffing: `UNIQUE(SESSION_TRAINER.session_id, SESSION_TRAINER.trainer_id)`; enforce `CLASS_SESSION.max_trainers` in app/trigger (?)
- Trainer availability: `UNIQUE(TRAINER_AVAIL_DATE.trainer_id, for_date, period)`
- Inventory per gym: `UNIQUE(INVENTORY_COUNT.gym_id, equip_kind_id)`
- Time-window indexes: `CLASS_SESSION(starts_at)`, `CHECK_IN(member_id, checked_in_at)`
- Equipment dashboards: index `(EQUIPMENT_ITEM.gym_id, equip_kind_id)` and flags `service_required`, `cleaning_required`
- Audit tables: append-only; index `occurred_at`, `(actor_user_id, occurred_at)`

### 4.2 API Design
(?)

### 4.3 Application Logic
**Booking Workflow (transactional)**
1. verify role = `plus_member`; session is `scheduled` and within bookable window
2. capacity check + equipment sufficiency (per-attendee requirements × seats)
3. insert `Booking`; write `AuditLog`; commit or rollback on any failure

**Publish Sessions (manager)**
1. expand `TrainerAvailability` into sessions for date range
2. validate conflicts and equipment availability; create `ClassSession` rows; write audit in a single transaction

**Check-In**
- validate active membership; insert `CheckIn`; write audit

**RBAC Mapping (selected)**
- `member`: read-only sessions, own profile/check-ins
- `plus_member`: `member` + create/cancel own bookings
- `trainer`: manage own availability; view rosters
- `manager`: publish sessions; view any roster
- `front_desk`: check-ins only; read-only member status
- `floor_manager`: manage equipment
- `admin`: all privileges

### 4.4 User Interface (server-rendered MVP)
- **Member (regular):** profile + check-ins; sessions list (read-only)
- **Plus Member:** sessions list → details → confirm booking/cancel
- **Trainer:** “My Availability” editor; “My Sessions” roster.
- **Manager:** “Publish Sessions” wizard; “Equipment” dashboard; conflicts queue
- **Admin:** audit viewer + role assignments

## 5. Technology Stack
- **Backend:** Python + Flask
- **Database:** MySQL
- **Frontend:** HTML/CSS (for now)

## 6. Security & Compliance
- Password hashing (?)
- **MySQL roles** with least-privilege grants; `plus_member` inherits from `member`
- **Audit logging** via DB triggers
- Parameterized queries only (?)

## 7. Performance Considerations
- Provide `build.sql` and seed data (?)
- Capture EXPLAIN/ANALYZE for: session listing, booking insert path, utilization/equipment views
- Paginate audit and reports

## 8. Risks & Mitigations
- **Overbooking or equipment conflicts** → DB trigger + transaction checks
- **RBAC misconfiguration** → explicit role grants
- **ERD conflicts** → ERD reviews
- **Scope considerations** → enforce MVP

## 9. Testing Strategy
- **Unit tests:** booking constraints, session publish logic, RBAC decorators
- **Integration tests:** transaction rollbacks on forced failures; seed users/roles
- **SQL tests:** views return expected utilization/equipment demand

## 10. Deployment & Monitoring
- **Runtime logging:** audit stored in DB (as JSON?)
- **Metrics:** latency, error rates, booking success/failure counts
- **Backups:** do DB snapshots/backups (?)