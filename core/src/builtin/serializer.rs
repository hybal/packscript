use crate::*;
use macros::*;
use mlua::{Lua, Table, Value, Result};
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
        _ => Ok(value)
    }
}

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
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "into" => serialize,
        "from" => deserialize
    );
    Ok(())
}
