
local anime4k = {
    -- a = "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl",
    -- b = "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl",
    -- c = "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl",
    
    a = "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K_Restore_CNN_S.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl",
    b = "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_S.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl",
    c = "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Restore_CNN_S.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"
}

local state = {
    enabled = true,        -- 总开关状态
    current_mode = nil,    -- 当前模式
    show_shaders = false   -- 着色器是否生效
}

-- 更新着色器状态并显示OSD信息
local function update_shaders()
    mp.commandv('no-osd', 'change-list', 'glsl-shaders', 'clr', '')
    state.show_shaders = false
    state.current_mode = nil

    if state.enabled then
        local path = mp.get_property_osd("path")
        local height = mp.get_property_native("height")
        
        if string.find(path, 'Anime') then
            if height == 1080 then
                mp.commandv('change-list', 'glsl-shaders', 'set', anime4k.a)
                state.current_mode = 'A'
            elseif height == 720 then
                mp.commandv('change-list', 'glsl-shaders', 'set', anime4k.b)
                state.current_mode = 'B'
            elseif height == 480 then
                mp.commandv('change-list', 'glsl-shaders', 'set', anime4k.c)
                state.current_mode = 'C'
            end
            state.show_shaders = true
        end
    end

    -- 显示状态信息（2秒）
    local status = state.enabled and "ON" or "OFF"
    local mode = state.current_mode and (" ("..state.current_mode..")") or ""
    -- mp.osd_message("Anime4K: "..status..mode, 2)
end

-- 文件加载时触发
mp.register_event("file-loaded", update_shaders)

-- 切换快捷键（Ctrl+Alt+a）
mp.add_key_binding("Ctrl+Alt+a", "toggle-anime4k", function()
    state.enabled = not state.enabled
    update_shaders()
end)
