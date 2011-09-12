require 'log'
require 'serial'
-- boobie has 9 leds
local max_leds=9
local rate=1
local samples=1
local interval=0.1
local curr_leds=0
local prev_leds=0
local active_pins={4,5,9,10,11,12,13,14,15}
local ON = 1
local OFF = 0

function sleep(n)
    os.execute("sleep "..tonumber(n))
end

function configure()
    if wserial then
	for i=1, max_leds, 1 do
	    serial.write('c', active_pins[i], ON)
	end
    end
    curr_leds=0
    prev_leds=0
end

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
    curr_leds = math.ceil(math.floor((max_leds/100)*idle))
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
end

function pulse(value)
    if value == ON then
	for i=1,max_leds,1 do
	    serial.write('w',active_pins[i],value)
	end
    else
	for i=max_leds,1, -1 do
	    serial.write('w',active_pins[i],value)
	end
    end
end

function main()
    log.open('cpuidle')

    if arg[1] ~= nil then
	rate=arg[1]
    end

    if arg[2] ~= nil then
	samples=arg[2]
    end

    if arg[3] ~= nil then
	interval=arg[3]
    end

    log.info("Settings: rate["..rate.."], samples["..samples.."], interval["..interval.."])")

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
	if io.open("CPUIDLEPIPE", "r") ~= nil then 
	    for line in io.lines("CPUIDLEPIPE") do 
		if line == "stop" then loop = false end
	    end
	end
    end

    pulse(ON)
    pulse(OFF)
    serial.close()
end

function usage()
    print("Usage: lua cpuidle.lua [-h|rate] [samples] [interval]")
    print("-h|--help : print this message then exit")
    print("rate : interval between calls to iostat (default is 1)")
    print("samples : number of sample to average cpu idle over (default is 2)")
    print("interval : number of second to wait before sampling again (default is 1)")
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
