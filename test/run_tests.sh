#!/bin/bash

echo "🧪 Esecuzione Test Suite Completa - Walk & Fit"
echo "=============================================="
echo ""

echo "📋 1. Unit Tests..."
flutter test test/unit/ --reporter expanded

echo ""
echo "📊 2. Generazione Coverage Report..."
flutter test --coverage

echo ""
echo "✅ Test completati!"
echo ""
echo "📈 Report coverage disponibile in: coverage/lcov.info"
