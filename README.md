# FitDB (CS‑437 Project)

## What is this?
A Gym Membership Management System emphasizing database design: registrations, check-ins, plus-member class bookings, trainer availability (manager‑published sessions), equipment allocations, reporting, and auditing.

## MVP
- **Scope:** Single gym, one trainer, one regular member, one plus member (seed).
- **Roles:** `member` (view only), `plus_member` (booking), `trainer` (availability/rosters), `manager` (publish sessions, equipment, audits), `admin` (everything), `front_desk` (inherits a minimal subset from manager for check-ins), `floor_manager` (inherits a minimal subset from manager for equipment logging).
- **Must-have flows:** register member, check-in, publish sessions from availability, book seat (plus only), cancel, view rosters, managers can issue strikes/bans to members, allocate equipment, managers can generate reports, audit log on every write.
- **Out-of-scope:** payroll, billing, comms (email/SMS).

## Roadmap (WIP)
```mermaid
gantt
    dateFormat  YYYY-MM-DD
    title FitDB Project Roadmap (WIP)
    section Phase 1: Planning & Design
    section Phase 2: Development
    section Phase 3: Services & Interface
    section Phase 4: Testing & Optimization
    section Phase 5: Finalize & Delivery
```


## Stack (proposed)
- Python • Flask
- MySQL
- HTML/CSS (no JS framework for MVP)
- Optional: AWS for deployment & photos

## Docs
- [`contributors.md`](./docs/contributors.md) – people, roles, responsibilities, and collaboration guidelines
- [`architecture.md`](./docs/architecture.md) – overview, context, components, deployment, data flows, security summary
- [`FRD.md`](./docs/FRD.md) – scope, requirements, stakeholders, acceptance criteria, and assumptions
- [`TDD.md`](./docs/TDD.md) - technical design, data model, APIs, security, performance, testing.