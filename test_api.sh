#!/bin/bash

# Test script to diagnose the gold API issue

echo "🔍 Testing Gold API Endpoint"
echo "=============================="
echo ""

echo "1️⃣ Testing direct API call..."
echo "URL: https://api.metals.live/v1/spot/gold"
echo ""

# Try with curl
echo "Testing with curl:"
curl -i "https://api.metals.live/v1/spot/gold" 2>&1 | head -20

echo ""
echo "2️⃣ Testing with wget:"
wget -O - "https://api.metals.live/v1/spot/gold" 2>&1 | head -20

echo ""
echo "3️⃣ Try alternative gold API:"
echo "URL: https://api.coingecko.com/api/v3/simple/price?ids=gold&vs_currencies=inr"
curl -s "https://api.coingecko.com/api/v3/simple/price?ids=gold&vs_currencies=inr" 2>&1

echo ""
echo "=============================="
echo "✅ If you see JSON response above, the API is working"
echo "❌ If you see nothing or error, the API might be blocked"

