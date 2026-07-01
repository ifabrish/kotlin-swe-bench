#!/bin/bash
set -uo pipefail

mkdir -p /logs/verifier

# Apply the test patch an run the tests (repo-specific)
cd /home/TeXiFy-IDEA
git apply --whitespace=nowarn /tests/test.patch

./gradlew clean test --continue --init-script /home/exclude-flaky-tests.gradle.kts || true
exit_code=$?

# Collect JUnit XML from build output directories
XML_OUT=/logs/verifier/all-testsuites.xml
if bash /tests/kotlin_logs_collector.sh --root . --output "$XML_OUT" 2>/dev/null; then
  # Parse XML and compare against expected bench tests
  python3 /tests/junit_compare.py \
    --xml      "$XML_OUT" \
    --expected /tests/expected_tests.json \
    --reward   /logs/verifier/reward.txt
else
  # Fallback: no JUnit XML found — use exit code
  echo "WARNING: JUnit XML collection failed; falling back to exit-code reward." >&2
  if [ $exit_code -eq 0 ]; then
    echo 1 > /logs/verifier/reward.txt
  else
    echo 0 > /logs/verifier/reward.txt
  fi
fi
