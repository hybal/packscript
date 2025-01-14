
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

#[macro_export] macro_rules! info {
    ($($args:tt)*) => {
        use colored::*;
        let out = format!($($args)*);
        println!("{}", format!("=> {}", out).green());
    }
}
