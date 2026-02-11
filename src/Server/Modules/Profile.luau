local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Log = require(ReplicatedStorage.Common.Log)

export type ProfileData = {
    Cash: number,
    Rebirth: number,
    Pickaxe: string,
    Owned_Pickaxes: { string },
    Opens: number,
    Gamepasses: { string },
    Stock: { [string]: number },
    Last_Restock: number,
    Block_Queue: { string },
    Upgrades: { [string]: number },
}

local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
type Profile = ProfileStore.Profile<ProfileData>

local PLAYER_DATA_TEMPLATE: ProfileData = {
    Cash = 999_999_999,
    Rebirth = 5,
    Pickaxe = "Angel",
    Owned_Pickaxes = { "Starter", "Angel" },
    Opens = 0,
    Gamepasses = {},
    Stock = {},
    Last_Restock = os.time(),
    Block_Queue = {},
    Upgrades = {},
}

local PlayerProfileStore = ProfileStore.New("Main", PLAYER_DATA_TEMPLATE)

local Profiles: { [Player]: Profile } = {}

function Load_Profile(Player: Player): Profile?
    if not Player:IsDescendantOf(Players) then
        return nil
    end

    local Profile

    if _G.IN_DEV == true then
        Profile = PlayerProfileStore.Mock:StartSessionAsync(tostring(Player.UserId), {
            Cancel = function()
                return not Player:IsDescendantOf(Players)
            end,
        })
    else
        Profile = PlayerProfileStore:StartSessionAsync(tostring(Player.UserId), {
            Cancel = function()
                return not Player:IsDescendantOf(Players)
            end,
        })
    end

    if Profile then
        Profile:AddUserId(Player.UserId)
        Profile:Reconcile()

        Profile.OnSessionEnd:Connect(function()
            Profiles[Player] = nil

            Player:Kick(`Profile session ended - please rejoin`)

            Log.Info(`Profile session ended for: '{Player.Name}'`)
        end)

        if Player.Parent == Players then
            Profiles[Player] = Profile

            Log.Info(`Profile loaded for: '{Player.Name}'`)

            return Profile
        else
            Profile:EndSession()

            Log.Info(`'{Player.Name}' left before their profile loaded`)

            return nil
        end
    else
        Player:Kick(`Profile failed to load`)

        Log.Warn(`Profile failed to load for: '{Player.Name}'`)

        return nil
    end
end

function Unload_Profile(Player: Player)
    local Profile = Profiles[Player]

    if Profile then
        Profile:EndSession()
        Profiles[Player] = nil

        Log.Info(`Profile unloaded for: '{Player.Name}'`)
    end
end

return table.freeze({
    Load = Load_Profile,
    Unload = Unload_Profile,
})
