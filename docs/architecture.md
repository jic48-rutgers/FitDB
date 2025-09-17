# Architectural Diagram

## 1. Overview
FitDB is a small, well-structured Flask + MySQL system emphasizing database design and auditable transactions.

**To Start:**
- one gym location
- one trainer; one member of each type (regular, plus)
- roles: `member`, `plus_member`, `trainer`, `manager`, `front_desk`, `floor_manager`, `admin`

**To Address:**
- registrations,
- bookings,
- trainer availability,
- equipment tracking,
- auditing
- reporting

**To Avoid:**
- focus on on things this project doesn't address such as payrolls

**Extensibility Goal:**
- the schema and services should be designed to scale to many gyms, trainers, members, and overlapping class sessions

---

## 2. Context Diagram
**Actors → System:**
- Member / Plus Member → portal (member view) → see personal information, book classes/view bookings (plus only)
- Trainer → portal (trainer view) → view class rosters, (provide availability to mananger possibly added later)
- Manager → portal (manager console view) →  manage equipment inventory/allocations, override class rosters, ban members
- Admin → portal (admin console view) → global configuration, auditing

**External systems (possibly added later):**
- AWS integrations

(create visual diagram)

---

## 3. Component Diagram
- **Auth** Flask: session auth(?) with role/permission checks
- **Membership**: members, membership plans, check‑ins, member photos
- **Scheduling**: trainers, class sessions, bookings
- **Equipment**: inventory, maintenance status, session equipment allocations (?)
- **Reporting**: denormalized views (utilization, class fill, equipment demand) (?)
- **Audit**: append‑only audit log via DB triggers (?)

(create visual diagram)

---

## 4. Deployment Diagram
- **Dev:** Flask + MySQL
- **Prod (optional):** AWS

(create visual diagram)

---

## 5. Data Flow Diagram
**A) Plus member books a class**
1. auth check based on role
2. validate capacity and equipment constraints in a transaction
3. insert booking + triggers write to an audit log
4. return booking confirmation + reporting views update automatically

**B) Manager publishes sessions (from trainer availability to be added later)**
1. manager chooses a class template + availability block
2. system creates class session (rows) for the window; validates equipment pool
3. manager can override capacity or reassign trainer if conflicts arise
4. manager can ban members if needed

**C) Trainer updates availability (to be added later)**
1. trainer proposes weekly recurring blocks (e.g., Tue 10:00–12:00)
2. conflicts checked against existing sessions
3. changes recorded in the audit log

(create visual diagram)

---

## 6. Security Considerations
- using MySQL roles (member → plus member inherits; trainer; manager; admin)
- try to counter SQL injection risks from dynamic SQL strings
- PII: hashed passwords and encrypt membership photo (?)
- audit trail for all state‑changing operations

### 6.1 Role-Based Access Control (RBAC) & Security
- app-level decorators AND MySQL roles: `member` → `plus_member` (inherits), `trainer`, `manager`, `front_desk` (subset of manager focused on check-ins), `floor_manager` (subset of manager focused on equipment), `admin`.
- use least privilege grants; sensitive tables via views/procedures where helpful.
- passwords: encrypted somehow; PII protected; member photos stored as encrypted BLOB
- audit: DB triggers on INSERT/UPDATE/DELETE to an append-only `AuditLog` table; updates to audit rows are blocked.
- SQL injection protection via parameterized queries (?)

### 6.2 Transactions
- **booking:** atomic insert with capacity guard and equipment check; on failure → rollback with clear error.
- **publish sessions:** atomic generation of sessions from availability with equipment validation; rollback on conflict.

### 6.3 Build & Performance
- use **EXPLAIN/ANALYZE** to show query plans.