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
local function vers_string(vers) 
    local pre = vers.prerelease and "-"..vers.prerelease or ""
    local met = vers.meta and "+"..vers.meta or ""
    return string.format("%d.%d.%d", vers.major or 0, vers.minor or 0, vers.patch or 0)..pre..met

end
local function lt_compare(op1, op2)
    if op1.major ~= op2.major then
        return op1.major < op2.major
    end
    if op1.minor ~= op2.minor then
        return op1.minor < op2.minor
    end

    if op1.patch ~= op2.patch then
        return op1.patch < op2.patch
    end
    if op1.prerelease ~= nil or op2.prerelease ~= nil then
        if not op1.prerelease then
            return false
        end
        if not op2.prerelease then
            return true
        end

        if op1.prerelease ~= op2.prerelease then 
            return op1.prerelease < op2.prerelease
        end
    end
    return false
end

-- Public Functions
function core.runtask(id, ...)
    local args = {...}
    tasks[id](args)
end


function core.Version(major, minor, patch, prerelease, meta)
   
    local mt = {

        __tostring = vers_string,
        __serialize = vers_string,
        __lt = lt_compare
    }

    
    local vers = {
        major = major,
        minor = minor,
        patch = patch,
        prerelease = prerelease,
        meta = meta
    }
    return setmetatable(vers, mt)

end

function core.version(str) 
    if string.sub(str, 1, 1) == "v" then
        str = string.sub(str, 2)
    end
    local pattern = [=[^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$]=]
    local match = re.matches(str, pattern)[1]
    local version = Version(match[2], match[3], match[4], match[5], match[6])
    return version
end


-- Table validation

-- TODO: Clean up
function core.makeschema(schema)
    local out = {schema = schema}
    function out:validate(tbl)
        local function is_required_missing(rules, value)
            local required = rules.required ~= false
            return required and value == nil
        end
        
        local function assign_default(rules, tbl, key)
            if rules.required == false and tbl[key] == nil and rules.default ~=nil then
                tbl[key] = rules.default
            end
        end

        local function validate_types(types, value, key, required)
            local value_type = type(value)
            if value_type == "userdata" and not io.type(value) then
                value_type = "file"
            end

            if (type(types) == "table" and icontains(types, "any")) or types == "any" then
                return
            end

            if type(types) == "table" then
                if not icontains(types, value_type) and required == true then
                    local str_types = reduce(types, function(accum, val) return accum .. ", " .. val end)
                    error("Key '" .. key .. "' is the wrong type. Expected one of [" .. str_types .. "], got: '" .. value_type .."'")
                end
            elseif type(types) == "string" and types ~= value_type and required == true then
                error("Key '" .. key .. "' is the wrong type. Expected: '" .. types .. "', got: '" .. value_type .. "'")
            end
        end

        local function validate_schema(rules, value)
            if type(rules) == "table" and rules.schema then
                core.makeschema(rules.schema):validate(value)
            end
        end
        local function check_alternatives() end
        local function check_rule(rules, key, tbl)
            local value = tbl[key]
            local rule_types = type(rules) == "table" and (rules.type or rules.types) or rules
            local required = true
            if is_required_missing(rules, value) then
                if not check_alternatives(rules, key, tbl) then
                    error("Missing required key: [" .. key .. "]")
                else
                    return
                end
            else
                required = false
            end

            assign_default(rules, tbl, key)
            validate_schema(rules, value)
            validate_types(rule_types, value, key, required)
        end

        local function check_alternatives(rules, key, tbl) 
            if rules.alternates then
                for _, alternate in ipairs(rules.alternates) do
                    print(tbl[alternate])
                    if tbl[alternate] then
                        if type(alternate) == "table" then
                            validate_schema(rules.alternates, tbl[alternate])
                        elseif type(alternate) == "string" then
                            local rule = self.schema[alternate]
                            if not rule then
                                error("Alternative: '" .. alternate .."' is missing in schema, required by: '"..key"'")
                            end
                            check_rule(rule, key, tbl)
                        end
                        return true
                    end
                end
            end
            return false
        end


        for key, rules in pairs(self.schema) do
            check_rule(rules, key, tbl)

        end
    end

    return out
end

local use_schema = core.makeschema {
    id = "string",
    version = {types = {"string", "table"}},
    retvr = {required = false, type = "function"},
    path = {required = false, type = "string"},
    type = {type = "string", default = "lib"}
}
function core.use(artifact) 
   --TODO 
end

-- I/O

function core.write(path, data)
    local file = io.open(path, "wb")
    if file then
        file:write(data)
        file:close()
    else
        error("Failed to write or create file: \""..path.."\"")
    end
end

function core.cdtmp()
    mkdir(IWD.."/.pksc")
    cd(IWD.."/.pksc")
end

function core.append(path, data)
    local file = io.open(path, "a")
    if file then
        file:write(data)
        file:close()
    else
        print("Failed to open or append file: \""..path.."\"")
    end
end


-- Regex

function re.freplace(path, pattern, replace)
    local temp = cat(path)
    if temp then
        temp = re.replace(temp, pattern, replace)
        write(path, temp)
    end
end

-- Shell
core.shell = require("shell")
core.cat = core.shell.cat
core.ls = core.shell.ls
core.mktmp = core.shell.mktmp

-- Iterators 

function core.map(tbl, fn)
    local out = {}
    for i,v in pairs(tbl) do
        out[i] = fn(i, v)
    end
    return out
end


function table.append_all(a, b)
    for k,v in pairs(b) do
        table.append(a, v)
    end
end

function table.append(tbl, val)
    local max = table.maxn(tbl) + 1
    tbl[max] = val
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

function core.icontains(tbl, val)
    for _,v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function core.contains(tbl, val)
    for _, v in pairs(tbl) do 
        if v == val then
            return true
        end
    end
    return false
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

function core.idiscard(fn)
    return function(i,v) return fn(v) end
end

-- Misc

function core.curry(fn)
    local function curried_fn(...)
        local args = { ... }
        return function(...)
            local new_args = { ... }
            local all_args = {}
            for i, v in ipairs(args) do
                table.insert(all_args, v)
            end
            for i, v in ipairs(new_args) do
                table.insert(all_args, v)
            end
            if #all_args >= select('#', fn) then
                return fn(table.unpack(all_args))
            else
                return curried_fn(table.unpack(all_args))
            end
        end
    end
    return curried_fn
end

function core.git_fetch(user, repo, branch, url_format)
    local form = url_format or "https://github.com/%s/%s/archive/refs/heads/%s.zip"
    local url = string.format(form, user, repo, branch or "main")
    print(url)
    return fetch(url)
end

core.m = require("ops")


return core
