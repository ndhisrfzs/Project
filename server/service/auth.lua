local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"

local auth = {}
local users = {}
local cli = client.handler()

local SUCC = { ok = true }
local FAIL = { ok = false }
local userid = 1

function cli:login(args)
	log("login account=%s", args.account)
	if users[args.account] == nil then
		return { status = 0 }
	elseif users[args.account] ~= args.password then
		return { status = 1 }
	else 
		self.userid = userid
		userid = userid + 1
		self.exit = true
		return { stauts = 2 }
	end
end

function cli:register(args)
	log("register account=%s", args.account)
	if users[args.account] then
		return FAIL
	else
		users[args.account] = args.password
		return SUCC
	end
end

function auth.shakehand(fd)
	local c = client.dispatch { fd = fd }
	return c.userid
end

service.init {
	command = auth,
	data = users,
	init = client.init "proto",
}
