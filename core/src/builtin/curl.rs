use curl::easy::Easy;
use crate::utils::*;
use macros::*;
use std::io::{self, Write};
use std::fs::File;
use mlua::prelude::*;
fn curl(lua: &Lua, (url, name): (String, String)) -> LuaResult<()> {
    let mut handle = Easy::new();
    let mut file = File::create(name)?;
    handle.url(&url).unwrap();
    handle.follow_location(true).unwrap();
    handle.write_function(move |data| {
        file.write_all(data).map(|_| data.len()).map_err(|e| {
            eprintln!("Error: Could not write to file, {}", e);
            curl::easy::WriteError::Pause
        })
    }).unwrap();
    match handle.perform() {
        Err(err) => panic!("Failed to preform: {}", err),
        Ok(_) => {}
    }
    Ok(())
}

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    crate::set_global_functions!(lua,
        "curl" => curl
    );
    Ok(()) 
}
