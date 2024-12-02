module utils::iterator::stream;
import std::io;

fn char! File.next(&self) 
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    return self.read_byte();
}

<*
    @require $defined(self.seek)
*>
fn char! File.peek(&self) 
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    char out;
    out = self.read_byte()!;
    self.seek(-1, Seek.SET)!;
    return out;

}
<*
    @require $defined(self.seek)
*>

fn char! File.get(&self) 
{
    if(!self.has_next()) return IteratorResult.NO_MORE_ELEMENT?;
    char out = self.read_byte()!;
    self.seek(-1, Seek.SET)!;
    return out;
}

<*
    @require $defined(self.seek)
*>

fn bool File.has_next(&self) 
{
    return (io::available(self) ?? 0) > 0;
}
