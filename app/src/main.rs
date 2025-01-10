use mlua::prelude::*;

pub mod stdlib;
fn main() -> LuaResult<()>{
    let lua = Lua::new();
    stdlib::StdLib::create(&lua)?;
    let _ = lua.load(r#"
        greet("me")
        "#).exec();
    Ok(())
}
