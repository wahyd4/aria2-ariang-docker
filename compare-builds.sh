#!/bin/bash

echo "Building and comparing Docker images..."

# Build original image
echo "Building original image..."
docker build -f Dockerfile -t aria2-original:latest .

# Build Debian-optimized image
echo "Building Debian-optimized image..."
docker build -f Dockerfile.debian-optimized -t aria2-debian-optimized:latest .

# Build Alpine-optimized image
echo "Building Alpine-optimized image..."
docker build -f Dockerfile.optimized -t aria2-alpine-optimized:latest .

# Compare sizes
echo ""
echo "=== IMAGE SIZE COMPARISON ==="
echo "Original image:"
docker images aria2-original:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "Debian-optimized image:"
docker images aria2-debian-optimized:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "Alpine-optimized image:"
docker images aria2-alpine-optimized:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "=== DETAILED LAYER ANALYSIS ==="
echo "Original layers:"
docker history aria2-original:latest --format "table {{.CreatedBy}}\t{{.Size}}"

echo ""
echo "Debian-optimized layers:"
docker history aria2-debian-optimized:latest --format "table {{.CreatedBy}}\t{{.Size}}"

echo ""
echo "Alpine-optimized layers:"
docker history aria2-alpine-optimized:latest --format "table {{.CreatedBy}}\t{{.Size}}"
