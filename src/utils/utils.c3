module conical::utils;
import std::collections;
import conical::parser;
import conical::tunion;
import conical::lexer;
fn bool String.eq(&self, String b){

    if(self.len != b.len) return false;
    StringIterator iter1 = self.iterator();
    StringIterator iter2 = self.iterator();
    while(iter1.has_next() && iter2.has_next()){
        if(iter1.next()!! != iter2.next()!!) return false;
    }
    return true;
}


module conical::parser;
import conical::lexer;
import std::collections::map; //all of this needs to be better
fn long! String.eval_str(&self)
{
    Ast* out = parser::parse(*self)!;
    return out.eval_ast();
}
def SymTab = map::HashMap(<String, long>);
SymTab symbol_table;
fn long! Ast.eval_ast(&self) {
    symbol_table.new_init();
    return self.eval();
}

/*
    will likely want to use monadic types for evaluation, since the evals can fail, and there are several different types that need to be supported, including user types
    an idea would be to use the result/either monad so if the value is an error it is specefically caught (it would also be easy to check)
    however this would increase the size (and amount of boilerplate) of the code, since you would have to check if either of the values are an error, so a lot of if statements. It would    be nice if c3 supported arbitrary error values with faults but since it does not it makes the code larger
*/

fn long! Ast.eval(&self) 
{
    if(self == null) return 0;
    if(self.is_leaf()) {
        if(self.data.type == TokenType.ID) return symbol_table[self.data.token.cast_to(String)]!;
        return self.data.token.cast_to(long);
    }
    switch(self.data.type) {
        case EQ: {
            symbol_table[self.left.data.token.cast_to(String)] = self.right.eval()!;
            return 0;
        }
        case PLUS: return self.left.eval() + self.right.eval();
        case MINUS: return self.right == null ? -self.left.eval()! : self.left.eval() - self.right.eval();
        case STAR: return self.left.eval() * self.right.eval();
        case DIV: return self.left.eval() / self.right.eval();
        case MOD: return self.left.eval() % self.right.eval();
        case GT: return self.left.eval()! > self.right.eval()! ? 1 : 0;
        case LT: return self.left.eval()! < self.right.eval()! ? 1 : 0;
        case GTEQ: return self.left.eval()! >= self.right.eval()! ? 1 : 0;
        case LTEQ: return self.left.eval()! <= self.right.eval()! ? 1 : 0;
        case EQEQ: return self.left.eval()! == self.right.eval()! ? 1 : 0;
        case NEQ: return self.left.eval()! != self.right.eval()! ? 1 : 0;
        case LAND: return self.left.eval()! && self.right.eval()! ? 1 : 0;
        case LOR: return self.left.eval()! || self.right.eval()! ? 1 : 0;
        case NOT: return !self.left.eval()! ? 1 : 0;
        case AND: return self.left.eval() & self.right.eval();
        case OR: return self.left.eval() | self.right.eval();
        case XOR: return self.left.eval() ^ self.right.eval();
        case LSH: return self.left.eval() << self.right.eval();
        case RSH: return self.left.eval() >> self.right.eval();
        default: return 0;
    }
}


