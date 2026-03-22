# Rust Language Idioms

Rust-specific patterns aligned with coding rigor principles.

---

## Result and Option Types

**Rust's type system enforces error handling.**

### Result for Fallible Operations

```rust
// Use Result<T, E> for operations that can fail
fn parse_config(data: &[u8]) -> Result<Config, ParseError> {
    serde_json::from_slice(data)
        .map_err(|e| ParseError::Json(e.to_string()))
}

// Chain with ? operator
fn load_and_parse(path: &Path) -> Result<Config, Error> {
    let data = std::fs::read(path)?;  // Propagates error
    let config = parse_config(&data)?;  // Propagates error
    Ok(config)
}

// Pattern match for handling
match load_and_parse(path) {
    Ok(config) => println!("Loaded: {:?}", config),
    Err(e) => eprintln!("Error: {}", e),
}
```

### Option for Nullable Values

```rust
// Use Option<T> instead of null
fn find_user(id: &str) -> Option<User> {
    users.get(id).cloned()
}

// Chain operations
fn get_user_email(id: &str) -> Option<String> {
    find_user(id)
        .and_then(|user| user.email)
        .map(|email| email.to_lowercase())
}

// Provide defaults
let email = get_user_email("123").unwrap_or_else(|| "unknown@example.com".to_string());
```

---

## Type State Pattern

**Encode state machine in types for compile-time safety.**

```rust
use std::marker::PhantomData;

// States
struct Draft;
struct Validated;
struct Published;

// Contract with type parameter for state
struct Contract<State> {
    name: String,
    version: String,
    fields: Vec<Field>,
    _state: PhantomData<State>,
}

// Draft state can only create and validate
impl Contract<Draft> {
    fn new(name: String, version: String) -> Self {
        Contract {
            name,
            version,
            fields: Vec::new(),
            _state: PhantomData,
        }
    }
    
    fn add_field(mut self, field: Field) -> Self {
        self.fields.push(field);
        self
    }
    
    // Transition to Validated state
    fn validate(self) -> Result<Contract<Validated>, ValidationError> {
        if self.name.is_empty() {
            return Err(ValidationError::NameRequired);
        }
        
        Ok(Contract {
            name: self.name,
            version: self.version,
            fields: self.fields,
            _state: PhantomData,
        })
    }
}

// Validated state can only publish
impl Contract<Validated> {
    fn publish(self) -> Contract<Published> {
        Contract {
            name: self.name,
            version: self.version,
            fields: self.fields,
            _state: PhantomData,
        }
    }
}

// Published state is read-only
impl Contract<Published> {
    fn name(&self) -> &str {
        &self.name
    }
}

// Usage - compiler enforces state machine!
let contract = Contract::new("API".into(), "1.0".into())
    .add_field(Field::new("id"))
    .validate()?  // Must validate before publishing
    .publish();   // Can only publish validated contract

// This won't compile:
// let contract = Contract::new("API".into(), "1.0".into())
//     .publish();  // ERROR: no method `publish` for Contract<Draft>
```

---

## Builder Pattern

**Construct complex types incrementally.**

```rust
#[derive(Default)]
pub struct ContractBuilder {
    name: Option<String>,
    version: Option<String>,
    fields: Vec<Field>,
    metadata: HashMap<String, String>,
}

impl ContractBuilder {
    pub fn new() -> Self {
        Self::default()
    }
    
    pub fn name(mut self, name: impl Into<String>) -> Self {
        self.name = Some(name.into());
        self
    }
    
    pub fn version(mut self, version: impl Into<String>) -> Self {
        self.version = Some(version.into());
        self
    }
    
    pub fn field(mut self, field: Field) -> Self {
        self.fields.push(field);
        self
    }
    
    pub fn metadata(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.metadata.insert(key.into(), value.into());
        self
    }
    
    pub fn build(self) -> Result<Contract, BuildError> {
        Ok(Contract {
            name: self.name.ok_or(BuildError::MissingName)?,
            version: self.version.ok_or(BuildError::MissingVersion)?,
            fields: self.fields,
            metadata: self.metadata,
        })
    }
}

// Usage
let contract = ContractBuilder::new()
    .name("UserAPI")
    .version("2.0")
    .field(Field::new("id", FieldType::Integer))
    .field(Field::new("email", FieldType::String))
    .metadata("author", "Alice")
    .build()?;
```

---

## Test Organization

### Module-Based Tests

```rust
// src/contract.rs
pub fn validate(contract: &Contract) -> Result<&Contract, ValidationError> {
    if contract.name.is_empty() {
        return Err(ValidationError::NameRequired);
    }
    Ok(contract)
}

#[cfg(test)]
mod tests {
    use super::*;

    mod validate {
        use super::*;

        #[test]
        fn returns_ok_for_valid_contract() {
            let contract = Contract {
                name: "test".into(),
                version: "1.0".into(),
                fields: vec![],
            };
            
            assert!(validate(&contract).is_ok());
        }

        #[test]
        fn returns_err_for_empty_name() {
            let contract = Contract {
                name: "".into(),
                version: "1.0".into(),
                fields: vec![],
            };
            
            assert!(matches!(
                validate(&contract),
                Err(ValidationError::NameRequired)
            ));
        }
    }
}
```

### Property-Based Testing

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn parse_and_serialize_roundtrip(name: String, version: String) {
        let contract = Contract { name, version, fields: vec![] };
        let serialized = serialize(&contract)?;
        let deserialized = deserialize(&serialized)?;
        
        prop_assert_eq!(contract, deserialized);
    }
}
```

---

## Trait-Based Polymorphism

### Small, Focused Traits

```rust
// BAD - kitchen sink trait
trait Repository {
    fn create(&mut self, user: User) -> Result<(), Error>;
    fn read(&self, id: &str) -> Result<User, Error>;
    fn update(&mut self, user: User) -> Result<(), Error>;
    fn delete(&mut self, id: &str) -> Result<(), Error>;
    fn list(&self) -> Result<Vec<User>, Error>;
    fn search(&self, query: &str) -> Result<Vec<User>, Error>;
}

// GOOD - focused traits
trait UserReader {
    fn read(&self, id: &str) -> Result<User, Error>;
}

trait UserWriter {
    fn create(&mut self, user: User) -> Result<(), Error>;
}

trait UserSearcher {
    fn search(&self, query: &str) -> Result<Vec<User>, Error>;
}
```

### Trait Objects vs Generics

```rust
// Generics - monomorphization (faster, larger binary)
fn process<R: Reader>(reader: R) -> Result<Output, Error> {
    let data = reader.read()?;
    transform(data)
}

// Trait objects - dynamic dispatch (smaller binary, slight runtime cost)
fn process(reader: &dyn Reader) -> Result<Output, Error> {
    let data = reader.read()?;
    transform(data)
}

// Use generics for hot paths, trait objects for flexibility
```

---

## Error Handling

### Custom Error Types

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ValidationError {
    #[error("name is required")]
    NameRequired,
    
    #[error("version is required")]
    VersionRequired,
    
    #[error("invalid field: {0}")]
    InvalidField(String),
    
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
}

// Usage
fn validate(contract: &Contract) -> Result<(), ValidationError> {
    if contract.name.is_empty() {
        return Err(ValidationError::NameRequired);
    }
    Ok(())
}
```

### Error Propagation

```rust
// Use ? for error propagation
fn load_config(path: &Path) -> Result<Config, Error> {
    let content = std::fs::read_to_string(path)?;  // Propagates std::io::Error
    let config = serde_json::from_str(&content)?;   // Propagates serde_json::Error
    Ok(config)
}

// map_err for error conversion
fn parse(data: &str) -> Result<Value, AppError> {
    serde_json::from_str(data)
        .map_err(|e| AppError::ParseError(e.to_string()))
}
```

---

## Ownership and Borrowing

### Function Signatures

```rust
// Take ownership when you need to consume
fn process(data: Vec<u8>) -> ProcessedData {
    // data is moved, caller can't use it anymore
}

// Borrow immutably when you just read
fn analyze(data: &[u8]) -> Analysis {
    // data is borrowed, caller retains ownership
}

// Borrow mutably when you need to modify
fn transform(data: &mut Vec<u8>) {
    // data is mutably borrowed, caller can still use it after
}

// Return owned data when creating new values
fn generate() -> Vec<u8> {
    vec![1, 2, 3]  // Ownership transferred to caller
}
```

### Clone Wisely

```rust
// BAD - unnecessary clone
fn process(data: &Data) -> ProcessedData {
    let cloned = data.clone();  // Expensive!
    transform(cloned)
}

// GOOD - borrow when possible
fn process(data: &Data) -> ProcessedData {
    transform(data)  // Just reference
}

// Clone only when you need owned data
fn process(data: &Data) -> ProcessedData {
    if needs_modification(data) {
        let mut owned = data.clone();
        modify(&mut owned);
        transform(owned)
    } else {
        transform(data)
    }
}
```

---

## Iterator Patterns

### Functional Transformations

```rust
// Chaining iterator adapters (lazy, efficient)
let result: Vec<_> = items
    .iter()
    .filter(|item| item.is_active())
    .map(|item| item.price)
    .filter(|&price| price > 100.0)
    .collect();

// Early termination
let first_expensive = items
    .iter()
    .find(|item| item.price > 1000.0);

// Avoiding allocations with iterators
fn sum_prices(items: &[Item]) -> f64 {
    items.iter()
        .map(|item| item.price)
        .sum()  // No intermediate Vec allocated
}
```

---

## Concurrency

### Thread Safety with Send and Sync

```rust
use std::sync::{Arc, Mutex};
use std::thread;

// Arc for shared ownership across threads
let data = Arc::new(Mutex::new(vec![1, 2, 3]));

let handles: Vec<_> = (0..3)
    .map(|i| {
        let data = Arc::clone(&data);
        thread::spawn(move || {
            let mut data = data.lock().unwrap();
            data.push(i);
        })
    })
    .collect();

for handle in handles {
    handle.join().unwrap();
}
```

### Channels for Communication

```rust
use std::sync::mpsc;
use std::thread;

let (tx, rx) = mpsc::channel();

// Sender thread
thread::spawn(move || {
    for i in 0..10 {
        tx.send(i).unwrap();
    }
});

// Receiver thread
for received in rx {
    println!("Got: {}", received);
}
```

---

## Dependency Injection

### Constructor Injection

```rust
pub struct Handler<R: Reader, W: Writer> {
    reader: R,
    writer: W,
}

impl<R: Reader, W: Writer> Handler<R, W> {
    pub fn new(reader: R, writer: W) -> Self {
        Handler { reader, writer }
    }
    
    pub fn process(&self, input: &str) -> Result<(), Error> {
        let data = self.reader.read(input)?;
        let transformed = transform(data);
        self.writer.write(&transformed)?;
        Ok(())
    }
}

// Test with fakes
#[test]
fn test_process() {
    let fake_reader = FakeReader::new(vec![1, 2, 3]);
    let fake_writer = FakeWriter::new();
    
    let handler = Handler::new(fake_reader, fake_writer);
    assert!(handler.process("input").is_ok());
}
```

---

## Testable Time

```rust
use chrono::{DateTime, Utc};

// Trait for clock abstraction
pub trait Clock {
    fn now(&self) -> DateTime<Utc>;
}

// Real implementation
pub struct SystemClock;

impl Clock for SystemClock {
    fn now(&self) -> DateTime<Utc> {
        Utc::now()
    }
}

// Fake for tests
pub struct FakeClock {
    time: DateTime<Utc>,
}

impl Clock for FakeClock {
    fn now(&self) -> DateTime<Utc> {
        self.time
    }
}

// Usage
fn is_expired<C: Clock>(subscription: &Subscription, clock: &C) -> bool {
    subscription.end_date < clock.now()
}

#[test]
fn test_expiration() {
    let clock = FakeClock {
        time: Utc.ymd(2024, 1, 1).and_hms(0, 0, 0),
    };
    
    let subscription = Subscription {
        end_date: Utc.ymd(2023, 12, 31).and_hms(0, 0, 0),
    };
    
    assert!(is_expired(&subscription, &clock));
}
```

---

## Common Patterns

### Newtype Pattern

```rust
// Wrap primitive types for type safety
pub struct UserId(String);
pub struct Email(String);

impl UserId {
    pub fn new(id: String) -> Result<Self, ValidationError> {
        if id.is_empty() {
            return Err(ValidationError::InvalidUserId);
        }
        Ok(UserId(id))
    }
    
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

// Compiler prevents mixing up types
fn get_user(id: UserId) -> Option<User> {
    // Can't accidentally pass Email here
}
```

### Extension Traits

```rust
// Extend existing types with new methods
pub trait StringExt {
    fn is_valid_email(&self) -> bool;
}

impl StringExt for String {
    fn is_valid_email(&self) -> bool {
        self.contains('@') && self.contains('.')
    }
}

// Usage
let email = "user@example.com".to_string();
assert!(email.is_valid_email());
```

---

## Anti-Patterns

### ❌ Overusing Clone

```rust
// BAD
fn process(data: &Data) -> Vec<ProcessedData> {
    data.items.clone()  // Unnecessary allocation
        .into_iter()
        .map(process_item)
        .collect()
}

// GOOD
fn process(data: &Data) -> Vec<ProcessedData> {
    data.items
        .iter()  // Just iterate, don't clone
        .map(process_item)
        .collect()
}
```

### ❌ Ignoring Result/Option

```rust
// BAD
let config = load_config().unwrap();  // Panics on error!

// GOOD
let config = load_config()?;  // Propagates error

// Or with default
let config = load_config().unwrap_or_default();
```

### ❌ String Allocations in Loops

```rust
// BAD
for item in items {
    let s = item.name.to_string();  // Allocates every iteration
    process(&s);
}

// GOOD
for item in items {
    process(&item.name);  // No allocation, just reference
}
```

---

## Best Practices Summary

1. **Errors** - Use Result and Option, avoid panic except for programming errors
2. **Ownership** - Borrow when possible, clone when necessary
3. **Traits** - Small, focused traits over large ones
4. **Generics** - Use for zero-cost abstractions
5. **Iterators** - Prefer iterator chains over explicit loops
6. **Type safety** - Use newtypes and type states
7. **Concurrency** - Arc + Mutex for shared state, channels for communication
8. **Testing** - Module-based organization, property-based where appropriate
9. **Dependencies** - Inject via generics or trait objects
10. **Zero-cost** - Leverage Rust's zero-cost abstractions

Rust's type system enforces many coding rigor principles at compile time. Use it!
