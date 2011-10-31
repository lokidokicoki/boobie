--- Use the interrupt mechanism to swtich between light patterns
module('button', package.seeall)
require 'log'
require 'serial'
local BUTTON_PIN=15
local sleepy_times={1,5,10,20}
local patterns={
    {1,3,5,7,9},
    {2,4,6,8},
    {1,9,2,8,3,7,4,6,5},
    {1,2,3,4,5,6,7,8,9},
    {9,8,7,6,5,4,3,2,1},
}

local mode=1
local hold=0.1
--- (Re)set any state.
function configure()
    mode=1
end

--- 'Listen' for an interrupt, advance to next mode when we get one.
-- If we run off the end, then start again.
function process()
    local pattern = patterns[mode]
    for k, pin in pairs(pattern) do
	serial.write('w', active_pins[pin], ON)
	sleep(hold)
    end
    for k, pin in pairs(pattern) do
        serial.write('w', active_pins[pin], OFF)
    end
    serial.write('c', BUTTON_PIN, INPUT)
    serial.write('i', BUTTON_PIN, ON)
    sleep(hold)

    local result = nil
    local _loop = true
    while _loop do 
	result = serial.interrupt(BUTTON_PIN)
	if result == 1 then
	    mode = mode+1
	    if mode > #patterns then mode = 1 end
	    _loop=false
	    break
	end
	log.debug('button:loop')
    end

    serial.write('i', BUTTON_PIN, OFF)
    serial.write('c', BUTTON_PIN, OUTPUT)
end

--- Print sub-module usage message
function usage()
    print("Usage: start.sh button [-h]")
    print("Switch through various light patterns using the intterupt mechanism.")
    print("Requires Archonix Boobie firmware v1.3")
    print("-h|--help : print this message and exit")
end

--- Handle args
function setup(args)
    if arg[1] ~= nil and (arg[1] == "-h" or arg[1] == "--help") then 
	usage()
	os.exit()
    end
end
