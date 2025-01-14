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
        return string.format("%d.%d.%d", vers.major or 0, vers.minor or 0, vers.patch or 0)..pre..met

end

function core.Version(major, minor, patch, prerelease, meta)
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

core.lang = {
        C = "c",
        Cpp = "cpp",
        Rust = "rust",
        Python = "py3",
        Python2 = "py2",
}

return core
