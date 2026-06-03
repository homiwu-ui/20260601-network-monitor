# 20260601-network-monitor — 網路監看工具專案

## 對話開始時請先讀
進度與最近更動都在 Obsidian：`G:\我的雲端硬碟\2nddrain\20260601-network-monitor\工作筆記.md`

## 工作模式
- **加新工具**：對 AI 說「我想做一個 XXX」→ 建 `tools/<工具名>/` 子資料夾
- **結束工作**：說「收工」→ 自動三方同步
- **接續工作**：說「開工」→ 讀工作筆記 + 報進度

## 三個家
- 📋 GDrive 工作桌：`G:\我的雲端硬碟\20260601網路監看`
- 🐙 GitHub repo：`homiwu-ui/20260601-network-monitor`
- 📘 Obsidian 駕駛艙：`G:\我的雲端硬碟\2nddrain\20260601-network-monitor\工作筆記.md`

## 注意事項
- commit 訊息寫清楚做了什麼 + 為什麼
- 收工前說「收工」

## 2026-06-03 進度
- RADIUS 伺服器 (163.23.1.88) 加入 LibreNMS
  - 裝 snmpd（Debian 13 預設沒裝），配 `rocommunity public 163.23.32.158`
  - device_id=24，display="RADIUS伺服器"，status=1 綠燈
- 目前總計 20 台設備（19 AG-2800 + 1 RADIUS）
- 從 Obsidian 搜尋 FreeRADIUS 知識庫資料確認通訊埠 1812/1813
- 踩坑：Debian 13 預設無 snmpd、`--display-name` 旗標不可靠
