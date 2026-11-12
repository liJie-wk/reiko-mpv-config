-- 自动按需加载/卸载字体脚本
local function load_fonts_for_current_file()
  -- 1. 获取当前播放文件的完整路径
  local file_path = mp.get_property("path")
  if not file_path then
      return
  end

  -- 2. 提取文件所在的文件夹路径（兼容 Windows 和 Unix 的路径分隔符）
  local dir = file_path:match("(.*)[/\\]")
  if not dir then
      return
  end

  -- 3. 拼接出目标 font 文件夹
  local font_dir = dir .. "/Fonts"

  -- 4. 判断该 font 文件夹是否存在
  local is_exists = false
  local test_file = io.open(font_dir, "r") -- 尝试以读模式打开文件夹（在 Lua 中实际上会失败，改为检查目录）
  if test_file then
      test_file:close()
      is_exists = true
  else
      -- 更准确的目录检查（在 Windows/Linux 下判断目录是否存在）
      local handle = io.popen('if exist "' .. font_dir .. '" echo yes') -- Windows
      if not handle then
          handle = io.popen('test -d "' .. font_dir .. '" && echo yes') -- Linux/macOS
      end
      if handle then
          local result = handle:read("*a")
          handle:close()
          if result and result:match("yes") then
              is_exists = true
          end
      end
  end

  -- 改进后的目录检查（完全跨平台，使用 mpv 的 lua 辅助函数或直接简单判断）
  -- 由于 io.open 对目录在 Windows 下会报错，更稳妥的写法是尝试读取目录内的文件
  local function dir_exists(path)
      local f = io.open(path .. "/dummy_check.txt", "r") -- 利用读文件报错来判断目录权限
      if f then f:close() return true end
      -- 尝试用 lfs (LuaFileSystem) 太笨重，我们换一种：直接使用 os.rename 尝试改名（不推荐）
      -- 最稳妥：使用 mp.command_native 调用系统命令，或者直接依赖脚本逻辑。
      -- 我们改用简单的：直接用 io.open 打开路径下的任意已知字体文件，但如果目录为空呢？
      -- 实际上，我们检查目录是否存在，最干净的方式是依赖 mpv 的 "sub-fonts-dir" 特性：
      -- 即使路径不存在，mpv 也不会报错，只是不加载。
      -- 但我们为了精准执行卸载逻辑，必须区分 "存在但为空" 和 "完全不存在"。
  end

  -- *** 修正：为了可靠性，我们直接利用 mpv 的文件系统探测，但更简单：***
  -- 我们直接尝试列出目录（Lua 原生不支持，所以调用系统命令是标准做法）
  local function check_dir_exists(path)
      local command
      if package.config:sub(1,1) == "\\" then -- Windows
          command = 'if exist "' .. path .. '" echo FOUND'
      else -- Unix/Linux/macOS
          command = 'test -d "' .. path .. '" && echo FOUND'
      end
      local handle = io.popen(command)
      if handle then
          local result = handle:read("*a")
          handle:close()
          return result and result:find("FOUND") ~= nil
      end
      return false
  end

  local exists = check_dir_exists(font_dir)

  -- 5. 核心逻辑：根据是否存在，设置或清空字体目录
  if exists then
      -- 情景 A：存在 font 文件夹
      -- 设置字体目录。MPV 会自动扫描该目录下的所有 .ttf/.otf 并加载。
      -- 如果之前已经设置过同样的路径，MPV 内部会忽略重复加载，不会造成性能浪费。
      mp.set_property("sub-fonts-dir", font_dir)
      mp.msg.info("✅ 已加载字体目录: " .. font_dir)
  else
      -- 情景 B：不存在 font 文件夹
      -- 将字体目录设为空字符串。MPV 会立即清空之前加载的第三方字体索引，
      -- 并完全回退到操作系统默认字体（如 Windows 的 C:\Windows\Fonts）。
      mp.set_property("sub-fonts-dir", "")
      mp.msg.info("🔄 未找到自定义字体，已卸载第三方字体，回退系统字体")
  end

  -- 6. 重新加载当前的字幕，强制让新字体设置立即生效
  -- 这一步非常关键！不加这句，字幕样式可能要等到切换下一句才会刷新。
  mp.command("sub-reload")
end

-- 注册事件：每当有新文件被加载时（包括切换集数），自动执行上述逻辑
mp.register_event("file-loaded", load_fonts_for_current_file)