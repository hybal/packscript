module conical::utils::tree(<DType>);
import std::io;
struct Tree (Printable) @adhoc
{
    DType data;
    Tree* left;
    Tree* right;
}

fn Tree* new_node(DType data, Allocator allocator = allocator::heap())
{
    Tree* node = allocator::alloc(allocator, Tree);
    node.data = data;
    node.left = null;
    node.right = null;
    return node;
}
fn Tree* Tree.create_child(&self, DType data, Allocator allocator = allocator::heap())
{
    return new_node(data, allocator: allocator);
}
fn Tree* Tree.set_left(&self, DType data, Allocator allocator = allocator::heap()) 
{
    self.left = new_node(data, allocator);
    return self.left;
}
fn Tree* Tree.set_right(&self, DType data, Allocator allocator = allocator::heap()) 
{
    self.right = new_node(data, allocator);
    return self.right;
}
fn bool Tree.is_leaf(&self)
{
    return self.left == null && self.right == null;
}

fn String Tree.print_string(&self, String prefix = "", bool is_last = true, Allocator allocator)
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


