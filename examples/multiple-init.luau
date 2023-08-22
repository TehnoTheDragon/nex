local class = require("nex")

local Player = class "Player" {}

function Player:init()
    print("Main Init")
end

Player.operator.init(function(self)
    self.name = "None"
    print("None")
end)

Player.operator.init(function(self, name)
    self.name = name
    print(name)
end, "string")

Player()
Player("Somename")