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

	run_proxy_sanitizer = function()
		if not storage.ACTIVE_PROXIES then
			game.print(
				"Cannot run sanitizer, proxy tracking is disabled!\n"
					.. "Tracking proxies is disabled by default since it breaks multiplayer. Enable it in the settings"
			)
		end
		-- just in case
		collectgarbage("collect")
		local active_proxies = table.deepcopy(storage.ACTIVE_PROXIES)

		-- ignore all proxies that are still in the cache. We have other tools to debug these
		for _, v in pairs(storage.reactive.proxy_cache) do
			active_proxies[v.__id] = nil
		end

		local leaked = 0

		for key, value in pairs(active_proxies) do
			game.print("Proxy with ID " .. key .. " is no longer active, but was not collected\n" .. value)
			leaked = leaked + 1
		end

		if leaked == 0 then
			game.print("No proxy leaks detected. Good job!")
		else
			game.print("Detected " .. leaked .. " proxy leaks. :(")
		end
	end,
})
