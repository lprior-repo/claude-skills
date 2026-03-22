# Architecture Patterns

Functional Core / Imperative Shell with Ports and Adapters. Push I/O to the edges, keep core pure.

---

## Core Principle

> **Pure functions in the core. Side effects at the edges.**

```
┌─────────────────────────────────────────────┐
│              IMPERATIVE SHELL               │
│  (Side Effects: I/O, Network, Database)     │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │         FUNCTIONAL CORE                │ │
│  │  (Pure: Deterministic, No I/O)         │ │
│  │                                        │ │
│  │  All business logic lives here         │ │
│  │  Total functions, no exceptions        │ │
│  │  Same input → Same output              │ │
│  └───────────────────────────────────────┘ │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Directory Structure

```
project/
├── cmd/                    # Entry points
│   └── app/
│       └── main.go         # Wiring only, no logic
│
├── internal/
│   ├── core/               # FUNCTIONAL CORE
│   │   ├── types.go        # Domain types (plain data)
│   │   ├── logic.go        # Pure transformations
│   │   └── logic_test.go   # Table-driven tests, no mocks
│   │
│   ├── ports/              # INTERFACES (contracts)
│   │   └── ports.go        # Small, focused interfaces
│   │
│   ├── adapters/           # IMPERATIVE SHELL
│   │   ├── fs/             # Filesystem adapter
│   │   │   └── reader.go
│   │   ├── http/           # HTTP adapter
│   │   │   └── client.go
│   │   └── memory/         # In-memory (for tests)
│   │       └── storage.go
│   │
│   └── shell/              # ORCHESTRATION
│       ├── handler.go      # Thin glue, delegates to core
│       └── handler_test.go # Integration tests with memory adapters
│
└── go.mod
```

---

## Layer Responsibilities

### Core Layer (Functional)

**Characteristics:**
- Pure functions only
- No I/O operations
- No side effects
- Deterministic (same input → same output)
- Total functions (handle all cases, no panics)
- Zero dependencies on adapters or shell

**Contains:**
- Domain types (structs, enums)
- Business logic (validation, calculation, transformation)
- Domain rules and invariants

**Example:**

```go
// core/types.go
type Contract struct {
    Name    string
    Version string
    Fields  []Field
}

type Field struct {
    Name     string
    Type     string
    Required bool
}

// core/logic.go
func ValidateContract(c Contract) Result[Contract] {
    if c.Name == "" {
        return Err[Contract]("name required")
    }
    if c.Version == "" {
        return Err[Contract]("version required")
    }
    return Ok(c)
}

func MergeContracts(a, b Contract) Contract {
    // Pure transformation
    // Same inputs always produce same outputs
    return Contract{
        Name:    a.Name,
        Version: b.Version,
        Fields:  append(a.Fields, b.Fields...),
    }
}

// Test with simple assertions, no mocks needed
func TestValidateContract(t *testing.T) {
    tests := []struct {
        name    string
        input   Contract
        wantErr bool
    }{
        {
            name:    "valid",
            input:   Contract{Name: "test", Version: "1.0"},
            wantErr: false,
        },
        {
            name:    "empty name",
            input:   Contract{Name: "", Version: "1.0"},
            wantErr: true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := ValidateContract(tt.input)
            if (result.IsErr()) != tt.wantErr {
                t.Errorf("wantErr %v, got %v", tt.wantErr, result.IsErr())
            }
        })
    }
}
```

---

### Ports Layer (Interfaces)

**Characteristics:**
- Defines contracts with external world
- Small, focused interfaces (Interface Segregation Principle)
- No implementation details
- Core depends on these, NOT on adapters

**Contains:**
- Reader/Writer interfaces
- Repository interfaces
- External service interfaces

**Example:**

```go
// ports/ports.go

// Small interfaces - one responsibility each
type ContractReader interface {
    Read(path string) ([]byte, error)
}

type ContractWriter interface {
    Write(path string, data []byte) error
}

type SchemaValidator interface {
    Validate(schema []byte) error
}

// NOT this (kitchen sink):
type ContractRepository interface {
    Read(path string) ([]byte, error)
    Write(path string, data []byte) error
    Validate(schema []byte) error
    List() ([]string, error)
    Delete(path string) error
    // ... 20 more methods
}
```

**Why small interfaces?**
- Easier to implement
- Easier to test (fewer methods to mock)
- Easier to compose
- Easier to change

---

### Adapters Layer (Imperative)

**Characteristics:**
- Implements port interfaces
- Contains all I/O operations
- One adapter per external dependency
- Adapters are interchangeable

**Contains:**
- File system adapters
- Database adapters
- HTTP client adapters
- Third-party service adapters
- Test doubles (in-memory, fake, stub)

**Example:**

```go
// adapters/fs/reader.go
type FileReader struct{}

func (r FileReader) Read(path string) ([]byte, error) {
    return os.ReadFile(path)  // I/O happens here
}

// adapters/http/client.go
type HTTPClient struct {
    baseURL string
    client  *http.Client
}

func (c HTTPClient) Fetch(endpoint string) ([]byte, error) {
    resp, err := c.client.Get(c.baseURL + endpoint)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()
    return io.ReadAll(resp.Body)
}

// adapters/memory/storage.go - For tests!
type MemoryReader struct {
    Files map[string][]byte
}

func (r MemoryReader) Read(path string) ([]byte, error) {
    data, ok := r.Files[path]
    if !ok {
        return nil, os.ErrNotExist
    }
    return data, nil
}
```

---

### Shell Layer (Orchestration)

**Characteristics:**
- Thin glue between adapters and core
- Coordinates I/O and logic
- Contains NO business logic
- Delegates all logic to core

**Pattern:**
1. Read from adapter (impure)
2. Transform via core (pure)
3. Write via adapter (impure)

**Example:**

```go
// shell/handler.go
type Handler struct {
    reader    ports.ContractReader
    writer    ports.ContractWriter
    validator ports.SchemaValidator
}

func NewHandler(
    r ports.ContractReader,
    w ports.ContractWriter,
    v ports.SchemaValidator,
) *Handler {
    return &Handler{
        reader:    r,
        writer:    w,
        validator: v,
    }
}

func (h *Handler) Process(inputPath, outputPath string) error {
    // 1. READ (impure)
    data, err := h.reader.Read(inputPath)
    if err != nil {
        return fmt.Errorf("read: %w", err)
    }
    
    // 2. TRANSFORM (pure - delegate to core)
    contract := core.Parse(data)
    result := core.ValidateContract(contract)
    if result.IsErr() {
        return result.Err()
    }
    
    // 3. WRITE (impure)
    output := core.Serialize(result.Value())
    if err := h.writer.Write(outputPath, output); err != nil {
        return fmt.Errorf("write: %w", err)
    }
    
    return nil
}
```

**Testing the shell:**

```go
// shell/handler_test.go
func TestHandler_Process(t *testing.T) {
    // Use in-memory adapters for testing
    reader := &memory.MemoryReader{
        Files: map[string][]byte{
            "input.json": []byte(`{"name":"test","version":"1.0"}`),
        },
    }
    writer := &memory.MemoryWriter{
        Files: make(map[string][]byte),
    }
    validator := &memory.NoOpValidator{}
    
    handler := NewHandler(reader, writer, validator)
    
    err := handler.Process("input.json", "output.json")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    
    // Verify output was written
    if _, ok := writer.Files["output.json"]; !ok {
        t.Error("output.json not written")
    }
}
```

---

## Dependency Direction

```
         main.go
            │
            ├──► shell (depends on ports)
            │      │
            │      ├──► core (no dependencies)
            │      │
            │      └──► ports (interfaces only)
            │
            └──► adapters (implements ports)
```

**Key rule:** Core never imports from adapters or shell.

**Dependency Inversion:** Core defines interfaces (ports), adapters implement them.

---

## Result Type Pattern

Avoid panics. Make errors explicit and type-safe.

```go
// core/result.go
type Result[T any] struct {
    value T
    err   error
    ok    bool
}

func Ok[T any](v T) Result[T] {
    return Result[T]{value: v, ok: true}
}

func Err[T any](msg string) Result[T] {
    return Result[T]{err: errors.New(msg), ok: false}
}

func (r Result[T]) IsOk() bool  { return r.ok }
func (r Result[T]) IsErr() bool { return !r.ok }
func (r Result[T]) Value() T    { return r.value }
func (r Result[T]) Err() error  { return r.err }

// Functor map
func (r Result[T]) Map(fn func(T) T) Result[T] {
    if r.IsErr() {
        return r
    }
    return Ok(fn(r.value))
}

// Monadic bind
func (r Result[T]) FlatMap(fn func(T) Result[T]) Result[T] {
    if r.IsErr() {
        return r
    }
    return fn(r.value)
}
```

**Usage:**

```go
func ValidateAndTransform(data []byte) Result[Contract] {
    parsed := Parse(data)
    if parsed.IsErr() {
        return Err[Contract]("parse failed")
    }
    
    validated := ValidateContract(parsed.Value())
    if validated.IsErr() {
        return validated
    }
    
    return Ok(Transform(validated.Value()))
}

// Or with chaining
func ValidateAndTransform(data []byte) Result[Contract] {
    return Parse(data).
        FlatMap(ValidateContract).
        Map(Transform)
}
```

---

## Testing Strategy

| Layer     | Test Type         | Mocks Required       | Speed   |
|-----------|-------------------|----------------------|---------|
| Core      | Unit (table)      | None                 | Fast    |
| Adapters  | Integration       | External systems     | Medium  |
| Shell     | Integration       | Memory adapters      | Fast    |
| E2E       | Acceptance        | None (real system)   | Slow    |

**Pyramid:**
```
        ┌─────┐
        │ E2E │  Few, slow, comprehensive
        ├─────┤
        │ INT │  Some, medium, integration
        ├─────┤
        │UNIT │  Many, fast, focused
        └─────┘
```

**Most tests in core** (pure, fast, no mocks).
**Some tests in shell** (with memory adapters).
**Few E2E tests** (full stack, slow).

---

## Benefits

### Testability
- Core is pure → easy to test, no mocks needed
- Shell tested with memory adapters → fast, deterministic
- Adapters tested in isolation → clear failure points

### Maintainability
- Business logic isolated in core → easy to find and change
- Adapters swappable → change data source without touching logic
- Clear boundaries → know where to look for bugs

### Complexity Management
- Pure functions are simple (no hidden state/side effects)
- Small interfaces → easy to implement/mock
- Separation of concerns → each layer has one job

### Refactoring Safety
- Core heavily tested → refactor with confidence
- Adapter changes don't affect core → swap implementations
- Shell is thin → little logic to break

---

## Anti-Patterns

### ❌ Business Logic in Shell

```go
// BAD - Shell contains business logic
func (h *Handler) Process(path string) error {
    data, _ := h.reader.Read(path)
    
    // Business logic leaking into shell!
    if len(data) == 0 {
        return errors.New("empty data")
    }
    if !strings.Contains(string(data), "name") {
        return errors.New("missing name")
    }
    
    // ...
}

// GOOD - Shell delegates to core
func (h *Handler) Process(path string) error {
    data, _ := h.reader.Read(path)
    result := core.Validate(data)  // Logic in core
    if result.IsErr() {
        return result.Err()
    }
    // ...
}
```

### ❌ Core Depends on Adapters

```go
// BAD - Core importing adapter
package core

import "myapp/adapters/fs"  // WRONG!

func LoadConfig() Config {
    data := fs.ReadFile("config.json")  // Core doing I/O!
    return Parse(data)
}

// GOOD - Core defines interface, shell wires it
package core

func ParseConfig(data []byte) Config {  // Pure function
    return Parse(data)
}

// Shell does I/O
package shell

func (h *Handler) LoadConfig() Config {
    data, _ := h.reader.Read("config.json")
    return core.ParseConfig(data)
}
```

### ❌ Fat Interfaces

```go
// BAD - Kitchen sink interface
type Repository interface {
    Create(User) error
    Read(string) (User, error)
    Update(User) error
    Delete(string) error
    List() ([]User, error)
    Search(string) ([]User, error)
    Count() (int, error)
    // ... 20 more methods
}

// GOOD - Focused interfaces
type UserReader interface {
    Read(id string) (User, error)
}

type UserWriter interface {
    Create(user User) error
}

type UserSearcher interface {
    Search(query string) ([]User, error)
}
```

---

## Philosophy

> **Make illegal states unrepresentable.**
> **Make effects explicit.**
> **Make dependencies obvious.**

Functional Core / Imperative Shell is not about functional programming languages. It's about organizing code so:

- Pure logic is easy to reason about (functional core)
- Side effects are isolated and explicit (imperative shell)
- Dependencies flow in one direction (inward)
- Tests are fast and don't need mocks (pure functions)

This architecture emerges naturally from TDD. Hard-to-test code forces you to separate pure logic from I/O.
