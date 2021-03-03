local parser = {}

parser.errors = {
	unfinishedString = 1,
	unfinishedPlaceDefinition = 2,
	malformedPlaceDefinition = 3,
}

parser.errorMessages = {
	[1] = "Unfinished string starting at line %d",
}

parser.tokenTypes = {
	unknown = 0,
	string = 1,
	place = 2,
	number = 3,
}

--

local function getType(str)
	if tonumber(str) then return parser.tokenTypes.number
	else return parser.tokenTypes.unknown end
end

function parser:parse(text)
	local tokens = {{}}
	
	do -- Get tokens
		local token = ""
        local function addToken(addingToken, tokenType)
			table.insert(tokens[#tokens], {token = addingToken, type = tokenType})
			token = ""
		end
		
		local inString = false
		local inPlaceDef = false
		local placeDef, placeDefining = nil
		local ignoringLetter = false
		
		for i = 1, #text do
			local v = text:sub(i, i)
			
			if not ignoringLetter then -- Ignore letters if ignoringLetter
			
			-- Push token if space found (and it was not inside a string, neither of a place def)
			if v == " " and not inString then
				if #token~=0 then
					addToken(token, getType(token))
				end
			-- Make string if " found (and not in inPlaceDef)
			elseif v == [["]] then
				inString = (i and not inString)
				
				if not inString then -- If string ended
					addToken(token, parser.tokenTypes.string)
				elseif #token~=0 then -- If string started
					addToken(token, getType(token))
				end
			-- If \ found, ignore next letter
			elseif v == "\\" then
				ignoringLetter = true
			--- If [ or ] found, start a placeDefinition
			elseif (v == "[" or v == "]" or v == "," or v == ":") and not inString then
				if v == "[" then -- start placeDefinition
					-- Check for error
					if inPlaceDef then return self.errors.malformedPlaceDefinition end
					
					-- End
					table.insert(tokens, {}) -- Make so tokens insert to this new table
					placeDef = {starting = i, def = {}, calledWith = token}
					token = ""
				elseif v == "," then -- Next value
					-- Push a token if possible
					if #token~=0 then addToken(token, getType(token))
					end
					
					-- Check for error
					if not placeDefining then return self.errors.malformedPlaceDefinition end
					
					-- Get val to define to var
					local vals = tokens[#tokens]
					if #vals > 1 then return self.errors.malformedPlaceDefinition end
					val = vals[1]
					
					-- Define
					if val then
						placeDef.def[placeDefining.token] = val
					else
						table.insert(placeDef.def, val)
					end
					
					-- End
					placeDefining = nil
					table.remove(tokens[#tokens], 1)
				elseif v == ":" then -- Define value
					-- Push a token if possible
					if #token~=0 then addToken(token, getType(token))
					end
					
					-- Gets var to def
					local vars = tokens[#tokens]
					if #vars > 1 then return self.errors.malformedPlaceDefinition end
					var = vars[1]
					
					-- Make so it starts defining it
					placeDefining = var
					
					-- End
					table.remove(tokens[#tokens], 1)
				else -- end placeDefinition
					-- Check for errors
					if #tokens[#tokens] ~= 0 then return self.errors.malformedPlaceDefinition end
					
					-- End placeDef
					table.remove(tokens, #tokens)
					addToken(placeDef, self.tokenTypes.place)
				end
			--
			else -- Sometimes a white space gets insterted out of nowhere for no reason, would like to look at the reason but I wrote this in like 3 mins quickly so fuck it
				token = token .. v
			end
			
			-- End
			else ignoringletter = false end
		end
			
		-- Return error if unfinishedString
		if inString then
			return self.errors.unfinishedString, inString
		end
		
		-- Return error if unfinishedPlaceDefinition
		if inPlaceDef then
			return self.errors.unfinishedPlaceDefinition, placeDef.starting
		end
		
		-- Push a token if possible
		if #token~=0 then addToken(token, getType(token))
		end
	end
	
	return tokens[1]
end

--

return parser