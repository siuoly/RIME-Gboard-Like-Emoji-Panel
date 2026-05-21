# RIME Gboard-Like Emoji Panel 🚀

一個為 RIME (中州韻輸入法引擎) 量身打造的**極簡版類 Gboard Emoji 快捷面板**插件。

一鍵敲下快捷鍵（預設 `jj`），就能在電腦上完美重現手機 Gboard 輸入法的經典配置：**「前排動態常用（自動排序）＋ 後排自訂固定盤（雷打不動）」**。本插件支援最新 RIME 的免 `rime.lua` 載入機制，檔案放對位置、方案檔一行掛載即可直接起飛！

---
<img width="400"  alt="PixPin_2026-05-21_09-58-40" src="https://github.com/user-attachments/assets/16d3dd39-938c-4c19-8c0a-944d150fc553" />

## ✨ 核心主打功能

*   **📱 類 Gboard 雙層體驗**：一鍵呼叫面板，前排自動顯示你最近最常敲的 15 個 Emoji（動態排序），後排則是你的核心常用固定盤。
*   **💾 純文字按行自訂 (Line-based)**：`emoji_fixed.txt`（固定盤）與 `emoji_history.txt`（常用紀錄）全面採用**「一行一個 Emoji」**的極簡格式，想加什麼直接開記事本貼上換行即可。
*   **🔒 隔離防禦，擊敗內建去重**：RIME 內建的去重機制常會把固定盤裡重複的 Emoji 吃掉。本插件透過專屬的 Filter 管道，**保證後排固定盤的 Emoji 絕對雷打不動、完整重複出現**。
*   **🧼 0 隱形字元，上屏 100% 純淨**：徹底拋棄會導致部分軟體排版崩壞、斷字失敗的隱形字元（如 `\u{feff}`）黑魔法，送上螢幕的 Emoji 100% 乾淨無瑕。

---

## 📂 檔案架構配置

將以下三個 Lua 檔案放入你的 RIME `lua/` 使用者資料夾中：

```text
💾 Rime User Directory/
├── 📂 lua/
│   ├── 📄 emoji_selector_translator.lua # Panel 翻譯器（負責按行讀取與emoji注入）
│   ├── 📄 emoji_history_processor.lua  # 動態常用紀錄器（負責按行寫入與即時重排輸入歷程）
│   └── 📄 emoji_uniquifier_filter.lua   # 面板清洗過濾器（負責繞過 RIME 去重機制）
├── 📄 emoji_fixed.txt                   # 💡【自訂固定盤】開記事本，一行放一個你最愛的 Emoji
└── 📄 emoji_history.txt                 # 🕒【動態常用盤】系統自動產生與維護的常用快取

```

---

## 🛠️ 兩步快速安裝

### Step 1. 打造你的固定盤 (`emoji_fixed.txt`)

在你的 **RIME 使用者資料夾根目錄**下建立 `emoji_fixed.txt`，並以**一行一個**的格式塞入你的常用經典款。例如：

```text
🔥
😂
🚀
👍
👀

```

專案 `emoji_fixed.txt` 內建125個 emoji，複製自 Gboard 符號。

### Step 2. 掛載到輸入方案 (`.schema.yaml`)

開啟你平常使用的輸入方案（例如 `pinyin_simp.schema.yaml` 或 `bopomofo.schema.yaml`），在對應位置補上組件。

> ⚠️ **大前提提醒**：
> 1. 請注意組件名稱前都有加上 **`*`** 號，這能讓 RIME 直接免註冊尋找獨立檔案。
> 2. 為了完美擊敗內建去重，`lua_filter@*emoji_uniquifier_filter` **務必放在 `filters:` 列表的最底端**！
> 
> 

```yaml
engine:
  processors:
    - lua_processor@*emoji_history_processor  # 監聽並將常用 Emoji 寫入歷史
    # ... 原有的 processors
  translators:
    - lua_translator@*emoji_selector_translator # 觸發快捷鍵 `jj` 翻譯面板
    # ... 原有的 translators
  filters:
    # ... 原有的 filters (如 simplifier, uniquifier 等)
    - lua_filter@*emoji_uniquifier_filter     # 👈 務必放在 filters 家族的最下層！

```

---

## 🎮 面板操控指南

1. 點擊 RIME 的 **「重新部署 (Deploy)」** 讓設定生效。
2. **呼叫 Gboard 完整面板**：在輸入法中輸入 **`jj`**，候選框會瞬間吐出：
* `1~15 號候選`：🕒 近期最常使用的常用 Emoji 紀錄。
* `16 號候選之後`：📌 你在 `emoji_fixed.txt` 定義的雷打不動固定盤。


3. **常用動態更新**：當你在面板選中任何一個 Emoji 上屏後，它會自動衝到常用清單的最頂端（第 1 順位），並自動同步回 `emoji_history.txt` 檔案。

## 📄 授權條款

本項目採用 [MIT License](https://zh.wikipedia.org/zh-tw/MIT%E8%A8%B1%E5%8F%AF%E8%AD%89) 授權。歡迎自由 Fork、調整與分享！
