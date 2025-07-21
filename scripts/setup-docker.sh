#!/bin/bash

echo "======================================"
echo "Docker Setup for Supabase"
echo "======================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "📦 Docker not found. Installing Docker Desktop..."
    echo ""
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    echo "Installing Docker Desktop via Homebrew..."
    brew install --cask docker
    
    echo ""
    echo "✅ Docker Desktop installed!"
    echo ""
    echo "⚠️  IMPORTANT: You need to start Docker Desktop manually!"
    echo ""
    echo "Steps:"
    echo "1. Open Docker Desktop from Applications"
    echo "2. Accept the license agreement"
    echo "3. Wait for Docker to start (icon in menu bar)"
    echo "4. Run this script again"
    
    # Try to open Docker
    echo ""
    echo "Opening Docker Desktop..."
    open -a Docker
    exit 0
fi

# Check if Docker daemon is running
if ! docker ps &> /dev/null; then
    echo "🔴 Docker is installed but not running!"
    echo ""
    echo "Starting Docker Desktop..."
    open -a Docker
    
    echo ""
    echo "⏳ Waiting for Docker to start..."
    echo "   This may take 30-60 seconds..."
    
    # Wait for Docker to start
    COUNTER=0
    while ! docker ps &> /dev/null; do
        if [ $COUNTER -gt 30 ]; then
            echo ""
            echo "❌ Docker is taking too long to start."
            echo "   Please start Docker Desktop manually and run this script again."
            exit 1
        fi
        
        printf "."
        sleep 2
        COUNTER=$((COUNTER + 1))
    done
    
    echo ""
    echo "✅ Docker is now running!"
fi

# Verify Docker is working
echo ""
echo "🐳 Docker Status:"
docker --version
docker ps

echo ""
echo "✅ Docker is ready for Supabase!"
echo ""
echo "Next steps:"
echo "1. Run: supabase start"
echo "2. This will download Supabase Docker images"
echo "3. Then you can use all Supabase CLI features"