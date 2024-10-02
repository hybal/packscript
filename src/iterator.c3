module iterator (<Type>);

struct Iterator {
    Type[] data;
    usz cursor;
}

fn Iterator Type[].to_iterator(&self) {
    return Iterator {*self, 0};
}

fn bool Iterator.has_next(&self) {
    return self.cursor < self.data.len;
}

fn Type! Iterator.get(&self) {
    if(self.data.len == 0) return IteratorResult.NO_MORE_ELEMENT?;
    if(self.cursor == 0) return self.data[self.cursor];
    return self.data[self.cursor - 1];
}

fn Type! Iterator.peek(&self) {
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    return self.data[self.cursor];
}

fn Type! Iterator.next(&self) {
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    return self.data[self.cursor++];
}

