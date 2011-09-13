require 'log'
require 'serial'
-- boobie has 9 leds
local active_pins={4,5,9,10,11,12,13,14,15}
local ON = 1
local OFF = 0
local interval=0.1
local sleepy_times={1,5,10,5,1}
local patterns={
    {1,3,5,7,9},
    {2,4,6,8},
    {1,9,2,8,3,7,4,6,5},
    {1,2,3,4,5,6,7,8,9},
    {9,8,7,6,5,4,3,2,1},
}
function sleep(n)
    os.execute("sleep "..tonumber(n))
end

function configure()
    for i=1, #active_pins, 1 do
	serial.write('c', active_pins[i], ON)
    end
end

function process()
    -- various stree test patterns
    for i,hold in pairs(sleepy_times) do
	for j,pattern in pairs(patterns) do
	    for k, pin in pairs(pattern) do
		serial.write('w', active_pins[pin], ON)
	    end
	    sleep(hold)
	    for k, pin in pairs(pattern) do
		serial.write('w', active_pins[pin], OFF)
	    end
	end
    end
end

function pulse(value)
    if value == ON then
	for i=1,#active_pins,1 do
	    serial.write('w',active_pins[i],value)
	end
    else
	for i=#active_pins,1, -1 do
	    serial.write('w',active_pins[i],value)
	end
    end
end

function main()
    log.open('boobie')


    serial.connect()
    configure()
    pulse(ON)
    pulse(OFF)

    local loop=true 
    while(loop) do
	process()
	sleep(interval)
	if serial.checkport() then 
	    configure()
	end
	if io.open("BOOBIE_PIPE", "r") ~= nil then 
	    for line in io.lines("BOOBIE_PIPE") do 
		if line == "stop" then loop = false end
	    end
	end
    end

    pulse(ON)
    pulse(OFF)
    serial.close()
end

function usage()
    print("Usage: lua stress.lua ")
end

if arg[1] ~= nil then
    if (arg[1] == "-h" or arg[1] == "--help") then 
	usage()
	os.exit()
    end

    if (arg[1] == '-d' or arg[1] == '--debug') then
	log.DEBUG=true
	table.remove(arg, 1)
    end
    if (arg[1] == '-s' or arg[1] == '--sim') then
	serial.simulate=true
	table.remove(arg, 1)
    end
end

main() 
