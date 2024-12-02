module utils::iterator (<Type>);

interface Iterator
{
    fn Type! next();
    fn Type! peek() @optional;
    fn Type! get() @optional;
    fn Type! peek_back() @optional;
    fn Type! back() @optional;
    fn bool has_next();
}


struct DefaultIterator (Iterator)
{
    isz cursor;
    Type[] data;
}

fn DefaultIterator Type[].iterator(&self) @dynamic 
{
    return {0, *self};
}
fn Type! DefaultIterator.next(&self) @dynamic 
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    return self.data[self.cursor++];
}
fn Type! DefaultIterator.peek(&self) @dynamic
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    return self.data[self.cursor];
}
fn Type! DefaultIterator.get(&self) @dynamic
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    if(self.cursor == 0) return self.data[0];
    return self.data[self.cursor - 1];
}
fn Type! DefaultIterator.peek_back(&self) @dynamic
{
    if(self.cursor - 2 < 0) return IteratorResult.NO_MORE_ELEMENT?;
    return self.data[self.cursor - 2];
}
fn Type! DefaultIterator.back(&self) @dynamic
{
    if(self.cursor - 2 < 0) return IteratorResult.NO_MORE_ELEMENT?;
    self.cursor -= 2;
    return self.data[self.cursor];
}

fn bool DefaultIterator.has_next(&self) @dynamic
{
    return self.cursor < self.data.len;
}

