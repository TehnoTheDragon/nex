local class = require("nex")
local unit = require("tests.unit")

local basics = unit.new("Basics")
basics:fine("Create Class", class "" {})
basics:equal("Class init", function(x)
    local myclass = class "MyClass" {}

    function myclass:init(x)
        self.value = x
    end

    return myclass(x).value
end, 10, 10)
basics:fine("Class overload init", function()
    local myclass = class "MyClass" {}

    function myclass:init()
        self.always = "Always"
    end

    myclass.operator.init(function(self)
        self.state = "init with no parameters"
    end)

    myclass.operator.init(function(self, name)
        self.state = "init with name"
        self.name = name
    end, "string")

    assert(myclass().name == nil)
    assert(myclass("hi").name == "hi")
end)
basics:fine("Class init with table", function()
    local myclass = class "MyClass" {}

    function myclass:init(data)
        self.data = data
    end

    myclass({message = "Hello!"})
end)
print(basics())