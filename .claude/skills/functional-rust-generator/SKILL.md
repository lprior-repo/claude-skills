---
name: functional-rust-generator
description: Functional-first Rust: Data→Calc→Actions, zero panics/unwrap/mut, clippy-flawless. Tests: compiles.
allowed-tools: ["bash"]
version: 3.2.0
---

```jsonl
{"kind":"meta","skill":"functional-rust-generator","version":"3.2.0","updated":"2026-02","format":"markdown-with-embedded-jsonl","compressed":true}
{"kind":"hierarchy","id":"data_calculations_actions","text":"Organize: Data (inert) → Calculations (pure fn) → Actions (I/O). Refactor: Actions→Calc→Data.","order":["Data","Calculations","Actions"],"strategy":"Push logic RIGHT: Actions→Calc→Data"}
{"kind":"tier","id":"data","rank":1,"text":"Inert, serializable, comparable. Use: structs, enums, newtypes, rpds/im.","ex":["JSON","receipt","CustomerId(String)","rpds::Vector"]}
{"kind":"tier","id":"calculations","rank":2,"text":"Pure fn: time-indep, referential transparency, no side effects.","ex":["validate(x)->Result<T,E>","iterator pipelines","state->state transitions"]}
{"kind":"tier","id":"actions","rank":3,"text":"Impure, time-dep, I/O. Keep minimal at shell boundary.","ex":["async fn with tokio","db.read()","file.write()"]}
{"kind":"principle","id":"make_illegal_states_unrepresentable","text":"Use enums for state machines. Each variant has exactly valid fields.","ex_bad":"Order{shipped:bool,addr:Option<Address>}",ex_good":"enum Order{Draft(Draft),Validated(Validated),Shipped(Shipped)}"}
{"kind":"principle","id":"parse_dont_validate","text":"Parse at boundary into trusted types. Once parsed, data is always valid.","ex":"struct Email(String); impl Email{fn parse(s)->Result<Self,Err>}",benefit:"No re-validation needed"}
{"kind":"principle","id":"types_as_documentation","text":"Signature tells everything. No bool params—use enums.","ex_bad":"fn process(flag:bool)",ex_good":"fn process(mode:Mode){enum Mode{A,B}}"}
{"kind":"principle","id":"workflows","text":"StateA→Result<StateB,E> transitions. Pure functions, explicit in types.","ex":"Unvalidated→Validate→Validated→Price→Placed"}
{"kind":"pattern","id":"single_case_union","text":"Newtypes prevent primitive obsession.","ex":"struct CustomerId(String);impl Display for CustomerId{fn fmt(...){write!(f,\"{}\",self.0)}}"}
{"kind":"pattern","id":"persistent_state","text":"State→state transitions, no mut. Use rpds/im.","ex":"State{events:state.events.push_back(event)}"}
{"kind":"pattern","id":"railway","text":"Compose fallible steps: validate(x).and_then(parse).map(transform)","ex":"validate(x).and_then(parse).map(transform)"}
{"kind":"pattern","id":"capability_based","text":"Pass only needed capabilities: impl Fn(...) or traits, not db: &Database.","ex":"fn process(lookup:impl Fn(UserId)->Result<User>)"}
{"kind":"stack","crate":"itertools","use":"iterator pipelines","when":"core+shell"}
{"kind":"stack","crate":"tap","use":"suffix pipelines (pipe/tap/conv)","when":"core(pipe/conv),shell(tap)"}
{"kind":"stack","crate":"rpds","use":"persistent state (default)","when":"agent state"}
{"kind":"stack","crate":"im","use":"persistent state (thread-share)","when":"Arc needed"}
{"kind":"stack","crate":"thiserror","use":"domain errors","when":"core"}
{"kind":"stack","crate":"anyhow","use":"boundary errors","when":"shell/main"}
{"kind":"stack","crate":"tokio","use":"async runtime","when":"shell only"}
{"kind":"stack","crate":"futures-util","use":"async combinators","when":"shell only"}
{"kind":"stack","crate":"tokio-util","use":"codec/compat","when":"shell only"}
{"kind":"bifurcation","id":"source_vs_test","text":"Source: clippy-mandatory, zero unwrap/mut/panic. Tests: whatever compiles.","source":{"clippy":"mandatory","quality":"flawless","unwrap":"banned","mut":"avoid"},"test":{"clippy":"ignore","quality":"irrelevant","unwrap":"allowed","mut":"allowed"}}
{"kind":"rule","id":"no_unwrap","level":"error","scope":"source","bans":["unwrap","expect","panic!","unwrap_or","unwrap_or_else","unwrap_or_default"],"pref":["match","if let","map","and_then","ok_or_else","map_or","map_or_else"]}
{"kind":"rule","id":"no_mut","level":"error","scope":"source","bans":["let mut","mut "],"pref":["fold","scan","map","filter","collect","rpds"]}
{"kind":"rule","id":"pure_core","level":"error","scope":"source","bans":["I/O in core","logging in core","global mutation"],"pref":["pure fn","newtypes","enums","persistent state","shell adapters"]}
{"kind":"rule","id":"no_indexing","level":"error","scope":"source","bans":["arr[i]","slice[i]","vec[i]"],"pref":[".get(i)","Iterator::nth(i)"]}
{"kind":"rule","id":"no_interior_mut","level":"error","scope":"source","bans":["RefCell","Cell","OnceCell","Lazy","OnceLock"],"pref":["pure fn returning new","rpds","explicit mut at shell"]}
{"kind":"rule","id":"no_bool_params","level":"warn","scope":"source","bans":["fn process(flag:bool)"],"pref":["fn process(mode:Mode){enum Mode{A,B}}"]}
{"kind":"rule","id":"no_stringly","level":"warn","scope":"source","bans":["id:String","email:String","amount:i64"],"pref":["UserId","Email","Cents"]}
{"kind":"rule","id":"no_arc_mutex","level":"error","scope":"source","bans":["Arc<Mutex<T>>","Arc<RwLock<T>>"],"pref":["channels","rpds","explicit handoff"]}
{"kind":"rule","id":"expression_based","level":"warn","scope":"source","bans":["let x;if c{x=a;}else{x=b;}"],"pref":["let x=if c{a}else{b};","match as expr"]}
{"kind":"rule","id":"property_based","level":"warn","scope":"source","lib":"proptest","patterns":["for all inputs, output satisfies postcond","f(f⁻¹(x))==x","f(a⊕b)==f(a)⊕f(b)"]}
{"kind":"rule","id":"clippy_mandatory","level":"error","scope":"source","bans":["ignoring clippy","#![allow(clippy::"],"notes":"Fix ALL warnings—no shortcuts"}
{"kind":"rule","id":"use_core_libs","level":"warn","scope":"source","libs":["itertools","tap","rpds","im","thiserror","anyhow"]}
{"kind":"rule","id":"errors","level":"error","text":"Core:thiserror; shell:anyhow with context","bans":["Result<T,String> in core","Box<dyn Error> in core"]}
{"kind":"rule","id":"functional_style","level":"warn","scope":"source","pref":["itertools","combinators"],"bans":["for in core","while in core"]}
{"kind":"rule","id":"no_unsafe","level":"error","bans":["unsafe"],"notes":"Only with justification"}
{"kind":"lint","id":"file_header","scope":"source","lines":["#![deny(clippy::unwrap_used)]","#![deny(clippy::expect_used)]","#![deny(clippy::panic)]","#![warn(clippy::pedantic)]","#![warn(clippy::nursery)]","#![forbid(unsafe_code)]"]}
{"kind":"gate","id":"quality_gates","text":"Source: flawless. Tests: compile+pass.","cmds":["cargo fmt --check -- src/","cargo clippy -- -D warnings -W pedantic -W nursery -- src/","cargo test","cargo build --release"]}
{"kind":"cargo_template","id":"sync","toml":"[dependencies]\nitertools=\"0.14\"\ntap=\"1.0\"\nrpds=\"1.2\"\nthiserror=\"2.0\"\nanyhow=\"1.0\"\n[dev-dependencies]\nproptest=\"1.0\""}
{"kind":"cargo_template","id":"async","toml":"[dependencies]\nitertools=\"0.14\"\ntap=\"1.0\"\nrpds=\"1.2\"#im=\"15.1\"\nthiserror=\"2.0\"\nanyhow=\"1.0\"\ntokio={version=\"1.49\",features=[\"full\"]}\nfutures-util=\"0.3\"\ntokio-util={version=\"0.7\",features=[\"codec\",\"compat\",\"io\"]}\n[dev-dependencies]\nproptest=\"1.0\""}
{"kind":"ref","file":"references/scott-ddd-types.md","use":"Strict DDD+types doctrine"}
{"kind":"ref","file":"references/typing-refactor-checklist.md","use":"Stepwise primitive→type migration"}
{"kind":"ref","file":"references/complete-workflow.md","use":"Full Data→Calc→Actions example"}
```

Examples (compact):
```rust
// Data: newtypes + enums
struct Email(String);
impl Email{fn parse(s:String)->Result<Self,EmailError>{s.contains('@').then(||Self(s)).ok_or(EmailError)}}
enum Order{Draft(Draft),Validated(Validated),Shipped(Shipped)}

// Calculations: pure fn, iterator pipelines
fn validate_order(draft:DraftOrder)->Result<ValidatedOrder,ValidationError>{...}
fn top_names(input:&[String])->Vec<String>{input.iter().map(str::trim).filter(|s|!s.is_empty()).map(String::from).unique().sorted().take(10).collect()}

// Actions: shell only, minimal
async fn process_order(id:u64)->Result<(),anyhow::Error>{let order=db.get_order(id).await?;if should_discount(&order){send_discount().await?}Ok(())}
fn should_discount(order:&Order)->bool{order.total>1000}
```
