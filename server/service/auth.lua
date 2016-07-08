local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"

local auth = {}
local users = {}
local cli = client.handler()

local SUCC = { ok = true }
local FAIL = { ok = false }

function cli:login(args)
	log("login account=%s", args.account)
	local account = skynet.call(service.database, "lua", "HGET", "users", args.account)
	if account == nil or account.password == nil then
		return { status = 0 } 	--未注册
	elseif account.password ~= args.password then
		return { status = 1 } 	--密码错误
	else 						--登录成功
		self.userid = account.uid
		self.exit = true
		return { stauts = 2 }
	end
end

function cli:register(args)
	log("register account=%s", args.account)
	local account = skynet.call(service.database, "lua", "HGET", "users", args.account)
	if account ~= nil then
		return FAIL
	else
		args["uid"] = skynet.call(service.database, "lua", "HLEN", "users") + 1
		skynet.call(service.database, "lua", "HSET", "users", args.account, args)
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
	require = {
		"database",
	}
}
