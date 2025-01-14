use mlua::prelude::*;
use macros::*;
pub mod builtin;
pub mod utils;
create_registry!();

pub fn build(src: String, task: Option<String>, args: Option<Vec<String>>) -> LuaResult<()>{
    let lua = Lua::new();
    register_all(&lua)?;
    info!("Reading script");
    lua.load(src).exec()?;
    if let Some(cmd) = task {
        info!("Task [{}]", cmd);
        if let Some(arguments) = args {
            let table = lua.create_sequence_from(arguments.into_iter())?;
            lua.globals().get::<mlua::Function>("runtask")?.call((cmd, table))?;
        }else {
            lua.load(format!("runtask \"{}\"", cmd)).exec()?;
        }
    }
    info!("Build Finished");
    Ok(())
}
