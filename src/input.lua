--- 用于处理输入事件的模块
--- @class input
local _M = {}

local terminal = require("terminal")
local keymap = terminal.input.keymap.default_key_map
local keys = terminal.input.keymap.default_keys

--- 输入事件注册表
--- @type table<string, function>
local input_handlers = {}

--- 处理输入
--- @param key string? 输入的原始键值
--- @param keyname string? 输入的键名
local function process(key, keyname)
    key = key or ""
    keyname = keyname or ""
    -- 键名优先
    local handler = input_handlers[keyname] or input_handlers[key]
    if handler then
        handler()
    end
end

--- 注册输入事件函数的参数检查辅助函数
--- @param keyname string 键名
--- @param handler function 处理函数
--- @return boolean valid 是否合法
--- @return string? error 错误信息，如果注册失败则返回
local function validate_registration(keyname, handler)
    -- 检查参数合法性
    if type(keyname) ~= "string" then
        return false, "Key name must be a string"
    end
    -- 检查是否已经注册了该键的处理函数
    if input_handlers[keyname] then
        return false, "Handler for key '" .. keyname .. "' already exists"
    end

    -- 检查handler是不是函数
    if type(handler) ~= "function" then
        return false, "Handler must be a function"
    end
    return true
end

--- 注册输入事件，提供装饰器式接口
---
--- 装饰器形式调用示例：
--- ``` lua
--- _ = input.register({ "q", "Q" }) ..
---     function()
---         os.exit(0)
---     end
--- ```
--- @param keyname string|string[] 键名，如果不存在则使用原始键值，可以使用字符串或字符串数组注册多个键
--- @param handler function? 处理函数，如果不提供则以装饰器形式调用
--- @return boolean success 是否注册成功
--- @return string? error 错误信息，如果注册失败则返回
_M.register = function(keyname, handler)
    -- 装饰器形式
    if handler == nil then
        -- 此处的返回值用于支持装饰器，用户无需处理
        ---@diagnostic disable-next-line: return-type-mismatch
        return keyname
    end

    -- 展开可能的字符串数组
    if type(keyname) == "table" then
        for _, k in ipairs(keyname) do
            local success, err = _M.register(k, handler)
            if not success then
                return false, err
            end
        end
        return true
    end

    -- 参数检查
    local success, err = validate_registration(keyname, handler)
    if not success then
        return false, err
    end
    -- 实际注册
    input_handlers[keyname] = handler
    return true
end

-- 返回的keyname用于正式调用
debug.setmetatable(_M.register, {
    __concat = function(keyname, handler)
        _M.register(keyname, handler)
    end,
})

--- 进行一次输入处理
_M.step = function()
    local key = terminal.input.readansi(0.1)
    local keyname = keymap[key or ""]
    process(key, keyname)
end

return _M
