use macros::*;
use mlua::prelude::*;
use crate::*;

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()>{
    set_globals!(lua,
        "tasks" => lua.create_table()?,
        "project" => create_project(lua)?
    );
    
    Ok(())
}

fn create_project(lua: &Lua) -> LuaResult<mlua::Table> {
    let out = lua.create_table()?;
    out.set("config", lua.create_table()?)?;
    Ok(out)
}
