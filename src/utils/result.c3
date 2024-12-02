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


fn bool Result.is_left(&self) => self.side == Side.LEFT;
fn bool Result.is_right(&self) => self.side == Side.RIGHT;

macro make_left(value) => Result {.side = LEFT, .left_v = value};
macro make_right(value) => Result {.side = RIGHT, .right_v = value};

fn String Result.to_string(&self, Allocator allocator) @dynamic
{
    if(self.is_left()) return string::format("Left(%s)", self.left_v, allocator: allocator);
    return string::format("Right(%s)", self.right_v, allocator: allocator);
}


//monadic functions

macro Result Result.bind(self, callback) 
{
    if(self.is_left()) {
        return make_left(callback(self.left_v));
    }
    return self;
}

macro Result Result.seq(self, callback, other)
{
    self.bind(callback);
    return other.bind(callback);
}

def MonadicFunc = fn Result(Result);
fn Result Result.apply(&self, MonadicFunc func) 
{
    return func(*self);
}
