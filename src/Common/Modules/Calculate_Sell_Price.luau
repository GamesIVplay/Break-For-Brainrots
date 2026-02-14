local Calculate_Income_Per_Sec = require(script.Parent.Calculate_Income_Per_Sec)

return function(Data: {
    Brainrot_Name: string,
    Primary_Mutation: string?,
    Secondary_Mutations: { string },
    Weight: number,
}): number
    local Sell_Price = Calculate_Income_Per_Sec(Data)
    Sell_Price = math.round(Sell_Price * 15)

    return math.max(1, Sell_Price)
end
