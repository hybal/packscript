#[macro_export] macro_rules! info {
    ($($args:tt)*) => {
        use colored::*;
        let out = format!($($args)*);
        println!("{}", format!("=> {}", out).green());
    }
}
