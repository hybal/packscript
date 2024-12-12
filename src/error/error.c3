module errors;
enum Severity
{
    DEBUG,
    INFO,
    WARN,
    FATAL
}

module errors::error (<Type>);
import std::io;
struct Error (Printable)
{
    Severity severity;
    Type error_type;
    String message;
    usz line;
    usz column;
    ushort code;
}

fn String Error.to_string(&self, Allocator allocator) @dynamic
{
    return string::format("{ severity: %s, error_type: %s, message: %s, line: %d, column: %d, code: %d }",
        self.severity, self.error_type, self.message, self.line, self.column, self.code, allocator: allocator);
}


fn Error make_error(Severity severity, Type error_type, String message, usz line, usz col, ushort code)
{
    return {severity, error_type, message, line, col, code};
}


