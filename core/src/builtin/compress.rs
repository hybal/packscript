use mlua::prelude::*;
use crate::*;
use flate2::read::GzDecoder;
use tar::Archive;
use zip::read::ZipArchive;
use std::fs::{self, File};
use std::io::{self, Write, Read};
use std::path::Path;

fn extract(_lua: &Lua, (path_in, path_out): (String, String)) -> anyhow::Result<String> {
    let input_path = Path::new(&path_in);
    let output_dir = Path::new(&path_out);
    if !output_dir.exists() {
        fs::create_dir_all(output_dir)?;
    }
    let file = File::open(input_path)?;
    match input_path.extension().and_then(|ext| ext.to_str()) {
        Some("gz") if input_path.file_stem().and_then(|stem| stem.to_str()).map(|stem| stem.ends_with(".tar")).unwrap_or(false) => {
            let decoder = GzDecoder::new(file);
            let mut archive = Archive::new(decoder);
            archive.unpack(output_dir)?;
        }
        Some("gz") => {
            let mut decoder = GzDecoder::new(file);
            let output_file_name = input_path
                .file_stem()
                .ok_or_else(|| anyhow::anyhow!("Invalid file name"))?;
            let output_file_path = output_dir.join(output_file_name);
            let mut output_file = File::create(output_file_path)?;
            let mut src = String::new();
            decoder.read_to_string(&mut src)?;
            output_file.write_all(src.as_bytes())?;
        }
        Some("tar") => {
            let mut archive = Archive::new(file);
            archive.unpack(output_dir)?;
        }
        Some("zip") => {
            let mut archive = ZipArchive::new(file)?;
            for i in 0..archive.len() {
                let mut file = archive.by_index(i)?;
                let output_file_path = output_dir.join(file.name());
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
        }
        _ => return Err(anyhow::anyhow!("Unsupported archive format"))
    }
    Ok(output_dir.canonicalize()?.display().to_string())
}

#[registry]
pub fn register(lua: &Lua) -> LuaResult<()> {
    set_global_functions!(lua,
        "extract" => |lua, (input_path, output_path): (String, String)| {
            extract(lua, (input_path, output_path))
                .map_err(|err| mlua::Error::external(err))
        }
    );
    Ok(())
    
}
