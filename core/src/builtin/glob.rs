use macros::*;
use crate::*;
use glob::glob;
use crate::builtin::path::*;

fn glob_files(_lua: &Lua, patt: String) -> LuaResult<Vec<LuaPath>> {
    match glob(&patt) {
        Err(err) => Err(mlua::Error::RuntimeError(err.to_string())),
        Ok(entries) => entries.filter_map(Result::ok).map(|entry| {
            Ok(LuaPath(entry))
        }).collect()
    }
}

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "glob" => glob_files
    );
    Ok(())
}
