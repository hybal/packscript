use std::fs::File;
use std::io::prelude::*;
use std::path::Path;
use clap::Parser;
use pksc_core::*;
pub mod utils;
use colored::Colorize;

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    ///Use a custom build script.
    #[arg(short, long, value_name="FILE")]
    file: Option<String>,
    #[arg(short, long)]
    ///Toggle JIT compilation
    jit: Option<bool>,
    cmd: Option<String>,
    args: Option<Vec<String>>
    

}

fn main() {
    let cli = Cli::parse();
    let path = match &cli.file {
        Some(f) => Path::new(f),
        None => {
            let mut out = Path::new("build.lua");
            if !out.exists() {
                out = Path::new("build.pksc");
            }
            out
        }
    };

    let mut file = match File::open(path) {
        Err(_) => panic!("Could not find build file"),
        Ok(file) => file
    };

    let mut s = String::new();
    if let Err(err) = file.read_to_string(&mut s) {
        panic!("could not read {}: {}", path.display(), err);
    }
    info!("Building Project");
    let options = PkscOptions {
        task: cli.cmd,
        args: cli.args,
        enable_jit: cli.jit.unwrap_or(true),
        filepath: Some(path.display().to_string())
    };
    match build(s, options) {
        Ok(_) => {},
        Err(msg) => {println!("{}", format!("{}", msg).bold().red()); return;}
    }
    info!("Finished");
}
