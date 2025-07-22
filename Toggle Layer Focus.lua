-- Toggles hiding all layers but the selected layer - By PhantomEye --

local focusLayer = app.layer
local sprite     = app.sprite

if not focusLayer then return app.alert "No active layer" end
if not sprite     then return app.alert "No active sprite" end

local focusChar = "*"
local hideChar  = "-"

-- Get the last character from a string
local function lastChar(str)
	return str:sub(-1)
end

-- Remove the last character from a string
local function removeLastChar(str)
	return str:sub(1, -2)
end

app.transaction(
	function()
		local countFocus = 0

		-- Count how many layers are marked as focused
		for _, layer in ipairs(sprite.layers) do
			if lastChar(layer.name) == focusChar then
				countFocus = countFocus + 1
			end
		end

		-- Invalid if there's more than one focus marker,
		-- or if one exists but it's not on the focusLayer
		if countFocus > 1 or (countFocus == 1 and lastChar(focusLayer.name) ~= focusChar) then
			return app.alert("Invalid situation!")
		end

		local queue = {}
		for _, layer in ipairs(sprite.layers) do
			table.insert(queue, layer)
		end

		local condition = lastChar(focusLayer.name) ~= focusChar

		if condition then
			-- Mark current layer as focused
			focusLayer.name = focusLayer.name .. focusChar
		else
			-- Remove the focus mark
			focusLayer.name = removeLastChar(focusLayer.name)
		end

		-- Iterate over other layers
		while #queue > 0 do 
			local layer = table.remove(queue, 1)

			if layer.isGroup then
				for _, child in ipairs(layer.layers) do
					table.insert(queue, child)
				end
			elseif layer ~= focusLayer then
				if condition then
					if layer.isVisible then
						layer.name = layer.name .. hideChar
						layer.isVisible = false
					end
				elseif lastChar(layer.name) == hideChar then
					layer.name = removeLastChar(layer.name)
					layer.isVisible = true
				end
			end
		end
	end
)

