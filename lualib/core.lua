local core = {}

-- Constants
core.format = {
    json = "json",
    toml = "toml",
    yaml = "yaml",
    ini = "ini",
}

core.lang = {
    C = "c",
    Cpp = "cpp",
    Rust = "rust",
    Python = "py3",
    Python2 = "py2",
}

-- Private
function vers_string(vers) 
    local pre = vers.prerelease and "-"..vers.prerelease or ""
    local met = vers.meta and "+"..vers.meta or ""
    return string.format("%d.%d.%d", vers.major or 0, vers.minor or 0, vers.patch or 0)..pre..met

end

-- Public Functions
function core.runtask(id, ...)
    local args = {...}
    tasks[id](args)
end


function core.Version(major, minor, patch, prerelease, meta)
    local mt = {
        __tostring = vers_string,
        __serialize = vers_string
    }
    local vers = {
        major = major,
        minor = minor,
        patch = patch,
        prerelease = prerelease,
        meta = meta
    }
    setmetatable(vers, mt)
    return vers

end

-- Shell
core.shell = require("shell")
core.cat = core.shell.cat

-- Utility

function core.map(tbl, fn)
    local out = {}
    for i,v in pairs(tbl) do
        out[i] = fn(i, v)
    end
    return out
end

function core.filter(tbl, fn)
    local out = {}
    for i,v in pairs(tbl) do
        if fn(i,v) then
            out[i] = v
        end
    end
    return out
end

function core.filter_map(tbl, fn)
    local out = {}
    for i,v in pairs(tbl) do
        local keep = fn(i,v)
        if keep ~= nil then
            out[i] = keep
        end
    end
    return out
end

function core.foreach(tbl, fn)
    for i,v in pairs(tbl) do
        fn(i,v)
    end
end

function core.iforeach(tbl, fn)
    for i,v in ipairs(tbl) do
        fn(v)
    end
end

function core.reduce(tbl, fn)
    local result = nil
    for _, value in pairs(tbl) do
        if result == nil then 
            result = value
        else
            result = fn(result, value)
        end
    end
    return result
end

function core.discard(fn)
    return function(i,v) return fn(v) end
end

-- Misc

function core.curry(fn)
    local function curried_fn(...)
        local args = { ... }
        return function(...)
            local new_args = { ... }
            local all_args = {}
            -- Add previously captured arguments to the new arguments
            for i, v in ipairs(args) do
                table.insert(all_args, v)
            end
            for i, v in ipairs(new_args) do
                table.insert(all_args, v)
            end
            -- If the total number of arguments is enough, call the original function
            if #all_args >= select('#', fn) then
                return fn(table.unpack(all_args))
            else
                return curried_fn(table.unpack(all_args))
            end
        end
    end
    return curried_fn
end

core.m = require("ops")


return core
