# FitDB: Functional Requirements Document (FRD)

## 1. Document Control
- **Version:**  1.0
- **Author:**  Jared Cordova, Henry Huerta
- **Date:**  09/11/25
- **Reviewers:**  Prof. Arnold Lau, T.A. Sneh Bhandari

## 2. Purpose
FitDB is a reliable, central system that supports the day-to-day functions of large, multiple-location gym chains. These functions include registering new members, tracking membership details, booking fitness class sessions, viewing trainer availability, member analytics for decision-making, and member check-ins.

## 3. Scope
- **In-Scope:**  
  - Register new members
  - Maintain membership details
  - Support detailed member analytics
  - Book training sessions with personal trainers
  - Maintain trainer availability
  - Member verification at Check-In
- **Out-of-Scope:**
  - Employee Payroll Information
  - Equipment Inventory Management


## 4. Stakeholders
- Gym Owners
- Managerial Staff
- Front Desk Staff
- Personal Trainers
- Gym Members (Non-active, Basic, Plus)

## 5. Functional Requirements
- **FR-1: Register new members**
  - Description: Managerial and front desk staff can add a new member to the database, including identifying details and membership tier
  - Acceptance Criteria: New member entry is created with all details saved and no missing fields
- **FR-2: Create new class session**
  - Description: Managerial, front desk, trainers, and members (plus tier only) can book class sessions based on trainer availability.
  - Acceptance Criteria: New training session is booked which does not overlap with other sessions.
- **FR-3: Perform member analytics**
  - Description: Managers and Owners can view reports on membership activity, new sign-ups, and the popularity of classes/trainers to inform decision-making.
  - Acceptance Criteria: a human-readable graph is generated and presented based on data present in the database.  
- **FR-4: Verify members at check-in**
  - Description: Front Desk staff can retrieve and view membership details and photos to verify that an active member with matching identity is attempting to enter the gym.
  - Acceptance Criteria: Upon request, Front Desk staff is presented with an active (or inactive) membership status and the member's photo is shown on screen.


## 6. Non-Functional Requirements
- **Performance:**  
  - Load trainer availability in < 3s
  - Retrieve member data in < 3s
- **Security:**  
  - Enforce role-based access
  - Maintain append-only audit log 
- **Scalability:**
  - Must handle up to 1,000 concurrent users while maintaining transactional integrity
- **Usability:**  
  - Users will retrieve and add data through a GUI including calendars, text-based entry, and clickable items.

## 7. Assumptions & Dependencies
[List assumptions and dependencies]

## 8. Success Metrics
[List measurable KPIs]
