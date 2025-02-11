project = {
    id = "id",
    name = "name",
    version = Version(1,0,0),
    type = lang.C
}


github ={resolver = {}}
lock.artifacts = {}
function github.resolver.resolve(id, version, args)
    cdtmp()
    mkdir(id)
    cd(id)
    mkdir("v"..version)
    local fetch_url = args.url or string.format("https://github.com/%s/archive/refs/heads/%s.zip", args.repo, args.branch or "main")
    if args.release and not args.url then
        if args.release == true then
            fetch_url = string.format("https://github.com/%s/archive/refs/tags/v%s.zip", args.repo, version)
        else
            fetch_url = string.format("https://github.com/%s/releases/download/%s/", args.repo, args.release)
        end
    end
    local tmpfile = os.tmpname()
    print(tmpfile)
    write(fetch(fetch_url), tmpfile)
    local out = extract(tmpfile, path("."), format.archive.zip)
    os.execute("mv -f "..out.abspath.."/* "..path("v"..version).abspath)
    lock.artifacts[id] = {path(".").abspath, version}
    rm(tmpfile)
    rm(out)
end
settings = {
    resolver = github.resolver,
    builder = ""
}

function use(tbl)
    local id = tbl[1] or tbl.id
    local version = tbl[2] or tbl.version
    local resolver = tbl.resolver or settings.resolver
    resolver.resolve(id, version, tbl)
end

use {"cJSON", "1.7.18", repo = "DaveGamble/cJSON", release=true}
