# Go Language Idioms

Go-specific patterns aligned with coding rigor principles.

---

## Table-Driven Tests

**The Go way of writing comprehensive test cases.**

```go
func TestValidate(t *testing.T) {
    tests := []struct {
        name    string
        input   Contract
        wantErr bool
        errMsg  string
    }{
        {
            name:    "valid contract",
            input:   Contract{Name: "test", Version: "1.0"},
            wantErr: false,
        },
        {
            name:    "empty name",
            input:   Contract{Name: "", Version: "1.0"},
            wantErr: true,
            errMsg:  "name required",
        },
        {
            name:    "empty version",
            input:   Contract{Name: "test", Version: ""},
            wantErr: true,
            errMsg:  "version required",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Validate(tt.input)
            
            if tt.wantErr {
                if result.IsOk() {
                    t.Errorf("expected error, got ok")
                }
                if result.Err().Error() != tt.errMsg {
                    t.Errorf("got %q, want %q", result.Err(), tt.errMsg)
                }
            } else {
                if result.IsErr() {
                    t.Errorf("unexpected error: %v", result.Err())
                }
            }
        })
    }
}
```

**Benefits:**
- Add cases without duplicating test logic
- Clear documentation of expected behavior
- Easy to spot coverage gaps

---

## Error Handling

### Explicit Errors Over Panics

```go
// BAD - panic
func MustParse(data []byte) Config {
    var c Config
    if err := json.Unmarshal(data, &c); err != nil {
        panic(err)  // Crashes program!
    }
    return c
}

// GOOD - explicit error
func Parse(data []byte) (Config, error) {
    var c Config
    if err := json.Unmarshal(data, &c); err != nil {
        return Config{}, fmt.Errorf("parse config: %w", err)
    }
    return c, nil
}

// BETTER - Result type
func Parse(data []byte) Result[Config] {
    var c Config
    if err := json.Unmarshal(data, &c); err != nil {
        return Err[Config](fmt.Sprintf("parse config: %v", err))
    }
    return Ok(c)
}
```

### Error Wrapping

```go
// Use %w to wrap errors (Go 1.13+)
if err != nil {
    return fmt.Errorf("processing file %s: %w", filename, err)
}

// Check wrapped errors
if errors.Is(err, os.ErrNotExist) {
    // Handle missing file
}

// Extract wrapped error type
var pathErr *os.PathError
if errors.As(err, &pathErr) {
    fmt.Println("Failed path:", pathErr.Path)
}
```

---

## Interfaces

### Small, Focused Interfaces

```go
// BAD - kitchen sink
type Repository interface {
    GetUser(id string) (User, error)
    CreateUser(u User) error
    UpdateUser(u User) error
    DeleteUser(id string) error
    ListUsers() ([]User, error)
    GetUserByEmail(email string) (User, error)
    SearchUsers(query string) ([]User, error)
    CountUsers() (int, error)
}

// GOOD - focused interfaces
type UserReader interface {
    GetUser(id string) (User, error)
}

type UserWriter interface {
    CreateUser(u User) error
}

type UserLister interface {
    ListUsers() ([]User, error)
}

type UserSearcher interface {
    SearchUsers(query string) ([]User, error)
}
```

### Accept Interfaces, Return Structs

```go
// GOOD - Accept interface (flexible)
func ProcessData(reader io.Reader) error {
    // Can accept file, network conn, bytes.Buffer, etc.
}

// GOOD - Return struct (concrete, no surprises)
func NewHandler(r io.Reader) *Handler {
    return &Handler{reader: r}
}

// BAD - Return interface (hides implementation)
func NewHandler(r io.Reader) HandlerInterface {
    // Caller can't access concrete methods/fields
}
```

---

## Constructor Pattern

### Basic Constructor

```go
type Handler struct {
    reader ports.Reader
    writer ports.Writer
    logger *log.Logger
}

func NewHandler(r ports.Reader, w ports.Writer) *Handler {
    return &Handler{
        reader: r,
        writer: w,
        logger: log.New(os.Stdout, "Handler: ", log.LstdFlags),
    }
}
```

### Functional Options Pattern

```go
type Handler struct {
    reader  ports.Reader
    writer  ports.Writer
    timeout time.Duration
    retries int
    logger  *log.Logger
}

type Option func(*Handler)

func WithTimeout(d time.Duration) Option {
    return func(h *Handler) {
        h.timeout = d
    }
}

func WithRetries(n int) Option {
    return func(h *Handler) {
        h.retries = n
    }
}

func WithLogger(l *log.Logger) Option {
    return func(h *Handler) {
        h.logger = l
    }
}

func NewHandler(r ports.Reader, w ports.Writer, opts ...Option) *Handler {
    h := &Handler{
        reader:  r,
        writer:  w,
        timeout: 30 * time.Second,  // defaults
        retries: 3,
        logger:  log.Default(),
    }
    
    for _, opt := range opts {
        opt(h)
    }
    
    return h
}

// Usage
handler := NewHandler(
    reader,
    writer,
    WithTimeout(60 * time.Second),
    WithRetries(5),
)
```

---

## Zero Values

### Design for Zero Value Usability

```go
// GOOD - zero value is useful
type Buffer struct {
    buf []byte
}

func (b *Buffer) Write(p []byte) (int, error) {
    b.buf = append(b.buf, p...)  // Works even if buf is nil
    return len(p), nil
}

// Can use without initialization
var b Buffer
b.Write([]byte("hello"))

// BAD - requires initialization
type BadBuffer struct {
    buf []byte
}

func (b *BadBuffer) Write(p []byte) (int, error) {
    if b.buf == nil {
        return 0, errors.New("buffer not initialized")
    }
    b.buf = append(b.buf, p...)
    return len(p), nil
}

// Requires explicit init
b := &BadBuffer{buf: make([]byte, 0)}
```

---

## Concurrency

### Channels for Communication

```go
// Producer
func produce(ch chan<- int) {
    for i := 0; i < 10; i++ {
        ch <- i
    }
    close(ch)
}

// Consumer
func consume(ch <-chan int) {
    for val := range ch {
        fmt.Println(val)
    }
}

// Orchestration
ch := make(chan int)
go produce(ch)
consume(ch)
```

### Context for Cancellation

```go
func LongRunningTask(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()  // Cancelled or timed out
        default:
            // Do work
            time.Sleep(100 * time.Millisecond)
        }
    }
}

// Usage with timeout
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

if err := LongRunningTask(ctx); err != nil {
    log.Printf("task failed: %v", err)
}
```

### Testable Time

```go
// ports/ports.go
type Clock interface {
    Now() time.Time
}

// adapters/realclock.go
type RealClock struct{}

func (RealClock) Now() time.Time {
    return time.Now()
}

// adapters/fakeclock.go
type FakeClock struct {
    T time.Time
}

func (c FakeClock) Now() time.Time {
    return c.T
}

// Usage in tests
func TestTimeDependent(t *testing.T) {
    clock := FakeClock{T: time.Date(2024, 1, 1, 0, 0, 0, 0, time.UTC)}
    result := ProcessWithTime(clock)
    // Deterministic test!
}
```

---

## Naming Conventions

### Package Names

```go
// GOOD - short, lowercase, no underscores
package user
package httputil
package ioutil

// BAD
package user_service
package HTTPUtil
package IO_Util
```

### Interface Names

```go
// GOOD - single method interfaces end in -er
type Reader interface { Read([]byte) (int, error) }
type Writer interface { Write([]byte) (int, error) }
type Closer interface { Close() error }

// GOOD - descriptive for multi-method
type FileSystem interface {
    Open(string) (File, error)
    Create(string) (File, error)
    Remove(string) error
}

// BAD - unnecessary "I" prefix
type IReader interface { Read([]byte) (int, error) }
```

### Variable Names

```go
// GOOD - short in small scopes
for i := 0; i < 10; i++ { ... }
if err != nil { ... }

// GOOD - descriptive in larger scopes
func ProcessUserRegistration(userData UserRegistrationRequest) error {
    validatedUser := ValidateUserData(userData)
    // ...
}

// BAD - unnecessarily verbose in small scope
for index := 0; index < 10; index++ { ... }
if errorValue != nil { ... }
```

---

## Common Patterns

### Dependency Injection

```go
type Handler struct {
    reader ports.Reader  // Inject interface
    writer ports.Writer  // Inject interface
}

func NewHandler(r ports.Reader, w ports.Writer) *Handler {
    return &Handler{reader: r, writer: w}
}

// Test with fakes
func TestHandler(t *testing.T) {
    fakeReader := &memory.FakeReader{Data: []byte("test")}
    fakeWriter := &memory.FakeWriter{}
    
    handler := NewHandler(fakeReader, fakeWriter)
    // Test with fakes, not real I/O
}
```

### Early Returns

```go
// GOOD - early returns reduce nesting
func Process(data Data) error {
    if err := Validate(data); err != nil {
        return err
    }
    
    if err := Transform(data); err != nil {
        return err
    }
    
    if err := Save(data); err != nil {
        return err
    }
    
    return nil
}

// BAD - nested ifs
func Process(data Data) error {
    if err := Validate(data); err == nil {
        if err := Transform(data); err == nil {
            if err := Save(data); err == nil {
                return nil
            } else {
                return err
            }
        } else {
            return err
        }
    } else {
        return err
    }
}
```

### Struct Embedding

```go
// Composition over inheritance
type BaseHandler struct {
    logger *log.Logger
}

func (h *BaseHandler) Log(msg string) {
    h.logger.Println(msg)
}

type UserHandler struct {
    BaseHandler  // Embedded
    repo UserRepository
}

// UserHandler automatically has Log method
handler := &UserHandler{
    BaseHandler: BaseHandler{logger: log.Default()},
    repo:        userRepo,
}
handler.Log("processing user")  // Works!
```

---

## Anti-Patterns

### ❌ Naked Returns

```go
// BAD - naked return confusing
func Calculate(a, b int) (result int, err error) {
    if a < 0 {
        err = errors.New("negative a")
        return  // Returns (0, err) - confusing!
    }
    result = a + b
    return  // Returns (result, nil)
}

// GOOD - explicit returns
func Calculate(a, b int) (int, error) {
    if a < 0 {
        return 0, errors.New("negative a")
    }
    return a + b, nil
}
```

### ❌ Ignoring Errors

```go
// BAD - silently ignoring error
data, _ := os.ReadFile("config.json")

// GOOD - handle or propagate
data, err := os.ReadFile("config.json")
if err != nil {
    return fmt.Errorf("read config: %w", err)
}
```

### ❌ Using panic for Control Flow

```go
// BAD - panic for normal errors
func GetUser(id string) User {
    user, err := db.Find(id)
    if err != nil {
        panic(err)  // Don't do this!
    }
    return user
}

// GOOD - return error
func GetUser(id string) (User, error) {
    user, err := db.Find(id)
    if err != nil {
        return User{}, fmt.Errorf("find user: %w", err)
    }
    return user, nil
}
```

---

## Code Organization

### Package Layout

```go
// Good package structure
myapp/
├── cmd/
│   └── server/
│       └── main.go          // Entry point only
├── internal/
│   ├── user/                // Domain package
│   │   ├── user.go          // Types
│   │   ├── service.go       // Business logic
│   │   └── service_test.go  // Tests
│   ├── ports/               // Interfaces
│   │   └── ports.go
│   └── adapters/            // Implementations
│       ├── postgres/
│       └── memory/
└── go.mod
```

### Internal Packages

```go
// Use internal/ to prevent external imports
myapp/
├── internal/              // Can't be imported by other modules
│   ├── core/
│   └── ports/
└── pkg/                   // Can be imported externally
    └── client/
```

---

## Best Practices Summary

1. **Errors** - Return errors, don't panic
2. **Interfaces** - Small and focused
3. **Tests** - Table-driven when possible
4. **Constructors** - Use New* functions
5. **Zero values** - Make them useful
6. **Names** - Short in small scopes, descriptive in large
7. **Packages** - Cohesive, single responsibility
8. **Concurrency** - Channels for communication, mutexes for state
9. **Context** - For cancellation and deadlines
10. **Dependency injection** - Via interfaces
