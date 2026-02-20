# Scott DDD + Types (Strict Mode, Compressed)

```jsonl
{"kind":"meta","doc":"scott-ddd-types","skill":"functional-rust-generator","version":"1.1.0","compressed":true}
{"kind":"intent","text":"Strict default: type-driven DDD, explicit workflows, compile-time correctness"}
{"kind":"position","points":["Domain correctness in types","Invalid states unconstructable","Workflows explicit","Core consumes trusted types only"]}
{"kind":"non_negotiable","points":["No primitives in domain APIs","No bool control flags","No Option lifecycle","No wildcard in domain matches"]}
{"kind":"design_pattern","steps":["Parse boundary→newtypes","DTO→domain","Pure transitions in core","I/O in shell only"]}
{"kind":"transition_signature","ex":["Unvalidated→Result<Validated,E>","Validated→Result<Priced,E>","Priced→Result<Placed,E>"]}
{"kind":"transition_contract","must":["source","target","expected failures"]}
{"kind":"error_discipline","core":"thiserror","shell":"anyhow+context","ban":"Result<T,String> in core"}
```
