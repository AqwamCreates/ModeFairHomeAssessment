-- If you wish to run this Luau code, then please get the compiler here: https://github.com/luau-lang/luau/releases

-- Even though Luau is derived from Lua, Lua compiler will not run this code as Luau is a heavily modified version of Lua by Roblox.

local alphabetMatrix = {
	
	{"A", "B", "C"},
	{"D", "E", "F"},
	{"G", "H", "I"},
	
}

local letterCombinationStringArray = {}

local function checkIfElementHasAlreadyAdded(row, column, visitedRowIndexArray, visitedColumnArray, currentDepth)
	
	for i = 1, currentDepth, 1 do

		if (visitedRowIndexArray[i] == row) and (visitedColumnArray[i] == column) then return true end

	end
	
	return false
	
end

local function checkIfCanCrossElementsAlongRows(targetRow, targetColumn, originRow, visitedRowIndexArray, visitedColumnArray, currentDepth)
	
	for row = originRow, targetRow do
		
		if (row == originRow) and (row == targetRow) then continue end  -- Because the target row can be smaller than origin row and vice versa, I think it is better to skip those rows instead of finding the modified target row and origin row values for better code readability.
			
		if not checkIfElementHasAlreadyAdded(row, targetColumn, visitedRowIndexArray, visitedColumnArray, currentDepth) then return false end
		
	end
	
	return true
	
end

local function checkIfCanCrossElementsAlongColumns(targetRow, targetColumn, originColumn, visitedRowIndexArray, visitedColumnArray, currentDepth)

	for column = originColumn, targetColumn do
		
		if (column == originColumn) and (column == targetColumn) then continue end -- Same explaination to the above.
			
		if not checkIfElementHasAlreadyAdded(targetRow, column, visitedRowIndexArray, visitedColumnArray, currentDepth) then return false end

	end

	return true

end

local function checkIfCanCrossElementsAlongDiagonals(targetRow, targetColumn, visitedRowIndexArray, visitedColumnArray, currentDepth)
	
	for row = 1, 3, 1 do
		
		for column = 1, 3, 1 do
			
			if (row == targetRow) or (column == targetColumn) then continue end -- Skip elements that are along the same rows or columns as these are not diagonal positions.
			
			local total = row + column
			
			if (total % 2 ~= 0) then continue end -- Skip non-diagonal positions.
			
			if not checkIfElementHasAlreadyAdded(row, column, visitedRowIndexArray, visitedColumnArray, currentDepth) then return false end
			
		end
		
	end
	
	return true
	
end

local function checkIfCanSearch(targetRow, targetColumn, visitedRowIndexArray, visitedColumnArray, currentDepth) -- I prefer to break large problems to smaller ones. Then answer the smaller problems with small answers. Then I build larger answers using small answers and use it to solve large problems.
	
	if (currentDepth == 0) then return true end
	
	local originRow = visitedRowIndexArray[currentDepth]
	
	local originColumn = visitedColumnArray[currentDepth]

	local absoluteShiftInRowPosition = math.abs(targetRow - originRow)

	local absoluteShiftInColumnPosition = math.abs(targetColumn - originColumn)
	
	local isElementNotHasAlreadyAdded = not checkIfElementHasAlreadyAdded(targetRow, targetColumn, visitedRowIndexArray, visitedColumnArray, currentDepth)
	
	-- If statements when the other element is nearby.
		
	if (absoluteShiftInRowPosition == 0) and (absoluteShiftInColumnPosition == 1) then return isElementNotHasAlreadyAdded end -- Other element in same row, but adjacent column and has not added yet, then true.
	
	if (absoluteShiftInRowPosition == 1) and (absoluteShiftInColumnPosition == 0) then return isElementNotHasAlreadyAdded end -- Other element in same column, but adjacent row and has not added yet, then true.
	
	if (absoluteShiftInRowPosition == 1) and (absoluteShiftInColumnPosition == 1) then return isElementNotHasAlreadyAdded end -- If the other element is a "proper diagonal" position and has not added yet, then true.
	
	-- If statements when the other element is behind another value.
	
	if (absoluteShiftInRowPosition == 0) and (absoluteShiftInColumnPosition >= 2) and checkIfCanCrossElementsAlongColumns(targetRow, targetColumn, originColumn, visitedRowIndexArray, visitedColumnArray, currentDepth) then return isElementNotHasAlreadyAdded end
	
	if (absoluteShiftInRowPosition >= 2) and (absoluteShiftInColumnPosition == 0) and checkIfCanCrossElementsAlongRows(targetRow, targetColumn, originRow, visitedRowIndexArray, visitedColumnArray, currentDepth) then return isElementNotHasAlreadyAdded end -- Other element in same column, but adjacent row and has not added yet, then true.
	
	local totalAbsoluteShiftInPosition = absoluteShiftInRowPosition + absoluteShiftInColumnPosition
	
	if (totalAbsoluteShiftInPosition % 2 == 0) and checkIfCanCrossElementsAlongDiagonals(targetRow, targetColumn, visitedRowIndexArray, visitedColumnArray, currentDepth) then return isElementNotHasAlreadyAdded end
	
	return isElementNotHasAlreadyAdded -- If improper diagonal and not added yet, then then true.
	
end

local function depthFirstSearch(letterCombinationString, currentDepth, visitedRowArray, visitedColumnArray)
	
	-- letterCombinationString is used so that we don't have to recreate the previous parts of the string to create and store new string once the DFS could not find any new path. Otherwise, the maximum (or worst) time complexity becomes O(numberOfRows x numberOfColumns).
	
	-- currentDepth variable is used so that we can reduce O(numberOfRows) + O(numberOfColumns) time complexity to get the length of visited index arrays.
	
	for row = 1, 3, 1 do
		
		for column = 1, 3, 1 do
			
			if checkIfCanSearch(row, column, visitedRowArray, visitedColumnArray, currentDepth) then
				
				local newLetterCombinationString = letterCombinationString .. alphabetMatrix[row][column]
				
				table.insert(visitedRowArray, row)

				table.insert(visitedColumnArray, column)
				
				table.insert(letterCombinationStringArray, newLetterCombinationString)

				local newCurrentDepth = currentDepth + 1

				depthFirstSearch(newLetterCombinationString, newCurrentDepth, visitedRowArray, visitedColumnArray)

				table.remove(visitedRowArray, newCurrentDepth)

				table.remove(visitedColumnArray, newCurrentDepth)
				
			end
			
		end
		
	end
	
end

local function listPatterns(firstLetter, secondLetter, thirdLetter) -- I could have used regular expression here, but this method is more readable for future code maintenance.
	
	local selectedPatternArray = {}
	
	for index, letterCombinationString in letterCombinationStringArray do
		
		if (string.sub(letterCombinationString, 1, 1) ~= firstLetter) then continue end -- Get our first character from the string using string.sub().
		
		local letterCombinationStringLength = string.len(letterCombinationString)
		
		if (string.sub(letterCombinationString, letterCombinationStringLength, letterCombinationStringLength) ~= thirdLetter) then continue end -- If the ending letter does not match the third letter, then skip.
		
		if not string.find(letterCombinationString, secondLetter) then continue end
		
		table.insert(selectedPatternArray, letterCombinationString)
		
	end
	
	return selectedPatternArray
	
end

depthFirstSearch("", 0, {}, {}) -- There's another answer can be built without having to pass the visited row and column arrays as parameters. But for the assignment sake, let's do the harder path.

wait(1) -- These wait function are here because Roblox Studio sets a limit on how long the code can run without stopping. So if you're using pure Luau compiler, you wouldn't have this issue.

local selectedPatternArray = listPatterns("A", "E", "D")

print(letterCombinationStringArray)

wait(1)

print(selectedPatternArray)
