local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"

local agent = {}
local data = {}
local cli = client.handler()

function cli:ping()
	log "ping"
end

local function new_user(fd)
	local ok, error = pcall(client.dispatch , { fd = fd })
	log("fd=%d is gone. error = %s", fd, error)
	client.close(fd)
	if data.fd == fd then
		data.fd = nil
		skynet.sleep(1000)	-- exit after 10s
		if data.fd == nil then
			-- double check
			if not data.exit then
				data.exit = true	-- mark exit
				skynet.call(service.manager, "lua", "exit", data.userid)	-- report exit
				log("user %s afk", data.userid)
				skynet.exit()
			end
		end
	end
end

function agent.assign(fd, userid)
	if data.exit then
		return false
	end
	data.fd = fd
	if data.userid == nil then
		data.userid = userid
	end
	assert(data.userid == userid)
	skynet.fork(new_user, fd)
	return true
end

service.init {
	command = agent,
	info = data,
	require = {
		"manager",
	},
	init = client.init "proto",
}

