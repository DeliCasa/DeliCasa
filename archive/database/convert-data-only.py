#!/usr/bin/env python3
"""
Convert SQLite export to PostgreSQL data-only format (no table creation)
Handles timestamp conversion from integers to PostgreSQL timestamps
"""

import re
import sys
import argparse
from datetime import datetime

def unix_timestamp_to_postgres(match):
    """Convert Unix timestamp to PostgreSQL timestamp"""
    timestamp = match.group(1)
    try:
        # Convert Unix timestamp (seconds or milliseconds) to PostgreSQL format
        timestamp_int = int(timestamp)
        if timestamp_int > 1e10:  # Likely milliseconds
            timestamp_int = timestamp_int // 1000
        
        dt = datetime.fromtimestamp(timestamp_int)
        return f"'{dt.strftime('%Y-%m-%d %H:%M:%S')}'"
    except (ValueError, OSError):
        return f"'{timestamp}'"

def convert_sqlite_data_to_postgres(input_file, output_file):
    """Convert SQLite SQL dump to PostgreSQL data-only format"""
    
    with open(input_file, 'r') as f:
        content = f.read()
    
    # Remove everything except INSERT statements
    lines = content.split('\n')
    insert_lines = [line for line in lines if line.strip().startswith('INSERT INTO')]
    
    if not insert_lines:
        print("No INSERT statements found in input file")
        return
    
    content = '\n'.join(insert_lines)
    
    # Fix table names with double quotes
    content = re.sub(r'INSERT INTO ([^"\s(]+)', r'INSERT INTO "\1"', content)
    
    # Convert Unix timestamps to PostgreSQL timestamps
    # This matches integer values that look like timestamps (10+ digits)
    content = re.sub(r'\b(1[0-9]{9,12})\b', unix_timestamp_to_postgres, content)
    
    # Convert boolean values (0/1 to FALSE/TRUE)
    # Be careful not to convert other numbers that happen to be 0 or 1
    content = re.sub(r',0,', ',FALSE,', content)
    content = re.sub(r',1,', ',TRUE,', content)
    content = re.sub(r'\(0,', '(FALSE,', content)
    content = re.sub(r'\(1,', '(TRUE,', content)
    content = re.sub(r',0\)', ',FALSE)', content)
    content = re.sub(r',1\)', ',TRUE)', content)
    
    # Handle NULL values
    content = re.sub(r'VALUES\(NULL,', 'VALUES(DEFAULT,', content)
    
    # Clean up foreign key references (remove double quotes around table names in INSERT)
    content = re.sub(r'""([^"]+)""', r'"\1"', content)
    
    # Add PostgreSQL-specific settings at the beginning
    postgres_content = f"""-- Data import for PostgreSQL (converted from SQLite)
-- Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- Temporarily disable foreign key checks for data import
SET session_replication_role = replica;

"""
    
    # Add re-enable foreign key checks at the end
    postgres_content += content + "\n\n-- Re-enable foreign key checks\nSET session_replication_role = DEFAULT;\n"
    
    # Write converted content
    with open(output_file, 'w') as f:
        f.write(postgres_content)
    
    print(f"Converted {len(insert_lines)} INSERT statements from {input_file} to {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Convert SQLite dump to PostgreSQL data-only format')
    parser.add_argument('input_file', help='Input SQLite SQL file')
    parser.add_argument('output_file', help='Output PostgreSQL SQL file')
    
    args = parser.parse_args()
    
    try:
        convert_sqlite_data_to_postgres(args.input_file, args.output_file)
        print("Data conversion completed successfully!")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()