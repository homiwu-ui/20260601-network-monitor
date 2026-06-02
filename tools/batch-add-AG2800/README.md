# AG-2800 批次加設備工具

## 用法

```bash
cd /home/sn2602/librenms/tools/batch-add-AG2800
bash add_devices.sh
```

## 設備清單格式

`devices.txt`，每行一組 `IP|Display Name`，註解以 `#` 開頭。

範例：
```
163.23.9.252|C203
163.23.11.250|A401第4櫃
```

## 腳本做了什麼

1. **檢查並加入新設備** — 已存在的 IP 自動跳過
2. **補 community** — 自動把所有 `community IS NULL` 的設為 `public`（避開 LibreNMS 已知坑）
3. **設 display name** — 用 SQL UPDATE（`lnms device:add --display-name` 旗標會被當成 template 處理，純字串不可靠）
4. **印結果報表** — 加完馬上看 status

## 重要注意事項

- **SysName 不動** — 保留 Alcatel 原廠值（如 `ag-2800-26g`），靠 `allow_duplicate_sysName=true` 達成
- **Display Name 隨意** — 只存 LibreNMS DB 裡的 `display` 欄位，跟設備無關
- **可以重跑** — 已經加過的會跳過，display name 會被覆寫

## 重要設定（已配置在 LibreNMS）

| 設定 | 值 | 為何需要 |
|------|---|---------|
| `allow_duplicate_sysName` | `true` | 所有 AG-2800 出廠 sysName 都一樣，要放行 |
| `snmp.timeout` | `5` 秒 | Alcatel-Lucent 預設 1 秒會 timeout |
| 主機 `fping` | 已裝 | LibreNMS 預設需要 |
| SNMP community | `public` | Alcatel 原廠預設 |

## 之後新加設備

1. 把新 IP|名稱 加進 `devices.txt`
2. 跑 `bash add_devices.sh`
3. 完成 ✅
