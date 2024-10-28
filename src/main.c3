module conical::package_manager;
import std::io;
import conical::lexer;
import conical::parser;
import conical::utils;
fn void! main(String[] args){
    while(true){
        io::print(">>> ");
        String line = io::readline()!;
        Ast*! tree = parser::parse(line);
        if(catch e = tree) {
            io::eprintfn("Parser failed with %s", e);
            continue;
        }
        io::printn(tree);
        io::printn(tree.eval())!!;

    }
}
