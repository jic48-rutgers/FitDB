# MVP Scope Clarification

## Document Control
- **Version:** 1.0
- **Author:** Henry Huerta
- **Date:** 2025-10-29
- **Reviewers:** Prof. Arnold Lau, T.A. Sneh Bhandari

## Overview

This document clarifies what features are included in the **Minimum Viable Product (MVP)** versus what will be implemented in future phases. While the database schema and documentation support the full feature set, the MVP focuses on core account and access card management functionality.

## MVP Features (Current Phase)

### Account Management
- **User Account Creation**: Users can create accounts (username, email, password)
- **Front Desk Manager Member Registration**: Front desk managers can create member accounts for new users
- **Access Card Issuance**: Front desk managers can issue access cards to members

### Core Data Model
- Database schema is complete and supports all planned features
- Tables for users, members, access cards, and related entities are fully implemented
- Audit logging system is in place for all operations

### Role-Based Access Control
- RBAC infrastructure is implemented via MySQL roles
- Front desk manager role (`r_front_desk`) has permissions to:
  - Create member accounts
  - Issue access cards
  - View member information

## Out of Scope for MVP (Future Phases)

### Session Management
- Trainer availability entry
- Session publishing by managers
- Class session creation

### Booking System
- Session bookings by plus members
- Booking cancellations
- Capacity management for sessions

### Check-In System
- Member check-ins at gym locations
- Check-in validation and logging

### Equipment Management
- Equipment inventory tracking
- Equipment status management
- Service logging

### Reporting & Analytics
- Utilization reports
- Equipment demand reports
- Member analytics

### Advanced Member Management
- Member deactivation
- Member strikes/bans
- Membership plan changes

## MVP Use Cases

### UC-MVP-1: User Account Creation
**Actor:** End User  
**Precondition:** User account does not exist  
**Flow:**
1. User navigates to account creation page
2. User enters username, email, and password
3. System creates USER record with encrypted password
4. System writes audit log entry
**Postcondition:** User account exists and is ready for member registration  
**Exceptions:** Username/email already exists

### UC-MVP-2: Member Account Creation by Front Desk Manager
**Actor:** Front Desk Manager  
**Precondition:** User account exists (created via UC-MVP-1)  
**Flow:**
1. Front desk manager navigates to member registration page
2. Front desk manager enters user ID or username
3. Front desk manager selects membership plan
4. Front desk manager enters home gym and other member details
5. System creates MEMBER record linked to USER and membership plan
6. System assigns appropriate role to user
7. System writes audit log entry
**Postcondition:** Member account is created and ready for access card issuance  
**Exceptions:** User already has a member account, invalid membership plan

### UC-MVP-3: Access Card Issuance
**Actor:** Front Desk Manager  
**Precondition:** Member account exists (created via UC-MVP-2)  
**Flow:**
1. Front desk manager navigates to access card management
2. Front desk manager selects member (by ID or username)
3. Front desk manager enters card UID (unique identifier)
4. Front desk manager selects gym where card is issued
5. System creates ACCESS_CARD record linked to member and gym
6. System sets card status to "active"
7. System writes audit log entry
**Postcondition:** Member has an active access card for gym access  
**Exceptions:** Card UID already exists, member already has active card for that gym

## MVP Data Model

The MVP uses the following core tables:
- `USER` - User accounts (username, email, password)
- `MEMBER` - Member accounts linked to users
- `ACCESS_CARD` - Access cards issued to members
- `MEMBERSHIP_PLAN` - Available membership plans
- `GYM` - Gym locations
- All related status indicator tables
- All audit tables (`USER_AUD`, `MEMBER_AUD`, `ACCESS_CARD_AUD`)

## MVP Interfaces

### User Interface
- **Account Creation Page**: Simple form for username, email, password
- **Member Registration Page** (Front Desk Manager only): Form to create member account from existing user
- **Access Card Issuance Page** (Front Desk Manager only): Form to issue access cards to members

### API Endpoints (Post-MVP)
- `POST /api/auth/register` - User account creation
- `POST /api/front-desk/members` - Create member account (front desk only)
- `POST /api/front-desk/access-cards` - Issue access card (front desk only)
- `GET /api/auth/login` - User authentication

## MVP Success Criteria

1. Users can create accounts successfully
2. Front desk managers can create member accounts for users
3. Front desk managers can issue access cards to members
4. All operations are audited in audit tables
5. RBAC prevents unauthorized access to front desk functions
6. Database constraints enforce data integrity

## Future Phase Roadmap

After MVP completion, features will be added in phases:

### Phase 2: Check-In System
- Member check-ins at gym locations
- Check-in validation based on membership status
- Gym restriction enforcement (trial/basic vs plus members)

### Phase 3: Booking System
- Trainer availability management
- Session publishing by managers
- Plus member session bookings
- Booking capacity management

### Phase 4: Equipment & Reporting
- Equipment inventory management
- Service logging
- Utilization and demand reporting
- Analytics dashboards