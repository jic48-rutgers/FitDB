# FitDB (CS‑437 Project)

## What is this?
A Gym Membership Management System emphasizing database design: registrations, check-ins, plus-member class bookings, trainer availability (manager‑published sessions), equipment allocations, reporting, and auditing.

### Key Features
- **Role-Based Access Control (RBAC)** via MySQL roles with proper inheritance
- **Comprehensive Audit Trail** - All modifications are logged immutably
- **Business Rule Enforcement** - Triggers and constraints ensure data integrity
- **Denormalized Reporting Views** - Optimized queries for utilization and demand analytics
- **Transaction-Safe Operations** - ACID-compliant booking and session management

## MVP
- **Scope:** Single gym (expandable to many); core account and access card management
- **MVP Features:**
  -  **User Account Creation** - Users can create accounts (username, email, password)
  -  **Member Account Registration** - Front desk managers can create member accounts for users
  -  **Access Card Issuance** - Front desk managers can issue access cards to members
  -  **Audit Logging** - All operations logged immutably (append-only audit trail)
  -  **RBAC Infrastructure** - Role-based access control via MySQL roles (front desk manager role enabled)
- **MVP Roles Enabled:** `front_desk` (member registration, access card management)
- **MVP Out-of-scope:**
  - Session management (bookings, trainer availability, session publishing)
  - Check-in system
  - Equipment tracking
  - Reporting and analytics
  - Advanced member management (deactivation, strikes, bans)
  - Payroll, billing, comms (email/SMS)

> **Note:** While the database schema supports the full feature set, the MVP focuses exclusively on account creation and access card issuance. See [`docs/MVP_SCOPE.md`](./docs/MVP_SCOPE.md) for detailed MVP clarification. Future phases will add bookings, check-ins, equipment management, and reporting.

## Technology Stack
- **Backend:** Python + Flask
- **Database:** MySQL
- **Frontend:** HTML/CSS
- **Testing:** manual SQL testing
- **Build:** Make
- **Deployment:** Optional AWS

## Quick Start (WIP)

### Prerequisites
- Python
- MySQL

**Important:** MySQL must have `local_infile` enabled for bulk data loading. To enable it:

1. Add to your MySQL configuration file (`my.cnf` or `my.ini`):
   ```ini
   [mysqld]
   local_infile=1
   
   [mysql]
   local_infile=1
   ```

2. Or set it dynamically (requires SUPER privilege):
   ```sql
   SET GLOBAL local_infile = 1;
   ```

### Installation

1. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
   Or use the Makefile:
   ```bash
   make install-deps
   ```

2. **Configure database connection:**
   
   Using command-line arguments:
   ```bash
   make init DB_HOST=localhost DB_PORT=3306 DB_USER=root DB_PASSWORD=yourpassword
   ```
   
   Or using environment variables:
   ```bash
   export DB_HOST=localhost
   export DB_PORT=3306
   export DB_USER=root
   export DB_PASSWORD=yourpassword
   make init
   ```

3. **Build database schema:**
   ```bash
   make build
   ```

4. **Generate and load seed data:**
   ```bash
   make seed SEED_SIZE=tiny
   ```
   
   Available sizes:
   - `tiny`: 10 members (default, good for development)
   - `small`: 100 members
   - `medium`: 1000 members
   - `large`: 10000 members
   - `huge`: 100000 members

### Full Setup (One Command)
```bash
make full-setup SEED_SIZE=small DB_USER=root DB_PASSWORD=yourpassword
```

### Available Makefile Commands
```bash
make help              # Show all available commands
make init              # Initialize database connection and create database
make build             # Run build.sql to create tables, views, procedures, etc.
make seed              # Generate and load seed data
make clean             # Drop the database (WARNING: destroys all data)
make reset             # Clean and rebuild database (init + build)
make full-setup        # Complete setup: init + build + seed
make check-deps        # Check if required Python packages are installed
make install-deps      # Install Python dependencies
```

### Database Configuration

The database connection can be configured in two ways (in order of precedence):

1. **Command-line arguments** (highest priority):
   ```bash
   make init DB_HOST=localhost DB_PORT=3306 DB_USER=root DB_PASSWORD=secret
   ```

2. **Environment variables**:
   ```bash
   export DB_HOST=localhost
   export DB_PORT=3306
   export DB_USER=root
   export DB_PASSWORD=secret
   make init
   ```

> **Note:** `.env` file support will be added post-MVP

#### Database Accounts

The build script (`sql/build.sql`) automatically creates two database users:

- **`fitdb_admin`** (password: `change-me-admin`): Admin account with full privileges for development
- **`fitdb_app`** (password: `change-me`): Application account used by the Flask app to interface with the database

These accounts are defined in lines 11-16 of `sql/build.sql`. For production deployments, **change these default passwords**.

### Seed Data Sizes

The seed generator creates realistic MVP data using the Faker library (accounts and access cards only):

| Size   | Members | Staff (Front Desk + Admin) | Access Cards | Users (Total) |
|--------|---------|----------------------------|--------------|---------------|
| tiny   | 10      | 10 (5+5)                  | ~10          | 20            |
| small  | 100     | 10 (5+5)                  | ~80          | 110           |
| medium | 1,000   | 15 (10+5)                 | ~800         | 1,015         |
| large  | 10,000  | 30 (20+10)                | ~8,000       | 10,030        |
| huge   | 100,000 | 70 (50+20)                | ~80,000      | 100,070       |

**Note:** Post-MVP tables (equipment, sessions, bookings, check-ins) receive empty CSV files for schema compatibility. All counts are rounded to multiples of 5.

### Directory Structure
```
FitDB/
├── data/
│   ├── csvs/                # Generated CSV files (not committed)
│   └── generate_seed.py     # Seed data generator script
├── docs/                    # Documentation, ERDs, specs
├── scripts/
│   ├── init.py              # Database initialization and setup script
│   └── utils.py             # Utility Python scripts (e.g. load helpers)
├── sql/
│   ├── build.sql            # Main DB build script (tables, views, triggers)
│   ├── bulkcopy.sql         # CSV bulk loader and initial bulk inserts
│   └── helpers/             # SQL helper files and partial DDLs
├── Makefile                 # Build and automation recipes
├── requirements.txt         # Python dependency list
└── README.md                # Project overview and documentation index
```

## Midterm Demo

**Demonstrates all 11 required database concepts** through `sql/midterm_demo.sql`:
1. Database Objects, 2. Access Control, 3. Stored Procedures, 4. Views, 5. Query Performance (EXPLAIN),
6. Data Initialization, 7. Audit Strategy, 8. Cascading Deletes, 9. Transactions, 10. Constraints/Triggers, 11. Additional Elements

**Setup and Run:**
```bash
# Full setup with medium seed (1,000 members)
make full-setup SEED_SIZE=medium DB_USER=root DB_PASSWORD=yourpass

# Run demonstration (generates log for Canvas submission)
mysql -u root -p fitdb < sql/midterm_demo.sql > midterm_output.log 2>&1
```

**MySQL Workbench Alternative:**
- Connection: fitdb_admin@127.0.0.1:3306 (setup instructions in `sql/midterm_demo.sql` header)
- Export output: Query > Export Results > Export All Results to Single File

**Output:** `midterm_output.log` (or exported file from Workbench) contains all requirement demonstrations and evidence

## Implementation Status

### Completed 
- Database schema design (tables, views, procedures, triggers)
- Role-based access control (RBAC) implementation
- Audit logging system (triggers and audit tables)
- Comprehensive documentation (FRD, TDD, ERDs, Testing)

### In Progress 
- Seed data generation with configurable sizes
- Build automation via Makefile
- Index optimization for performance
- Business rule enforcement via constraints and triggers

### Future Features
- Flask application development
- Front-end templates and interfaces
- Integration testing automation
- API endpoint implementation
- Web application UI deployment
- Performance benchmarking at scale
- Multi-gym configuration UI

## Docs
- [`MVP_SCOPE.md`](./docs/MVP_SCOPE.md) – MVP scope clarification: what's included vs future features
- [`contributors.md`](./docs/contributors.md) – people, roles, responsibilities, and collaboration guidelines
- [`architecture.md`](./docs/architecture.md) – overview, context, components, deployment, data flows, security summary
- [`FRD.md`](./docs/FRD.md) – scope, requirements, stakeholders, use cases, business rules, and acceptance criteria
- [`TDD.md`](./docs/TDD.md) - technical design, data model, APIs, entitlements, interface design, security, scalability
- [`ERDs.md`](./docs/ERDs.md) - entity relationship diagrams with normalization notes and notation legend