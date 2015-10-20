local IO = require "kong.tools.io"
local cutils = require "kong.cli.utils"
local constants = require "kong.constants"
local stringy = require "stringy"

local _M = {}

function _M.stop(kong_config)
  local pid_file = kong_config.nginx_working_dir.."/"..constants.CLI.SERF_PID
  local _, code = IO.kill_process_by_pid_file(pid_file)
  if code and code == 0 then
    cutils.logger:info("serf stopped")
  end
end

function _M.start(nginx_working_dir)
  local cmd = cutils.find_cmd("serf")
  if not cmd then
    cutils.logger:error_exit("Can't find serf")
  end

  -- Start the serf daemon
  local file_pid = nginx_working_dir..(stringy.endswith(nginx_working_dir, "/") and "" or "/")..constants.CLI.SERF_PID
  local res, code = IO.os_execute("nohup "..cmd.." agent > /dev/null 2>&1 & echo $! > "..file_pid)
  if code ~= 0 then
    cutils.logger:error_exit(res)
  else
    -- Check if serf starts in a timely manner
    os.execute("sleep 1")
    local pid = IO.read_file(file_pid)
    local _, code = IO.os_execute("kill -0 "..pid)
    if code == 0 then
      cutils.logger:info("serf started ("..cmd..")")
    else
      cutils.logger:error_exit("Could not start serf")
    end
  end
end

function _M.send_signal(signal, args)
  local cmd = cutils.find_cmd("serf")
  if not cmd then
    cutils.logger:error("Can't find serf")
  end

  local res, code = IO.os_execute(cmd.." "..signal.." "..table.concat(args, " "))
  if code == 0 then
    cutils.logger:info(res)
  else
    cutils.logger:error(res)
  end
end

return _M