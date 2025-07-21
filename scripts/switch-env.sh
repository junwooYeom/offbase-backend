#!/bin/bash

# Switch between Supabase environments

set -e

echo "Supabase Environment Switcher"
echo "============================="
echo ""

# Check if .env file exists
if [ ! -f ".env.local" ]; then
    echo "Error: .env.local file not found!"
    echo "Please create .env.local with your project references:"
    echo ""
    echo "STAGING_PROJECT_REF=dijtowiohxvwdnvgprud"
    echo "PRODUCTION_PROJECT_REF=zutbqmhxvdgvcllobtxo"
    echo "SUPABASE_ACCESS_TOKEN=your-access-token"
    exit 1
fi

# Load environment variables
export $(cat .env.local | grep -v '^#' | xargs)

# Function to switch environment
switch_env() {
    local env=$1
    local project_ref=$2
    
    echo "Switching to $env environment..."
    
    # Unlink current project
    if [ -d ".supabase" ]; then
        echo "Unlinking current project..."
        rm -rf .supabase
    fi
    
    # Link new project
    echo "Linking to $env project: $project_ref"
    supabase link --project-ref "$project_ref"
    
    # Show diff
    echo ""
    echo "Checking differences with remote..."
    supabase db diff
    
    echo ""
    echo "✅ Switched to $env environment!"
}

# Menu
echo "Select environment:"
echo "1) Staging (develop branch) - dijtowiohxvwdnvgprud"
echo "2) Production (main branch) - zutbqmhxvdgvcllobtxo"
echo "3) Local"
echo "4) Show current status"
echo "5) Exit"
echo ""
read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        if [ -z "$STAGING_PROJECT_REF" ]; then
            echo "Error: STAGING_PROJECT_REF not set in .env.local"
            exit 1
        fi
        switch_env "Staging" "$STAGING_PROJECT_REF"
        ;;
    2)
        if [ -z "$PRODUCTION_PROJECT_REF" ]; then
            echo "Error: PRODUCTION_PROJECT_REF not set in .env.local"
            exit 1
        fi
        echo "⚠️  WARNING: You're switching to PRODUCTION!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            switch_env "Production" "$PRODUCTION_PROJECT_REF"
        else
            echo "Cancelled."
        fi
        ;;
    3)
        echo "For local development, use:"
        echo "  supabase start    # Start local instance"
        echo "  supabase stop     # Stop local instance"
        echo "  supabase status   # Check status"
        ;;
    4)
        echo "Current Supabase status:"
        supabase projects list
        ;;
    5)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac