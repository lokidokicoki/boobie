--- Harness for Archinix Boobie Board.
require 'log'
require 'serial'
-- boobie has 9 leds
active_pins={4,5,9,10,11,12,13,14,15}
ON = 1
OFF = 0
local mod=nil
local mod_name=nil

--- Calls native sleep function.
function sleep(n)
    os.execute("sleep "..tonumber(n))
end

--- Override (but do not save) Boobie board pin configuration
function configure()
    for i=1, #active_pins, 1 do
	serial.write('c', active_pins[i], ON)
    end

    if mod then
	mod.configure()
    end
end

--- Call sub-module process code
function process()
    if mod then
	mod.process()
    end
end

--- Flash all the active output pins.
-- @param value ON/OFF
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

--- Main loop to process sub-module code and check if the harness should exit.
-- Connect and cofngiure Boobie board.
-- Each time round loop, check value of fifo BOOBIE_PIPE.
function main()
    log.open('boobie_'..mod_name)

    serial.connect()
    configure()
    pulse(ON)
    pulse(OFF)

    local loop=true 
    while(loop) do
	process()
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

--- Print help message.
function usage()
    print("Usage: start.sh [-h|-d|-s] MODULE")
    print("Harness for Archnonix Boobie Board modules.")
    print("Can either be run via the `start.sh` script or invoked thusly:")
    print("lua boobie.lua [options] MODULE [options]")
    print("-h|--help : print this message and exit")
    print("-d|--debug : enable debug output")
    print("-s|--sim : simulate connection to boobie board")
    print("MODULE : e.g. cpuidle")
end

-- handle input args
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

    mod_name=arg[1]
    mod=require(mod_name)
    table.remove(arg,1)
    mod.setup(arg)
else
    usage()
    os.exit()
end

main() 
