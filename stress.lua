--- Simple stress test and burn-in module that runs a variety of
-- 'light shows' on the Boobie.
module('stress', package.seeall)
require 'log'
require 'serial'
local sleepy_times={1,5,10,20}
local patterns={
    {1,3,5,7,9},
    {2,4,6,8},
    {1,9,2,8,3,7,4,6,5},
    {1,2,3,4,5,6,7,8,9},
    {9,8,7,6,5,4,3,2,1},
}

--- (Re)set any state.
function configure()
    --blank
end

--- Loop over patterns and dispaly them for increasing amounts of time.
function process()
    -- various stress test patterns
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

--- Print sub-module usage message
function usage()
    print("Usage: start.sh stress [-h]")
    print("Run through a variety of patterns and hold times for testing.")
    print("-h|--help : print this message and exit")
end

--- Handle args
function setup(args)
    if arg[1] ~= nil and (arg[1] == "-h" or arg[1] == "--help") then 
	usage()
	os.exit()
    end
end
