local mysql = exports.mysql
savedTextures = {}
integration = exports.integration
global = exports.global
textureItemID = 147

addEventHandler('onResourceStart', resourceRoot,
	function()
		local count = 0
		local result = mysql:query("SELECT * FROM interior_textures")
		local time = getTickCount()
		if result then
			while true do
				row = mysql:fetch_assoc(result)
				if not row then break end

				row.interior = tonumber(row.interior)
				row.id = tonumber(row.id)
				if not savedTextures[row.interior] then
					savedTextures[row.interior] = {}
				end
				savedTextures[row.interior][row.id] = { id = row.id, texture = row.texture, url = row.url }

				count = count + 1
			end

			outputDebugString('Loaded ' .. count .. ' texture records for all interiors in ' .. math.ceil(getTickCount() - time) .. 'ms')
			mysql:free_result(result)
		end
	end)

--
function getPath(url)
	return 'cache/' .. md5(tostring(url)) .. '.tex'
end

-- loads a skin from an url
function loadFromURL(url, interior, id)
	fetchRemote(url, function(str, errno)
			if str == 'ERROR' then
				-- outputDebugString('clothing:stream - unable to fetch ' .. url)
			else
				local file = fileCreate(getPath(url))
				fileWrite(file, str)
				fileClose(file)

				local data = savedTextures[interior][id]
				if data and data.pending then
					triggerLatentClientEvent(data.pending, 'frames:file', resourceRoot, id, url, str, #str)
					data.pending = nil
				end
			end
		end)
end


-- send frames to the client
addEvent( 'frames:stream', true )
addEventHandler( 'frames:stream', resourceRoot,
	function(interior, id)
		local interior = tonumber(interior)
		local id = tonumber(id)
		-- if its not a number, this'll fail
		if type(id) == 'number' and type(interior) == 'number' then
			local data = savedTextures[interior] and savedTextures[interior][id]
			if data then
				local path = getPath(data.url)
				if fileExists(path) then
					local file = fileOpen(path, true)
					if file then
						local size = fileGetSize(file)
						if tonumber(size) then
							local content = fileRead(file, size)

							if #content == size then
								triggerLatentClientEvent(client, 'frames:file', resourceRoot, id, data.url, content, size)
							else
								outputDebugString('frames:stream - file ' .. path .. ' read ' .. #content .. ' bytes, but is ' .. size .. ' bytes long')
							end
							fileClose(file)
						end
					else
						outputDebugString('frames:stream - file ' .. path .. ' existed but could not be opened?')
					end
				else
					-- try to reload the file from the given url
					if data.pending then
						table.insert(data.pending, client)
					else
						data.pending = { client }
						loadFromURL(data.url, interior, id)
					end
				end
			else
				outputDebugString('frames:stream - frames #' .. interior .. '/' .. id .. ' do not exist.')
			end
		end
	end, false)

--

addEvent("frames:loadInteriorTextures", true)
addEventHandler("frames:loadInteriorTextures", root,
	function(dimension)
		triggerClientEvent(client or source, 'frames:list', resourceRoot, dimension, savedTextures[dimension])
	end)

--

addEvent("frames:delete", true)
addEventHandler("frames:delete", resourceRoot,
	function(id)
		local interior = getElementDimension(client)
		if (global:hasItem(client, 4, interior) or global:hasItem(client, 5, interior) or integration:isPlayerAdmin(client) or (interior==0 and integration:isPlayerLeadAdmin(client))) then
			local data = savedTextures[interior]
			if not data or not data[id] then
				outputChatBox("This isn't even your texture?", client, 255, 0, 0)
			else
				local success = mysql:query_free("DELETE FROM interior_textures WHERE id = '" .. mysql:escape_string ( id ) .. "' AND interior = '" .. mysql:escape_string( interior ) .. "'" )
				if success then
					outputChatBox("Deleted Texture with ID " .. id .. ".", client, 0, 255, 0)

					-- sorta tell everyone who is inside
					for k,v in ipairs(getElementsByType"player") do
						if getElementDimension(v) == interior then
							triggerClientEvent(v, 'frames:removeOne', resourceRoot, interior, id)
						end
					end

					local thisData = data[id]
					--give the removed texture as a picture frame item with the same values
					exports['item-system']:giveItem(client, textureItemID, tostring(thisData.url)..";"..tostring(thisData.texture))

					savedTextures[interior][id] = nil
				else
					outputChatBox("Failed to remove texture ID " .. id .. ".", client, 255, 0, 0)
				end
			end
		else
			outputChatBox("You need a key.", client, 255, 0, 0)
		end
	end)

-- exported
function newTexture(source, url, texture)
	local dimension = getElementDimension(source)
	if (dimension > 0 or exports.integration:isPlayerLeadAdmin(source)) then
		if (global:hasItem(source, 4, dimension) or global:hasItem(source, 5, dimension) or exports.integration:isPlayerAdmin(source)) then
			-- check if said texture is already replaced
			if savedTextures[dimension] then
				for k, v in pairs(savedTextures[dimension]) do
					if v.texture:lower() == texture:lower() then
						outputChatBox('This texture is already replaced, please remove it first with /texlist.', source, 255, 0, 0)
						return false
					end
				end
			end

			local id = mysql:query_insert_free("INSERT INTO interior_textures SET interior = '" .. mysql:escape_string(dimension) .. "', texture = '" .. mysql:escape_string(texture) .. "', url = '" .. mysql:escape_string(url) .. "'")
			if id then
				local row = { id = id, texture = texture, url = url }
				if not savedTextures[dimension] then
					savedTextures[dimension] = {}
				end
				savedTextures[dimension][id] = row

				for k, v in ipairs(getElementsByType"player") do
					if getElementDimension(v) == dimension then
						triggerClientEvent(v, 'frames:addOne', resourceRoot, dimension, row)
					end
				end

				outputChatBox ( "Texture successfully replaced!", source, 0, 255, 0 )
				return true
			end
			outputChatBox ( "Failed to replace texture.", source, 255, 0, 0 )
			return false
		else
			outputChatBox("You do not own this interior.", source, 255, 0, 0, false)
			return false
		end
	else
		outputChatBox("You need to be in an interior to retexture.", source, 255, 0, 0, false)
		return false
	end
	return false
end
