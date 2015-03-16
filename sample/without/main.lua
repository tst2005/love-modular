local t
function love.load()
	-- pre --
	-- nothing

	-- default --
        require("love.graphics")
        t = 0

	-- post --
	-- nothing
end
function love.update(dt)
	-- pre --
	-- nothing

	-- default --
        t = t + dt

	-- post --
	-- nothing
end
function love.draw()
	-- pre --
	-- nothing

	-- default --
        love.graphics.print("hello"..tostring(t), 0, 0)

	-- post
	-- nothing
end
function love.keypressed(key)
	-- pre --
	-- nothing

	-- default --
	if key == "escape" then
		love.event.quit()
	end

	-- post
	-- nothing
end
