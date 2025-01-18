use mlua::prelude::*;
use macros::*;
use crate::*;
use onig::*;
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
