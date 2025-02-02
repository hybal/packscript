use std::path::PathBuf;
use mlua::{Value, Error};
use crate::*;
use std::time::UNIX_EPOCH;
use std::ops::Deref;
use std::convert::*;
use std::path::Path;


pub struct LuaPath(pub PathBuf);
impl IntoLua for LuaPath {
    fn into_lua(self, lua: &Lua) -> LuaResult<mlua::Value> {
        let out_table = lua.create_table()?;
        set_table!(out_table, 
            "exists" => self.exists(),
            "extension" => self.extension().map(|ext| ext.to_os_string()),
            "name" => self.file_name().map(|ext| ext.to_os_string()),
            "stem" => self.file_stem().map(|ext| ext.to_os_string()),
            "parent" => self.parent().map(|p| p.to_path_buf()),
            "is_dir" => self.is_dir(),
            "abspath" => self.canonicalize()?,
            "path" => self.display().to_string(),
            "absparent" => self.canonicalize()?.parent().map(|p| p.to_path_buf()),
        );
        Ok(mlua::Value::Table(out_table))

    }
}

impl FromLua for LuaPath {
    fn from_lua(value: Value, _lua: &Lua) -> LuaResult<Self> {
        match value {
            Value::String(path) => {
                let temp = path.display().to_string();
                Ok(LuaPath(PathBuf::from(temp)))
            },
            Value::Table(table) => {
                let temp = table.get::<String>("abspath")?;
                Ok(LuaPath(PathBuf::from(temp)))
            },
            _=> {
                Err(Error::FromLuaConversionError {
                    from: value.type_name(),
                    to: "LuaPath".to_string(),
                    message: Some("expected string".to_string())
                })
            }
        }
    }
}

impl Deref for LuaPath {
    type Target = PathBuf;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl AsRef<Path> for LuaPath {
    fn as_ref(&self) -> &Path {
        &self.0
    }
}

fn stat(lua: &Lua, path: LuaPath) -> LuaResult<mlua::Table> {
    let out = lua.create_table()?;
    let metadata = path.metadata()?;
    set_table!(out,
        "file_type" => {
            if metadata.is_file() {
                "file"
            } else if metadata.is_dir() {
                "dir"
            } else if metadata.is_symlink() {
                "symlink"
            } else {
                "unknown"
            }
        },
        "len" => metadata.len(),
        "readonly" => metadata.permissions().readonly(),
        "modified" => metadata.modified()?.duration_since(UNIX_EPOCH).map_err(|err| Error::external(err))?.as_secs(),
        "accessed" => metadata.accessed()?.duration_since(UNIX_EPOCH).map_err(|err| Error::external(err))?.as_secs(),
        "created" => metadata.created()?.duration_since(UNIX_EPOCH).map_err(|err| Error::external(err))?.as_secs(),
    );
    Ok(out)
}

fn exists(_: &Lua, path: String) -> LuaResult<bool> {
    Ok(Path::new(&path).exists())
}

#[registry]
fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "path" => |_, path: String| Ok(LuaPath(PathBuf::from(path))),
        "stat" => stat,
        "exists" => exists
    );
    Ok(())
}

