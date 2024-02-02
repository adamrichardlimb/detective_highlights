if CLIENT then
	local highlighted_corpses = {}

	net.Receive("detective_highlights", function( len )

		highlighted_corpses = net.ReadTable()
		PrintTable(highlighted_corpses)

		local color_red = Color( 255, 0, 0 )

		halo.add(highlighted_corpses, color_red, 5, 5, 2)
	end)
end