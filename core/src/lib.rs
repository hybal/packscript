use mlua::prelude::*;
use macros::*;
pub mod builtin;
pub mod utils;
create_registry!();

pub fn build(src: String, task: Option<String>) -> LuaResult<()>{
    let lua = Lua::new();
    register_all(&lua)?;
    info!("Reading script");
    lua.load(src).exec()?;
    if let Some(cmd) = task {
        info!("Task [{}]", cmd);
        lua.load(format!("runtask \"{}\"", cmd)).exec()?;
    }
    info!("Build Finished");
    Ok(())
}
