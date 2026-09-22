hl.config({
	plugin = {
		scrolloverview = {
			scale = 0.7,
			layout = "vertical",
		},
	},
})

-- Toggle ScrollOverview with SUPER+g
hl.bind("SUPER + Return", function()
	hl.plugin.scrolloverview.overview("toggle all")
end)

hl.bind("SUPER + Return", function()
	hl.plugin.scrolloverview.overview("toggle all")
end)
