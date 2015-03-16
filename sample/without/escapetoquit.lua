local function keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
return {
	__love = {
		default = {
			keypressed = keypressed,
		},
	},
}
