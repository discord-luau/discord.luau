local CDN = require("cdn")
local REST = require("rest")
local Utils = require("utils/utils")

export type CDN = CDN.CDN
export type ImageURLOptions = CDN.ImageURLOptions
export type REST = REST.REST

return {
    CDN = CDN,
    REST = REST,
    calculateUserDefaultAvatarIndex = Utils.calculateUserDefaultAvatarIndex
}