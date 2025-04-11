local utils = require 'mp.utils'
local msg = require 'mp.msg'

local function open_containing_directory()
    local path = mp.get_property("path")
    if not path then
        msg.error("没有正在播放的文件")
        return
    end

    local expanded_path = mp.command_native({"expand-path", path})
    
    -- 检测操作系统平台
    local platform = mp.get_property_native("platform")
    local args
    
    if platform == "windows" then
        args = { "explorer", "/select,", expanded_path }
    elseif platform == "darwin" then
        args = { "open", "-R", expanded_path }
    else -- linux
        local directory = expanded_path:match("(.*[/\\])") or expanded_path
        args = { "xdg-open", directory }
    end
    
    utils.subprocess_detached({ args = args, cancellable = false })
end

mp.add_key_binding("Ctrl+e", "open-containing-directory", open_containing_directory)