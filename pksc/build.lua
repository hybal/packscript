
project = {
        name = "Example Project",
        id = "example",
        version = Version(1,0,1),
        language = lang.C,
}

for line in io.lines("../Cargo.toml") do
    print(line)
end
