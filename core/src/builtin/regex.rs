//! Regex functions. 
use mlua::prelude::*;
use pksc_macros::*;
use crate::*;
use fancy_regex::Regex;



///takes a string and a pattern and returns an array with all of the matches for that pattern. 
fn rmatch(lua: &Lua, (src, patt): (String, String)) -> LuaResult<mlua::Value> {
    let regex = Regex::new(&patt).map_err(|err| mlua::Error::RuntimeError(format!("Could not compile regex pattern: {}", err)))?;
    let matches: Result<Vec<_>, _> = regex.captures_iter(&src)
        .map(|caps| caps.unwrap().iter().flatten()
            .map(|val| lua.create_string(val.as_str()))
            .collect::<Result<Vec<_>, _>>())
        .map(|res| res.and_then(|value| lua.create_sequence_from(value.iter())))
        .collect();
    let matches = matches?;
    Ok(mlua::Value::Table(lua.create_sequence_from(matches.iter())?))
}

///replaces all occurences of `patt` in `src` using `rep`
fn replace_all(_lua: &Lua, (src, patt, rep): (String, String, String)) -> LuaResult<String> {
    let regex = Regex::new(&patt).map_err(|err| mlua::Error::RuntimeError(format!("Could not compile regex pattern: {}", err)))?;
    let replaced = regex.replace_all(&src, &rep).to_string();
    Ok(replaced)
}

///replaces the first occurence of `patt` in `src` using `rep`
fn replace(_lua: &Lua, (src, patt, rep): (String, String, String)) -> LuaResult<String> {
    let regex = Regex::new(&patt).map_err(|err| mlua::Error::RuntimeError(format!("Could not compile regex pattern: {}", err)))?;
    let replaced = regex.replace(&src, &rep).to_string();
    Ok(replaced)
}


#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    let re = lua.create_table()?;
    set_table_functions!(lua, re,
        "matches" => rmatch,
        "replace_all" => replace_all,
        "replace" => replace
    );
    set_globals!(lua,
        "re" => re,
    );
    Ok(())
}
