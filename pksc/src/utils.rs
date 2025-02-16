
#[macro_export] macro_rules! info {
    ($($args:tt)*) => {
        let out = format!($($args)*);
        println!("{}", colored::Colorize::green(&format!("=> {}", out) as &str));
    }
}
