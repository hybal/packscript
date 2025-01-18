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
        println!("{}", hardened_path.display());
        original_open.call::<mlua::Value>((hardened_path, mode))
    })?;
    Ok(restricted)
}

fn lines(lua: &Lua, (filename, args): (String, mlua::Variadic<mlua::Value>)) -> LuaResult<mlua::Value> {
    let hardened_path = harden_path(&filename).map_err(|err| mlua::Error::external(err))?;
    lua.globals()
        .get::<mlua::Table>("io")?
        .get::<mlua::Function>("lines")?
        .call::<mlua::Value>((hardened_path, args))
}

fn path(_lua: &Lua, path: String) -> LuaResult<String> {
    Ok(harden_path(&path).map_err(|err| mlua::Error::external(err))?.canonicalize().map_err(|err| mlua::Error::external(err))?.display().to_string())
}

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_table_functions!(lua, lua.globals().get::<mlua::Table>("io")?,
        "lines" => lines,
        "path" => path
    );
    set_table!(lua.globals().get::<mlua::Table>("io")?,
        "popen" => mlua::Value::Nil,
        "open" => create_open(lua)?
    );
    Ok(())
}
