local shell = {}
-- Common Shell Functions (without the shell)
function shell.cat(path)
    local file, err = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content

end

function shell.ls(path)
    return glob((path or ".").."/*")
end

function shell.mv(from, to, overwrite)
    cp(from, to)
    rm(from, true)
end

function os.appendenv(var, val)
    os.setenv(var, os.getenv(var)..val)
end
return shell
