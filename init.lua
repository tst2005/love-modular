--[[--------------------------------------------------------
	-- Dragoon Framework - A Framework for Lua/LOVE --
	-- Copyright (c) 2014-2015 TsT worldmaster.fr --
--]]--------------------------------------------------------

local target = "modular"
local path = (... or ""):gsub("%.[^%.]+$", "");path=path~="" and path.."." or ""
return require(path..target)
