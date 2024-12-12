module errors (<Type>);

enum Severity
{
    DEBUG,
    INFO,
    WARN,
    FATAL
}

struct Error 
{
    Severity severity;
    Type error_type;
    String message;
    usz line;
    usz column;
    ushort code;
}

fn Error make_error(Severity severity, Type error_type, String message, usz line, usz col, ushort code)
{
    return {severity, error_type, message, line, column, code};
}


