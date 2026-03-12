#!/bin/bash
cd /Users/sundarrajan/FlutterWeProjects/daily_rates_web

echo "Current status:"
git status

echo -e "\nAdding all changes..."
git add -A

echo -e "\nCommitting changes..."
git commit -m "Fix: Update gold rate fallback to 160,000 and add GitHub Actions deployment workflow"

echo -e "\nPushing to GitHub..."
git push origin main

echo -e "\nDeployment script completed!"

