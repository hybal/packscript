
#[macro_export] macro_rules! set_global_functions {
    ($lua:expr, $($name:expr => $value:expr),* $(,)?) => {
        {
            let globals = $lua.globals();
            $(
                globals.set($name, $lua.create_function($value)?)?;
            )*
        }
    }
}
#[macro_export] macro_rules! set_globals {
    ($lua:expr, $($name:expr => $value:expr),* $(,)?) => {
        {
            let globals = $lua.globals();
            $(
                globals.set($name, $value)?;
            )*
        }
    }
}
#[macro_export] macro_rules! set_table {
    ($table:expr, $($name:expr => $value:expr),* $(,)?) => {
        {
            $(
                $table.set($name, $value)?;
            )*
        }
    }
}
#[macro_export] macro_rules! set_table_functions {
    ($lua:expr, $table:expr, $($name:expr => $value:expr),* $(,)?) => {
        {
            $(
                $table.set($name, $lua.create_function($value)?)?;
            )*
        }
    }
}

use std::path::PathBuf;

pub fn harden_path(path: &str) -> Result<PathBuf, std::io::Error> {
    let full_path = if path.starts_with("/") {
        crate::CWD.join(&path[1..])
    } else {
        crate::CWD.join(path)
    };
    let canon = full_path.canonicalize()?;
    let initial_canon = crate::CWD.canonicalize()?;
    if canon.starts_with(&initial_canon) {
        Ok(canon)
    } else {
        Err(std::io::Error::new(std::io::ErrorKind::NotFound, format!("File not found \"{}\", files outside of the script directory cannot be accessed", path)))
    }
}
