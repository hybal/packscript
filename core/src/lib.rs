use mlua::prelude::*;
use macros::*;
use once_cell::sync::Lazy;
pub mod builtin;
pub mod utils;
use std::path::PathBuf;
create_registry!();

pub static CWD: Lazy<PathBuf> = Lazy::new(|| {
    std::env::current_dir().expect("Failed to get current working directory")
});

pub fn build(src: String, task: Option<String>, args: Option<Vec<String>>, enable_jit: bool) -> LuaResult<()> {
    let lua = Lua::new();
    builtin::core::setup_lib(&lua)?; 
    register_all(&lua)?;
    builtin::core::setup_core(&lua)?;
    if !enable_jit {
        lua.load("jit.off(true, true)").exec()?;
    }
    lua.load(src).exec()?;
    if let Some(cmd) = task {
        if let Some(arguments) = args {
            let table = lua.create_sequence_from(arguments.into_iter())?;
            lua.globals().get::<mlua::Function>("runtask")?.call::<()>((cmd, table))?;
        }else {
            lua.load(format!("runtask \"{}\"", cmd)).exec()?;
        }
    }
    Ok(())
}
