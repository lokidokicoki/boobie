module(..., package.seeall)
DEBUG=false

local log_file;
function open(mod_name)
    log_file = io.open(mod_name..'.log', 'w')
    if not log_file then
	err('Could not create log file for module: '..mod_name)
    end
end

function close()
    if log_file then 
	log_file:flush()
	log_file:close()
	log_file=nil
    end
end

function err(msg)
    log('ERR: '..msg, true)
end

function warn(msg)
    log('WRN: '..msg)
end

function info(msg)
    log('INF: '..msg)
end

function debug(msg)
    if DEBUG then
	log ('DBG: '..msg)
    end
end

function log(msg, is_error)
    -- output to file
    if log_file then
	log_file:write(msg..'\n')
	log_file:flush()
    end

    if is_error then
	error(msg)
    else
	print(msg)
    end
end
