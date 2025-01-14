
project = {
        name = "Example Project",
        id = "example",
        version = Version(1,0,0),
        language = lang.C,
        system = {
                arch = {"*"},
                plat = {"*"}
        }
}

task {"build", function(args)
        print(args[1])
end}


