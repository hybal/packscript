use mlua::prelude::*;
use pksc_macros::*;
use once_cell::sync::Lazy;
pub mod builtin;
pub mod utils;
use std::path::PathBuf;
create_registry!();

pub static CWD: Lazy<PathBuf> = Lazy::new(|| {
    std::env::current_dir().expect("Failed to get current working directory")
});

pub struct PkscOptions {
    pub task: Option<String>,
    pub args: Option<Vec<String>>,
    pub enable_jit: bool,
    pub filepath: Option<String>
}


pub fn build(src: String, options: PkscOptions) -> LuaResult<()> {
    let lua = Lua::new();
    builtin::core::setup_lib(&lua)?; 
    register_all(&lua)?;
    builtin::core::setup_core(&lua)?;
    if !options.enable_jit {
        lua.load("jit.off(true, true)").exec()?;
    }
    lua.load("if cat(IWD..\"/build.lock\") ~= nil then lock = from(cat(IWD..\"/build.lock\"), format.json) end").exec()?;
    lua.load(src).set_name(format!("@[{}]", options.filepath.unwrap_or("unknown".to_string()))).exec()?;
    if let Some(cmd) = options.task {
        if let Some(arguments) = options.args {
            let table = lua.create_sequence_from(arguments.into_iter())?;
            lua.globals().get::<mlua::Function>("runtask")?.call::<()>((cmd, table))?;
        }else {
            lua.load(format!("runtask \"{}\"", cmd)).exec()?;
        }
    }
    lua.load("if next(lock) ~= nil then write(into(lock, format.json), IWD..\"/build.lock\") end").exec()?;

    Ok(())
}
