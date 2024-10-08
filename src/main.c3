module package_manager;
import std::io;
import lexer;
import parser;
fn void! main(){
    String test = "30123 + 4 + 12";
    Token[] tokens = lexer::lex(test)!;
    //Ast ast = parser::parse(test)!;
    io::printn(tokens);    
}
