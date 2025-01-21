
function download(name)

        local data = fetch("https://github.com/ellipse12/Pack/archive/refs/heads/main.zip")
        write(name..".zip", data)
end
for i = 1,20 do
        download(tostring(i))
end


