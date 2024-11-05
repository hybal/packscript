module conical::parser;
import conical::lexer;
import conical::utils::tree;
import conical::iterator;
import std::collections::list;
import std::io;
import std::collections::map;
def TokenIterator = iterator::Iterator(<Token>);
def Ast = tree::Tree(<Token>);
fault ParsingResult
{
    EXPECT,
    FACTOR,
    EXPR,
    TERM,
    PRIMARY
}


fn Token! TokenIterator.expect(&self, TokenType type)
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    if(self.peek()!.type != type) return ParsingResult.EXPECT?;
    return self.next();
}

fn bool! TokenIterator.is_next(&self, TokenType... types)
{
    if(!self.has_next()){
        return false;
    }
    foreach(TokenType t : types){
        if(self.peek()!.type == t) return true;
    }
    return false;


}
fn Ast*! parse(String code){
    Token[] tokens = lexer::lex(code)!;
    TokenIterator iter = tokens.to_iterator();
    return stmt(&iter)!;
}

fn Ast*! stmt(TokenIterator* iterator)
{
    while(iterator.is_next(TokenType.SET)!) {
        iterator.next()!;
        Token id = iterator.expect(TokenType.ID)!;
        if(iterator.is_next(TokenType.EQ)!) {
            Ast* eq = tree::new_node(<Token>)(iterator.next())!;
            eq.left = tree::new_node(<Token>)(id);
            eq.right = boolean_expr(iterator)!;
            iterator.expect(TokenType.SEMICOLON)!;
            return eq;
        }
    }
    while(iterator.is_next(TokenType.EQ)!) {
        Token id = iterator.get()!;
        if(iterator.is_next(TokenType.EQ)!) {
            Ast* eq = tree::new_node(<Token>)(iterator.next())!;
            eq.left = tree::new_node(<Token>)(id);
            eq.right = boolean_expr(iterator)!;
            iterator.expect(TokenType.SEMICOLON)!;
            return eq;
        }

    }
    return boolean_expr(iterator)!;
}

fn Ast*! boolean_expr(TokenIterator* iterator)
{
    Ast* node = arith_expr(iterator)!;
    while(iterator.is_next(TokenType.LAND, TokenType.LOR, TokenType.GT, TokenType.LT, TokenType.GTEQ, TokenType.LTEQ, TokenType.EQEQ, TokenType.NEQ)!){
       Ast* op = tree::new_node(<Token>)(iterator.next())!;
       op.left = node;
       op.right = arith_expr(iterator)!;
       node = op;
    }
    return node;
}

fn Ast*! arith_expr(TokenIterator* iterator)
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
   while(iterator.is_next(TokenType.STAR, TokenType.DIV, TokenType.MOD, TokenType.AND, TokenType.OR, TokenType.LSH, TokenType.RSH, TokenType.XOR)!){
        Ast* op = tree::new_node(<Token>)(iterator.next()!);
        op.right = factor(iterator)!;
        op.left = node;
        node = op;
   }
   return node;
}

fn Ast*! factor(TokenIterator* iterator)
{
    if(iterator.is_next(TokenType.MINUS, TokenType.NOT, TokenType.XOR)!) {
        Ast* first = tree::new_node(<Token>)(iterator.next()!);
        Ast* second = primary(iterator)!;
        first.left = second;
        return first;
    }
    if(iterator.is_next(TokenType.LPAREN)!){
        iterator.next()!;
        Ast* node = boolean_expr(iterator)!;
        iterator.expect(TokenType.RPAREN)!;
        return node;
    }
    return primary(iterator)!;
    

}

fn Ast*! primary(TokenIterator* iterator)
{
    if(iterator.is_next(TokenType.ID, TokenType.INT, TokenType.FLOAT, TokenType.BOOL, TokenType.STR, TokenType.CHAR)!){
        return tree::new_node(<Token>)(iterator.next()!);
    }
    return ParsingResult.PRIMARY?;

}





