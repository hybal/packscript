module parser;
import lexer;
import utils::tree;
import iterator;
import std::collections::list;
import std::io;
def Ast = tree::Tree(<Token>);
def TokenIterator = iterator::Iterator(<Token>);

fault ParsingResult
{
    EXPECT,
    FACTOR,
    EXPR,
    TERM
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
fn Ast*! parse(String code){
    Token[] tokens = lexer::lex(code)!;
    TokenIterator iter = tokens.to_iterator();
    return expr(&iter)!;
}


fn Ast*! expr(TokenIterator* iterator)
{
   Ast* node = term(iterator)!;
   while(iterator.is_next(TokenType.PLUS, TokenType.MINUS)!){
        Ast* op = tree::new_node(<Token>)(iterator.next()!);
        op.left = node;
        op.right = term(iterator)!;
        node = op;
   }
   return node;
}

fn Ast*! term(TokenIterator* iterator)
{
   Ast* node = factor(iterator)!;
   while(iterator.is_next(TokenType.STAR, TokenType.DIV, TokenType.MOD)!){
        Ast* op = tree::new_node(<Token>)(iterator.next()!);
        op.right = factor(iterator)!;
        op.left = node;
        node = op;
   }
   return node;
}

fn Ast*! factor(TokenIterator* iterator)
{
    if(iterator.is_next(TokenType.ID, TokenType.INT, TokenType.FLOAT)!){
        return tree::new_node(<Token>)(iterator.next()!);
    }
    if(iterator.is_next(TokenType.LPAREN)!){
        iterator.next()!;
        Ast* node = expr(iterator)!;
        iterator.expect(TokenType.RPAREN)!;
        return node;
    }
    return ParsingResult.TERM?;
    //boolean(ast, iterator)!;
    

}

fn void! boolean(Ast* ast, TokenIterator* iterator)
{
    if(iterator.is_next(TokenType.BOOL)!){
        ast.set_left(iterator.next()!);
        return;
    }
    boolean_expr(ast, iterator)!;


}

fn void! boolean_expr(Ast* ast, TokenIterator* iterator)
{
    expr(iterator)!;
    if(iterator.is_next(TokenType.LAND, TokenType.LOR)!){
       ast.set_right(iterator.next()!);
    }
}


