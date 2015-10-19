#!/usr/bin/env lua

local constants = require "kong.constants"
local cutils = require "kong.cli.utils"
local serf = require "kong.cli.utils.serf"
local args = require("lapp")(string.format([[
Kong cluster operations.

Usage: kong cluster <command> <args>

Commands:
  <command> (string) where <command> is one of:
                       join, leave, members

                       Kong datastore migrations.
]], constants.CLI.GLOBAL_KONG_CONF))

serf.send_signal(args.config)