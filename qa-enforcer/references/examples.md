# QA Enforcer Examples

## CLI Testing

```bash
# Test CLI binary exists
run_test "Binary exists" "which myapp" 0

# Test help
run_test "Help works" "myapp --help" 0

# Test invalid input
run_test "Invalid command fails" "myapp bogus-cmd" 1

# Test missing args
run_test "Missing args shows error" "myapp new" 1
```

## API Testing

```bash
# Test endpoint
response=$(curl -s -w "\n%{http_code}" "http://localhost:8080/api/tasks")
status=$(echo "$response" | tail -1)
body=$(echo "$response" | head -1)

# Validate status
if [[ ! "$status" =~ ^[23] ]]; then
  fail "Unexpected status: $status"
fi

# Validate JSON
echo "$body" | jq '.'
```

## Workflow Testing

```bash
# User story: Create task and approve it

# Step 1: Create
output=$(oya new -s test-task)
grep -q "Created task" <<< "$output" || fail "Creation failed"

# Step 2: Verify
bd show test-task || fail "Not found"

# Step 3: Approve
oya approve -s test-task || fail "Approval failed"

# Step 4: Verify state
bd show test-task | grep -q "status: approved" || fail "Not approved"
```

## Adversarial Testing

```bash
# Test SQL injection
curl -s -X POST "http://localhost:8080/api/tasks" \
  -d "name='; DROP TABLE tasks; --"

# Expected: Rejected safely
# Failure: SQL error, data loss
```
