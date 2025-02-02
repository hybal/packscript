//! Network Functions
use std::collections::HashMap;
use pksc_macros::*;
use reqwest::Client;
use tokio::runtime::Runtime;
use mlua::prelude::*;

/// Sends a GET request to `url` given `options`
/// Returns: the fetched data
/// Options is a table with two keys:
/// `headers` => key-value pairs to send as headers
/// `query` => key-value pairs for queries (equivalent to appending ?key=value to the url)
async fn fetch(lua: Lua, (url, options): (String, Option<HashMap<String, mlua::Value>>)) -> LuaResult<mlua::Value>{
    let runtime = Runtime::new().map_err(|err| mlua::Error::external(format!("Failed to create Tokio runtime: {}", err)))?;
    runtime.block_on(async {
        let client = Client::new();
        let mut request = client.get(&url);
        if let Some(option) = options {
            for (key, value) in option {
                match key.as_str() {
                    "headers" => {
                        if let mlua::Value::Table(headers) = value {
                            for pair in headers.pairs::<String, String>() {
                                if let Ok((header_name, header_value)) = pair {
                                    request = request.header(header_name, header_value);
                                }
                            }
                        }
                    },
                    "query" => {
                        if let mlua::Value::Table(query) = value {
                            let mut query_params = vec![];
                            for pair in query.pairs::<String, String>() {
                                if let Ok((key, value)) = pair {
                                    query_params.push((key, value));
                                }
                            }
                            request = request.query(&query_params);
                        }
                    }
                    _ => {}
            }
        }
        }
        match request.send().await {
            Ok(response) => match response.bytes().await {
                Ok(body) => Ok(mlua::Value::String(lua.create_string(&body)?)),
                Err(err) => Err(mlua::Error::external(format!("Error reading response body: {}", err))),
            },
            Err(err) => Err(mlua::Error::external(format!("Request failed: {}", err)))
        }
    })
}

#[registry]
fn register(lua: &Lua) -> LuaResult<()> {
    crate::set_globals!(lua,
        "fetch" => lua.create_async_function(fetch)?
    );
    Ok(()) 
}
