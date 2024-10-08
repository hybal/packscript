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
import std::collections::list;
import std::io;
def NodeList = list::List(<Tree>);
struct Tree (Printable)
{
    Type data;
    NodeList children;
}

fn Tree* Tree.add_child(&self, Type data){
        Tree* node = mem::malloc(Type.sizeof);
        self.children.push(*node);
        return node;
}

fn Tree[] Tree.get_children(&self){
    return self.children.array_view();
}

fn bool Tree.has_children(&self){
    return self.children.len() > 0;
}

fn usz Tree.get_height(&self)
{
    if(self.get_children().len == 0) return 1;
    usz out = 0;
    foreach(Tree node : self.get_children()){
        out = 1 + node.get_height();
    }
    return out;
}

fn String Tree.print_string(&self, usz level, Allocator allocator) @private
{
    
        if(self.get_children().len == 0) return self.data.to_string(allocator: allocator);
        DString out;
        out.temp_init(); defer out.free();
        for(int i = 5; i < level + 5; i++){
            out.append(" ");
        }
        out.append(self.data.to_string(allocator: allocator));
        out.append("\n");
        foreach(Tree node : self.get_children()){
            out.append(node.print_string(level + 5, allocator));
        }
        return out.copy_str(allocator: allocator);
    
}

fn String Tree.to_string(&self, Allocator allocator) @dynamic
{
    return self.print_string(0, allocator);
}


module tunion;

struct TagUnion
{
    union
    {
        String s;
        long l;
        char c;
    }
    typeid tag;
}

macro TagUnion.get_type(&self)
{
    return self.tag;
}

macro TagUnion.get_val(self)
{
    $switch(self.typeid)
        $case String.typeid: return self.s;
        $case long.typeid: return self.l;
        $case char.typeid: return self.c;
    $endswitch
}
macro make(data)
{
    return TagUnion{data, $typeof(data).typeid};
}


