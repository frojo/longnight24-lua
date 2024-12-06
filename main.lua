local request = require "http.request"

print("hello")


local uri = "http://localhost:8081"

local req = request.new_from_uri(uri)

print(req)

for k, v in req.headers:each() do
	print(k, v)
end


if req.body then
	print("## BODY")
	print(req.body)
	print()
end

-- actually send a request
local headers, stream = req:go(req_timeout)