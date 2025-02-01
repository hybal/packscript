
project = {
    name = "PackScript Test Project",
    id = "test",
    version = Version(1,0,0)
}

settings = {
    include_dirs = glob "include",
    srcs = glob "src/**/*.c",
    cc = "gcc",
    out_dir = "bin"
}

function tasks.build() 
    mkdir(IWD.."/"..settings.out_dir)
    cdtmp()
    local commands = {}
    local include_opt = {}
    for _, incl in pairs(settings.include_dirs) do
            table.append(include_opt, "-I"..incl.abspath)
    end

    for i, file in pairs(settings.srcs) do
        local args = {settings.cc, "-c"}
        table.append(args, file.abspath)
        table.append_all(args, include_opt)
        mkdir(file.parent)
        table.append(args, "-o ".. file.parent.."/"..file.stem..".o")
        table.append(commands, args)
    end
    local cmd = {settings.cc}
    table.append_all(cmd, map(settings.srcs, function(i,v) return v.abspath end))
    table.append_all(cmd, include_opt)
    table.append(cmd, "-o "..IWD.."/"..settings.out_dir.."/"..(settings.out or project.id))
    table.append(commands, cmd)
    commands = map(commands, function(i,v) return table.concat(v, " ") end)
    for i, cmd in ipairs(commands) do
        os.execute(cmd)
    end
end

function tasks.run() 
    runtask "build"
    os.execute(IWD.."/"..settings.out_dir.."/"..(settings.out or project.id))
end


