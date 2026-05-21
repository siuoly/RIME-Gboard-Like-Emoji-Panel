-- ==========================================================
-- 獨立組件：Emoji 全域歷史處理器 (全名單命中比對版)
-- ==========================================================

local history_file_name = "emoji_history.txt"
local fixed_file_name = "emoji_fixed.txt"
local max_history_size = 15

-- 按行讀取工具
local function read_emojis_by_line(file_path)
    local emojis = {}
    local file = io.open(file_path, "r")
    if file then
        for line in file:lines() do
            -- 清除可能干擾比對的頭尾空白或換行符
            local emoji = string.gsub(line, "^%s*(.-)%s*$", "%1")
            if emoji ~= "" then
                table.insert(emojis, emoji)
            end
        end
        file:close()
    end
    return emojis
end

-- 寫入歷史紀錄
local function record_emoji(user_dir, emoji)
    local history_path = user_dir .. "/" .. history_file_name
    local history = read_emojis_by_line(history_path)
    
    -- 歷史紀錄去重
    for i, v in ipairs(history) do
        if v == emoji then
            table.remove(history, i)
            break
        end
    end
    
    -- 插入到最前面並裁切多餘長度
    table.insert(history, 1, emoji)
    if #history > max_history_size then 
        table.remove(history) 
    end
    
    -- 按行寫入檔案
    local file = io.open(history_path, "w")
    if file then
        for _, e in ipairs(history) do
            file:write(e .. "\n")
        end
        file:close()
    end
end

local processor = {}

function processor.init(env)
    local context = env.engine.context
    
    env.commit_connection = context.commit_notifier:connect(function(ctx)
        -- 1. 獲取當前上屏的文字（無論是從哪裡輸入）
        local commit_text = ctx:get_commit_text() or ""
        
        -- 清洗頭尾空白與特殊字符
        commit_text = string.gsub(commit_text, "^%s*(.-)%s*$", "%1")
        if commit_text == "" then return end
        
        local user_dir = rime_api.get_user_data_dir()
        local fixed_path = user_dir .. "/" .. fixed_file_name
        
        -- 2. 讀取完整的自訂固定表
        local fixed_emoji_list = read_emojis_by_line(fixed_path)
        
        -- 3. 【核心修正】：不論 Candidate Type，逐一比較上屏文字是否在固定表中
        local is_our_emoji = false
        for _, e in ipairs(fixed_emoji_list) do
            if commit_text == e then 
                is_our_emoji = true
                break 
            end
        end
        
        -- 4. 如果命中，則記錄到歷史常用檔案中
        if is_our_emoji then
            record_emoji(user_dir, commit_text)
        end
    end)
end

function processor.func(key_event, env)
    return 2 -- kNoop
end

function processor.fini(env)
    if env.commit_connection then
        env.commit_connection:disconnect()
    end
end

return processor