#!/usr/bin/env lua

local constants = require "kong.constants"
local cutils = require "kong.cli.utils"
local utils = require "kong.tools.utils"
local serf = require "kong.cli.utils.serf"
local signal = require "kong.cli.utils.signal"
local args = require("lapp")(string.format([[
Kong cluster operations.

Usage: kong cluster <command> <args> [options]

Commands:
  <command> (string) where <command> is one of:
                       join, leave, force-leave, members, keygen

Options:
  -c,--config (default %s) path to configuration file

]], constants.CLI.GLOBAL_KONG_CONF))

local SUPPORTED_COMMANDS = { "join", "members", "keygen", "leave", "force-leave"}

-- Check if running, will exit if no
local running = signal.is_running(args.config)
if not running then
  cutils.logger:error_exit("Kong needs to be running before running cluster commands")
end

if not utils.table_contains(SUPPORTED_COMMANDS, args.command) then
  cutils.logger:error("Invalid cluster command. Supported commands are: "..table.concat(SUPPORTED_COMMANDS, ", "))
else
  local signal = args.command
  args.command = nil
  args.config = nil

  if signal == "join" then
    if utils.table_size(args) ~= 1 then
      cutils.logger:error_exit("You must specify one address")
    end
  end

  serf.send_signal(signal, args)
end