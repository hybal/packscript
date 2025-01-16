use include_dir::{include_dir, Dir};
use mlua::prelude::*;
use mlua::{Lua, Result, Value, Function};
use macros::*;
pub static LUA_DIR: Dir = include_dir!("lualib");

#[registry]
pub fn setup_lib(lua: &Lua) -> Result<()> {
    let globals = lua.globals();
    let package: mlua::Table = globals.get("package")?;
    let searchers: mlua::Table = package.get("searchers")?;
    let custom_loader = lua.create_function(|lua, module_name: String| {
        if let Some(file) = LUA_DIR.get_file(format!("{}.lua", module_name)) {
            let source = file
                .contents_utf8()
                .ok_or_else(|| mlua::Error::RuntimeError(format!("Failed to load module '{}'", module_name)))?;
            lua.load(source).set_name(&module_name).into_function()
        } else {
            Err(mlua::Error::RuntimeError(format!(
                        "Module '{}' not found in embedded library",
                        module_name
            )))
        }
    })?;
    searchers.push(custom_loader)?;
    let core: mlua::Table = lua.load(LUA_DIR.get_file("core.lua").unwrap().contents_utf8().unwrap()).eval()?;
    for pair in core.pairs::<String, Value>() {
        let (key,value) = pair?;
        globals.set(key, value)?;
    }

    Ok(())
}


