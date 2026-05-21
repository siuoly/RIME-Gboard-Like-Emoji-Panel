-- ==========================================================
-- 獨立組件：Emoji 清洗過濾器 (修正遍歷 API 版)
-- ==========================================================

local filter = {}

function filter.init(env)
end

function filter.func(input, env)
    -- 修正：RIME Filter 的 input 本身就是迭代器，直接遍歷即可，不可呼叫 :handle()
    for cand in input:iter() do
        if cand.type == "emoji_fixed" then
            -- 抓到帶有標籤的固定清單，把後綴 " [F]" 抹除還原
            local clean_text = string.gsub(cand.text, " %[F%]$", "")
            
            -- 創建一個一模一樣但外表純淨的全新候選字送上螢幕
            local new_cand = Candidate("emoji_fixed", cand.start, cand._end, clean_text, cand.comment)
            yield(new_cand)
        else
            -- 其他普通候選字或歷史 Emoji，直接放行
            yield(cand)
        end
    end
end

function filter.fini(env)
end

return filter