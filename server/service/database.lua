local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local redis = require "redis"
local service = require "service"
local packer = require "packer"

local db
local command = {}

function command.GET(key)
	return packer.unpack(db:get(key))
end

function command.SET(key, value)
	return db:set(key, packer.pack(value))
end

function command.HSET(key, field, value)
	return db:hset(key, field, packer.pack(value))
end

function command.HGET(key, field)
	return packer.unpack(db:hget(key, field))
end

function command.HLEN(key)
	return db:hlen(key)
end

local function init()
	db = redis.connect({host="127.0.0.1", port=6379})
end

service.init {
	command = command,
	init = init,
}
