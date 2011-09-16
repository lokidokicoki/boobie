--- Log file and 'streams' handler.
module(..., package.seeall)
DEBUG=false

local log_file;

--- Open a text file to dump log contents to.
function open(mod_name)
    log_file = io.open(mod_name..'.log', 'w')
    if not log_file then
	err('Could not create log file for module: '..mod_name)
    end
end

--- Close the log file.
function close()
    if log_file then 
	log_file:flush()
	log_file:close()
	log_file=nil
    end
end

--- Print string prefixed with 'ERR'.
-- @param msg error message
function err(msg)
    log('ERR: '..msg, true)
end

--- Print string prefixed with 'WRN'.
-- @param msg warning message
function warn(msg)
    log('WRN: '..msg)
end

--- Print string prefixed with 'INF'.
-- @param msg information message
function info(msg)
    log('INF: '..msg)
end

--- Print string prefixed with 'DBG'.
-- Only displayed if global variable DEBUG is true.
-- @param msg error message
function debug(msg)
    if DEBUG then
	log ('DBG: '..msg)
    end
end

--- Print messgae, if it is an error, then raise error.
-- String is written to log file.
-- @param msg error message
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
