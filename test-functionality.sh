#!/bin/bash

echo "Testing Debian-optimized Docker image functionality..."

# Build the optimized image
echo "Building debian-optimized image..."
docker build -f Dockerfile.debian-optimized -t aria2-test:latest .

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"

# Start container in background
echo "Starting container..."
docker run -d --name aria2-test-container -p 6800:80 -p 6881:6881 aria2-test:latest

# Wait for startup
echo "Waiting for services to start..."
sleep 10

# Test health endpoint
echo "Testing health endpoint..."
if curl -f http://localhost:6800/ping >/dev/null 2>&1; then
    echo "✅ Health check passed!"
else
    echo "❌ Health check failed!"
    echo "Container logs:"
    docker logs aria2-test-container
    docker rm -f aria2-test-container
    exit 1
fi

# Test AriaNg interface
echo "Testing AriaNg interface..."
if curl -f http://localhost:6800/ >/dev/null 2>&1; then
    echo "✅ AriaNg interface accessible!"
else  
    echo "❌ AriaNg interface not accessible!"
fi

# Test aria2 RPC
echo "Testing aria2 RPC..."
if curl -f http://localhost:6800/jsonrpc >/dev/null 2>&1; then
    echo "✅ Aria2 RPC accessible!"
else
    echo "❌ Aria2 RPC not accessible!"
fi

# Show final image size
echo ""
echo "=== Final Image Size ==="
docker images aria2-test:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Cleanup
echo ""
echo "Cleaning up test container..."
docker rm -f aria2-test-container

echo "✅ Functionality test completed!"
