# Project Contributors & Collaboration

## 1. Document Control
- **Version:**  2.1
- **Author:**  Henry Huerta
- **Date:**  2025-11-3
- **Reviewers:**  Prof. Arnold Lau, T.A. Sneh Bhandari

Welcome to FitDB (CS-437). This document outlines who's involved, what the project is about, and how we'll collaborate. It reflects the current scope in the docs folder.

---

## 2. Contributors

| Name            | GitHub Handle   | Role(s)                                                | Email / Contact        |
|-----------------|-----------------|--------------------------------------------------------|------------------------|
| Henry    | @hah97      | Project Leader · Full Stack Developer       | tbd            |
| Jared    | @jic48      | Project Leader · Full Stack Developer       | tbd            |
| Prof. Lou       | @tbd               | Course Instructor                         | tbd                      |
| You            | [GitHub ID]| Contributor                                            | [Your Contact Info]    |

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

- Core gym membership management (user registration, member activation/deactivation, check-ins) and access control (RBAC at app and DB levels, audit logging)
- Class session booking, scheduling, capacity/conflict handling, and equipment allocation (with reporting views and inventory modeling)
- Flask + MySQL implementation; future extensibility for AWS deployment and advanced features
