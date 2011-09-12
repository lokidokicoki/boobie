require 'serial'
-- boobie has 7 leds
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

function process()
    os.execute("iostat -c "..rate.." ".. samples + 1 .." > /tmp/cpuidle");
    local count=0
    local idle=0
    for line in io.lines("/tmp/cpuidle") do
	count = count+1
	if count == (7 + (3 * (samples-1)))  then
	--print('count:'..count)
	    local word_count =0
	    for word in string.gmatch(line, "%d+%.?%d*") do 
		word_count=word_count+1
		if word_count == 6 then
		    --print('word:'..word)
		    idle=idle+word
		end 
	    end
	end
    end

    idle = 100-(idle/samples)
    curr_leds = math.ceil(math.floor((max_leds/100)*idle))
    if curr_leds ~= prev_leds then
	--print('actual idle:'..idle..', curr_leds:'..curr_leds..', prev_leds:'..prev_leds)
	--[[
	for i=1,max_leds,1 do
	    local pin = active_pins[i]
	    local value = OFF --off
	    if i <= curr_leds then value=ON end
	    serial.write('w',pin,value)
	end
	]]
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
    if arg[1] ~= nil then
	rate=arg[1]
    end

    if arg[2] ~= nil then
	samples=arg[2]
    end

    if arg[3] ~= nil then
	interval=arg[3]
    end

    print("Settings: rate["..rate.."], samples["..samples.."], interval["..interval.."])")

    --serial.debug=true
    --serial.simulate=true
    serial.connect()
    pulse(ON)
    pulse(OFF)

    local loop=true 
    while(loop) do
	process()
	sleep(interval)
	if serial.checkport() then 
	    curr_leds=0;
	    prev_leds=0;
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

if arg[1] ~= nil and (arg[1] == "-h" or arg[1] == "--help") then 
	usage()
else
	main() 
end
