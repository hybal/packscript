use macros::*;
use mlua::prelude::*;
use crate::utils::*;
use crate::*;


#[registry]
pub fn register(lua: &Lua) -> LuaResult<()>{
    set_globals!(lua,
        "tasks" => lua.create_table()?
    );
    
    Ok(())
}
