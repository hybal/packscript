module utils;
import std::collections;
import parser;
import tunion;
import lexer;
fn bool String.eq(&self, String b){

    if(self.len != b.len) return false;
    StringIterator iter1 = self.iterator();
    StringIterator iter2 = self.iterator();
    while(iter1.has_next() && iter2.has_next()){
        if(iter1.next()!! != iter2.next()!!) return false;
    }
    return true;
}

fn long! String.eval_str(&self)
{
    Ast* out = parser::parse(*self)!;
    return out.eval_ast();
}
def SymTab = map::HashMap(<String, long>);
SymTab symbol_table;
fn long! Ast.eval_ast(&self) {
    symbol_table.new_init();
    return self.eval();
}
fn long! Ast.eval(&self)
{
    if(self == null) return 0;
    if(self.is_leaf()) {
        if(self.data.type == TokenType.ID) return symbol_table[self.data.token.cast_to(String)];
        return self.data.token.cast_to(long);
    }
    switch(self.data.type) {
        case EQ: {
            symbol_table[self.left.data.token.cast_to(String)] = self.right.eval()!;
            return 0;
        }
        case PLUS: return self.left.eval() + self.right.eval();
        case MINUS: return self.right == null ? -self.left.eval()! : self.left.eval() - self.right.eval();
        case STAR: return self.left.eval() * self.right.eval();
        case DIV: return self.left.eval() / self.right.eval();
        case MOD: return self.left.eval() % self.right.eval();
        case GT: return self.left.eval()! > self.right.eval()! ? 1 : 0;
        case LT: return self.left.eval()! < self.right.eval()! ? 1 : 0;
        case GTEQ: return self.left.eval()! >= self.right.eval()! ? 1 : 0;
        case LTEQ: return self.left.eval()! <= self.right.eval()! ? 1 : 0;
        case EQEQ: return self.left.eval()! == self.right.eval()! ? 1 : 0;
        case NEQ: return self.left.eval()! != self.right.eval()! ? 1 : 0;
        case LAND: return self.left.eval()! && self.right.eval()! ? 1 : 0;
        case LOR: return self.left.eval()! || self.right.eval()! ? 1 : 0;
        case NOT: return !self.left.eval()! ? 1 : 0;
        case AND: return self.left.eval() & self.right.eval();
        case OR: return self.left.eval() | self.right.eval();
        case XOR: return self.left.eval() ^ self.right.eval();
        case LSH: return self.left.eval() << self.right.eval();
        case RSH: return self.left.eval() >> self.right.eval();
        default: return 0;
    }
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

fn String Tree.print_string(&self, String prefix = "", bool is_last = true, Allocator allocator) @private
{
        if(self == null) return "";
        DString out;
        out.new_init(); defer out.free();
        out.append(prefix);
        out.append(is_last ? "└── " : "├── ");
        out.appendf("%s\n", self.data);
        DString new_prefix_temp;
        new_prefix_temp.new_init(); defer out.free();
        new_prefix_temp.append(prefix);
        new_prefix_temp.append(is_last ? "    " : "│   ");
        String new_prefix = new_prefix_temp.copy_str(allocator: allocator);
        out.append(self.left.print_string(new_prefix, self.is_leaf(), allocator));
        out.append(self.right.print_string(new_prefix, !self.is_leaf(), allocator));
        return out.copy_str(allocator: allocator);
    
}

fn String Tree.to_string(&self, Allocator allocator) @dynamic
{
    return self.print_string(allocator: allocator);
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


