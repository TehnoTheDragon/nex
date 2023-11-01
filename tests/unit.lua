local function fln(fname, label)
    return ("[%s][%s]"):format(fname, label)
end

local function make_lazy_pcall(fn)
    return function(...)
        return pcall(fn, ...)
    end
end

local unit = {}

function unit.new(label)
    local self = {}
    self.messages = {}
    self.tests = {}
    return setmetatable(self, {
        __index = unit,
        __tostring = function()
            local message = "[".. label .."]:\n-   "
            local len = #self.messages
            for index, msg in ipairs(self.messages) do
                message = message .. msg
                if index < len then
                    message = message .. "\n-   "
                end
            end
            return message
        end,
        __call = function()
            self.messages = {}
            
            for _, task in ipairs(self.tests) do
                local result = task.task(unpack(task.args))
                local testResult = task.test(result)

                local resultMessage = testResult and "Successful" or "Failed"
                table.insert(self.messages, ("[%s][%s]"):format(task.label, resultMessage))
            end

            return tostring(self)
        end
    })
end

function unit:__test(label, run, test, ...)
    table.insert(self.tests, { label=label, task=run, test=test, args={...} })
end

function unit:messages()
    return self.messages
end

function unit:nofine(label, fn, ...)
    self:__test(label, make_lazy_pcall(fn), function(result, x)
        return result == false
    end, ...)
end

function unit:fine(label, fn, ...)
    self:__test(label, make_lazy_pcall(fn), function(result)
        return result == true
    end, ...)
end

function unit:equal(label, fn, expect, ...)
    self:__test(label, fn, function(result)
        return result == expect
    end, ...)
end

return unit