//! Various builtin values
use pksc_macros::*;
use mlua::prelude::*;
use crate::*;

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()>{
    set_globals!(lua,
        "tasks" => lua.create_table()?,
        "project" => lua.create_table()?,
        "lock" => lua.create_table()?,
        "IWD" => crate::CWD.display().to_string()
    );
    
    Ok(())
}

