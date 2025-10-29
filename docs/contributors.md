# Project Contributors & Collaboration

## 1. Document Control
- **Version:**  2.0
- **Author:**  Henry Huerta
- **Date:**  2025-10-29
- **Reviewers:**  Prof. Arnold Lau, T.A. Sneh Bhandari

Welcome to FitDB (CS-437). This document outlines who's involved, what the project is about, and how we'll collaborate. It reflects the current scope in the docs folder.

---

## 2. Contributors

| Name            | GitHub Handle   | Role(s)                                                | Email / Contact        |
|-----------------|-----------------|--------------------------------------------------------|------------------------|
| Henry    | @hah97      | Project Leader · Full Stack Developer       | tbd            |
| Prof. Lou       | @tbd               | Course Instructor                         | tbd                      |
| You            | [Your GitHub ID]| Contributor                                            | [Your Contact Info]    |

---

## 3. Roles & Responsibilities

- **Project Lead** – Own project direction, architecture choices, and major deliverables
- **Developers (Back-end)** – Implement Flask endpoints, enforce MySQL roles; add audit logging; maintain denormalized reporting views.
- **Developers (Front-end)** – Build Flask pages (member/plus booking, trainer availability, manager publishing & equipment dashboard); add validation and basic error handling.
- **Data/DB Specialists** – Create/Maintain indexes, triggers, and views (utilization, equipment demand)
- **Testers/QA** – Create test data to test for booking capacity, session publishing, verify audit immutability, overall performance, etc.
- **Documentation** – Keep [`README.md`](../README.md), [`architecture.md`](./architecture.md), [`FRD.md`](./FRD.md), and [`TDD.md`](./TDD.md) accurate

---

## 4. Topics of Interest

This project explores or relies on the following areas (see `docs` folder for context):

- Gym membership lifecycle (registration, activation/deactivation, check-ins)
- Role-based access control (member, plus_member, trainer, manager, admin) at app and DB layers
- Class sessions, booking capacity guards, and conflict checks
- Trainer availability (planned) and manager-driven session publication
- Issuing strikes and bans to members (as manager or trainer)
- Equipment inventory and per-session allocation modeling
- Audit logging (append-only) and security controls
- Denormalized reporting views (class utilization, equipment demand)
- Flask + MySQL implementation details - optional AWS deployment
