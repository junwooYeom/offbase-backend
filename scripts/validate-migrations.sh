#!/bin/bash

echo "======================================"
echo "Migration Validator"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
MIGRATIONS=0

# Check if migrations directory exists
if [ ! -d "supabase/migrations" ]; then
    echo -e "${RED}❌ No migrations directory found!${NC}"
    exit 1
fi

# Check if there are any migration files
if [ -z "$(ls -A supabase/migrations/*.sql 2>/dev/null)" ]; then
    echo -e "${RED}❌ No migration files found!${NC}"
    exit 1
fi

echo "Validating migration files..."
echo ""

# Validate each migration file
for file in supabase/migrations/*.sql; do
    if [ -f "$file" ]; then
        MIGRATIONS=$((MIGRATIONS + 1))
        echo "📄 Checking: $(basename $file)"
        
        # Check file is not empty
        if [ ! -s "$file" ]; then
            echo -e "${RED}   ❌ ERROR: File is empty${NC}"
            ERRORS=$((ERRORS + 1))
            continue
        fi
        
        # Check for semicolons
        if ! grep -q ";" "$file"; then
            echo -e "${YELLOW}   ⚠️  WARNING: No semicolons found - might be missing statement terminators${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
        
        # Check for dangerous operations
        if grep -i "drop table\|drop schema\|drop database\|truncate" "$file"; then
            echo -e "${YELLOW}   ⚠️  WARNING: Contains potentially dangerous operations (DROP/TRUNCATE)${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
        
        # Check for transaction blocks
        if grep -i "begin;\|commit;" "$file"; then
            echo -e "${GREEN}   ✅ Has transaction blocks${NC}"
        fi
        
        # Check for common syntax patterns
        if grep -i "create table\|alter table\|create function\|create trigger" "$file"; then
            echo -e "${GREEN}   ✅ Contains schema definitions${NC}"
        fi
        
        # Check for IF EXISTS clauses (good practice)
        if grep -i "if not exists\|if exists" "$file"; then
            echo -e "${GREEN}   ✅ Uses IF EXISTS clauses${NC}"
        fi
        
        # Check file naming convention
        if [[ ! "$file" =~ ^supabase/migrations/[0-9]{14}.*\.sql$ ]]; then
            echo -e "${YELLOW}   ⚠️  WARNING: Non-standard filename format${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
        
        echo ""
    fi
done

# Summary
echo "======================================"
echo "Validation Summary"
echo "======================================"
echo "📊 Total migrations: $MIGRATIONS"
echo -e "${RED}❌ Errors: $ERRORS${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Validation failed with $ERRORS errors${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Validation passed with $WARNINGS warnings${NC}"
    exit 0
else
    echo ""
    echo -e "${GREEN}✅ All validations passed!${NC}"
    exit 0
fi