module package_manager;
import std::io;
import lexer;
import parser;
fn void! main(){
    String test = "30123+2-123";
    Ast* ast = parser::parse(test)!;
    io::printn(ast);
}
