module lexer_test @test;
import std::io;
import lexer;
fn void! test_literal(){
    assert(lexer::lex("12")![0].type == TokenType.INT);
    assert(lexer::lex("1.1")![0].type == TokenType.FLOAT);
    assert(lexer::lex("1104698797")![0].type == TokenType.INT);
    assert(lexer::lex("1.")![0].type == TokenType.FLOAT);
    assert(lexer::lex("0.1")![0].type == TokenType.FLOAT);
    assert(lexer::lex("123908547.1")![0].type == TokenType.FLOAT);
    assert(lexer::lex("1.1")![0].type == TokenType.FLOAT);
    assert(lexer::lex("\"Hello\"")![0].type == TokenType.STR);
    assert(lexer::lex("\'H\'")![0].type == TokenType.CHAR);
    assert(*(ulong*)lexer::lex("0xff")![0].token.ptr == 255);
    assert(*(ulong*)lexer::lex("0o10")![0].token.ptr == 8);
    assert(*(ulong*)lexer::lex("0b1")![0].token.ptr == 1);
}

fn void! test_other(){
    assert(lexer::lex("this_is_an_id")![0].type == TokenType.ID);
}

fn void! test_keywords(){
    assert(lexer::lex("import")![0].type == TokenType.IMPORT);
    assert(lexer::lex("interface")![0].type == TokenType.INTERFACE);
    assert(lexer::lex("set")![0].type == TokenType.SET);
    assert(lexer::lex("let")![0].type == TokenType.LET);
    assert(lexer::lex("var")![0].type == TokenType.VAR);
    assert(lexer::lex("task")![0].type == TokenType.TASK);
    assert(lexer::lex("true")![0].type == TokenType.BOOL);
    assert(lexer::lex("false")![0].type == TokenType.BOOL);
}
fn void! test_syntax(){
    assert(lexer::lex("{")![0].type == TokenType.LBRACE);
    assert(lexer::lex("}")![0].type == TokenType.RBRACE);
    assert(lexer::lex("[")![0].type == TokenType.LBRACKET);
    assert(lexer::lex("]")![0].type == TokenType.RBRACKET);
    assert(lexer::lex("(")![0].type == TokenType.LPAREN);
    assert(lexer::lex(")")![0].type == TokenType.RPAREN);
    assert(lexer::lex(",")![0].type == TokenType.COMMA);
    assert(lexer::lex(".")![0].type == TokenType.DOT);
    assert(lexer::lex("-")![0].type == TokenType.MINUS);
    assert(lexer::lex("+")![0].type == TokenType.PLUS);
    assert(lexer::lex("/")![0].type == TokenType.DIV);
    assert(lexer::lex("*")![0].type == TokenType.STAR);
    assert(lexer::lex("&")![0].type == TokenType.AND);
    assert(lexer::lex("&&")![0].type == TokenType.LAND);
    assert(lexer::lex("|")![0].type == TokenType.OR);
    assert(lexer::lex("||")![0].type == TokenType.LOR);
    assert(lexer::lex("!")![0].type == TokenType.NOT);
    assert(lexer::lex("!=")![0].type == TokenType.NEQ);
    assert(lexer::lex("==")![0].type == TokenType.EQEQ);
    assert(lexer::lex("=")![0].type == TokenType.EQ);
    assert(lexer::lex(":")![0].type == TokenType.COLON);
    assert(lexer::lex(";")![0].type == TokenType.SEMICOLON);
    assert(lexer::lex("<")![0].type == TokenType.LT);
    assert(lexer::lex("<=")![0].type == TokenType.LTEQ);
    assert(lexer::lex(">")![0].type == TokenType.GT);
    assert(lexer::lex(">=")![0].type == TokenType.GTEQ);
    assert(lexer::lex("=>")![0].type == TokenType.ARROW);
    assert(lexer::lex("^")![0].type == TokenType.XOR);
    assert(lexer::lex("?")![0].type == TokenType.QUESTION);

}

