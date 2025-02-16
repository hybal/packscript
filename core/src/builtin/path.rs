use std::path::PathBuf;
use mlua::{Value, Error};
use crate::*;
use std::time::UNIX_EPOCH;
use std::ops::Deref;
use std::convert::*;
use std::path::Path;

/// Wraps a PathBuf to be used with lua functions
#[derive(Debug)]
pub struct LuaPath(pub PathBuf);
impl IntoLua for LuaPath {
    /// Converts the given LuaPath into a table with the values:
    /// `extension` => the file extension
    /// `name` => the file name (with extension)
    /// `stem` => the file name (without extension)
    /// `parent` => the parent path
    /// `is_dir` => if this path is a directatory 
    /// `abspath` => the canonicalized path
    /// `path` => the original path
    /// `absparent` => the canonicalized parent path
    fn into_lua(self, lua: &Lua) -> LuaResult<mlua::Value> {
        let out_table = lua.create_table()?;
        set_table!(out_table, 
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

/// Converts a String or Table into a LuaPath
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

/// Gets various statistics about the provided path.
/// Returns a table with:
/// `file_type` => one of "file", "dir", "symlink", or "unknown"
/// `len` => the length of the file
/// `readonly` => whether or not the file is readonly
/// `modified` => the last-modified time in seconds from the unix epoch
/// `accessed` => the last-accessed time in seconds from the unix epoch
/// `create` => the time created in seconds from the unix epoch
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
        "modified" => metadata.modified()?.duration_since(UNIX_EPOCH).map_err(Error::external)?.as_secs(),
        "accessed" => metadata.accessed()?.duration_since(UNIX_EPOCH).map_err(Error::external)?.as_secs(),
        "created" => metadata.created()?.duration_since(UNIX_EPOCH).map_err(Error::external)?.as_secs(),
    );
    Ok(out)
}

/// Whether or not the given path exists
fn exists(_: &Lua, path: String) -> LuaResult<bool> {
    Ok(Path::new(&path).exists())
}

#[registry]
fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "path" => |_, path: LuaPath| Ok(path),
        "stat" => stat,
        "exists" => exists
    );
    Ok(())
}

