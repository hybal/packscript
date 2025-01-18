use mlua::prelude::*;
use macros::*;
pub mod builtin;
pub mod utils;
create_registry!();

pub fn build(src: String, task: Option<String>, args: Option<Vec<String>>) -> LuaResult<()>{
    let lua = Lua::new();
    builtin::core::setup_lib(&lua)?; 
    register_all(&lua)?;
    builtin::core::setup_core(&lua)?;
    lua.load(src).exec()?;
    if let Some(cmd) = task {
        if let Some(arguments) = args {
            let table = lua.create_sequence_from(arguments.into_iter())?;
            lua.globals().get::<mlua::Function>("runtask")?.call((cmd, table))?;
        }else {
            lua.load(format!("runtask \"{}\"", cmd)).exec()?;
        }
    }
    Ok(())
}
