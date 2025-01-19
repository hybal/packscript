use mlua::prelude::*;
use macros::*;
use crate::utils::*;
use crate::*;

fn create_open(lua: &Lua) -> LuaResult<mlua::Function> {
    let original_open = lua.globals()
        .get::<mlua::Table>("io")?
        .get::<mlua::Function>("open")?;
    let restricted = lua.create_function(move |_lua, (path, mode): (String, String)| {
        let hardened_path = harden_path(&path).map_err(|err| mlua::Error::external(err))?;
        original_open.call::<mlua::Value>((hardened_path, mode))
    })?;
    Ok(restricted)
}

fn create_lines(lua: &Lua) -> LuaResult<mlua::Function> {
    let original_lines = lua.globals()
        .get::<mlua::Table>("io")?
        .get::<mlua::Function>("lines")?;
    let restricted = lua.create_function(move |_, path: String| {
        let hardened_path = harden_path(&path).map_err(|err| mlua::Error::external(err))?;
        original_lines.call::<mlua::Value>(hardened_path)
    })?;
    Ok(restricted)
}

fn path(_lua: &Lua, path: String) -> LuaResult<String> {
    Ok(harden_path(&path).map_err(|err| mlua::Error::external(err))?.canonicalize().map_err(|err| mlua::Error::external(err))?.display().to_string())
}

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_table_functions!(lua, lua.globals().get::<mlua::Table>("io")?,
        "path" => path
    );
    set_table!(lua.globals().get::<mlua::Table>("io")?,
        "popen" => mlua::Value::Nil,
        "open" => create_open(lua)?,
        "lines" => create_lines(lua)?
    );
    Ok(())
}
