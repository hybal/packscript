use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, ItemFn};

#[proc_macro_attribute]
pub fn registry(_attr: TokenStream, item: TokenStream) -> TokenStream {
    let input = parse_macro_input!(item as ItemFn);
    let ident = &input.sig.ident;
    let expanded = quote! {
        #input
        inventory::submit!(crate::RegistryFn{func: #ident});
    };
    TokenStream::from(expanded)
}


#[proc_macro]
pub fn create_registry(_item: TokenStream) -> TokenStream {
    TokenStream::from(quote! {
        pub struct RegistryFn {
            func: fn(&Lua)->LuaResult<()>
        }
        inventory::collect!(RegistryFn);
        fn register_all(lua: &Lua) -> LuaResult<()>{
            for item in inventory::iter::<RegistryFn>{
                (item.func)(lua)?;
            }
            Ok(())
        }
    })
}
