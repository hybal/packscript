use std::path::PathBuf;
use std::fs::File;
use std::io::prelude::*;
use std::path::Path;
use clap::{Parser, Subcommand};
use packscript::*;
pub mod utils;

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    ///Use a custom build script.
    #[arg(short, long, value_name="FILE")]
    file: Option<String>,
    cmd: Option<String>,
    args: Option<Vec<String>>
    

}

fn main() {
    let cli = Cli::parse();
    let path = match &cli.file {
        Some(f) => Path::new(f),
        None => Path::new("build.lua")
    };

    let mut file = match File::open(&path) {
        Err(err) => panic!("could not open {}: {}", path.display(), err),
        Ok(file) => file
    };

    let mut s = String::new();
    match file.read_to_string(&mut s) {
        Err(err) => panic!("could not read {}: {}", path.display(), err),
        Ok(_) => {} 
    }
    info!("Building Project");
    match build(s, cli.cmd, cli.args) {
        Ok(_) => {},
        Err(msg) => panic!("build failed with: {}", msg)
    }
    info!("Finished");
}
