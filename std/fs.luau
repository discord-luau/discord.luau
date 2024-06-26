local fs = require("@lune/fs")

local Fs = {}


function Fs.appendFile(path: string, contents: buffer | string): ()
    local oldContents = fs.readFile(path)

    local newContents = {}

    for i, content in string.split(oldContents, '\n') do
        if content ~= "" then
            table.insert(newContents, content)
        end
    end

    table.insert(newContents, tostring(contents))

    fs.writeFile(path, table.concat(newContents, '\n'))
end

return setmetatable(Fs, {
    __index = require("@lune/fs")
})