use mlua::prelude::*;
use macros::*;
use crate::*;
use std::env;
use std::path::Path;
use std::process::Command;
use std::fs;
fn cd(_lua: &Lua, path: String) -> LuaResult<()> {
    env::set_current_dir(Path::new(&path)).map_err(|err| mlua::Error::external(err))?;
    Ok(())
}

fn pwd(_lua: &Lua, _: ()) -> LuaResult<String> {
    let pwd = env::current_dir().map_err(|err| mlua::Error::external(err))?;
    Ok(pwd.display().to_string())
}

fn setenv(_lua: &Lua, (var, val): (String, String)) -> LuaResult<()> {
    env::set_var(&var, &val);
    Ok(())
}

fn exec(lua: &Lua, (cmd, args): (String, mlua::Variadic<String>)) -> LuaResult<mlua::Table> {
    let command = Command::new(&cmd)
        .args(args.into_iter())
        .output()
        .map_err(|err| mlua::Error::external(err))?;
    let out_table = lua.create_table()?;
    out_table.set("status", command.status.code())?;
    out_table.set("stdout", String::from_utf8(command.stdout).map_err(|err| mlua::Error::external(err))?)?;
    out_table.set("stderr", String::from_utf8(command.stderr).map_err(|err| mlua::Error::external(err))?)?;
    Ok(out_table)

}

fn cp(_: &Lua, (from, to): (String, String)) -> LuaResult<()> {
    let src = Path::new(&from);
    let dest = Path::new(&to);

    if dest.is_dir() {
        let dest_path = dest.join(src.file_name().unwrap());
        fs::copy(src, dest_path).map_err(|err| mlua::Error::external(err))?;
    } else {
        fs::copy(from, to).map_err(|err| mlua::Error::external(err))?;
    }
    Ok(())
}

fn mkdir(_: &Lua, path: String) -> LuaResult<bool> {
    match fs::create_dir_all(&path) {
        Ok(_) => Ok(true),
        Err(_) => Ok(false)
    }
}

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "cd" => cd,
        "mkdir" => mkdir,
        "cp" => cp,
        "pwd" => pwd,
        "setenv" => setenv,
        "exec" => exec,
    );
    Ok(())
}
