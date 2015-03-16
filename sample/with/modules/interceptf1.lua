local lovemodular = require("modules.lovemodular")
local signal_continue = lovemodular.signal_continue

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
