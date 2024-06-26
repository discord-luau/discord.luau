local test = {}

local main = require("./main")
local assert = require("./assert")
local reporter = require("./lib/reporter")
local utils = require('utils')

-- make sure to initalize a reporter before running, otherwise you will get no output
-- see `src/reporters` for builtin reporters available
-- returns false if any test failed, true otherwise
test.run = function(): boolean
    main.load_suites()
    return main.run_tests()
end

test.test = main
test.assert = assert

test.run_tests = function(configPath: string?)
    utils.run_tests_file(configPath)
    reporter.init()
    local success = test.run()
    if not success then
        require("@std/process").exit(1)
    end
end

return test