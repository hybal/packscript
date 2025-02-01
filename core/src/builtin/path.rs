use std::path::PathBuf;
use std::path::Path;
use mlua::*;
use crate::*;

pub struct LuaPath(pub PathBuf);
impl IntoLua for LuaPath {
    fn into_lua(self, lua: &Lua) -> LuaResult<mlua::Value> {
        let out_table = lua.create_table()?;
        set_table!(out_table, 
            "exists" => self.0.exists(),
            "extension" => self.0.extension().map(|ext| ext.to_os_string()),
            "name" => self.0.file_name().map(|ext| ext.to_os_string()),
            "stem" => self.0.file_stem().map(|ext| ext.to_os_string()),
            "parent" => self.0.parent().map(|p| p.to_path_buf()),
            "is_dir" => self.0.is_dir(),
            "abspath" => self.0.canonicalize()?,
            "path" => self.0.display().to_string(),
            "absparent" => self.0.canonicalize()?.parent().map(|p| p.to_path_buf()),
        );
        Ok(mlua::Value::Table(out_table))

    }
}

#[registry]
fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "path" => |_, path: String| Ok(LuaPath(Path::new(path.display().to_string().as_str()).to_path_buf()))
    );
    Ok(())
}

