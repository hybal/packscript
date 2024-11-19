module conical::either(<Right, Left>);

struct Either //make a specefic type for errors
{
    bool is_err;
    union
    {
        Right right;
        Left left;
    }
}

fn Either make_right(Right right) 
{
    return {false, right};
}

fn Either make_left(Left left)
{
    return {true, left = left};
}

fn bool Either.is_left(&self)
{
    return self.is_err;
}
fn bool Either.is_right(&self)
{
    return !self.is_err;
}

