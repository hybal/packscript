use mlua::prelude::*;
use macros::*;
pub struct StdLib;

#[lua_builtin]
impl StdLib {
    pub fn greet(lua: &Lua, name: String) -> LuaResult<String> {
        println!("hello, {}", name);
        Ok(format!("hello, {}!", name))
    }
}
