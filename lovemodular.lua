--[[--------------------------------------------------------
	-- Dragoon Framework - A Framework for Lua/LOVE --
	-- Copyright (c) 2014-2015 TsT worldmaster.fr --
--]]--------------------------------------------------------

-- API:
-- the module to register must have a __love field
-- the __love field must have one or more of the followin sub-field :
--    pre / default / post
-- each sub-field will contains love callbacks name to bind.
-- the numerical field 1 must bethe module name (used in error message)

local levelnames = {"pre", "default", "post"}
local validsubfields = {}
do
	for i,levelname in ipairs(levelnames) do
		validsubfields[levelname] = true
	end
end

local internal = {} -- internal.<callback>.<level>[n]

local function dolevels(internal, __love, modname)
	local function dolevel(levelname, callbacks)
		for callback,f in pairs(callbacks) do
			if type(f) ~= "function" then
				error("handler for ... (function expected, got "..type(f)..")", 3)
			end
			local q_callback = internal[callback]
			if not q_callback then
				q_callback = {}
				internal[callback] = q_callback
			end
			local q_level = q_callback[levelname]
			if not q_level then
				q_level = {}
				q_callback[levelname] = q_level
			end
			-- check if f is already in this level, do not add twice.
			local function exists(f)
				for i, f2 in ipairs(q_level) do
					if f == f2 then
						return true
					end
				end
				return false
			end
			if not exists(f) then
				q_level[#q_level+1] = f
				--print("[modular] ".. tostring(modname) .. " register love." .. callback .. "(level=".. levelname..")", f)
			end
		end
	end

	for i,levelname in ipairs(levelnames) do
		local callbacks = __love[levelname]
		if callbacks then
			dolevel(levelname, callbacks)
		end
	end
	local reg = __love.registered
	if reg and type(reg) == "function" then
		reg()
	end
end
local function undolevels(internal, __love, modname)
	local function undolevel(levelname, callbacks)
		for callback,f in pairs(callbacks) do
			local q_callback = internal[callback]
			if not q_callback then
				return
			end
			local q_level = q_callback[levelname]
			if not q_level then
				return
			end
			for i, f2 in ipairs(q_level) do
				if f == f2 then
					table.remove(q_level, i)
					--print("[modular] ".. tostring(modname) .. " unregister love." .. callback .. "(level=".. levelname..")", f)
				end
			end
		end
	end

	for i,levelname in ipairs(levelnames) do
		local callbacks = __love[levelname]
		if callbacks then
			undolevel(levelname, callbacks)
		end
	end
	local unreg = __love.unregistered
	if unreg and type(unreg) == "function" then
		unreg()
	end
end


local function checksubfield(__love)
	local todo = false
	for k, v in pairs(__love) do
		if type(k) ~= "number" then
			if not validsubfields[k] then
				assert("Invalid love modular field : "..tostring(k))
			else
				todo=true -- something todo
			end
		end
	end
	return todo
end

local function register(mod)
	if type(mod) ~= "table" then
		error("bad argument #1 to 'register' (table expected, got "..type(mod)..")", 2)
	end

	-- module name --
	local name = mod._NAME and tostring(mod._NAME)
	--if not name then error("WARNING: module._NAME not defined", 2) end
	name = name or "?"

	-- check field --
	if not mod.__love then
		return false, name..": No callback to register for this module"
	end

	-- check sub field --
	local todo = checksubfield(mod.__love)
	if not todo then
		return false, name..": Nothing to do, there no pre/default/post field inside __love"
	end
	dolevels(internal, mod.__love, name)

	return true, name..": ok"
end

local function unregister(mod)
	if type(mod) ~= "table" then
		error("bad argument #1 to 'unregister' (table expected, got "..type(mod)..")", 2)
	end

	-- module name --
	local name = mod._NAME and tostring(mod._NAME)
	name = name or "?"

	-- check field --
	if not mod.__love then
		return false, name..": No callback to unregister for this module"
	end

	-- check sub field --
	local todo = checksubfield(mod.__love)
	if not todo then
		return false, name..": Nothing to do, there no pre/default/post field inside __love"
	end
	undolevels(internal, mod.__love, name)

	return true, name..": ok"
end


local signal_continue
signal_continue = function(...)
	local t = {...}
	return signal_continue, function() return unpack(t) end
end

-- Some uniq data only provide by this module
local signal_stop_all;
signal_stop_all = function() return signal_stop_all end
local signal_stop;
signal_stop = function(all)
	if all == "all" then
		return signal_stop_all
	end
	return signal_stop
end

local function signal_emit(callback, ...)
	--print("DEBUG: signal_emit", callback, ...)
	local q_callback = internal[callback]
	if q_callback then
		local finalreturn = nil
		local continuemode = false
		local continue_with = nil
		for i,q_level in ipairs(levelnames) do
			if q_callback[q_level] then
				for i,f in ipairs(q_callback[q_level]) do
					local r,s
					if continuemode then
						--print("[lovemodular] continuemode in level "..q_level.." of callback "..callback)
						r,s = f(continue_with())
						continuemode = false
						continue_with = nil
					else
						r,s = f(...)
					end
					if r == signal_stop then
						--print("[lovemodular] stop level "..q_level.." of callback "..callback)
						break -- exit only from the current level
					elseif r == signal_stop_all then
						--print("[lovemodular] stop all level of callback "..callback.." from level "..q_level)
						return s
					elseif r == signal_continue then
						assert(type(s) == "function", "Invalid usage of signal_continue. Usage: signal_continue(data...)")
						--print("[lovemodular] signal_continue in level "..q_level.." of callback "..callback)
						continuemode = true
						continue_with = s
					else
						if s ~= nil then finalreturn = s end -- remember the return value of the latest handle.
					end
				end
			end
		end
		return finalreturn
	end
end

local all_callbacks = {
	'draw', 'errhand', 'focus', 'keypressed', 'keyreleased', 'load',
	'mousefocus', 'mousepressed', 'mousereleased', 'quit', 'resize',
	'textinput', 'threaderror', 'update', 'visible',
	'gamepadaxis', 'gamepadpressed', 'gamepadreleased',
	'joystickadded', 'joystickaxis', 'joystickhat',
	'joystickpressed', 'joystickreleased', 'joystickremoved',
	'touch',
}


local function validcallback(callback)
	for i,c in ipairs(all_callbacks) do
		if c == callback then
			return true
		end
	end
	return false
end

local beforeinstall = {} -- to store original callbacks (will be restored on uninstall)
local registred = {} -- remember generated handler to check / do stuff once time


local function registerEvent(callback, love)
	if not validcallback(callback) then
		error("Invalid callback "..tostring(callback), 3)
	end
	if not registred[callback] then
		--print("[modular] register love."..callback)
		local current = love[callback]
		local f
		if current then
			beforeinstall[callback] = current
			f = function(...)
				current(...)
				return signal_emit(callback, ...)
			end
		else
			f = function(...)
				return signal_emit(callback, ...)
			end
       	        end
		love[callback] = f
		registred[callback] = f
	elseif love[callback] ~= registred[callback] then
		error("WARNING: something overwrite the love."..callback.." love."..callback.."="..tostring(love[callback]).. " != "..tostring(registred[callback]))
	end
end

local function install(callbacks, love)
	if love ~= nil and type(love) ~= "table" then
		error("bad argument #2 to 'install' (nil or table expected, got "..type(love)..")", 2)
	end
	if love == nil then
		love = require("love")
	end
	assert(type(love) == "table", "bad argument #2 to 'install' (love is not a table)")

	if callbacks == "*" then
		callbacks = all_callbacks
	end

	if not callbacks then
		for callback in pairs(internal) do
			registerEvent(callback, love)
		end
	elseif type(callbacks) == "table" then
		for _, callback in ipairs(callbacks) do
			registerEvent(callback, love)
		end
	elseif type(callbacks) == "string" then
		registerEvent(callbacks, love)
	else
		error("bad argument #1 to 'install' (nil, string or table expected, got "..type(callbacks)..")", 2)
	end
end

local function uninstall()
	-- NOT IMPLEMENTED YET
end

local _M = {
	install    = install,
	uninstall  = uninstall,  -- TODO
	register   = register,
	unregister = unregister, -- to check
	signal_emit     = assert(signal_emit),
	signal_stop     = assert(signal_stop),
	signal_continue = assert(signal_continue),

	all = function() return unpack(all_callbacks) end, -- returns all the callbacks supported.
}

return _M
