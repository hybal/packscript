module conical::errors::generator;
import std::io;
import std::collections::map;
import conical::lexer;

struct Error
{
    Severity severity;
    String msg;
    String quick_fix;
    String file;
    usz line;
    usz column;
}

enum Severity
{
    LOG,
    WARN,
    FATAL
}


fn Error make_error(Severity severity, String msg, String fix, String file, Token token)
{
    return {.severity = severity, .msg = msg, .quick_fix = fix, .line = token.line, .column = token.col};
}
