# Functional Requirements Document (FRD)

## 1. Document Control
- **Version:**  1.1
- **Author:**  Jared Cordova, Henry Huerta
- **Date:**  09/17/25
- **Reviewers:**  Prof. Arnold Lau, T.A. Sneh Bhandari

## 2. Purpose
FitDB is a reliable, central system that supports the day-to-day functions of large, multiple-location gym chains. These functions include registering new members, tracking membership details, booking fitness class sessions, viewing trainer availability, member analytics for decision-making, and member check-ins.

## 3. Scope
- **In-Scope (MVP):**
  - register/edit/deactivate/strike/ban members; member photo reference (BLOB)
  - check-ins (id input) with status validation
  - trainer availability entry (trainer) and session publication (manager)
  - class session bookings/cancellations (plus members only)
  - equipment inventory and per-session allocation checks
  - audit logging (append-only) and reporting views** (utilization, equipment demand)
- **Out-of-Scope (MVP):**
  - payroll, billing, messaging (email/SMS), waitlists, multi-gym UI (schema supports it later)

## 4. Stakeholders
- **Member (regular):** view profile and check-ins; no booking
- **Member (plus):** all of the above + book/cancel sessions
- **Trainer:** maintain availability; view rosters
- **Manager:** publish sessions, manage equipment, adjust trainer assignment, does reporting
- **Front Desk:** check-ins; view-only member status (inherits subset from manager)
- **Floor Manager:** equipment counts/maintenance (inherits from manager)
- **Admin:** full access; role assignments; audit viewer

## 5. Functional Requirements (selected)
- **FR-1 Register Member**: create member with tier, status, optional photo
  - **AC:** all required fields validated; member row created; audit entry written.
- **FR-2 Publish Sessions** (manager from trainer availability)
  - **AC:** sessions created within date window; no conflicts; equipment sufficiency verified; audit entry written; rollback on any failure.
- **FR-3 Book Session** (plus member)
  - **AC:** capacity and equipment checks enforced; unique booking per member/session; audit entry written; rollback on failure.
- **FR-4 Check-In** (front desk)
  - **AC:** active status required; check-in saved with timestamp and method; audit entry written.
- **FR-5 Reporting**
  - **AC:** views return utilization and equipment demand; queries complete < 3s on 50k rows (dev target).

## 6. Non-Functional Requirements
- **Performance:**
  - load trainer availability in < 3s
  - retrieve member data in < 3s
- **Security:**
  - enforce RBAC
  - maintain append-only audit log
  - hash passwords/protect photos
- **Scalability:**
  - Must handle up to 1,000 concurrent users while maintaining transactional integrity
  - Provide EXPLAIN/ANALYZE snapshots
  - index strategy documented
  - paginate heavy lists
- **Usability:**
  - Users will retrieve and add data through a GUI including calendars, text-based entry, and clickable items.

## 7. Assumptions & Dependencies

### Data & Scripts
- provide `build.sql` to create schema & indexes; provide seed data for week‑6 demo (?)
- provide fixtures for forced-failure cases (overbooking, past-date booking).

### Other Assumptions
- Schema supports multi-gym in future phases.
- AWS optional for prod; dev uses Docker Compose.

## 8. Success Metrics
- demoable booking with audit proof
- check rubric (?)
