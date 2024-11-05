module conical::tunion;
import std::io;
struct TagUnion (Printable)
{
    union data
    {
        String s;
        long l;
        char c;
        double d;
        bool b;
    }
    typeid tag;
}

fn String TagUnion.to_string(&self, Allocator allocator) @dynamic
{
    switch(self.tag)
    {
        case String.typeid: return string::new_format("%s", self.data.s, allocator: allocator);
        case long.typeid: return string::new_format("%s", self.data.l, allocator: allocator);
        case char.typeid: return string::new_format("%c", self.data.c, allocator: allocator);
        case double.typeid: return string::new_format("%s", self.data.d, allocator: allocator);
        case bool.typeid: return string::new_format("%s", self.data.b, allocator: allocator);
        default: return "<Unknown>";
    }

}


macro TagUnion.get_type(&self)
{
    return self.tag;
}

fn void* TagUnion.get_val(&self)
{
    switch(self.tag)
    {
        case String.typeid: return &self.data.s;
        case long.typeid: return &self.data.l;
        case char.typeid: return &self.data.c;
        case double.typeid: return &self.data.d;
        case bool.typeid: return &self.data.b;
    }
    return null;
}

macro make(data)
{
    TagUnion out;
    $switch($typeof(data).typeid)
        $case String.typeid: out.data.s = data;
        $case long.typeid: out.data.l = data;
        $case char.typeid: out.data.c = data;
        $case double.typeid: out.data.d = data;
        $case bool.typeid: out.data.b = data;
    $endswitch
    out.tag = $typeof(data).typeid;
    return out;
}
macro TagUnion.cast_to(self, $Type) 
{
    return *($Type*)self.get_val();
}


module conical::symtab;

enum ConicalType
{
    CHAR,
    INT,
    STR,
    DOUBLE
}

struct SymVal
{
    ConicalType type;
    String id;
    union value
    {
        char c;
        int i;
        String s;
        double d;
    }
    usz scope;
    usz size;
    usz line;
    ConicalType return_type;
    SymVal[] parameters;
}
