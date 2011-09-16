--- Use iostat (from sysstat package) to get/display CPU idle percentage.
module('cpuidle', package.seeall)
require 'log'
require 'serial'
-- boobie has 9 leds
local rate=1
local interval=0.1
local samples=1
local curr_leds=0
local prev_leds=0

--- (Re)set LEDs count trackers
function configure()
    curr_leds=0
    prev_leds=0
end

--- Call iostat, read CPU idle %, calc number of LED to display, write value to Boobie board.
function process()
    os.execute("iostat -c "..rate.." ".. samples + 1 .." > /tmp/cpuidle");
    local count=0
    local idle=0
    for line in io.lines("/tmp/cpuidle") do
	count = count+1
	if count == (7 + (3 * (samples-1)))  then
	    local word_count =0
	    for word in string.gmatch(line, "%d+%.?%d*") do 
		word_count=word_count+1
		if word_count == 6 then
		    idle=idle+word
		end 
	    end
	end
    end

    idle = 100-(idle/samples)
    curr_leds = math.ceil(math.floor((#active_pins/100)*idle))
    if curr_leds ~= prev_leds then
	log.debug('actual idle:'..idle..', curr_leds:'..curr_leds..', prev_leds:'..prev_leds)
	if curr_leds - prev_leds > 0 then
	    -- turn on
	    for i=prev_leds,curr_leds,1 do
		serial.write('w', active_pins[i], ON)
	    end
	else
	    -- turn off
	    for i=prev_leds,curr_leds,-1 do
		serial.write('w', active_pins[i], OFF)
	    end
	end
	prev_leds=curr_leds
    end
    sleep(interval)
end

--- Print sub-module usage message
function usage()
    print("Usage: start.sh cpuidle [-h|[options]]")
    print("Monitor the CPU idle percentage over a given time frame and display on boobie board.")
    print("-h|--help : print this message and exit")
    print("1st option : number of seconds between samples, default 1 sec")
    print("2nd option : number of samples to take, 2")
    print("3rd option : interval between sample iterations, 0.1 seconds")
end

--- Handle args
function setup(args)
    if arg[1] ~= nil and (arg[1] == "-h" or arg[1] == "--help") then 
	usage()
	os.exit()
    end

    if args[1] ~= nil then
	rate=arg[1]
    end

    if args[2] ~= nil then
	samples=args[2]
    end

    if args[3] ~= nil then
	interval=args[3]
    end
end
