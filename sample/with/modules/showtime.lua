local t
local function load()
	require("love.graphics")
	t = 0
end
local function update(dt)
	t = t + dt
end
local function draw()
	love.graphics.print("hello"..tostring(t), 0, 0)
end
return {
	__love = {
		default = {
			load = load,
			update = update,
			draw = draw,
		},
	},
}

