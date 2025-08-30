#!/usr/bin/env python3
"""
Convert SQLite export to PostgreSQL-compatible format
"""

import re
import sys
import argparse

def convert_sqlite_to_postgres(input_file, output_file):
    """Convert SQLite SQL dump to PostgreSQL format"""
    
    with open(input_file, 'r') as f:
        content = f.read()
    
    # Remove SQLite-specific pragmas
    content = re.sub(r'PRAGMA[^;]+;', '', content)
    
    # Fix CREATE TABLE statements
    # Remove backticks around table/column names (SQLite) and use double quotes (PostgreSQL)
    content = re.sub(r'`([^`]+)`', r'"\1"', content)
    
    # Convert SQLite data types to PostgreSQL equivalents
    content = re.sub(r'\binteger\b', 'INTEGER', content, flags=re.IGNORECASE)
    content = re.sub(r'\btext\b', 'TEXT', content, flags=re.IGNORECASE)
    content = re.sub(r'\breal\b', 'REAL', content, flags=re.IGNORECASE)
    content = re.sub(r'\bnumeric\b', 'NUMERIC', content, flags=re.IGNORECASE)
    
    # Convert AUTOINCREMENT to SERIAL
    content = re.sub(r'\bINTEGER PRIMARY KEY AUTOINCREMENT\b', 'SERIAL PRIMARY KEY', content, flags=re.IGNORECASE)
    content = re.sub(r'\bid SERIAL PRIMARY KEY\b', 'id SERIAL PRIMARY KEY', content)
    
    # Handle DEFAULT CURRENT_TIMESTAMP properly
    content = re.sub(r'DEFAULT \(CURRENT_TIMESTAMP\)', 'DEFAULT CURRENT_TIMESTAMP', content)
    content = re.sub(r'DEFAULT CURRENT_TIMESTAMP', 'DEFAULT CURRENT_TIMESTAMP', content)
    
    # Convert boolean values
    content = re.sub(r'\bfalse\b', 'FALSE', content)
    content = re.sub(r'\btrue\b', 'TRUE', content)
    
    # Fix INSERT statements
    content = re.sub(r'INSERT INTO ([^"\s(]+)', r'INSERT INTO "\1"', content)
    content = re.sub(r'INSERT INTO "([^"]+)" VALUES\(NULL,', r'INSERT INTO "\1" VALUES(DEFAULT,', content)
    content = re.sub(r'VALUES\(NULL,', 'VALUES(DEFAULT,', content)
    
    # Handle REFERENCES properly
    content = re.sub(r'REFERENCES ([^(]+)\(([^)]+)\)', r'REFERENCES "\1"("\2")', content)
    
    # Clean up excessive whitespace
    content = re.sub(r'\n\s*\n', '\n\n', content)
    
    # Add PostgreSQL-specific settings at the beginning
    postgres_content = """-- Converted from SQLite to PostgreSQL
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

"""
    
    # Write converted content
    with open(output_file, 'w') as f:
        f.write(postgres_content + content)
    
    print(f"Converted {input_file} to {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Convert SQLite dump to PostgreSQL format')
    parser.add_argument('input_file', help='Input SQLite SQL file')
    parser.add_argument('output_file', help='Output PostgreSQL SQL file')
    
    args = parser.parse_args()
    
    try:
        convert_sqlite_to_postgres(args.input_file, args.output_file)
        print("Conversion completed successfully!")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()