-- ==========================================================
-- 獨立組件：Emoji 翻譯器 (按行讀取 + 標籤注入版)
-- ==========================================================

local history_file_name = "emoji_history.txt"
local fixed_file_name = "emoji_fixed.txt"
local max_history_display = 15

-- 全新按行讀取工具：相容萬國碼與各種換行符
local function read_emojis_by_line(file_path)
    local emojis = {}
    local file = io.open(file_path, "r")
    if not file then return nil, "檔案不存在" end
    
    for line in file:lines() do
        -- 清除前後空白與換行符
        local emoji = string.gsub(line, "^%s*(.-)%s*$", "%1")
        if emoji ~= "" then
            table.insert(emojis, emoji)
        end
    end
    file:close()
    return emojis, nil
end

local translator = {}

function translator.init(env)
end

function translator.func(input, seg, env)
    local user_dir = rime_api.get_user_data_dir()
    local fixed_path = user_dir .. "/" .. fixed_file_name
    local history_path = user_dir .. "/" .. history_file_name

    if input == "jj" then
        local fixed_emoji_list, fixed_err = read_emojis_by_line(fixed_path)
        if fixed_err then
            yield(Candidate("emoji_debug", seg.start, seg._end, "❌ 找不到檔案", " 請確認存在: " .. fixed_path))
            return
        end

        local emoji_history = read_emojis_by_line(history_path) or {}

        -- 1. 先輸出歷史紀錄
        local history_count = 0
        for i, emoji in ipairs(emoji_history) do
            if history_count >= max_history_display then break end
            yield(Candidate("emoji_history", seg.start, seg._end, emoji, ""))
            history_count = history_count + 1
        end

        -- 2. 輸出完整固定清單
        -- 這裡偷偷加上 " [F]" 後綴，使文字在 RIME 內建去重眼裡變成不同的字串！
        for i, emoji in ipairs(fixed_emoji_list) do
            yield(Candidate("emoji_fixed", seg.start, seg._end, emoji .. " [F]", ""))
        end
        return
    end

    if input == "bq" then
        local emoji_history, hist_err = read_emojis_by_line(history_path)
        if hist_err or #emoji_history == 0 then
            yield(Candidate("emoji_debug", seg.start, seg._end, "🕒 暫無紀錄", ""))
            return
        end
        for i, emoji in ipairs(emoji_history) do
            yield(Candidate("emoji_history", seg.start, seg._end, emoji, ""))
        end
        return
    end
end

return translator