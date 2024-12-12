module utils::option (<Type>);

struct Option
{
    bool has_some;
    Type value;
}

fn Option some(Type val)
{
    return {.value = val, .has_some = true};
}

fn bool Option.is_some(&self)
{
    return self.has_some;
}

fn bool Option.is_none(&self)
{
    return !self.has_some;
}

macro Option Option.bind(self, callback)
{
    if(self.is_some()) {
        return some(callback(self.value));
    }
    return self;
}

def MonadicFunc = fn Option(Option);
fn Option Option.apply(&self, MonadicFunc func)
{
    return func(*self);
}
