module parser;
import lexer;
import utils::tree;
import iterator;
import std::collections::list;

def Ast = tree::Tree(<Token>);
def TokenIterator = iterator::Iterator(<Token>);

fault ParsingResult
{
    EXPECT
}

fn Token! TokenIterator.expect(&self, TokenType type)
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    if(self.peek()!.type != type) return ParsingResult.EXPECT?;
    return self.next();
}

fn bool! TokenIterator.is_next(&self, TokenType... types)
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    foreach(TokenType t : types){
        if(self.peek()!.type == t) return true;
    }
    return false;


}
fn Ast! parse(String code){
    Token[] tokens = lexer::lex(code)!;
    TokenIterator iter = tokens.to_iterator();
    Ast tree;
    return tree;
}


fn void! expr(Ast ast, TokenIterator iterator)
{
    term(ast, iterator)!;
    if(iterator.is_next(TokenType.PLUS, TokenType.MINUS)!){
        term(*ast.add_child(iterator.next()!), iterator)!;
    }
}

fn void! term(Ast ast, TokenIterator iterator)
{
   factor(ast, iterator)!;
   if(iterator.is_next(TokenType.STAR, TokenType.DIV, TokenType.MOD)!){
        factor(*ast.add_child(iterator.next()!), iterator)!;
   }
}

fn void! factor(Ast ast, TokenIterator iterator)
{
    if(iterator.is_next(TokenType.ID, TokenType.INT, TokenType.FLOAT)!){
        ast.add_child(iterator.next()!);
        return;
    }
    if(iterator.is_next(TokenType.LPAREN)!){
        (void)iterator.next()!;
        expr(ast, iterator)!;
        (void)iterator.expect(TokenType.RPAREN)!;
        return;
    }
    boolean(ast, iterator)!;
    

}

fn void! boolean(Ast ast, TokenIterator iterator)
{
    if(iterator.is_next(TokenType.BOOL)!){
        ast.add_child(iterator.next()!);
        return;
    }
    boolean_expr(ast, iterator)!;


}

fn void! boolean_expr(Ast ast, TokenIterator iterator)
{
    expr(ast, iterator)!;
    if(iterator.is_next(TokenType.LAND, TokenType.LOR)!){
       ast.add_child(iterator.next()!);
    }
}


