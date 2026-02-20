# Typing Refactor Checklist (Compressed)

```jsonl
{"kind":"meta","doc":"typing-refactor-checklist","skill":"functional-rust-generator","version":"1.1.0","compressed":true}
{"kind":"check","text":"Identify primitives→domain concepts"}
{"kind":"check","text":"Add newtypes with fallible constructors"}
{"kind":"check","text":"Replace bool params with enums"}
{"kind":"check","text":"Replace status+Option with state enums"}
{"kind":"check","text":"Typed workflow transitions"}
{"kind":"check","text":"Parse/constrain at boundaries"}
{"kind":"check","text":"thiserror for domain errors"}
{"kind":"check","text":"Remove wildcard arms from domain matches"}
{"kind":"check","text":"Add transition tests"}
{"kind":"check","text":"Core uses trusted types only"}
{"kind":"exit","text":"Compiler rejects illegal states"}
```
