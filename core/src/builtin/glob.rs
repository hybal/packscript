use macros::*;
use crate::*;
use glob::glob;


fn glob_files(lua: &Lua, patt: String) -> LuaResult<Vec<mlua::Table>> {
    match glob(&patt) {
        Err(err) => Err(mlua::Error::RuntimeError(err.to_string())),
        Ok(entries) => entries.filter_map(Result::ok).map(|entry| {
            let table = lua.create_table()?;
            table.set("path", entry.display().to_string())?;
            table.set("isdir", entry.is_dir())?;
            Ok(table)
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
