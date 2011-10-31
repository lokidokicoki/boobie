--- Use iostat (from sysstat package) to get/display CPU idle percentage.
-- Requires Archonixs Boobie Servo v1.0
module('servoidle', package.seeall)
require 'log'
require 'serial'

local rate=1
local interval=0.1
local samples=1
local curr_idle=0
local prev_idle=0
local SERVO_PIN = 15

local MIN_STEP = 0 
local MAX_STEP = 23

--- (Re)set servo and count trackers
function configure()
    serial.write('x')
    sleep(interval)
    for i=23, 0, -1 do
	serial.write('w', SERVO_PIN, i)
	sleep(0.2)
    end
    for i=0, 23 do
	serial.write('w', SERVO_PIN, i)
	sleep(0.2)
    end
    curr_idle=0
    prev_idle=0
end

--- Call iostat, read CPU idle %, calc position of servo, write value to Boobie board.
function process()
    os.execute("iostat -c "..rate.." ".. samples + 1 .." > /tmp/servoidle");
    local count=0
    local idle=0
    for line in io.lines("/tmp/servoidle") do
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
    curr_idle = 24 - math.ceil(math.floor((24/100)*idle))
    if curr_idle ~= prev_idle then
	log.debug('actual idle:'..idle..', curr_idle:'..curr_idle..', prev_idle:'..prev_idle)
	serial.write('w', SERVO_PIN, curr_idle)
	prev_idle=curr_idle
    end
    sleep(interval)
end

--- Print sub-module usage message
function usage()
    print("Usage: start.sh servoidle [-h|[options]]")
    print("Monitor the CPU idle percentage over a given time frame and display using a servo gauge.")
    print("Only works with Archonix Boobie Servo firmware!")
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
