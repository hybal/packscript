//! General cryptographic functions.
use pksc_macros::*;
use mlua::prelude::*;
use mlua::{Error, Either};
use std::hash::Hasher;
use crate::*;
use crate::builtin::path::*;
use sha3::*;
use sha2::*;
use md5::*;
use std::fs;
use hex::encode;
use xxhash_rust::xxh3::*;
use adler32fast::*;
use digest::*;

/// Hashes the given file/s using the given format
/// # Examples
/// ```lua
/// hash("example.txt", format.hash.md5)
/// ```
fn hash(lua: &Lua, (file, format): (Either<LuaPath, Vec<LuaPath>>, String)) -> LuaResult<String> {
    match file {
        mlua::Either::Left(path) => {
            let data = fs::read_to_string(path)?;
            hash_str(lua, (data, format))
        },
        mlua::Either::Right(paths) => {
            let mut hasher = get_hasher(&format)?;
            for path in paths {
                let data = fs::read_to_string(path)?;
                hasher.update(data.as_ref());
            }
            Ok(encode(hasher.finalize()))
        }
    }
}


fn get_hasher(format: &str) -> LuaResult<Box<dyn DynDigest>> {
    Ok(match format {
        "sha256" => Box::new(Sha256::new()),
        "sha512" => Box::new(Sha512::new()),
        "sha224" => Box::new(Sha224::new()),
        "sha512-224" => Box::new(Sha512_224::new()),
        "sha512-256" => Box::new(Sha512_256::new()),
        "sha384" => Box::new(Sha384::new()),
        "sha3-224" => Box::new(Sha3_224::new()),
        "sha3-256" => Box::new(Sha3_256::new()),
        "sha3-384" => Box::new(Sha3_384::new()),
        "sha3-512" => Box::new(Sha3_512::new()),
        "md5" => Box::new(Md5::new()),
        v => return Err(Error::external(format!("Unkown hash algorithm: {}", v)))
    })
 
}
/// Hashes the given string using the given format
/// # Examples
/// ```lua
/// hashs("Hello, World!", format.sha256)
/// ```
fn hash_str(_lua: &Lua, (data, format): (String, String)) -> LuaResult<String> {
    let mut out = get_hasher(&format)?;
    out.update(data.as_ref());
    Ok(encode(out.finalize()))

}

fn get_checksum_algo(format: &str) -> LuaResult<Box<dyn Hasher>> {
    Ok(match format.as_ref() {
        "crc32" => Box::new(crc32fast::Hasher::new()),
        "xxh3" => Box::new(Xxh3::new()),
        "adler32" => Box::new(Adler32::new()),
        v => return Err(Error::external(format!("Unknown checksum algorithm: {}", v)))
    })

}

/// Caclulates a checksum from the given string using the given algorithm
/// # Examples 
/// ```lua
/// checksums("Hello, World!", format.checksum.crc32)
/// ```
fn checksums(_: &Lua, (data, format): (String, String)) -> LuaResult<u64> {
    let mut out = get_checksum_algo(&format)?;
    out.write(data.as_bytes());
    Ok(out.finish())
}

/// Calculates the checksum of the given file/s using the given algorithm
/// # Examples
/// ```lua
/// checksum(path "example.txt", format.checksum.xxh3)
/// ```
fn checksum(lua: &Lua, (file, format): (Either<LuaPath, Vec<LuaPath>>, String)) -> LuaResult<u64> {
    match file {
        mlua::Either::Left(path) => {
            let data = fs::read_to_string(path)?;
            checksums(lua, (data, format))
        },
        mlua::Either::Right(paths) => {
            let mut algo = get_checksum_algo(&format)?;
            for path in paths {
                let data = fs::read_to_string(path)?;
                algo.write(data.as_bytes());
            }
            Ok(algo.finish())
        }
    }
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
