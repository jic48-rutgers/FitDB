#!/usr/bin/env python3
# (WIP)
"""
FitDB Database Initialization Script

This script initializes the database connection and creates the FitDB database
if it doesn't already exist. It can read configuration from environment variables,
a .env file, or command-line arguments.

Usage:
    python init.py --host localhost --port 3306 --user root --password secret --database fitdb
    python init.py  # Uses .env file or environment variables
"""

import argparse
import sys
import os
from pathlib import Path

try:
    import mysql.connector
    from mysql.connector import Error
except ImportError:
    print("ERROR: mysql-connector-python is not installed.")
    print("Please run: pip install -r requirements.txt")
    sys.exit(1)

# Optional: support for .env files
try:
    from dotenv import load_dotenv
    load_dotenv()
    DOTENV_AVAILABLE = True
except ImportError:
    DOTENV_AVAILABLE = False


def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Initialize the FitDB database',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Using command-line arguments
  python init.py --host localhost --port 3306 --user root --password secret
  
  # Using .env file (requires python-dotenv)
  python init.py
  
Environment Variables:
  DB_HOST      - Database host (default: localhost)
  DB_PORT      - Database port (default: 3306)
  DB_USER      - Database user (default: root)
  DB_PASSWORD  - Database password (default: empty)
  DB_NAME      - Database name (default: fitdb)
        """
    )
    
    parser.add_argument(
        '--host',
        default=os.getenv('DB_HOST', 'localhost'),
        help='Database host (default: localhost or DB_HOST env var)'
    )
    parser.add_argument(
        '--port',
        type=int,
        default=int(os.getenv('DB_PORT', '3306')),
        help='Database port (default: 3306 or DB_PORT env var)'
    )
    parser.add_argument(
        '--user',
        default=os.getenv('DB_USER', 'root'),
        help='Database user (default: root or DB_USER env var)'
    )
    parser.add_argument(
        '--password',
        default=os.getenv('DB_PASSWORD', ''),
        help='Database password (default: empty or DB_PASSWORD env var)'
    )
    parser.add_argument(
        '--database',
        default=os.getenv('DB_NAME', 'fitdb'),
        help='Database name (default: fitdb or DB_NAME env var)'
    )
    parser.add_argument(
        '--verbose',
        action='store_true',
        help='Enable verbose output'
    )
    
    return parser.parse_args()


def test_connection(host, port, user, password, verbose=False):
    """Test the database connection without specifying a database."""
    if verbose:
        print(f"Testing connection to {user}@{host}:{port}...")
    
    try:
        connection = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=password
        )
        
        if connection.is_connected():
            db_info = connection.server_info
            if verbose:
                print(f"Successfully connected to MySQL Server version {db_info}")
            connection.close()
            return True
            
    except Error as e:
        print(f"ERROR: Failed to connect to MySQL Server")
        print(f"Details: {e}")
        return False


def create_database(host, port, user, password, database, verbose=False):
    """Create the database if it doesn't exist."""
    try:
        # Connect without specifying a database
        connection = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=password
        )
        
        cursor = connection.cursor()
        
        # Check if database exists
        cursor.execute(f"SHOW DATABASES LIKE '{database}'")
        result = cursor.fetchone()
        
        if result:
            if verbose:
                print(f"Database '{database}' already exists")
        else:
            # Create database with UTF-8 support
            if verbose:
                print(f"Creating database '{database}'...")
            
            create_db_query = f"""
            CREATE DATABASE `{database}` 
            CHARACTER SET utf8mb4 
            COLLATE utf8mb4_0900_ai_ci
            """
            cursor.execute(create_db_query)
            print(f"Database '{database}' created successfully")
        
        cursor.close()
        connection.close()
        return True
        
    except Error as e:
        print(f"ERROR: Failed to create database '{database}'")
        print(f"Details: {e}")
        return False


def verify_database(host, port, user, password, database, verbose=False):
    """Verify that the database exists and is accessible."""
    try:
        connection = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database=database
        )
        
        if connection.is_connected():
            if verbose:
                cursor = connection.cursor()
                cursor.execute("SELECT DATABASE()")
                current_db = cursor.fetchone()
                print(f"Successfully connected to database: {current_db[0]}")
                cursor.close()
            connection.close()
            return True
            
    except Error as e:
        print(f"ERROR: Failed to verify database '{database}'")
        print(f"Details: {e}")
        return False


def main():
    """Main execution function."""
    args = parse_arguments()
    
    print("=" * 50)
    print("FitDB Database Initialization")
    print("=" * 50)
    
    if args.verbose:
        print(f"\nConfiguration:")
        print(f"  Host:     {args.host}")
        print(f"  Port:     {args.port}")
        print(f"  User:     {args.user}")
        print(f"  Database: {args.database}")
        if not DOTENV_AVAILABLE:
            print(f"\n  Note: python-dotenv not installed. .env file support disabled.")
        print()
    
    # Step 1: Test connection
    if not test_connection(args.host, args.port, args.user, args.password, args.verbose):
        print("\nInitialization failed: Could not connect to MySQL server")
        sys.exit(1)
    
    # Step 2: Create database
    if not create_database(args.host, args.port, args.user, args.password, args.database, args.verbose):
        print("\nInitialization failed: Could not create database")
        sys.exit(1)
    
    # Step 3: Verify database
    if not verify_database(args.host, args.port, args.user, args.password, args.database, args.verbose):
        print("\nInitialization failed: Could not verify database")
        sys.exit(1)
    
    print("\n" + "=" * 50)
    print("✓ Database initialization completed successfully!")
    print("=" * 50)
    print(f"\nNext steps:")
    print(f"  1. Run 'make build' to create tables and schema")
    print(f"  2. Run 'make seed SEED_SIZE=<size>' to populate with data")
    print(f"  or run 'make full-setup SEED_SIZE=<size>' to do both")
    print()


if __name__ == "__main__":
    main()