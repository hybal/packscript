module lexer;
import std::collections::list;
import std::ascii;
import std::io;
import tunion;
String[*] keyword = {"impl", "set", "let", "var", "interface", "import", "task"};

enum TokenType
{
    STR,
    INT,
    CHAR,
    FLOAT,
    BOOL,
    ID,
    COMMA,
    DOT,
    EQ,
    EQEQ,
    NEQ,
    LT,
    GT,
    LTEQ,
    GTEQ,
    LBRACE,
    RBRACE,
    LPAREN,
    RPAREN,
    LBRACKET,
    RBRACKET,
    OR,
    AND,
    NOT,
    XOR,
    LOR,
    LAND,
    LNOT,
    SEMICOLON,
    COLON,
    PLUS,
    MINUS,
    DIV,
    MOD,
    STAR,
    ARROW,
    QUESTION,
    IMPL,
    SET,
    LET,
    VAR,
    INTERFACE,
    IMPORT,
    TASK
    
}
fault Lexing{
    TOO_MANY_DECIMALS
}
struct Token (Printable)
{
    TokenType type;
    TagUnion token;
}

fn String Token.to_string(&self, Allocator allocator) @dynamic
{
    return string::new_format("{type: %s, token: %s}", self.type, self.token);

}

fn Token new_token(TokenType type, TagUnion token = {}, String str = ""){
    Token* out = mem::malloc(Token.sizeof);
    out.type = type;
    if(str.len > 0){
        out.token = tunion::make(str);
    }else{
        out.token = token;
    }
    return *out;
}

def TokenList = list::List(<Token>);
fn Token[]! lex(String data)
{
    StringIterator iter = data.iterator();
    TokenList tokens;
    tokens.new_init(); defer tokens.free();
    while OUTER:(iter.has_next()){
        Token next_token;
        Char32 current_char = iter.next()!;
        switch OSW: (current_char){
            case '*': next_token = new_token(STAR, str: "*");
            case '/': next_token = new_token(DIV, str: "/");
            case '-': next_token = new_token(MINUS, str: "-");
            case '+': next_token = new_token(PLUS, str: "+");
            case '%': next_token = new_token(MOD, str: "%");
            case '^': next_token = new_token(XOR, str: "^");
            case ':': next_token = new_token(COLON, str: ":");
            case ';': next_token = new_token(SEMICOLON, str: ";");
            case '(': next_token = new_token(LPAREN, str: "(");
            case ')': next_token = new_token(RPAREN, str: ")");
            case '{': next_token = new_token(LBRACE, str: "{");
            case '}': next_token = new_token(RBRACE, str: "}");
            case '[': next_token = new_token(LBRACKET, str: "[");
            case ']': next_token = new_token(RBRACKET, str: "]");
            case ',': next_token = new_token(COMMA, str: ",");
            case '.': next_token = new_token(DOT, str: ".");
            case '?': next_token = new_token(QUESTION, str: "?");
            case '=': {next_token = iter.has_next() && (iter.peek() ?? '\0') == '=' ? 
                        {|iter.next()!!; return new_token(EQEQ, str: "==");|} : 
                            (iter.has_next() && (iter.peek()!!) == '>' ? 
                                {|iter.next()!!; return new_token(ARROW, str: "=>");|} : 
                                    {|return new_token(EQ, str: "=");|});}
            case '!': next_token = iter.has_next() && (iter.peek() ?? '\0') == '=' ? 
                {|iter.next()!!; return new_token(NEQ, str: "!="); |} : 
                {|return new_token(NOT, str: "!");|};
            case '>': next_token = iter.has_next() && (iter.peek() ?? '\0') == '=' ? 
                {|iter.next()!!; return new_token(GTEQ, str: ">="); |} : 
                {|return new_token(GT, str: ">");|};
            case '<': next_token = iter.has_next() && (iter.peek() ?? '\0') == '=' ? 
                {|iter.next()!!; return new_token(LTEQ, str: "<="); |} : 
                {|return new_token(LT, str: "<");|};
            case '|': next_token = iter.has_next() && (iter.peek() ?? '\0') == '|' ? 
                {|iter.next()!!; return new_token(LOR, str: "||"); |} : 
                {|return new_token(OR, str: "|");|};
            case '&': next_token = iter.has_next() && (iter.peek() ?? '\0') == '&' ? 
                {|iter.next()!!; return new_token(LAND, str: "&&"); |} : 
                {|return new_token(AND, str: "&");|};

            case '"': {
                DString out;
                out.new_init(); defer out.free();
                Char32 current = current_char;
                while(iter.has_next() && (iter.peek()! != '\"')){
                    current = iter.next()!;
                    out.append(current);
                }
                iter.next()!;
                next_token = new_token(STR, str: out.copy_str());
            }
            case '\'': {
                DString out;
                out.new_init(); defer out.free();
                Char32 current = current_char;
                while(iter.has_next() && (iter.peek()! != '\'')){
                    current = iter.next()!;
                    out.append(current);
                }
                iter.next()!;
                next_token = new_token(CHAR, str: out.copy_str());

            }
            case '0': {
                int base = 10;
                Char32 range_a = '0';
                Char32 range_b;
                bool is_complex = true;
                switch INNER: (iter.peek()!) {
                    case 'X': nextcase;
                    case 'x': {base = 16; range_b = 'F';}
                    case 'O': nextcase;
                    case 'o': {base = 8; range_b = '7';}
                    case 'B': nextcase;
                    case 'b': {base = 2; range_b = '1';}
                    default: is_complex = false;
                }
                if(is_complex){
                    iter.next()!;
                    Char32 current = iter.peek()!;
                    DString out;
                    out.new_init(); defer out.free();
                    while(iter.has_next() && current.in_range(range_a, range_b)){
                        current = iter.next()!;
                        out.append(current);
                    }
                    next_token = new_token(TokenType.INT, token: tunion::make(out.str_view().to_long(base: base)))!;
               }else{
                    nextcase;
               }
                
            }
            default:{
                if(current_char.is_blank()){
                    continue OUTER;
                }
                if(current_char.is_digit() || current_char == '.'){
                    DString out;
                    out.new_init();
                    out.append(current_char);
                    Char32 current = current_char;
                    bool is_float = false;
                    while(iter.has_next() && (iter.peek()!.is_digit() || iter.peek()! == '.')){
                        current = iter.next()!;
                        if(current == '.' && !is_float){
                            is_float = true;
                        }else if(current == '.' && is_float){
                            return Lexing.TOO_MANY_DECIMALS?; 
                        }
                        out.append(current);
                        
                    }
                    if(is_float){
                        double num = out.str_view().to_double()!;
                        next_token = new_token(TokenType.FLOAT, token: tunion::make(num));
                    }else{
                        long num = out.str_view().to_long()!;
                        next_token = new_token(TokenType.INT, token: tunion::make(num));
                        
                    }
                    out.clear();
                }
                if(current_char.is_alpha() || current_char == '_'){
                    DString out;
                    out.new_init(); defer out.free();
                    out.append(current_char);
                    Char32 current = current_char;
                
                    while(iter.has_next() && (current.is_alnum() || current == '_')){
                        current = iter.next()!;
                        out.append(current);
                    }
                    String out_str = out.copy_str();
                    TokenType out_type = TokenType.ID;
                    switch(out_str){
                        case "impl": out_type = TokenType.IMPL;
                        case "interface": out_type = TokenType.INTERFACE;
                        case "task": out_type = TokenType.TASK;
                        case "set": out_type = TokenType.SET;
                        case "let": out_type = TokenType.LET;
                        case "var": out_type = TokenType.VAR;
                        case "import": out_type = TokenType.IMPORT;
                        case "true" : out_type = TokenType.BOOL;
                        case "false" : out_type = TokenType.BOOL;
                    }
                    next_token = new_token(out_type, str: out.copy_str());
                } 
                
            }

        }
        tokens.push(next_token);
    }
    return tokens.to_new_array();
}


