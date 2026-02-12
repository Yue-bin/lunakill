local t = require("terminal")

local TextPanel = require("terminal.ui.panel.text")
local terminal = require("terminal")
local Screen = require("terminal.ui.panel.screen")
local Panel = require("terminal.ui.panel")
local Bar = require("terminal.ui.panel.bar")
local KeyBar = require("terminal.ui.panel.key_bar")
local input = require("input")

-- Create some sample text content
local sample_text = {
    "Line " .. string.rep("A", 50),
    "Line " .. string.rep("B", 30),
    "Line " .. string.rep("C", 40),
    "Line " .. string.rep("D", 20),
    "Line " .. string.rep("E", 60),
    "Line " .. string.rep("F", 60),
    "Line " .. string.rep("G", 60),
    "Line " .. string.rep("H", 60),
    "Line " .. string.rep("I", 60),
    "Line " .. string.rep("J", 60),
    "Line 🚀😎🍕🔥🤖🎉🤔👽 🚀😎🍕🔥🤖🎉🤔👽 🚀😎🍕🔥🤖🎉🤔👽 🚀😎🍕🔥🤖🎉🤔👽 🚀😎🍕🔥🤖🎉🤔👽",
}

local main_panel = Panel {
    orientation = Panel.orientations.horizontal,
    max_height = 5,
    children = {
        TextPanel {
            lines = sample_text,
            scroll_step = 1,
            text_attr = { fg = "white", brightness = "bright" },
            highlight_attr = { fg = "red", brightness = "bright" },
            border = { format = terminal.draw.box_fmt.single },
            auto_render = true,
        },
        TextPanel {
            lines = sample_text,
            scroll_step = 1,
            text_attr = { fg = "white", brightness = "bright" },
            highlight_attr = { fg = "red", brightness = "bright" },
            border = { format = terminal.draw.box_fmt.single },
            auto_render = true,
        },
    },
}

-- Main event loop
local function main()
    terminal.cursor.visible.set(false)

    local x, y = terminal.size()
    main_panel:set_split_ratio(0.75)


    -- 注册退出事件
    _ = input.register({ "q", "Q" }) ..
        function()
            os.exit(0)
        end

    while true do
        main_panel:calculate_layout(x - 4, 0, x, y)
        main_panel:render()
        input.step()
    end
end

--- @class tui
--- @field start nil 启动 TUI 界面
return {
    start = t.initwrap(main, {
        filehandle = io.stdout,
        --displaybackup = true,
    })
}
