local lovemodular = require("modules.lovemodular")

local f1 = require("modules.interceptf1")
lovemodular.register(f1)

local showtime = require("modules.showtime")
lovemodular.register(showtime)

local escapetoquit = require("modules.escapetoquit")
lovemodular.register(escapetoquit)

lovemodular.install()

