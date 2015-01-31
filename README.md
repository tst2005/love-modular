
# What is the problem ?

LÖVE ask to use functions love.{load,update,draw,...}

Sample :
```
function love.load()
	-- code
end

function love.update(dt)
	-- code
end

function love.draw()
	-- code
end
```

# Why using lovemodular ?

It's usefull to make module, and be able to re-used them easily.
It's also allow to enable/disable module dynamically.


# Documentation

## Simple use

Sample of module :
```
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
```

## Advanced Use

...


# Download

On github : https://github.com/tst2005/lovemodular.git

# Installation

...

# Sample of use

See https://github.com/tst2005/lovemodular-demo

