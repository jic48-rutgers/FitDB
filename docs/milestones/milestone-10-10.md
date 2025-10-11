# FitDB Milestone (10/1)

**Repo:** [https://github.com/jic48-rutgers/FitDB](https://github.com/jic48-rutgers/FitDB)

**Docs:**
- [`docs/ERDs.md`](docs/ERDs.md)
- [`docs/TDD.md`](docs/TDD.md)
- [`docs/architecture.md`](docs/architecture.md)
- [`docs/FRD.md`](docs/FRD.md)

**SQL:** `sql/build.sql` (main) + helpers in `sql/helpers/`

**Data:** `data/csv/*.csv` (to be bulk-loaded) · `data/generate_seed.py` (using Faker probably)

---

## ER → Database Objects Mapping (overview)
- **Identity & RBAC:** `USER`, `STAFF`, role specializations (`TRAINER`, `MANAGER`, `FLOOR_MANAGER`, `FRONT_DESK`, `ADMIN`, `SUPER_ADMIN`); status lookups (`ACCOUNT_STATUS_IND`); audits (`*_AUD`).
  **Indexes:** `k_user_status`, `k_staff_gym_status` · **Views:** `vw_member_profile`, `vw_member_lookup_minimal` · **Procs:** `sp_check_in`, `sp_access_card_issue`.
- **Gyms & Equipment:** `GYM`, `EQUIP_KIND`, `EQUIPMENT_ITEM`, `INVENTORY_COUNT`, `SERVICE_LOG`; status lookups (`GYM_STATUS_IND`, `EQUIPMENT_STATUS_IND`); audits.
  **Triggers:** `trg_equipment_item_clean_due`, `trg_service_log_flags`, `trg_inventory_reorder` · **Views:** `vw_equipment_status`, `vw_cleaning_due`, `vw_service_due`, `vw_equipment_demand`.
- **Classes & Scheduling:** `CLASS_SESSION`, `TRAINER_AVAIL_DATE`, `SESSION_TRAINER`, `SESSION_EQUIP_RESERVATION`; status/lookups (`SESSION_STATUS_IND`, `AVAILABILITY_STATUS_IND`); audits.
  **Indexes:** `k_csession_gym_starts`, `k_tavail_tr_date` · **Views:** `vw_sessions_open`, `vw_bookable_sessions`, `vw_trainer_schedule`, `vw_trainer_class_rosters`, `vw_class_utilization` · **Procs:** `sp_set_availability`, `sp_publish_sessions`.
- **Membership & Operations:** `MEMBERSHIP_PLAN`, `MEMBER`, `BOOKING`, `ACCESS_CARD`, `CHECK_IN`; lookups (`PLAN_STATUS_IND`, `BOOKING_STATUS_IND`, `ACCESS_CARD_STATUS_IND`); audits.
  **Indexes:** `k_booking_member_time`, `k_booking_status`, `k_checkin_member_time` · **Procs:** `sp_book_session`, `sp_cancel_booking`, `sp_check_in`.

---

## Functional Requirements → Data Model
| Requirement | Tables | Views/Procedures |
|---|---|---|
| Member registration | `USER`, `MEMBER`, `MEMBERSHIP_PLAN`, `ACCESS_CARD` | `sp_access_card_issue`, `vw_member_profile` |
| Plus-only class booking | `CLASS_SESSION`, `BOOKING` | `sp_book_session`, `sp_cancel_booking`, `vw_bookable_sessions` |
| Trainer availability | `TRAINER_AVAIL_DATE`, `TRAINER`, `SESSION_TRAINER` | `sp_set_availability`, `vw_trainer_schedule` |
| Session publishing | `CLASS_SESSION`, `SESSION_TRAINER` | `sp_publish_sessions`, `vw_sessions_open` |
| Check-ins | `CHECK_IN`, `ACCESS_CARD`, `GYM` | `sp_check_in`, `vw_member_checkins`, `vw_cards_by_gym` |
| Equipment tracking | `EQUIPMENT_ITEM`, `INVENTORY_COUNT`, `SERVICE_LOG` | triggers above, `vw_equipment_status`, `vw_cleaning_due`, `vw_service_due` |
| Utilization reporting | `CLASS_SESSION`, `BOOKING` | `vw_class_utilization`, `vw_equipment_demand` |
| RBAC/entitlements | roles + grants | view `SELECT`, proc `EXECUTE`|