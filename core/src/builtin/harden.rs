use mlua::prelude::*;
use macros::*;
use crate::utils::*;
use crate::*;
use std::path::PathBuf;


fn open(lua: &Lua, (path, mode): (String, String)) -> LuaResult<mlua::Value> {
    let hardened_path = harden_path(&path).map_err(|err| mlua::Error::external(err))?;
    lua.globals()
        .get::<mlua::Table>("io")?
        .get::<mlua::Function>("open")?
        .call::<mlua::Value>((hardened_path, mode))
}

fn lines(lua: &Lua, (filename, args): (String, mlua::Variadic<mlua::Value>)) -> LuaResult<mlua::Value> {
    let hardened_path = harden_path(&filename).map_err(|err| mlua::Error::external(err))?;
    lua.globals()
        .get::<mlua::Table>("io")?
        .get::<mlua::Function>("lines")?
        .call::<mlua::Value>((hardened_path, args))
}

fn path(lua: &Lua, path: String) -> LuaResult<String> {
    Ok(harden_path(&path).map_err(|err| mlua::Error::external(err))?.canonicalize().map_err(|err| mlua::Error::external(err))?.display().to_string())
}

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_table_functions!(lua, lua.globals().get::<mlua::Table>("io")?,
        "open" => open,
        "lines" => lines,
        "path" => path
    );
    set_table!(lua.globals().get::<mlua::Table>("io")?,
        "popen" => mlua::Value::Nil,
    );
    Ok(())
}
