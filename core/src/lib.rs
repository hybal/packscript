use mlua::prelude::*;
use macros::*;

pub mod builtin;
pub mod utils;
create_registry!();

pub fn build(src: String) -> LuaResult<()>{
    let lua = Lua::new();
    register_all(&lua)?;
    match lua.load(src).exec() {
            Ok(_) => {},
            Err(err) => println!("Error: {}", err)
        }
    Ok(())
}
