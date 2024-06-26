local fs = require("@std/fs")
local process = require("@std/process")
local luauPolyfill = require("@deps/polyfill")
local picomatch = require("@deps/picomatch")
local regexp = require("@deps/regexp")
local types = require('types')

local array = luauPolyfill.Array
local object = luauPolyfill.Object

type Array<T> = luauPolyfill.Array<T>

local utils = {}

-- i think this is a lune issue, but debug.info returns [string "<filename>"]
function utils.clean_filename(name: string): string
    local front_trimmed = name:sub(10)
    return front_trimmed:sub(1, -3)
end

function utils.trim(s: string): string
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function utils.make_indent(i: number): string
    local spaces = "    "
    local s = ""
    for j = 0, i - 1 do
        s = s .. spaces
    end
    return s
end

function utils.multiline_to_array(s: string): { string }
    local res = {}
    for line in string.gmatch(s .. "\n", "(.-)\n") do
        table.insert(res, line)
    end
    return res
end

function utils.indent_multiline(s: string, i: number): string
    local lines = utils.multiline_to_array(s)
    for k, s in ipairs(utils.multiline_to_array(s)) do
        lines[k] = utils.make_indent(i) .. s
    end
    return table.concat(lines, "\n")
end

function utils.get_all_descendant_files(dirPath)
    local files = {}

    local contents = fs.readDir(dirPath)

    array.forEach(contents, function(item)
        local itemPath = `{dirPath}/{item}`
        if fs.isDir(itemPath) then
            files = array.concat(files, utils.get_all_descendant_files(itemPath))
        else
            array.push(files, itemPath)
        end
    end)

    return files
end

--- @deprecated
function utils.glob_to_lua_pattern(globPattern)
    -- Escape characters that have special meaning in Lua patterns
    local luaPattern = string.gsub(globPattern, "[%.%^%$%(%)%%[%]%+%-%?]", "%%%1")

    -- Replace '**' with '.+' to match any number of directories
    luaPattern = string.gsub(luaPattern, "%*%*", ".+")

    -- Replace '*' with '[^/]*' to match any part of a filename
    luaPattern = string.gsub(luaPattern, "%*", "[^/]*")

    -- Replace '/' with '%/' to match the directory separator '/'
    luaPattern = string.gsub(luaPattern, "/", "%%/")

    -- Add anchors to match the whole string
    luaPattern = "^" .. luaPattern .. "%.luau$"

    return luaPattern
end

function utils.normalize(options: types.InitialOptions): types.ProjectConfig
    local newConfig = object.assign({}, options, { rootDir = options.rootDir or process.cwd})

    if newConfig.root ~= nil and typeof(newConfig.root) == "string" then
        if newConfig.root == "<rootDir>" then
            newConfig.root = newConfig.rootDir :: string
        end
    else
        newConfig.root = process.cwd
    end
    return newConfig 
end

function utils.read_config(configPath: string?)
    local req = require :: any
    local configPath = configPath or 'test.config.luau'


    local config: types.ProjectConfig
    config = fs.isFile(`{process.cwd}/{configPath}`) and req(`{process.cwd}/{configPath}`) or require('./config').default
    config = utils.normalize(config)

    return config :: types.ProjectConfig
end

function utils.get_files(path, files, config: types.ProjectConfig)
    local files = files or {}
    
    for _, item: string in fs.readDir(path) do
        local item_path = `{path}/{item}`
        if fs.isDir(item_path) then
            utils.get_files(item_path, files, config)
        else
            local isMatch = picomatch(config.testMatch)
            if isMatch(item) then
                table.insert(files, item_path)
            end 
        end
    end

    return files
end

function utils.get_test_files(config: types.ProjectConfig)
    local root = config.root

    local files = {}

    utils.get_files(root, files, config)
    return files 
end

function utils.run_tests_file(configPath: string?)
    local config: types.ProjectConfig = utils.read_config(configPath)
    local root = config.root

    local testFiles = utils.get_test_files(config)

    for _, file in testFiles do
        local req = require :: any
        req(file)
    end
end

return utils