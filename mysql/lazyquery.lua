function lazyQuery(message)
	local filename = "/maxime.log"

	local file = createFileIfNotExists(filename)
	local size = fileGetSize(file)
	fileSetPos(file, size)
	fileWrite(file, message .. "\r\n")
	fileFlush(file)
	fileClose(file)
	
	return true
end

function createFileIfNotExists(filename)
	local file = nil
	if fileExists ( filename ) then
		file = fileOpen(filename)
	else
		file = fileCreate(filename)
	end
	return file
end