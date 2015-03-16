
# What is the problem ?

LÖVE ask to use functions love.{load,update,draw,...}

Sample :
```lua
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

The problem is it's not easy to setup lot of features inside only one functions.
Each kind of feature needs to use one or more love callbacks.

# Why using love modular ?

It's usefull to make module, and be able to re-used them easily.
It's also allow to enable/disable module dynamically.


# Documentation

## Simple use

Sample of module :
```lua
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


## Catching Signals


### stop signal


Sample to stop the defaults keypressed events (but the pre or post keypressed events will still worked)
```lua
local modular = require("modular")
local signal_stop = modular.signal_stop

return {
	__love = {
		default = {
			keypressed = function(key)
				return signal_stop
			end,
		},
	},
}
```

### stop all signals

Sample of way to drop all keypressed events.
```lua
local modular = require("modular")
local signal_stop_all = modular.signal_stop("all")

return {
	 __love = {
		pre = {
			keypressed = function(key)
				return signal_stop_all
			end,
		},
	},
}
```


### intercept a signal

Sample of interception : replace the f1 by escape

```lua
local modular = require("modular")
local signal_continue = modular.signal_continue

return {
	__love = {
		pre = {
			keypressed = function(key)
				if key == "f1" then
					return signal_continue("escape")
				end
			end,
		},
	},
}
```
Note: the intercepted signal will be propaged to all others level (pre, default and post) callbacks.


# Download

On github : https://github.com/tst2005/love-modular

# TODO

 * More documentation and samples
 * Release it ! Write a thread on the love2d.org forum about it
 * Found a easy way to manage priority

# Sample of use

See https://github.com/tst2005/love-modular-demo

# License

 * My code follows the MIT License.
