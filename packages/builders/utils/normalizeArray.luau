export type RestOrArray<Type> = Type | { Type }

local function normalizeArray<ItemType>(arr: { RestOrArray<ItemType> })
    if #arr > 1 then
        return arr :: { ItemType }
    end
    local NewArray: { ItemType } = {}
    for _, v in arr :: any do
        table.insert(NewArray, v)
     end

    return NewArray
end

return normalizeArray