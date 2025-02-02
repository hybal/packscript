//! Serialization/ Deserialization functions
use crate::*;
use mlua::{Lua, Value, Result};

/// Utility function to recursivaly call `__serialize` on each pair
fn process(lua: &Lua, value: Value) -> Result<Value> {
    match value {
        Value::Table(table) => {
            if let Some(meta) = table.metatable().and_then(|mt| mt.get::<Value>("__serialize").ok()) {
                if let Value::Function(func) = meta {
                    let serialized: Value = func.call(table.clone())?;
                    return process(lua, serialized);
                }
            }
            let new_table = lua.create_table()?;
            for pair in table.pairs::<Value, Value>() {
                let (key, value) = pair?;
                new_table.set(key, process(lua, value)?)?;
            }
            Ok(Value::Table(new_table))
        },
        Value::UserData(data) => {
            if let Ok(meta) = data.metatable().and_then(|mt| mt.get::<Value>("__serialize")) {
                if let Value::Function(func) = meta {
                    let serialized: Value = func.call(data.clone())?;
                    return Ok(serialized);
                }
            }
            Ok(mlua::Value::Table(lua.create_table()?))
        },
        _ => Ok(value)
    }
}

/// Lua Name: `from`
/// converts the given string into a lua table using the given table.
fn deserialize(lua: &Lua, (string, format): (String, String)) -> LuaResult<Value> {
    let value: serde_json::Value = match &format as &str {
        "json" => serde_json::from_str(&string).unwrap(),
        "toml" => toml::from_str(&string).unwrap(),
        "yaml" => serde_yml::from_str(&string).unwrap(),
        "ini" => serde_ini::from_str(&string).unwrap(),
        _ => return Err(mlua::Error::RuntimeError("Unsupported serialization format".into()))
    };
    let deserialized = lua.to_value(&value)?;
    Ok(deserialized)
}

/// Lua Name: `into`
/// converts the given lua value into a string using the given format
fn serialize(lua: &Lua, (table, format):(mlua::Value, String)) -> LuaResult<String> {
    let processed_value = process(lua, table)?;
    let value = lua.from_value::<serde_json::Value>(processed_value.clone())?;
    let serialized = match &format as &str {
        "json" => serde_json::to_string_pretty(&value).unwrap(),
        "toml" => toml::to_string_pretty(&value).unwrap(),
        "yaml" => serde_yml::to_string(&value).unwrap(),
        "ini" => serde_ini::to_string(&value).unwrap(),
        _ => return Err(mlua::Error::RuntimeError("Unsupported serialization format".into())),
    };
    Ok(serialized)
}
#[registry]
fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "into" => serialize,
        "from" => deserialize
    );
    Ok(())
}
