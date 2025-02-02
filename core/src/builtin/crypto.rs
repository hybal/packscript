//! General cryptographic functions.
use pksc_macros::*;
use crate::*;
use crate::builtin::path::*;
use mlua::*;
use sha3::*;
use sha2::*;
use md5::*;
use std::fs;
use hex::encode;
use xxhash_rust::xxh3::*;
use adler32fast::*;

/// Hashes the given file using the given format
/// # Examples
/// ```lua
/// hash("example.txt", format.hash.md5)
/// ```
fn hash(lua: &Lua, (file, format): (LuaPath, String)) -> LuaResult<String> {
    let data = fs::read_to_string(file.0)?;
    Ok(hash_str(lua, (lua.create_string(data)?, format))?)
}

/// Hashes the given string using the given format
/// # Examples
/// ```lua
/// hashs("Hello, World!", format.sha256)
/// ```
fn hash_str(lua: &Lua, (data, format): (String, String)) -> LuaResult<String> {
    let format_str = format.to_str()?;
    let data = data.display().to_string();
    let out = match format_str.as_ref() {
        "sha256" => encode(Sha256::digest(data)),
        "sha512" => encode(Sha512::digest(data)),
        "sha224" => encode(Sha224::digest(data)),
        "sha512-224" => encode(Sha512_224::digest(data)),
        "sha512-256" => encode(Sha512_256::digest(data)),
        "sha384" => encode(Sha384::digest(data)),
        "sha3-224" => encode(Sha3_224::digest(data)),
        "sha3-256" => encode(Sha3_256::digest(data)),
        "sha3-384" => encode(Sha3_384::digest(data)),
        "sha3-512" => encode(Sha3_512::digest(data)),
        "md5" => encode(Md5::digest(data)),
        v => return Err(Error::external(format!("Unkown hash algorithm: {}", v)))

    };
    Ok(lua.create_string(out)?)

}

/// Caclulates a checksum from the given string using the given algorithm
/// # Examples 
/// ```lua
/// checksums("Hello, World!", format.checksum.crc32)
/// ```
fn checksums(_: &Lua, (data, format): (String, String)) -> LuaResult<u64> {
    let format_str = format.to_str()?;
    let data = data.display().to_string();
    let out = match format_str.as_ref() {
        "crc32" => crc32fast::hash(data.as_bytes()) as u64,
        "xxh3" => xxh3_64(data.as_bytes()),
        "adler32" => {
            let mut hasher = Adler32::new();
            hasher.update(data.as_bytes());
            hasher.as_u32() as u64
        },
        v => return Err(Error::external(format!("Unknown checksum algorithm: {}", v)))
    };
    Ok(out)
}

/// Calculates the checksum of the given file using the given algorithm
/// # Examples
/// ```lua
/// checksum(path "example.txt", format.checksum.xxh3)
/// ```
fn checksum(lua: &Lua, (file, format): (LuaPath, String)) -> LuaResult<u64> {
    let data = fs::read_to_string(file.0)?;
    Ok(checksums(lua, (lua.create_string(data)?, format))?)
}

#[registry]
fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "hash" => hash,
        "hashs" => hash_str,
        "checksum" => checksum,
        "checksums" => checksums
    );
    Ok(())
}
