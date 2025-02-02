//! Regex functions. 
//! > **Warning:** The regex API is current unstable and is subject to change
use mlua::prelude::*;
use pksc_macros::*;
use crate::*;
use onig::*;
//TODO: make it find every match instead of just the first one on each line
fn rmatch(lua: &Lua, (src, patt): (String, String)) -> LuaResult<mlua::Value> {
    let regex = Regex::new(&patt).map_err(|err| mlua::Error::RuntimeError(format!("Could not compile regex pattern: {}", err)))?;
    let mut out: Vec<mlua::Table> = vec![];
    for line in src.lines() {
        if let Some(captures) = regex.captures(&line) {
            let matches: Vec<String> = captures
                .iter()
                .flatten()
                .map(|m| m.to_string())
                .collect();
            out.push(lua.create_sequence_from(matches)?);
        }    
    }
    Ok(mlua::Value::Table(lua.create_sequence_from(out.iter())?))
}

//TODO: support all types of backreferences
fn replace(_lua: &Lua, (src, patt, rep): (String, String, String)) -> LuaResult<String> {
    let regex = Regex::new(&patt).map_err(|err| mlua::Error::RuntimeError(format!("Could not compile regex pattern: {}", err)))?;
    let replaced = regex.replace_all(&src, |caps: &Captures| {
        let mut out = rep.clone();
        for (i, group) in caps.iter().enumerate() {
            if let Some(group_str) = group {
                out = out.replace(&format!(r"\{}", i), group_str);
                
            }
        }
        return out;
    }).to_string();
    Ok(replaced)
}


#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    let re = lua.create_table()?;
    set_table_functions!(lua, re,
        "matches" => rmatch,
        "replace" => replace,
    );
    set_globals!(lua,
        "re" => re,
    );
    Ok(())
}
