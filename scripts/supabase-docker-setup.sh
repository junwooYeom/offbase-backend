#!/bin/bash

echo "======================================"
echo "Supabase Docker Setup"
echo "======================================"
echo ""

# Function to wait for Docker
wait_for_docker() {
    echo "⏳ Waiting for Docker to be ready..."
    COUNTER=0
    while ! docker ps &> /dev/null; do
        if [ $COUNTER -gt 30 ]; then
            echo ""
            echo "❌ Docker is not running!"
            echo ""
            echo "Please:"
            echo "1. Open Docker Desktop from Applications folder"
            echo "2. Wait for it to start (whale icon in menu bar)"
            echo "3. Run this script again"
            return 1
        fi
        printf "."
        sleep 2
        COUNTER=$((COUNTER + 1))
    done
    echo ""
    echo "✅ Docker is running!"
    return 0
}

# Check Docker status
echo "🐳 Checking Docker status..."
if ! docker ps &> /dev/null; then
    echo "Docker is not running. Attempting to start..."
    
    # Try to start Docker Desktop
    if [ -d "/Applications/Docker.app" ]; then
        open -a Docker
        wait_for_docker
        if [ $? -ne 0 ]; then
            exit 1
        fi
    else
        echo "❌ Docker Desktop not found in Applications!"
        echo "Please install Docker Desktop first."
        exit 1
    fi
else
    echo "✅ Docker is already running!"
fi

# Show Docker info
echo ""
echo "Docker version:"
docker --version

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo ""
    echo "❌ Supabase CLI not found!"
    echo "Install with: brew install supabase/tap/supabase"
    exit 1
fi

echo ""
echo "Supabase CLI version:"
supabase --version

# Now pull schema using Docker-based Supabase
echo ""
echo "======================================"
echo "Ready to pull schema with Docker!"
echo "======================================"
echo ""

# Check for access token
if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "⚠️  SUPABASE_ACCESS_TOKEN not set!"
    echo "Set it with: export SUPABASE_ACCESS_TOKEN=your-token"
    exit 1
fi

echo "Choose an option:"
echo "1. Start local Supabase (full local development)"
echo "2. Just pull schema from remote (recommended)"
echo "3. Exit"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "Starting local Supabase..."
        echo "This will download ~1GB of Docker images on first run"
        supabase start
        ;;
    2)
        echo ""
        echo "Pulling schema from remote..."
        
        # Link to staging
        echo "Linking to staging project..."
        supabase link --project-ref dijtowiohxvwdnvgprud
        
        # Try different methods
        echo ""
        echo "Method 1: Using remote commit..."
        supabase db remote commit
        
        if [ $? -ne 0 ]; then
            echo ""
            echo "Method 1 failed. Trying Method 2..."
            echo "Enter your database password when prompted:"
            supabase db pull
        fi
        
        # Check if migrations were created
        if [ "$(ls -A supabase/migrations/*.sql 2>/dev/null)" ]; then
            echo ""
            echo "✅ Schema pulled successfully!"
            ls -la supabase/migrations/
        else
            echo ""
            echo "❌ No migrations created. Try the manual method."
        fi
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac