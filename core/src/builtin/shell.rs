use mlua::prelude::*;
use macros::*;
use crate::*;


fn cd(lua: &Lua, path: String) -> LuaResult<()> {

    Ok(())
}


#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "cd" => cd
    );
    Ok(())
}
