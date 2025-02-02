use mlua::prelude::*;
use crate::*;
use flate2::read::GzDecoder;
use tar::Archive;
use zip::read::ZipArchive;
use std::fs::{self, File};
use std::io::{self, Write, Read};
use crate::builtin::path::*;

fn extract_tar<R: Read>(mut archive: Archive<R>, path_out: PathBuf) -> anyhow::Result<PathBuf> {
    let mut out = None;
    for entry in archive.entries()? {
        let mut entry = entry?;
        let entry_path = entry.path()?.to_path_buf();
        if out.is_none() {
            if let Some(first_comp) = entry_path.components().next() {
                let temp = path_out.join(PathBuf::from(first_comp.as_os_str()));
                if temp.is_dir() {
                    out = Some(temp);
                }
            }
        }
        let mut dest_path = path_out.to_path_buf();
        dest_path.push(&entry_path);
        if entry.path()?.is_dir() {
            fs::create_dir_all(&dest_path)?;
        } else {
            if let Some(parent) = dest_path.parent() {
                fs::create_dir_all(&parent)?;
            }
            entry.unpack(dest_path)?;
        }
    }
    if let Some(out) = out {
        Ok(out)
    } else {
        Ok(path_out)
    }
}

fn extract(_: &Lua, (path_in, path_out, format): (LuaPath, LuaPath, String)) -> anyhow::Result<LuaPath> {
    if !path_out.exists() {
        fs::create_dir_all(&path_out)?;
    }
    let file = File::open(&path_in)?;
    let mut out_path = None;
    match format.as_str() {
        "tar" => {
            let archive = Archive::new(file);
            out_path = Some(extract_tar(archive, path_out.to_path_buf())?);
        },
        "gz" => {
            let mut decoder = GzDecoder::new(file);
            let output_file_name = path_in
                .file_stem()
                .ok_or_else(|| anyhow::anyhow!("Invalid file name"))?;
            let output_file_path = path_out.join(output_file_name);
            out_path = Some(output_file_path.clone());
            let mut output_file = File::create(output_file_path)?;
            let mut src = String::new();
            decoder.read_to_string(&mut src)?;
            output_file.write_all(src.as_bytes())?;
        },
        "tar_gz" => {
            let decoder = GzDecoder::new(file);
            let archive = Archive::new(decoder);
            out_path = Some(extract_tar(archive, path_out.to_path_buf())?);
        },
        "zip" => {
            let mut archive = ZipArchive::new(file)?;
            for i in 0..archive.len() {
                let mut file = archive.by_index(i)?;
                let output_file_path = path_out.join(file.name());
                if i == 0 && output_file_path.is_dir() {
                    out_path = Some(output_file_path.clone());
                }
                if file.is_dir() {
                    fs::create_dir_all(&output_file_path)?;
                } else {
                    if let Some(parent) = output_file_path.parent() {
                        fs::create_dir_all(parent)?;
                    }
                    let mut output_file = File::create(output_file_path)?;
                    io::copy(&mut file, &mut output_file)?;
                }
            }
        },
        v => return Err(anyhow::anyhow!(format!("Unknown compression format: {}", v))),
    }
    if let Some(out) = out_path {
        Ok(LuaPath(out))
    } else {
        Ok(path_out)
    }

}


#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "extract" => |lua, (input_path, output_path, format): (LuaPath, LuaPath, String)| {
            extract(lua, (input_path, output_path, format))
                .map_err(|err| mlua::Error::external(err))
        }
    );
    Ok(())
    
}
