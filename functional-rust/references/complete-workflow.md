# Complete Workflow Example (Compressed)

```rust
// DATA: newtypes + state machine enum
#[derive(Clone,Debug,Serialize,Deserialize)]pub struct CustomerId(String);
#[derive(Clone,Debug,Serialize,Deserialize)]pub struct Email(String);
impl Email{pub fn parse(s:String)->Result<Self,EmailError>{s.contains('@').then(||Self(s)).ok_or(EmailError)}}
#[derive(Clone,Debug,Serialize,Deserialize)]pub struct OrderId(u64);
#[derive(Clone,Debug,Serialize,Deserialize)]pub struct Cents(u64);
enum Order{Draft(Draft),Validated(Validated),Priced(Priced),Placed(Placed)}
struct Draft{customer_id:CustomerId,items:Vec<OrderItem>}
struct Validated{customer_id:CustomerId,items:Vec<ValidatedItem>}
struct Priced{customer_id:CustomerId,items:Vec<PricedItem>,total:Cents}
struct Placed{order_id:OrderId,customer_id:CustomerId,items:Vec<PricedItem>,total:Cents}

// CALCULATIONS: pure fn
#[derive(Error)]enum ValidationError{#[error("no items")]NoItems,#[error("invalid qty")]InvalidQty}
fn validate_order(draft:Draft)->Result<Validated,ValidationError>{...}
fn price_order(validated:Validated,catalog:&Catalog)->Priced{...}

// ACTIONS: shell only
async fn place_order_workflow(draft:Draft,db:&Database,catalog:&Catalog,id_gen:&mut IdGen)->Result<Placed,anyhow::Error>{
    let validated=validate_order(draft)?;
    let priced=price_order(validated,catalog);
    let order_id=id_gen.next();
    db.save_order(&priced).await?;
    Ok(Placed{order_id,customer_id:priced.customer_id,items:priced.items,total:priced.total})
}
```
