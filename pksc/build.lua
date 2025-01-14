
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

task {"build", function()
        print "downloading"
        curl("https://github.com/c3lang/c3c/releases/download/v0.6.5/c3-linux.tar.gz", "test.tar.gz")
end}


