#!/bin/bash

# Change to the project root directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Source test helpers
source ./lib/test/test_helpers.sh

# Keep track of failures
FAILURES=0

# Function to run a test file
run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file")
    
    echo ">>> Running ${test_name}..."
    
    # Run the test and capture both stdout and stderr, filtering out the readonly variable warning
    if output=$($LIB_DIR/test/bashunit "$test_file" 2>&1 | grep -v "declare: BASHUNIT_GIT_REPO: readonly variable"); then
        echo "[PASS] ${test_name}"
        # Print any remaining output that wasn't filtered
        [ ! -z "$output" ] && echo "$output"
        return 0
    else
        echo "[FAIL] ${test_name}"
        echo "$output"
        return 1
    fi
}

echo "=== Running test suite ==="
echo

# Run each test file
for test_file in $TESTS_DIR/*.sh; do
    if ! run_test_file "$test_file"; then
        ((FAILURES++))
    fi
    echo
done

echo "=== Test suite complete ==="
if [ $FAILURES -eq 0 ]; then
    echo "All tests passed!"
else
    echo "Failed tests: $FAILURES"
fi

exit $FAILURES
