module utils;
import std::collections::list;
fn bool String.eq(&self, String b){

    if(self.len != b.len) return false;
    StringIterator iter1 = self.iterator();
    StringIterator iter2 = self.iterator();
    while(iter1.has_next() && iter2.has_next()){
        if(iter1.next()!! != iter2.next()!!) return false;
    }
    return true;
}


module utils::tree (<Type>);
import std::io;
struct Tree (Printable)
{
    Type data;
    Tree* left;
    Tree* right;
}

fn Tree* new_node(Type data, Allocator allocator = allocator::heap())
{
    Tree* node = allocator::alloc(allocator, Tree);
    node.data = data;
    node.left = null;
    node.right = null;
    return node;
}
fn Tree* Tree.create_child(&self, Type data, Allocator allocator = allocator::heap())
{
    return new_node(data, allocator: allocator);
}
fn Tree* Tree.set_left(&self, Type data, Allocator allocator = allocator::heap()) 
{
    self.left = new_node(data, allocator);
    return self.left;
}
fn Tree* Tree.set_right(&self, Type data, Allocator allocator = allocator::heap()) 
{
    self.right = new_node(data, allocator);
    return self.right;
}
fn bool Tree.is_leaf(&self)
{
    return self.left == null && self.right == null;
}

fn String Tree.print_string(&self, usz level, Allocator allocator) @private
{
        if(self == null) return "";
        if(self.is_leaf()) return string::new_format("%s", self.data, allocator: allocator);
        DString out;
        out.new_init(); defer out.free();
        for(int i = 5; i < level + 5; i++){
            out.append(" ");
        }
        out.append(self.data.to_string(allocator: allocator));
        out.append("\n");
        out.append(self.left.print_string(level+5, allocator));
        out.append(self.right.print_string(level+5, allocator));
        return out.copy_str(allocator: allocator);
    
}

fn String Tree.to_string(&self, Allocator allocator) @dynamic
{
    return self.print_string(0, allocator);
}


module tunion;
import std::io;
struct TagUnion (Printable)
{
    union data
    {
        String s;
        long l;
        char c;
        double d;
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
        default: return null;
    }
}

macro make(data)
{
    TagUnion out;
    $switch($typeof(data).typeid)
        $case String.typeid: out.data.s = data;
        $case long.typeid: out.data.l = data;
        $case char.typeid: out.data.c = data;
        $case double.typeid: out.data.d = data;
    $endswitch
    out.tag = $typeof(data).typeid;
    return out;
}


