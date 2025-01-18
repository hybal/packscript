
project = {
        name = "Example Project",
        id = "example",
        version = Version(1,0,1),
        language = lang.C,
}

local test = cat "test.lua"
print(test)
re.freplace("test.lua", [[version = "([^"]*)"]], [[version = \1]])
test = cat "test.lua"
print(test)
