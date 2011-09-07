require 'serial'
-- boobie has 7 leds
local max_leds=7
local rate=1
local samples=1
local interval=0.1
local curr_leds=0
local prev_leds=0

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
	--print('actual idle:'..idle..', curr_leds:'..curr_leds)
	for i=1,max_leds,1 do
	    local pin = i+8
	    local value = 1 --off
	    if i <= curr_leds then value=0 end
	    serial.write('w',pin,value)
	end
	prev_leds=curr_leds
    end
end
function shut_down()
    for i=1,max_leds,1 do
	local pin = i+8
	local value = 1 --off
	serial.write('w',pin,value)
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

    serial.debug=false
    serial.connect()
    serial.setport()

    local loop=true 
    while(loop) do
	process()
	sleep(interval)
	if io.open("CPUIDLEPIPE", "r") ~= nil then 
	    for line in io.lines("CPUIDLEPIPE") do 
		if line == "stop" then loop = false end
		shut_down()
	    end
	end
    end

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
