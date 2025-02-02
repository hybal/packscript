//! Setup functions for core.lua
use include_dir::{include_dir, Dir};
use crate::*;
use mlua::{Lua, Result, Value};
use std::fs;
use std::path::Path;
pub static LUA_DIR: Dir = include_dir!("core/lualib");

pub fn setup_lib(lua: &Lua) -> Result<()> {
    let globals = lua.globals();
    let package: mlua::Table = globals.get("package")?;
    let searchers: mlua::Table = package.get("loaders")?;
    let embedded_loader = lua.create_function(|lua, module_name: String| -> Result<Value> {
        if let Some(file) = LUA_DIR.get_file(format!("{}.lua", module_name)) {
            let source = file
                .contents_utf8()
                .ok_or_else(|| mlua::Error::RuntimeError(format!("Failed to load module '{}'", module_name)))?;
            Ok(Value::Function(lua.load(source).set_name(&module_name).into_function()?))
        } else {
            Ok(Value::Nil)
        }
    })?;
    let local_loader = lua.create_function(|lua, module_name: String| -> Result<Value> {
        let path = format!("{}.lua", module_name);
        let file = Path::new(&path); 
        let source = fs::read_to_string(file)
            .or_else(|_| Err(mlua::Error::RuntimeError(format!("Failed to load module '{}'", module_name))))?;
        Ok(Value::Function(lua.load(source).set_name(&module_name).into_function()?))
    })?;
    searchers.push(embedded_loader)?;
    searchers.push(local_loader)?;

    Ok(())
}

pub fn setup_core(lua: &Lua) -> Result<()> {
    let globals = lua.globals();
    let core: mlua::Table = lua.load(LUA_DIR.get_file("core.lua").unwrap().contents_utf8().unwrap()).eval()?;
    for pair in core.pairs::<String, Value>() {
        let (key,value) = pair?;
        globals.set(key, value)?;
    }
    Ok(())
}
#[registry]
fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "build" => build,
    );
    Ok(())
}

/// Deprecated
fn build(_lua: &Lua, (dir, task, enable_jit, args): (String, Option<String>, Option<bool>, mlua::Variadic<String>)) -> LuaResult<()>{
    let source = fs::read_to_string(&Path::new(&dir).join("build.lua"))?;
    let vec = args.to_vec();
    crate::build(source, task, if vec.len() == 0 {None} else {Some(vec)}, if let Some(val) = enable_jit {val} else {true})?;
    Ok(())
}


