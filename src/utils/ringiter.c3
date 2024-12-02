module utils::fileiter;
import std::io;
import utils::iterator;

def ParentIterator = iterator::Iterator(<char>);

struct RingIterator (ParentIterator)
{
    InStream stream;
    Allocator allocator;
    char[] buffer;
}

fn RingIterator InStream.iterator(&self, usz size = 128, Allocator allocator = allocator::heap())
{
    char[] buffer = allocator::alloc(char, size)[:size];
    return {self, allocator, buffer};
}
fn char! RingIterator.next(&self) @dynamic 
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    return self.data[self.cursor++];
}
fn char! RingIterator.peek(&self) @dynamic
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    return self.data[self.cursor];
}
fn char! RingIterator.get(&self) @dynamic
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    if(self.cursor == 0) return self.data[0];
    return self.data[self.cursor - 1];
}
fn char! RingIterator.peek_back(&self) @dynamic
{
    if(self.cursor - 2 < 0) return IteratorResult.NO_MORE_ELEMENT?;
    return self.data[self.cursor - 2];
}
fn char! RingIterator.back(&self) @dynamic
{
    if(self.cursor - 2 < 0) return IteratorResult.NO_MORE_ELEMENT?;
    self.cursor -= 2;
    return self.data[self.cursor];
}

fn bool RingIterator.has_next(&self) @dynamic
{
    return io::available(self.stream)!! > 0;
}

