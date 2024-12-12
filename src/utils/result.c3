module utils::result (<Left, Right>);
import std::io;
enum Side
{
    LEFT,
    RIGHT,
}

struct Result (Printable)
{
    Side side;
    union {
        Left left_v;
        Right right_v;
    }
}

fault ResultError
{
    TYPE_MISMATCH
}


fn bool Result.is_ok(&self) => self.side == Side.LEFT;
fn bool Result.is_err(&self) => self.side == Side.RIGHT;


fn String Result.to_string(&self, Allocator allocator) @dynamic
{
    if(self.is_ok()) return string::format("Some(%s)", self.left_v, allocator: allocator);
    return string::format("Err(%s)", self.right_v, allocator: allocator);
}


//monadic functions

macro Result Result.bind(self, callback) 
{
    if(self.is_ok()) {
        return make_some(callback(self.left_v));
    }
    return self;
}

def MonadicFunc = fn Result(Result);
fn Result Result.apply(&self, MonadicFunc func) 
{
    return func(*self);
}

macro make_some(value) => Result {.side = LEFT, .left_v = value};
macro make_right(value) => Result {.side = RIGHT, .right_v = value};

