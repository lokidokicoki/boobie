module(..., package.seeall)

local portdirection	={1,1,1,1,1,1,1,1,1,1,1,1}
local portvalue	={0,0,0,0,0,0,0,0,0,0,0,0}
local portconfiguration={}
local serialports={"/dev/ttyUSB0","/dev/ttyUSB1","/dev/ttyUSB2","/dev/ttyUSB3","/dev/ttyUSB4","/dev/ttyUSB5","/dev/ttyUSB6","/dev/ttyUSB7","/dev/ttyUSB8"}
local currentport=nil
local maxport= 9

local wserial = nil
local rserial = nil

local linetime = 0.1
debug=true

-- ******************************************************************

--[[
local webmode=nil
if cgilua~=nil then
	webmode=true
	setup=cgilua.QUERY.setup
	command=cgilua.QUERY.command
else
	setup=arg[1]
	command=arg[2]
end
]]

function connect(specificport)
	local received = nil
	local counter=0

	if specificport == nil then

		while wserial == nil do
			counter = counter + 1
			wserial=io.open(serialports[counter],"w")
			rserial=io.open(serialports[counter],"r")
			if counter >= maxport then
				counter = 0
			end
		end
		currentport = serialports[counter]

		if webmode == nil then
			print("Using " .. currentport)
		end
		os.execute("stty -F " .. currentport .. " 57600")
	else
		currentport=specificport
		wserial=io.open(specificport,"w")
		os.execute("stty -F " .. specificport .. " 57600")
	end
	return currentport
end

function checkport()
    local port = io.open(currentport, "w")
    if not port then
	print('port died, reconnecting...')
	close()
	connect()
    else
	io.close(port)
    end
end

function write(command, port, value)
	local outstring = ""
	if port~=nil then
		outstring = command .. string.format("%02d", port) .. value .. "\r"
	else
		outstring = command .. "\r"
	end
	if debug then print(outstring) end
	wserial:write(outstring)
	wserial:flush()
	sleep(linetime)
end

function setport()
	local i=0 
	for i=4, 15 do
		write("w", i, portvalue[i-3])
		sleep(linetime)
		write("c", i, portdirection[i-3])
		sleep(linetime)
	end
end

function close()
	if wserial then wserial:close(); wserial=nil; end
	if rserial then rserial:close(); rserial=nil; end
	sleep(linetime)
end

function setup()
	setport()
	write("s")
end
--[[
connect()

if setup == "1" then
	setport()
	write("s")
end
if command ~= nil then
	write(command)	
end	

if webmode == true then
	result = rserial:read()	
	cgilua.print(result)
	result = rserial:read()	
	cgilua.print(result)
else
	result = rserial:read()	
	print(result)
	result = rserial:read()	
	print(result)
end

wserial:close()
rserial:close()

]]
