type Hex = string | number
export type RGBTuple = { red: number, green: number, blue: number }

local function validateRGB(rgb: RGBTuple)
    assert(typeof(rgb) == "table", "Invalid RGB")
    assert(typeof(rgb.red) == "number", "Invalid RGB")
    assert(typeof(rgb.green) == "number", "Invalid RGB")
    assert(typeof(rgb.blue) == "number", "Invalid RGB")

    local red = math.clamp(rgb.red, 0, 255)
    local green = math.clamp(rgb.green, 0, 255)
    local blue = math.clamp(rgb.blue, 0, 255)

    local colorNumber = bit32.lshift(red, 16) + bit32.lshift(green, 8) + blue

    return colorNumber
end

local function validateHex(hex: Hex): number?
    if typeof(hex) == "number" then
        return hex
    end
    assert(typeof(hex) == "string", "Hex must be a string")

    hex = hex:gsub("#", "")
    hex = hex:gsub("^0x", "")

    local newHex = string.match(hex, `^%x%x%x%x%x%x$`)

    if newHex then
        return tonumber(newHex, 16) :: number
    end

    return
end

return {
    ValidateHex = validateHex,
    ValidateRGB = validateRGB
}
