local IO = require "kong.tools.io"
local cutils = require "kong.cli.utils"
local stringy = require "stringy"

local _M = {}

function _M.send_signal(args_config)
  local cmd = IO.cmd_exists("serf") and "serf"

  if not cmd then -- Load dnsmasq given the PATH settings
    local env_path = (os.getenv("PATH")..":" or "").."/usr/local/sbin:/usr/sbin" -- Also check in default paths
    local paths = stringy.split(env_path, ":")
    for _, path in ipairs(paths) do
      if IO.file_exists(path..(stringy.endswith(path, "/") and "" or "/").."serf") then
        cmd = path.."/serf"
        break
      end
    end
  end

  if not cmd then
    cutils.logger:error_exit("Can't find serf")
  end

  -- Start the dnsmasq daemon
  local file_pid = nginx_working_dir..(stringy.endswith(nginx_working_dir, "/") and "" or "/")..constants.CLI.DNSMASQ_PID
  local res, code = IO.os_execute(cmd.." -p "..dnsmasq_port.." --pid-file="..file_pid.." -N -o")
  if code ~= 0 then
    cutils.logger:error_exit(res)
  else
    cutils.logger:info("dnsmasq started ("..cmd..")")
  end
end

return _M