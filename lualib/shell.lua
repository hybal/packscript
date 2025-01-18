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



return shell
