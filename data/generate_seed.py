#!/usr/bin/env python3
# (WIP)
"""
FitDB Seed Data Generator

Generates realistic seed data for the FitDB database using the Faker library.
Outputs CSV files that can be loaded using bulkcopy.sql.

Usage:
    python generate_seed.py --size tiny --output ./csvs
    python generate_seed.py --size medium --output ./csvs

Sizes:
    tiny:   10 members (for 1 gym)
    small:  100 members (for 1 gym)
    medium: 1000 members (for 1 gym)
    large:  10000 members (for 1 gym)
    huge:   100000 members (for 1 gym)
"""

import argparse
import csv
import random
import sys
from datetime import datetime, timedelta, date
from pathlib import Path

try:
    from faker import Faker
except ImportError:
    print("ERROR: faker is not installed.")
    print("Please run: pip install -r requirements.txt")
    sys.exit(1)

# Initialize Faker
fake = Faker()
# Seed value: 437 (CS-437 course number) for reproducibility
SEED = 437
Faker.seed(SEED)
random.seed(SEED)

# Get the directory where this script is located
SCRIPT_DIR = Path(__file__).parent
BANKS_DIR = SCRIPT_DIR / 'banks'

# Size configurations (MVP-focused: accounts and access cards only)
# All counts are multiples of 5 for clean data
SIZE_CONFIG = {
    'tiny': {
        'members': 10,
        'gyms': 1,
        'front_desk_staff': 5,
        'admin_staff': 5,
        'access_cards_pct': 0.80  # 80% of members have cards
    },
    'small': {
        'members': 100,
        'gyms': 1,
        'front_desk_staff': 5,
        'admin_staff': 5,
        'access_cards_pct': 0.80
    },
    'medium': {
        'members': 1000,
        'gyms': 1,
        'front_desk_staff': 10,
        'admin_staff': 5,
        'access_cards_pct': 0.80
    },
    'large': {
        'members': 10000,
        'gyms': 1,
        'front_desk_staff': 20,
        'admin_staff': 10,
        'access_cards_pct': 0.80
    },
    'huge': {
        'members': 100000,
        'gyms': 1,
        'front_desk_staff': 50,
        'admin_staff': 20,
        'access_cards_pct': 0.80
    }
}

def load_bank_data(filename):
    """Load reference data from CSV files in the banks directory."""
    filepath = BANKS_DIR / filename
    data = []
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Convert dict to tuple of values (preserving order)
            data.append(tuple(row.values()))
    return data


# Load reference data from bank CSV files
EQUIPMENT_KINDS = load_bank_data('equipment_kinds.csv')
SESSION_TITLES = load_bank_data('session_titles.csv')


class SeedDataGenerator:
    """Generates seed data for FitDB database."""
    
    def __init__(self, size: str, output_dir: Path):
        self.size = size
        self.config = SIZE_CONFIG[size]
        self.output_dir = output_dir
        
        # ID counters
        self.user_id = 1
        self.staff_id = 1
        self.member_id = 1
        self.trainer_id = 1
        self.manager_id = 1
        self.floor_manager_id = 1
        self.front_desk_id = 1
        self.admin_id = 1
        self.super_admin_id = 1
        self.gym_id = 1
        self.equip_kind_id = 1
        self.equipment_item_id = 1
        self.inventory_count_id = 1
        self.service_log_id = 1
        self.class_session_id = 1
        self.trainer_avail_date_id = 1
        self.session_trainer_id = 1
        self.session_equip_reservation_id = 1
        self.membership_plan_id = 1
        self.booking_id = 1
        self.access_card_id = 1
        self.check_in_id = 1
        
        # Status IDs (matching the indicator tables)
        self.account_status = {'ACTIVE': 1, 'INACTIVE': 2, 'LOCKED': 3, 'SUSPENDED': 4, 'CANCELED': 5}
        self.gym_status = {'ACTIVE': 1, 'INACTIVE': 2}
        self.equipment_status = {'OK': 1, 'NEEDS_SERVICE': 2, 'OUT_OF_ORDER': 3, 'RETIRED': 4}
        self.session_status = {'SCHEDULED': 1, 'CANCELED': 2, 'COMPLETED': 3}
        self.availability_status = {'AVAILABLE': 1, 'UNAVAILABLE': 2}
        self.plan_status = {'ACTIVE': 1, 'RETIRED': 2}
        self.access_card_status = {'ACTIVE': 1, 'LOST': 2, 'REVOKED': 3}
        self.booking_status = {'CONFIRMED': 1, 'CANCELED_MEMBER': 2, 'CANCELED_SYSTEM': 3}
        
        # Data storage
        self.data = {}
        
    def generate_all(self):
        """Generate MVP seed data (accounts and access cards only)."""
        print(f"Generating {self.size} MVP seed data...")
        print(f"Configuration: {self.config}")
        
        # Ensure output directory exists
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate MVP data in order (respecting foreign keys)
        print("\n1. Generating gyms...")
        self.generate_gyms()
        
        print("2. Generating membership plans...")
        self.generate_membership_plans()
        
        print("3. Generating users (members)...")
        self.generate_member_users()
        
        print("4. Generating users (staff - front desk & admin only)...")
        self.generate_staff_users()
        
        print("5. Generating access cards...")
        self.generate_access_cards()
        
        # Write all CSVs (including empty ones for post-MVP tables)
        print("\n6. Writing CSV files...")
        self.write_all_csvs()
        
        print("\nSeed data generation complete!")
        self.print_summary()
    
    def generate_gyms(self):
        """Generate gym data."""
        self.data['gym'] = []
        
        for i in range(self.config['gyms']):
            address = fake.address().replace('\n', ', ')
            self.data['gym'].append({
                'id': self.gym_id,
                'name': fake.company() + ' Fitness',
                'address': address,
                'status_id': self.gym_status['ACTIVE'],
                'created_at': self.format_datetime(fake.date_time_between(start_date='-2y', end_date='-1y')),
                'updated_at': self.format_datetime(datetime.now())
            })
            self.gym_id += 1
    
    def generate_membership_plans(self):
        """Generate membership plan data."""
        self.data['membership_plan'] = []
        
        plans = [
            ('Trial - 7 Days', 'trial', 'monthly', 0.00),
            ('Basic Monthly', 'basic', 'monthly', 29.99),
            ('Basic Annual', 'basic', 'annual', 299.99),
            ('Plus Monthly', 'plus', 'monthly', 49.99),
            ('Plus Annual', 'plus', 'annual', 499.99),
        ]
        
        for name, tier, cycle, price in plans:
            self.data['membership_plan'].append({
                'id': self.membership_plan_id,
                'name': name,
                'tier': tier,
                'billing_cycle': cycle,
                'price': price,
                'status_id': self.plan_status['ACTIVE'],
                'created_at': self.format_datetime(fake.date_time_between(start_date='-2y', end_date='-1y')),
                'updated_at': self.format_datetime(datetime.now())
            })
            self.membership_plan_id += 1
    
    def generate_equipment_kinds(self):
        """Post-MVP: Equipment kinds."""
        self.data['equip_kind'] = []
    
    def generate_member_users(self):
        """Generate member users and associated member records."""
        self.data['user'] = []
        self.data['member'] = []
        
        num_members = self.config['members']
        
        for i in range(num_members):
            # Generate user
            first_name = fake.first_name()
            last_name = fake.last_name()
            username = f"{first_name.lower()}.{last_name.lower()}{random.randint(1, 999)}"
            
            user = {
                'id': self.user_id,
                'username': username,
                'email': f"{username}@{fake.free_email_domain()}",
                'password_hash': fake.sha256(),
                'password_algo': 'argon2id',
                'password_updated_at': self.format_datetime(fake.date_time_between(start_date='-1y', end_date='now')),
                'last_login_at': self.format_datetime(fake.date_time_between(start_date='-30d', end_date='now')) if random.random() > 0.2 else '',
                'profile_photo_path': f"/avatars/{username}.jpg" if random.random() > 0.5 else '',
                'status_id': random.choices(
                    list(self.account_status.values()),
                    weights=[85, 5, 2, 5, 3],
                    k=1
                )[0],
                'created_at': self.format_datetime(fake.date_time_between(start_date='-2y', end_date='-30d')),
                'updated_at': self.format_datetime(datetime.now())
            }
            self.data['user'].append(user)
            
            # Generate member
            # Plan distribution: trial 10%, basic 60%, plus 30%
            plan_id = random.choices(
                range(1, self.membership_plan_id),
                weights=[10, 30, 30, 15, 15],
                k=1
            )[0]
            
            joined_date = fake.date_between(start_date='-2y', end_date='-7d')
            is_trial = plan_id == 1  # Trial plan
            
            member = {
                'id': self.member_id,
                'user_id': self.user_id,
                'membership_plan_id': plan_id,
                'home_gym_id': random.randint(1, self.gym_id - 1),  # all members have a home gym
                'joined_on': joined_date.isoformat(),
                'trial_expires_on': (joined_date + timedelta(days=7)).isoformat() if is_trial else '',
                'status_id': user['status_id'],
                'created_at': user['created_at'],
                'updated_at': user['updated_at']
            }
            self.data['member'].append(member)
            
            self.user_id += 1
            self.member_id += 1
    
    def generate_staff_users(self):
        """Generate staff users (MVP: front desk and admin only)."""
        self.data['staff'] = []
        self.data['trainer'] = []
        self.data['manager'] = []
        self.data['floor_manager'] = []
        self.data['front_desk'] = []
        self.data['admin'] = []
        self.data['super_admin'] = []
        
        num_front_desk = self.config['front_desk_staff']
        num_admin = self.config['admin_staff']
        
        # Generate super admin first
        user = {
            'id': self.user_id,
            'username': 'admin.super',
            'email': 'admin.super@fitdb.com',
            'password_hash': fake.sha256(),
            'password_algo': 'argon2id',
            'password_updated_at': self.format_datetime(fake.date_time_between(start_date='-1y', end_date='now')),
            'last_login_at': self.format_datetime(fake.date_time_between(start_date='-7d', end_date='now')),
            'profile_photo_path': '',
            'status_id': self.account_status['ACTIVE'],
            'created_at': self.format_datetime(fake.date_time_between(start_date='-3y', end_date='-2y')),
            'updated_at': self.format_datetime(datetime.now())
        }
        self.data['user'].append(user)
        
        self.data['super_admin'].append({
            'id': self.super_admin_id,
            'user_id': self.user_id,
            'scope': 'global',
            'created_at': user['created_at'],
            'updated_at': user['updated_at']
        })
        
        self.user_id += 1
        self.super_admin_id += 1
        
        # Generate front desk staff
        for i in range(num_front_desk):
            first_name = fake.first_name()
            last_name = fake.last_name()
            username = f"{first_name.lower()}.{last_name.lower()}.frontdesk"
            
            user = {
                'id': self.user_id,
                'username': username,
                'email': f"{username}@fitdb.com",
                'password_hash': fake.sha256(),
                'password_algo': 'argon2id',
                'password_updated_at': self.format_datetime(fake.date_time_between(start_date='-1y', end_date='now')),
                'last_login_at': self.format_datetime(fake.date_time_between(start_date='-7d', end_date='now')),
                'profile_photo_path': '',
                'status_id': self.account_status['ACTIVE'],
                'created_at': self.format_datetime(fake.date_time_between(start_date='-2y', end_date='-6m')),
                'updated_at': self.format_datetime(datetime.now())
            }
            self.data['user'].append(user)
            
            staff = {
                'id': self.staff_id,
                'user_id': self.user_id,
                'gym_id': 1,
                'status_id': self.account_status['ACTIVE'],
                'notes': '',
                'created_at': user['created_at'],
                'updated_at': user['updated_at']
            }
            self.data['staff'].append(staff)
            
            self.data['front_desk'].append({
                'id': self.front_desk_id,
                'staff_id': self.staff_id,
                'capabilities': 'check_in,register',
                'created_at': staff['created_at'],
                'updated_at': staff['updated_at']
            })
            
            self.user_id += 1
            self.staff_id += 1
            self.front_desk_id += 1
        
        # Generate admin staff
        for i in range(num_admin):
            first_name = fake.first_name()
            last_name = fake.last_name()
            username = f"{first_name.lower()}.{last_name.lower()}.admin"
            
            user = {
                'id': self.user_id,
                'username': username,
                'email': f"{username}@fitdb.com",
                'password_hash': fake.sha256(),
                'password_algo': 'argon2id',
                'password_updated_at': self.format_datetime(fake.date_time_between(start_date='-1y', end_date='now')),
                'last_login_at': self.format_datetime(fake.date_time_between(start_date='-7d', end_date='now')),
                'profile_photo_path': '',
                'status_id': self.account_status['ACTIVE'],
                'created_at': self.format_datetime(fake.date_time_between(start_date='-2y', end_date='-6m')),
                'updated_at': self.format_datetime(datetime.now())
            }
            self.data['user'].append(user)
            
            staff = {
                'id': self.staff_id,
                'user_id': self.user_id,
                'gym_id': 1,
                'status_id': self.account_status['ACTIVE'],
                'notes': '',
                'created_at': user['created_at'],
                'updated_at': user['updated_at']
            }
            self.data['staff'].append(staff)
            
            self.data['admin'].append({
                'id': self.admin_id,
                'staff_id': self.staff_id,
                'scope': 'gym',
                'created_at': staff['created_at'],
                'updated_at': staff['updated_at']
            })
            
            self.user_id += 1
            self.staff_id += 1
            self.admin_id += 1
    
    # Post-MVP: Equipment, sessions, bookings, check-ins (stubbed for schema compatibility)
    def generate_equipment_items(self):
        """Post-MVP: Equipment items."""
        self.data['equipment_item'] = []
    
    def generate_inventory_counts(self):
        """Post-MVP: Inventory counts."""
        self.data['inventory_count'] = []
    
    def generate_service_logs(self):
        """Post-MVP: Service logs."""
        self.data['service_log'] = []
    
    def generate_class_sessions(self):
        """Post-MVP: Class sessions."""
        self.data['class_session'] = []
    
    def generate_trainer_availability(self):
        """Post-MVP: Trainer availability."""
        self.data['trainer_avail_date'] = []
    
    def generate_session_trainers(self):
        """Post-MVP: Session trainer assignments."""
        self.data['session_trainer'] = []
    
    def generate_session_equip_reservations(self):
        """Post-MVP: Session equipment reservations."""
        self.data['session_equip_reservation'] = []
    
    def generate_bookings(self):
        """Post-MVP: Bookings."""
        self.data['booking'] = []
    
    def generate_access_cards(self):
        """Generate access card data (MVP feature)."""
        self.data['access_card'] = []
        
        # Calculate target: round to nearest 5
        target_cards = int(len(self.data['member']) * self.config['access_cards_pct'])
        target_cards = round(target_cards / 5) * 5  # Round to nearest 5
        
        # Get active members
        active_members = [m for m in self.data['member'] 
                         if m['status_id'] == self.account_status['ACTIVE']]
        
        # Select members for cards
        members_to_issue = random.sample(active_members, min(target_cards, len(active_members)))
        
        for member in members_to_issue:
            gym_id = member['home_gym_id']
            
            # Parse created_at properly (it's already formatted)
            created_str = member['created_at']
            if '.' in created_str:
                # Has microseconds
                created_dt = datetime.strptime(created_str, '%Y-%m-%d %H:%M:%S.%f')
            else:
                created_dt = datetime.strptime(created_str, '%Y-%m-%d %H:%M:%S')
            
            issued_at = created_dt + timedelta(days=random.randint(0, 7))
            
            # All active for MVP (simplify)
            status_id = self.access_card_status['ACTIVE']
            revoked_at = ''
            
            self.data['access_card'].append({
                'id': self.access_card_id,
                'member_id': member['id'],
                'gym_id': gym_id,
                'card_uid': fake.uuid4(),
                'status_id': status_id,
                'issued_at': self.format_datetime(issued_at),
                'revoked_at': revoked_at,
                'created_at': self.format_datetime(issued_at),
                'updated_at': self.format_datetime(datetime.now())
            })
            self.access_card_id += 1
    
    def generate_check_ins(self):
        """Post-MVP: Check-ins."""
        self.data['check_in'] = []
    
    def write_all_csvs(self):
        """Write all data to CSV files (including empty ones for post-MVP tables)."""
        # Define tables and their fields
        tables = {
            'user': ['id', 'username', 'email', 'password_hash', 'password_algo', 'password_updated_at', 
                    'last_login_at', 'profile_photo_path', 'status_id', 'created_at', 'updated_at'],
            'staff': ['id', 'user_id', 'gym_id', 'status_id', 'notes', 'created_at', 'updated_at'],
            'trainer': ['id', 'staff_id', 'certification', 'bio', 'created_at', 'updated_at'],
            'manager': ['id', 'staff_id', 'scope', 'created_at', 'updated_at'],
            'floor_manager': ['id', 'staff_id', 'scope', 'created_at', 'updated_at'],
            'front_desk': ['id', 'staff_id', 'capabilities', 'created_at', 'updated_at'],
            'admin': ['id', 'staff_id', 'scope', 'created_at', 'updated_at'],
            'super_admin': ['id', 'user_id', 'scope', 'created_at', 'updated_at'],
            'gym': ['id', 'name', 'address', 'status_id', 'created_at', 'updated_at'],
            'equip_kind': ['id', 'name', 'mode', 'created_at', 'updated_at'],
            'equipment_item': ['id', 'gym_id', 'equip_kind_id', 'status_id', 'serial_no', 'uses_count',
                             'rated_uses', 'last_serviced_at', 'last_cleaned_at', 'cleaning_interval_uses',
                             'cleaning_interval_days', 'next_clean_due_at', 'service_required',
                             'cleaning_required', 'created_at', 'updated_at'],
            'inventory_count': ['id', 'gym_id', 'equip_kind_id', 'qty_on_floor', 'qty_in_storage',
                              'reorder_needed', 'updated_snapshot_at', 'created_at', 'updated_at'],
            'service_log': ['id', 'equipment_item_id', 'serviced_at', 'action', 'notes', 'staff_id',
                          'created_at', 'updated_at'],
            'class_session': ['id', 'gym_id', 'title', 'description', 'starts_at', 'ends_at', 'capacity',
                            'max_trainers', 'open_for_booking', 'status_id', 'created_at', 'updated_at'],
            'trainer_avail_date': ['id', 'trainer_id', 'gym_id', 'for_date', 'period', 'status_id',
                                  'created_at', 'updated_at'],
            'session_trainer': ['id', 'session_id', 'trainer_id', 'role', 'assigned_at', 'created_at', 'updated_at'],
            'session_equip_reservation': ['id', 'session_id', 'equip_kind_id', 'quantity', 'created_at', 'updated_at'],
            'membership_plan': ['id', 'name', 'tier', 'billing_cycle', 'price', 'status_id', 'created_at', 'updated_at'],
            'member': ['id', 'user_id', 'membership_plan_id', 'home_gym_id', 'joined_on', 'trial_expires_on',
                      'status_id', 'created_at', 'updated_at'],
            'booking': ['id', 'session_id', 'member_id', 'status_id', 'booked_at', 'cancellation_reason',
                       'notes', 'created_at', 'updated_at'],
            'access_card': ['id', 'member_id', 'gym_id', 'card_uid', 'status_id', 'issued_at', 'revoked_at',
                          'created_at', 'updated_at'],
            'check_in': ['id', 'member_id', 'gym_id', 'access_card_id', 'checked_in_at', 'method',
                        'created_at', 'updated_at']
        }
        
        for table_name, fields in tables.items():
            # Ensure data key exists (empty list if not populated)
            if table_name not in self.data:
                self.data[table_name] = []
            
            csv_path = self.output_dir / f"{table_name}.csv"
            
            with open(csv_path, 'w', newline='', encoding='utf-8') as f:
                writer = csv.DictWriter(f, fieldnames=fields, extrasaction='ignore')
                # Don't write header - bulkcopy will handle structure
                writer.writerows(self.data[table_name])
            
            print(f"  {table_name}.csv ({len(self.data[table_name])} rows)")
    
    def format_datetime(self, dt):
        """Format datetime for MySQL."""
        if isinstance(dt, datetime):
            return dt.strftime('%Y-%m-%d %H:%M:%S.%f')
        elif isinstance(dt, date):
            return dt.isoformat()
        return dt
    
    def print_summary(self):
        """Print summary of generated MVP data."""
        print("\n" + "=" * 50)
        print("MVP Data Generation Summary")
        print("=" * 50)
        print(f"Size: {self.size}")
        print(f"Gyms: {len(self.data.get('gym', []))}")
        print(f"Users: {len(self.data.get('user', []))}")
        print(f"Members: {len(self.data.get('member', []))}")
        print(f"Staff: {len(self.data.get('staff', []))}")
        print(f"  - Front Desk: {len(self.data.get('front_desk', []))}")
        print(f"  - Admins: {len(self.data.get('admin', []))}")
        print(f"  - Super Admins: {len(self.data.get('super_admin', []))}")
        print(f"Membership Plans: {len(self.data.get('membership_plan', []))}")
        print(f"Access Cards: {len(self.data.get('access_card', []))}")
        print(f"\nPost-MVP tables (empty CSVs): Equipment, Sessions, Bookings, Check-ins")
        print("=" * 50)


def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Generate seed data for FitDB database',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Sizes:
  tiny:   10 members (for 1 gym)
  small:  100 members (for 1 gym)
  medium: 1000 members (for 1 gym)
  large:  10000 members (for 1 gym)
  huge:   100000 members (for 1 gym)

Examples:
  python generate_seed.py --size tiny --output ./csvs
  python generate_seed.py --size medium --output ./csvs
        """
    )
    
    parser.add_argument(
        '--size',
        choices=['tiny', 'small', 'medium', 'large', 'huge'],
        default='tiny',
        help='Size of seed data to generate (default: tiny)'
    )
    parser.add_argument(
        '--output',
        type=Path,
        default=Path('./csvs'),
        help='Output directory for CSV files (default: ./csvs)'
    )
    
    return parser.parse_args()


def main():
    """Main execution function."""
    args = parse_arguments()
    
    print("=" * 50)
    print("FitDB Seed Data Generator")
    print("=" * 50)
    print(f"Size: {args.size}")
    print(f"Output: {args.output}")
    print()
    
    generator = SeedDataGenerator(args.size, args.output)
    generator.generate_all()
    
    print("\nCSV files generated successfully!")
    print(f"Next step: Run 'make seed' or load with bulkcopy.sql")


if __name__ == "__main__":
    main()