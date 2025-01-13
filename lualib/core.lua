local core = {}

function core.task(task)
        tasks[task[1]] = task[2]
end

function core.runtask(id)
        tasks[id]()
end

function vers_string(vers) 
        local pre = vers.prerelease and "-"..vers.prerelease or ""
        local met = vers.meta and "+"..vers.meta or ""
        return string.format("%d.%d.%d", vers.major, vers.minor, vers.patch)..pre..met

end

function core.Version(--[[required]]major, --[[required]]minor, --[[required]]patch, --[[optional]]prerelease, --[[optional]]meta)
        local mt = {
                __tostring = vers_string
        }
        local vers = {
                major = major,
                minor = minor,
                patch = patch,
                prerelease = prerelease,
                meta = meta
        }
        local out = setmetatable(vers, mt)
        return out

end


return core
