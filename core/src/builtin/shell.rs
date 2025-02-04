//! Various shell functions
use crate::builtin::path::*;
use mlua::prelude::*;
use pksc_macros::*;
use crate::*;
use std::env;
use std::process::Command;
use std::fs;

/// Changes the current directory to `path`
fn cd(_lua: &Lua, path: LuaPath) -> LuaResult<()> {
    env::set_current_dir(&path).map_err(mlua::Error::external)?;
    Ok(())
}

/// Returns the current working directatory 
fn pwd(_lua: &Lua, _: ()) -> LuaResult<LuaPath> {
    let pwd = env::current_dir().map_err(mlua::Error::external)?;
    Ok(LuaPath(pwd))
}

/// Sets the given enviroment variable to the given string
fn setenv(_lua: &Lua, (var, val): (String, String)) -> LuaResult<()> {
    env::set_var(&var, &val);
    Ok(())
}

/// Executes the given command with the given arguments using a new shell. Returns the output
/// instead of printing it
fn exec(lua: &Lua, (cmd, args): (String, mlua::Variadic<String>)) -> LuaResult<mlua::Table> {
    let command = Command::new(&cmd)
        .args(args.into_iter())
        .output()
        .map_err(mlua::Error::external)?;
    let out_table = lua.create_table()?;
    out_table.set("status", command.status.code())?;
    out_table.set("stdout", String::from_utf8(command.stdout).map_err(mlua::Error::external)?)?;
    out_table.set("stderr", String::from_utf8(command.stderr).map_err(mlua::Error::external)?)?;
    Ok(out_table)

}

/// Copies a file or directatory to the destination
fn cp(_: &Lua, (from, to): (LuaPath, LuaPath)) -> LuaResult<()> {
    if to.is_dir() {
        let dest_path = to.join(from.file_name().unwrap());
        fs::copy(from, dest_path).map_err(mlua::Error::external)?;
    } else {
        fs::copy(from, to).map_err(mlua::Error::external)?;
    }
    Ok(())
}

/// Creates a directatory.
/// Returns `true` on success and `false` otherwise.
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
