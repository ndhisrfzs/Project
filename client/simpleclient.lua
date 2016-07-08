local PATH,IP = ...

IP = IP or "127.0.0.1"

package.path = string.format("%s/client/?.lua;%s/3rd/skynet/lualib/?.lua", PATH, PATH)
package.cpath = string.format("%s/3rd/skynet/luaclib/?.so;%s/3rd/lsocket/?.so", PATH, PATH)

local socket = require "simplesocket"
local message = require "simplemessage"

local event = message.handler()
message.register(string.format("%s/common/proto/%s.sproto", PATH, "proto"))

message.peer(IP, 5678)
message.connect()

local function sleep(n)
   os.execute("sleep " .. n)
end

function event.ping()
	print("ping")
end

function event.login(_, resp)
	if resp.status == 0 then
		print("Account does not exist, register account")
		message.request("register", { account = "account@account.com", password = "123456" })
	elseif resp.status == 1 then
		print("password error")
	else
		print("login success")
		message.request("ping")
	end
end

function event.register(_, resp)
	if resp.ok then
		print("register success, relogin")
		message.request("login", { account = "account@account.com", password = "123456" })
	else
		print("register error")
	end
end

message.request("login", { account = "account@account.com", password = "123456" })

while true do
	message.update()
end
