--[[
    Fiction - Advanced Game Enhancement Script
    
    This script provides various game enhancements for personal use only.
    Not intended for use in competitive environments or to gain unfair advantages.
    
    Based on the feature-set of Starhook with complete mobile optimization.
]]

-- Prevent multiple instances
if _G.FictionLoaded then
    warn("[Fiction] Script is already running!")
    return
end

_G.FictionLoaded = true

-- Global variables
_G.Fiction = {
    Enabled = true,
    Version = "1.0.0",
    LastUpdated = "2023",
    Author = "Personal Use Only",
    Settings = {},
    ActiveGame = nil,
    Initialized = false,
    Debug = false,
    Modules = {}
}

-- Module definitions - all combined into one file for loadstring

-- Config Module
Fiction.Modules.Config = {}
local Config = Fiction.Modules.Config

-- Default settings cache
local defaultSettings = {}
local settings = {}

-- Initialize with default settings
local function initializeDefaultSettings()
    defaultSettings = {
        -- Core settings
        Version = "1.0.0",
