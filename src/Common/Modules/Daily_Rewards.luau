--!strict

type Reward =
    { Type: "Cash", Amount: number }
    | { Type: "Brainrot", Image: string, Name: string, Primary_Mutation: string? }

local Daily_Rewards: {
    [number]: {
        [number]: Reward,
    },
} = {
    [1] = {
        [1] = {
            Type = "Cash",
            Amount = 500,
        },
        [2] = {
            Type = "Brainrot",
            Image = "rbxassetid://138322655283019",
            Name = "Los Tralaleritos",
        },
        [3] = {
            Type = "Cash",
            Amount = 1000,
        },
        [4] = {
            Type = "Cash",
            Amount = 25_000,
        },
        [5] = {
            Type = "Brainrot",
            Image = "rbxassetid://108671715386218",
            Name = "Girafa Celeste",
            Primary_Mutation = "Diamond",
        },
        [6] = {
            Type = "Cash",
            Amount = 100_000,
        },
        [7] = {
            Type = "Brainrot",
            Image = "rbxassetid://86636033880234",
            Name = "Six Seven",
        },
    },
}

return table.freeze(Daily_Rewards)
