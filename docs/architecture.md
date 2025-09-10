## FitDB Architecture

## 1) Overview
FitDB is a small, well-structured Flask + MySQL system emphasizing database design and auditable transactions.

**To Start:**
- one gym location
- one trainer; 3 member of each type (regular, plus)
- roles: `member`, `plus_member`, `trainer`, `manager`, `admin`

**To Address:**
- registrations,
- bookings,
- trainer availability,
- equipment tracking,
- auditing
- reporting

**To Avoid:**
- focuson on things this project doesn't address such as payrolls

**Extensibility Goal:**
- the schema and services should be designed to scale to many gyms, trainers, members, and overlapping class sessions

---

## 2) Context Diagram
**Actors → System:**
- Member / Plus Member → portal (member view) → see personal information, book classes/view bookings (plus only)
- Trainer → portal (trainer view) → view class rosters, (provide availabilty to mananger possibly added later)
- Manager → portal (manager console view) →  manage equipment inventory/allocations, override class rosters, ban members
- Admin → portal (admin console view) → global configuration, auditing

**External systems (possibly added later):**
- AWS integrations

(create visual diagram)

---

## 3) Component Diagram
- **Auth** Flask: session auth(?) with role/permission checks
- **Membership**: members, membership plans, check‑ins, member photos
- **Scheduling**: trainers, class sessions, bookings
- **Equipment**: inventory, maintenance status, session equipment allocations (?)
- **Reporting**: denormalized views (utilization, class fill, equipment demand) (?)
- **Audit**: append‑only audit log via DB triggers (?)

(create visual diagram)

---

## 4) Deployment Diagram
- **Dev:** Flask + MySQL
- **Prod (optional):** AWS

(create visual diagram)

---

## 5) Data Flow Diagram
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

## 6) Security Considerations
- using MySQL roles (member → plus member inherits; trainer; manager; admin)
- try to counter SQL injection risks from dynamic SQL strings
- PII: hashed passwords and encrypt membership photo (?)
- audit trail for all state‑changing operations