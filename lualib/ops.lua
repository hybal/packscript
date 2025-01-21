local ops = {}
function ops.add(a,b)
    return a + b
end

function ops.sub(a,b)
    return a - b
end

function ops.mul(a,b)
    return a * b
end

function ops.div(a,b)
    return a / b
end

function ops.mod(a,b)
    return a % b
end

function ops.pow(a,b)
    return a ^ b
end

function ops.unm(a)
    return -a
end

function ops.conct(a,b)
    return a .. b
end

function ops.len(a)
    return #a
end

function ops.eq(a,b)
    return a == b
end

function ops.lt(a,b)
    return a < b
end

function ops.le(a,b)
    return a <= b
end

function ops.gt(a,b)
    return a > b
end

function ops.ge(a,b)
    return a >= b
end

return ops


