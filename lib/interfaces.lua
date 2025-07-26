remote.add_interface("reactive", {
	--- Used to test reactive updates from outside the UI
	flip = function(player_index)
		storage.reactive.player_scopes[player_index].controls_active =
			not storage.reactive.player_scopes[player_index].controls_active
	end,

	--- Debug prody relations
	print_proxy_relations = function()
		local nodes = ""
		local edges = ""

		local proxy_count = 0

		for _, proxy in pairs(storage.reactive.proxy_cache) do
			proxy_count = proxy_count + 1
			local data_string = ""

			for k, v in pairs(proxy.__data) do
				data_string = data_string
					.. (data_string == "" and "" or "|")
					.. "<"
					.. k
					.. ">"
					.. " "
					.. k
					.. "="
					.. tostring(v)
			end

			if data_string == "" then
				data_string = "empty"
			end

			nodes = nodes .. proxy.__id .. '[label="{' .. data_string
			if proxy.__owner then
				nodes = nodes .. "|" .. "Owner:" .. proxy.__owner
			end
			if proxy.__root then
				nodes = nodes .. "|" .. "Root:" .. proxy.__root
			end
			nodes = nodes .. '}"]\n'
		end

		for _, proxy in pairs(storage.reactive.proxy_cache) do
			for table, keys in pairs(proxy.__parents) do
				for key, _ in pairs(keys) do
					edges = edges .. table.__id .. ":" .. '"' .. key .. '"' .. "->" .. proxy.__id .. "\n"
				end
			end
		end

		game.print("Dumped data for " .. proxy_count .. " proxies")

		print(nodes)
		print(edges)
	end,
})
