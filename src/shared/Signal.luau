-- Minimal signal implementation for shared use
local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(handler)
	table.insert(self._handlers, handler)
	local disconnected = false

	return function()
		if disconnected then
			return
		end
		disconnected = true
		for i, fn in ipairs(self._handlers) do
			if fn == handler then
				table.remove(self._handlers, i)
				break
			end
		end
	end
end

function Signal:Fire(...)
	for _, fn in ipairs(self._handlers) do
		fn(...)
	end
end

return Signal
