#!/bin/bash
# AG-2800 批次加設備腳本
# 用法：bash add_devices.sh
# 設備清單寫在 devices.txt（一行一組 IP|DisplayName）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICES_FILE="${SCRIPT_DIR}/devices.txt"

if [ ! -f "$DEVICES_FILE" ]; then
    echo "❌ 找不到 $DEVICES_FILE"
    exit 1
fi

cd /home/sn2602/librenms

echo "=== 開始批次加 AG-2800 設備 ==="
echo ""

# Step 1: 加新設備（已存在的自動跳過）
echo "Step 1: 加新設備（已存在的自動跳過）"
while IFS='|' read -r ip name; do
    [[ -z "$ip" || "$ip" =~ ^# ]] && continue
    echo "--- $ip → $name ---"
    existing=$(docker compose exec -T db bash -c "mysql -u librenms -p'q2w1e4r3' -N -B librenms -e \"SELECT device_id FROM devices WHERE hostname = '$ip';\"" 2>/dev/null | tr -d '[:space:]')
    if [ -n "$existing" ]; then
        echo "  ✓ 已存在 (device_id=$existing)，跳過加設備"
    else
        echo "  + 加新設備..."
        # 注意：--display-name 旗標會被當成 template 處理，純字串不可靠
        # 加完後用 SQL 設 display 才穩
        docker compose exec -T librenms lnms device:add \
            --v2c \
            --community public \
            --ping-fallback \
            "$ip" 2>&1 | head -5
    fi
done < "$DEVICES_FILE"

# Step 2: 修已存在設備的 display name + 補 community
echo ""
echo "Step 2: 修 community + display name（已存在的設備）"

SQL_PARTS="UPDATE devices SET community = 'public' WHERE community IS NULL OR community = '';"

while IFS='|' read -r ip name; do
    [[ -z "$ip" || "$ip" =~ ^# ]] && continue
    safe_name=$(printf "%s" "$name" | sed "s/'/''/g")
    SQL_PARTS="${SQL_PARTS}UPDATE devices SET display = '${safe_name}' WHERE hostname = '${ip}';"
done < "$DEVICES_FILE"

docker compose exec -T db mysql -u librenms -p'q2w1e4r3' librenms -e "$SQL_PARTS"

# Step 3: 印結果
echo ""
echo "Step 3: 最終設備清單"
docker compose exec -T db mysql -u librenms -p'q2w1e4r3' librenms -e "SELECT device_id, hostname, display, sysName, community, status, status_reason FROM devices ORDER BY device_id;"

echo ""
echo "=== 完成！等 1-2 分鐘看 Web 介面是否綠燈 ==="
