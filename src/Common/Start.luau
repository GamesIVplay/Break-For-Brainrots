_G.IN_DEV = false
_G.JECS_DEBUG = true
_G.Mock = false

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Planck = require(ReplicatedStorage.Packages.Planck)
local Scheduler = require("./Scheduler")
local World = require("./World")

local Jabby = require(ReplicatedStorage.Packages.Jabby)

local Log = require("./Log")

local function Setup_Jabby()
    Jabby.set_check_function(function(Player)
        if Player.UserId == 3439160531 then
            return true
        else
            return false
        end
    end)

    if RunService:IsClient() then
        local client = Jabby.obtain_client()

        local function create_widget(_, state)
            if state ~= Enum.UserInputState.Begin then
                return
            end
            client.spawn_app(client.apps.home, nil)
        end

        ContextActionService:BindAction("Open Jabby Home", create_widget, false, Enum.KeyCode.F4)
    end

    Jabby.register({
        applet = Jabby.applets.world,
        name = "Break For Brainrots!",
        configuration = {
            world = World,
        },
    } :: any)
end

Scheduler.forceRunPhase = function(self, phase)
    if not self._phaseToSystems[phase] then
        self._phaseToSystems[phase] = {}
    end

    for _, system in self._phaseToSystems[phase] do
        self:runSystem(system)
    end

    return self
end

return function(Systems)
    if #Systems > 0 then
        Scheduler:addSystems(Systems)
            :forceRunPhase(Planck.Phase.PreStartup)
            :forceRunPhase(Planck.Phase.Startup)
            :forceRunPhase(Planck.Phase.PostStartup)
    else
        Log.Warn("There are 0 systems")
    end

    Setup_Jabby()
end
