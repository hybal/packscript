use mlua::prelude::*;
pub struct LuaFunction {
    pub name: &'static str,
    pub func: &'static str
}

inventory::collect!(LuaFunction);
