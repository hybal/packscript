use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, ImplItem, ItemImpl};


#[proc_macro_attribute]
pub fn lua_builtin(_attr: TokenStream, item: TokenStream) -> TokenStream {
    let mut input = parse_macro_input!(item as ItemImpl);
    let mut functions = Vec::new();
    for item in &input.items {
        if let ImplItem::Fn(method) = item {
            if matches!(&method.vis, syn::Visibility::Public(_)) {
                let ident = &method.sig.ident;
                let name = ident.to_string();
                functions.push(quote! {#name, lua.create_function(Self::#ident)?});
            }
        }
    }

    let expanded = quote! {
        pub fn create(lua: &Lua) -> LuaResult<()> {
            #(lua.globals().set(#functions)?;)*
            Ok(())
        }
    };
    input.items.push(syn::ImplItem::Verbatim(expanded));
    TokenStream::from(quote!{#input})
}
