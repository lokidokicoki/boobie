require 'serial'
-- boobie has 7 leds
local max_led=7
local idle=0
local rate=1
local samples=2
local interval=0.1

function sleep(n)
	os.execute("sleep "..tonumber(n))
end

function getData()
	os.execute("iostat -c "..rate.." ".. samples .." > /tmp/cpuidle");
	local count=0
	for line in io.lines("/tmp/cpuidle") do
		count = count+1
		if count == 7 or count == 10 then
			local word_count =0
			for word in string.gmatch(line, "%d+%.?%d*") do 
				--print(word)
				word_count=word_count+1
				if word_count == 6 then
					idle=idle+word
				end 
			end
		--	print(line)
		--	print(100-line)
		--	idle = 100-line
		end
	end

	print(100-(idle/2))
	idle = 100-(idle/2)
	local num_leds = math.ceil(math.floor((max_led/100)*idle))
	print(num_leds)
	for i=1,max_led,1 do
		local pin = i+8
		local value = 1 --off
		if i <= num_leds then value=0 end
		if pin < 10 then
			pin='0'..pin
		end
		--os.execute("lua serialinterface.lua 0 w"..pin..value)
		serial.write('w',pin,value)
	end
end

if arg[1] ~= nil then
	rate=arg[1]
end

if arg[2] ~= nil then
	samples=arg[2]
	samples=samples+1
end

if arg[3] ~= nil then
	interval=arg[3]
end

print("Settings: rate["..rate.."], samples["..samples.."], interval["..interval.."])")

serial.connect()

local loop=true
while(loop) do
	getData()
	sleep(interval)
end

serial.close()
