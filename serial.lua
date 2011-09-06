module(..., package.seeall)

local portdirection	={1,1,1,1,1,1,1,1,1,1,1,1}
local portvalue	={0,0,0,0,0,0,0,0,0,0,0,0}
local portconfiguration={}
local serialports={"/dev/ttyUSB0","/dev/ttyUSB1","/dev/ttyUSB2","/dev/ttyUSB3","/dev/ttyUSB4","/dev/ttyUSB5","/dev/ttyUSB6","/dev/ttyUSB7","/dev/ttyUSB8"}
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

		if webmode == nil then
			print("Using " .. serialports[counter])
		end
		os.execute("stty -F " .. serialports[counter] .. " 57600")
	else
		wserial=io.open(specificport,"w")
		os.execute("stty -F " .. specificport .. " 57600")
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
	if wserial then wserial:close() end
	if rserial then rserial:close() end
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
