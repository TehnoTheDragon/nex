# Nex
Lua module for creating classes and work with them

# Examples
```lua
local class = require('nex')

local Square = class "Square" {} -- class "Square" {} == class("Square")({})

function Square:init(width, height)
    self.width = width
    self.height = height
end

function Square:area()
    return self.width * self.height
end

local mySquare = Square(50, 10)
print(mySquare:area())
```