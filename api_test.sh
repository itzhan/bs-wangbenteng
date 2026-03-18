#!/bin/bash
# =====================================================
# 农作物种植生产管理系统 - 全接口API测试脚本
# 覆盖全部16个Controller的所有接口
# =====================================================

BASE_URL="http://localhost:8090/api"
PASS=0
FAIL=0
TOTAL=0

# URL编码辅助函数
urlencode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))" 2>/dev/null
}
ERRORS=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# =====================================================
# 核心测试函数 - 状态输出到stderr，响应体输出到stdout
# =====================================================
test_api() {
    local method="$1"
    local url="$2"
    local data="$3"
    local token="$4"
    local description="$5"

    TOTAL=$((TOTAL + 1))

    local headers=(-H "Content-Type: application/json")
    if [ -n "$token" ]; then
        headers+=(-H "Authorization: Bearer $token")
    fi

    local response http_code body

    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "${headers[@]}" "$url" 2>/dev/null)
    elif [ "$method" = "DELETE" ]; then
        response=$(curl -s -w "\n%{http_code}" -X DELETE "${headers[@]}" "$url" 2>/dev/null)
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "${headers[@]}" -d "$data" "$url" 2>/dev/null)
    elif [ "$method" = "PUT" ]; then
        response=$(curl -s -w "\n%{http_code}" -X PUT "${headers[@]}" -d "$data" "$url" 2>/dev/null)
    elif [ "$method" = "UPLOAD" ]; then
        if [ -n "$token" ]; then
            response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $token" -F "file=@$data" "$url" 2>/dev/null)
        else
            response=$(curl -s -w "\n%{http_code}" -F "file=@$data" "$url" 2>/dev/null)
        fi
    fi

    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')

    local biz_code
    biz_code=$(echo "$body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('code',''))" 2>/dev/null || echo "")

    if [ "$biz_code" = "200" ]; then
        PASS=$((PASS + 1))
        printf "  ${GREEN}✓${NC} [%s] %s\n" "$method" "$description" >&2
    else
        FAIL=$((FAIL + 1))
        local msg
        msg=$(echo "$body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message',''))" 2>/dev/null || echo "$body")
        printf "  ${RED}✗${NC} [%s] %s (HTTP:%s 业务码:%s 消息:%s)\n" "$method" "$description" "$http_code" "$biz_code" "$msg" >&2
        ERRORS="${ERRORS}\n  ✗ [$method] $description -> $biz_code: $msg"
    fi

    # 只把body输出到stdout供调用者提取
    echo "$body"
}

# 提取JSON字段的辅助函数
jq_field() {
    python3 -c "import sys,json; d=json.load(sys.stdin); $1" 2>/dev/null
}

find_id_by_field() {
    local json="$1"
    local field="$2"
    local value="$3"
    echo "$json" | python3 -c "
import sys, json
d = json.load(sys.stdin)
records = d.get('data',{}).get('records',[])
for r in records:
    if '$value' in str(r.get('$field','')):
        print(r['id']); break
" 2>/dev/null || echo ""
}

# =====================================================
echo "" >&2
echo "╔══════════════════════════════════════════════════╗" >&2
echo "║   农作物种植生产管理系统 - 全接口API测试          ║" >&2
echo "╚══════════════════════════════════════════════════╝" >&2
echo "" >&2

# 健康检查
echo -n "检查后端服务 (localhost:8090)... " >&2
if curl -s -o /dev/null http://localhost:8090/api/auth/login -X POST -H "Content-Type: application/json" -d '{}' 2>/dev/null; then
    echo -e "${GREEN}运行中${NC}" >&2
else
    echo -e "${RED}未启动!${NC}" >&2; exit 1
fi
echo "" >&2

# =====================================================
# 1. 认证模块
# =====================================================
echo -e "${CYAN}━━━ 1. 认证模块 (/api/auth) ━━━${NC}" >&2

ADMIN_RESP=$(test_api POST "$BASE_URL/auth/login" '{"username":"admin","password":"123456"}' "" "管理员登录")
ADMIN_TOKEN=$(echo "$ADMIN_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('token',''))" 2>/dev/null)

if [ -z "$ADMIN_TOKEN" ]; then
    echo -e "${RED}管理员Token获取失败，终止测试${NC}" >&2; exit 1
fi

FARMER_RESP=$(test_api POST "$BASE_URL/auth/login" '{"username":"farmer01","password":"123456"}' "" "种植户登录")
FARMER_TOKEN=$(echo "$FARMER_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('token',''))" 2>/dev/null)

TECH_RESP=$(test_api POST "$BASE_URL/auth/login" '{"username":"tech01","password":"123456"}' "" "技术员登录")
TECH_TOKEN=$(echo "$TECH_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('token',''))" 2>/dev/null)

test_api POST "$BASE_URL/auth/register" '{"username":"api_test_user_tmp","password":"123456","realName":"测试用户","phone":"13888888888"}' "" "用户注册" > /dev/null
echo "" >&2

# =====================================================
# 2. 用户管理模块
# =====================================================
echo -e "${CYAN}━━━ 2. 用户管理模块 (/api/users) ━━━${NC}" >&2

test_api GET "$BASE_URL/users?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询用户列表" > /dev/null
test_api GET "$BASE_URL/users?page=1&size=10&role=0" "" "$ADMIN_TOKEN" "按角色查询(种植户)" > /dev/null
test_api GET "$BASE_URL/users/1" "" "$ADMIN_TOKEN" "根据ID查询用户(id=1)" > /dev/null
test_api GET "$BASE_URL/users/current" "" "$ADMIN_TOKEN" "获取当前用户信息(管理员)" > /dev/null
test_api GET "$BASE_URL/users/current" "" "$FARMER_TOKEN" "获取当前用户信息(种植户)" > /dev/null

test_api POST "$BASE_URL/users" '{"username":"admin_created_tmp","password":"123456","realName":"管理员新增","phone":"13700000099","role":0,"status":1}' "$ADMIN_TOKEN" "管理员新增用户" > /dev/null
test_api PUT "$BASE_URL/users/current/profile" '{"realName":"张大山","phone":"13900000001"}' "$FARMER_TOKEN" "修改个人资料" > /dev/null
test_api PUT "$BASE_URL/users/current/password" '{"oldPassword":"123456","newPassword":"123456"}' "$FARMER_TOKEN" "修改密码" > /dev/null

# 清理测试用户
for uname in api_test_user_tmp admin_created_tmp; do
    LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/users?page=1&size=100&keyword=$uname" 2>/dev/null)
    UID_VAL=$(find_id_by_field "$LIST" "username" "$uname")
    if [ -n "$UID_VAL" ] && [ "$UID_VAL" != "" ]; then
        test_api DELETE "$BASE_URL/users/$UID_VAL" "" "$ADMIN_TOKEN" "删除测试用户($uname)" > /dev/null
    fi
done
echo "" >&2

# =====================================================
# 3. 作物管理模块
# =====================================================
echo -e "${CYAN}━━━ 3. 作物管理模块 (/api/crops) ━━━${NC}" >&2

test_api GET "$BASE_URL/crops?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询作物列表" > /dev/null
KW=$(urlencode "水稻")
test_api GET "$BASE_URL/crops?page=1&size=10&keyword=$KW" "" "$ADMIN_TOKEN" "关键字搜索(水稻)" > /dev/null
test_api GET "$BASE_URL/crops/1" "" "$ADMIN_TOKEN" "根据ID查询作物(id=1)" > /dev/null

test_api POST "$BASE_URL/crops" '{"name":"油菜","variety":"秦优10号","growthCycle":210,"plantingSeason":"秋季","suitableRegion":"长江流域","description":"测试新增"}' "$ADMIN_TOKEN" "新增作物(油菜)" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/crops?page=1&size=100&keyword=油菜" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "variety" "秦优10号")
if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/crops/$ID" '{"name":"油菜","variety":"秦优10号(改良)","growthCycle":200}' "$ADMIN_TOKEN" "修改作物(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/crops/$ID" "" "$ADMIN_TOKEN" "删除作物(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 4. 地块管理模块
# =====================================================
echo -e "${CYAN}━━━ 4. 地块管理模块 (/api/plots) ━━━${NC}" >&2

test_api GET "$BASE_URL/plots?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询地块列表" > /dev/null
test_api GET "$BASE_URL/plots/1" "" "$ADMIN_TOKEN" "根据ID查询地块(id=1)" > /dev/null
test_api GET "$BASE_URL/plots/my" "" "$FARMER_TOKEN" "查询我的地块" > /dev/null

test_api POST "$BASE_URL/plots" '{"userId":4,"name":"API测试地块","area":5.5,"location":"测试位置","soilType":"壤土","description":"测试"}' "$FARMER_TOKEN" "新增地块" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/plots?page=1&size=100&keyword=API测试地块" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "name" "API测试地块")
if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/plots/$ID" '{"userId":4,"name":"API测试地块(改)","area":6.0}' "$FARMER_TOKEN" "修改地块(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/plots/$ID" "" "$ADMIN_TOKEN" "删除地块(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 5. 种植计划模块
# =====================================================
echo -e "${CYAN}━━━ 5. 种植计划模块 (/api/plans) ━━━${NC}" >&2

test_api GET "$BASE_URL/plans?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询种植计划" > /dev/null
test_api GET "$BASE_URL/plans?page=1&size=10&status=3" "" "$ADMIN_TOKEN" "按状态查询(进行中)" > /dev/null
test_api GET "$BASE_URL/plans/1" "" "$ADMIN_TOKEN" "根据ID查询(id=1)" > /dev/null
test_api GET "$BASE_URL/plans/my" "" "$FARMER_TOKEN" "查询我的种植计划" > /dev/null

test_api POST "$BASE_URL/plans" '{"userId":4,"cropId":1,"plotId":1,"planName":"API测试计划","plannedArea":5.0,"plannedStartDate":"2026-05-01","plannedEndDate":"2026-10-01","status":0,"description":"测试"}' "$FARMER_TOKEN" "新增种植计划" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/plans?page=1&size=100&status=0" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "planName" "API测试计划")
# 尝试 plan_name (snake_case) 如果 planName 匹配不到
if [ -z "$ID" ] || [ "$ID" = "" ]; then
    ID=$(find_id_by_field "$LIST" "plan_name" "API测试计划")
fi

if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/plans/$ID" '{"userId":4,"cropId":1,"plotId":1,"planName":"API测试计划(改)","plannedArea":6.0,"plannedStartDate":"2026-05-01","plannedEndDate":"2026-10-01","status":0}' "$FARMER_TOKEN" "修改种植计划(id=$ID)" > /dev/null
    test_api PUT "$BASE_URL/plans/$ID/review" '{"status":1,"reviewNote":"测试审核通过"}' "$ADMIN_TOKEN" "审核种植计划-通过(id=$ID)" > /dev/null
    test_api PUT "$BASE_URL/plans/$ID/start" '{}' "$ADMIN_TOKEN" "开始执行计划(id=$ID)" > /dev/null
    test_api PUT "$BASE_URL/plans/$ID/complete" '{}' "$ADMIN_TOKEN" "完成计划(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/plans/$ID" "" "$ADMIN_TOKEN" "删除种植计划(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 6. 田间作业模块
# =====================================================
echo -e "${CYAN}━━━ 6. 田间作业模块 (/api/operations) ━━━${NC}" >&2

test_api GET "$BASE_URL/operations?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询田间作业" > /dev/null
test_api GET "$BASE_URL/operations?page=1&size=10&planId=1" "" "$ADMIN_TOKEN" "按计划查询" > /dev/null
test_api GET "$BASE_URL/operations?page=1&size=10&operationType=1" "" "$ADMIN_TOKEN" "按类型查询(灌溉)" > /dev/null
test_api GET "$BASE_URL/operations/1" "" "$ADMIN_TOKEN" "根据ID查询(id=1)" > /dev/null

test_api POST "$BASE_URL/operations" '{"planId":1,"userId":4,"operationType":1,"operationDate":"2026-03-15","description":"API测试灌溉"}' "$FARMER_TOKEN" "新增田间作业" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/operations?page=1&size=100&planId=1" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "description" "API测试灌溉")
if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/operations/$ID" '{"planId":1,"userId":4,"operationType":2,"operationDate":"2026-03-15","description":"API测试施肥(改)"}' "$FARMER_TOKEN" "修改田间作业(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/operations/$ID" "" "$ADMIN_TOKEN" "删除田间作业(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 7. 农资管理模块
# =====================================================
echo -e "${CYAN}━━━ 7. 农资管理模块 (/api/materials) ━━━${NC}" >&2

test_api GET "$BASE_URL/materials?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询农资列表" > /dev/null
KW=$(urlencode "种子")
test_api GET "$BASE_URL/materials?page=1&size=10&keyword=$KW" "" "$ADMIN_TOKEN" "关键字搜索(种子)" > /dev/null
test_api GET "$BASE_URL/materials?page=1&size=10&type=2" "" "$ADMIN_TOKEN" "按类型查询(化肥)" > /dev/null
test_api GET "$BASE_URL/materials/1" "" "$ADMIN_TOKEN" "根据ID查询(id=1)" > /dev/null

test_api POST "$BASE_URL/materials" '{"name":"API测试甲维盐","type":3,"unit":"克","specification":"100克/瓶","manufacturer":"测试厂","price":22.50,"description":"测试"}' "$ADMIN_TOKEN" "新增农资" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/materials?page=1&size=100&keyword=甲维盐" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "name" "甲维盐")
if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/materials/$ID" '{"name":"API测试甲维盐(改)","type":3,"unit":"克","price":25.00}' "$ADMIN_TOKEN" "修改农资(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/materials/$ID" "" "$ADMIN_TOKEN" "删除农资(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 8. 库存管理模块
# =====================================================
echo -e "${CYAN}━━━ 8. 库存管理模块 (/api/inventory) ━━━${NC}" >&2

test_api GET "$BASE_URL/inventory?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询库存" > /dev/null
test_api GET "$BASE_URL/inventory?page=1&size=10&materialId=1" "" "$ADMIN_TOKEN" "按农资ID查询" > /dev/null
test_api GET "$BASE_URL/inventory/warnings" "" "$ADMIN_TOKEN" "库存预警信息" > /dev/null
test_api POST "$BASE_URL/inventory/operate" '{"materialId":1,"type":1,"quantity":100.00,"reason":"API测试入库"}' "$ADMIN_TOKEN" "入库操作" > /dev/null
test_api POST "$BASE_URL/inventory/operate" '{"materialId":1,"type":2,"quantity":10.00,"reason":"API测试出库"}' "$ADMIN_TOKEN" "出库操作" > /dev/null
test_api GET "$BASE_URL/inventory/records?page=1&size=10" "" "$ADMIN_TOKEN" "查询操作记录" > /dev/null
test_api GET "$BASE_URL/inventory/records?page=1&size=10&type=1" "" "$ADMIN_TOKEN" "按类型查询记录(入库)" > /dev/null
echo "" >&2

# =====================================================
# 9. 产量记录模块
# =====================================================
echo -e "${CYAN}━━━ 9. 产量记录模块 (/api/yields) ━━━${NC}" >&2

test_api GET "$BASE_URL/yields?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询产量" > /dev/null
test_api GET "$BASE_URL/yields?page=1&size=10&planId=2" "" "$ADMIN_TOKEN" "按计划查询" > /dev/null
test_api GET "$BASE_URL/yields/1" "" "$ADMIN_TOKEN" "根据ID查询(id=1)" > /dev/null

test_api POST "$BASE_URL/yields" '{"planId":1,"userId":4,"quantity":5000.00,"unit":"斤","harvestDate":"2026-06-01","quality":"一等","notes":"API测试产量"}' "$FARMER_TOKEN" "新增产量记录" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/yields?page=1&size=100&planId=1" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "notes" "API测试产量")
if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/yields/$ID" '{"planId":1,"userId":4,"quantity":5500.00,"unit":"斤","harvestDate":"2026-06-01","quality":"特级","notes":"已修改"}' "$FARMER_TOKEN" "修改产量记录(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/yields/$ID" "" "$ADMIN_TOKEN" "删除产量记录(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 10. 成本记录模块
# =====================================================
echo -e "${CYAN}━━━ 10. 成本记录模块 (/api/costs) ━━━${NC}" >&2

test_api GET "$BASE_URL/costs?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询成本" > /dev/null
test_api GET "$BASE_URL/costs?page=1&size=10&planId=1" "" "$ADMIN_TOKEN" "按计划查询" > /dev/null
test_api GET "$BASE_URL/costs?page=1&size=10&type=1" "" "$ADMIN_TOKEN" "按类型查询(种子)" > /dev/null
test_api GET "$BASE_URL/costs/1" "" "$ADMIN_TOKEN" "根据ID查询(id=1)" > /dev/null

test_api POST "$BASE_URL/costs" '{"planId":1,"userId":4,"type":4,"amount":500.00,"description":"API测试人工费","costDate":"2026-03-15"}' "$FARMER_TOKEN" "新增成本记录" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/costs?page=1&size=100&planId=1" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "description" "API测试人工费")
if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/costs/$ID" '{"planId":1,"userId":4,"type":4,"amount":600.00,"description":"已修改","costDate":"2026-03-15"}' "$FARMER_TOKEN" "修改成本记录(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/costs/$ID" "" "$ADMIN_TOKEN" "删除成本记录(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 11. 公告管理模块
# =====================================================
echo -e "${CYAN}━━━ 11. 公告管理模块 (/api/announcements) ━━━${NC}" >&2

test_api GET "$BASE_URL/announcements?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询公告" > /dev/null
test_api GET "$BASE_URL/announcements?page=1&size=10&status=1" "" "$ADMIN_TOKEN" "按状态查询(已发布)" > /dev/null
test_api GET "$BASE_URL/announcements/published?page=1&size=10" "" "$FARMER_TOKEN" "已发布公告列表" > /dev/null
test_api GET "$BASE_URL/announcements/1" "" "$ADMIN_TOKEN" "根据ID查询(id=1)" > /dev/null

test_api POST "$BASE_URL/announcements" '{"title":"API测试公告","content":"测试内容","publisherId":1,"status":0}' "$ADMIN_TOKEN" "新增公告(草稿)" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/announcements?page=1&size=100&keyword=API测试公告" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "title" "API测试公告")
if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/announcements/$ID" '{"title":"API测试公告(改)","content":"已修改","publisherId":1,"status":0}' "$ADMIN_TOKEN" "修改公告(id=$ID)" > /dev/null
    test_api PUT "$BASE_URL/announcements/$ID/publish" '{}' "$ADMIN_TOKEN" "发布公告(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/announcements/$ID" "" "$ADMIN_TOKEN" "删除公告(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 12. 技术指导模块
# =====================================================
echo -e "${CYAN}━━━ 12. 技术指导模块 (/api/guidance) ━━━${NC}" >&2

test_api GET "$BASE_URL/guidance?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询技术指导" > /dev/null
test_api GET "$BASE_URL/guidance?page=1&size=10&cropId=1" "" "$ADMIN_TOKEN" "按作物查询" > /dev/null
KW=$(urlencode "小麦")
test_api GET "$BASE_URL/guidance?page=1&size=10&keyword=$KW" "" "$ADMIN_TOKEN" "关键字搜索(小麦)" > /dev/null
test_api GET "$BASE_URL/guidance/1" "" "$ADMIN_TOKEN" "根据ID查询(id=1)" > /dev/null

test_api POST "$BASE_URL/guidance" '{"title":"API测试技术指导","content":"测试内容","cropId":1,"authorId":2}' "$ADMIN_TOKEN" "新增技术指导" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/guidance?page=1&size=100&keyword=API测试" 2>/dev/null)
ID=$(find_id_by_field "$LIST" "title" "API测试技术指导")
if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/guidance/$ID" '{"title":"API测试技术指导(改)","content":"已修改","cropId":1,"authorId":2}' "$ADMIN_TOKEN" "修改技术指导(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/guidance/$ID" "" "$ADMIN_TOKEN" "删除技术指导(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 13. 仪表盘模块
# =====================================================
echo -e "${CYAN}━━━ 13. 仪表盘模块 (/api/dashboard) ━━━${NC}" >&2

test_api GET "$BASE_URL/dashboard" "" "$ADMIN_TOKEN" "仪表盘数据(管理员)" > /dev/null
test_api GET "$BASE_URL/dashboard" "" "$FARMER_TOKEN" "仪表盘数据(种植户)" > /dev/null
echo "" >&2

# =====================================================
# 14. 系统配置模块
# =====================================================
echo -e "${CYAN}━━━ 14. 系统配置模块 (/api/config) ━━━${NC}" >&2

test_api GET "$BASE_URL/config?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询配置" > /dev/null
test_api GET "$BASE_URL/config/1" "" "$ADMIN_TOKEN" "根据ID查询(id=1)" > /dev/null
test_api GET "$BASE_URL/config/key/system_name" "" "$ADMIN_TOKEN" "根据Key查询(system_name)" > /dev/null

test_api POST "$BASE_URL/config" '{"configKey":"api_test_key","configValue":"test_val","description":"API测试"}' "$ADMIN_TOKEN" "新增系统配置" > /dev/null

LIST=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE_URL/config?page=1&size=100&keyword=api_test" 2>/dev/null)
ID=$(echo "$LIST" | python3 -c "
import sys, json
d = json.load(sys.stdin)
for r in d.get('data',{}).get('records',[]):
    k = r.get('configKey','') or r.get('config_key','')
    if 'api_test' in k:
        print(r['id']); break
" 2>/dev/null || echo "")

if [ -n "$ID" ] && [ "$ID" != "" ]; then
    test_api PUT "$BASE_URL/config/$ID" '{"configKey":"api_test_key","configValue":"modified","description":"已修改"}' "$ADMIN_TOKEN" "修改配置(id=$ID)" > /dev/null
    test_api DELETE "$BASE_URL/config/$ID" "" "$ADMIN_TOKEN" "删除配置(id=$ID)" > /dev/null
fi
echo "" >&2

# =====================================================
# 15. 系统日志模块
# =====================================================
echo -e "${CYAN}━━━ 15. 系统日志模块 (/api/logs) ━━━${NC}" >&2

test_api GET "$BASE_URL/logs?page=1&size=10" "" "$ADMIN_TOKEN" "分页查询日志" > /dev/null
test_api GET "$BASE_URL/logs?page=1&size=10&username=admin" "" "$ADMIN_TOKEN" "按用户名查询(admin)" > /dev/null
KW=$(urlencode "用户管理")
test_api GET "$BASE_URL/logs?page=1&size=10&module=$KW" "" "$ADMIN_TOKEN" "按模块查询" > /dev/null
echo "" >&2

# =====================================================
# 16. 文件上传模块
# =====================================================
echo -e "${CYAN}━━━ 16. 文件上传模块 (/api/files) ━━━${NC}" >&2

# 创建上传目录（在Tomcat工作目录和项目目录下均创建）
TOMCAT_BASE=$(find /private/var/folders -maxdepth 8 -name "tomcat.8090.*" -type d 2>/dev/null | head -1)
if [ -n "$TOMCAT_BASE" ]; then
    UPLOAD_DIR="$TOMCAT_BASE/work/Tomcat/localhost/ROOT/./uploads/$(date +%Y/%m/%d)"
    mkdir -p "$UPLOAD_DIR" 2>/dev/null || true
fi
mkdir -p /Users/itzhan/Desktop/毕业设计/王奔腾/backend/uploads/$(date +%Y/%m/%d) 2>/dev/null || true
echo "API Test File" > /tmp/test_upload.txt
test_api UPLOAD "$BASE_URL/files/upload" "/tmp/test_upload.txt" "$ADMIN_TOKEN" "文件上传" > /dev/null
rm -f /tmp/test_upload.txt
echo "" >&2

# =====================================================
# 测试汇总
# =====================================================
echo "╔══════════════════════════════════════════════════╗" >&2
echo "║                 测试结果汇总                      ║" >&2
echo "╠══════════════════════════════════════════════════╣" >&2
printf "║  总计: %-5d  通过: %-5d  失败: %-5d            ║\n" "$TOTAL" "$PASS" "$FAIL" >&2
echo "╚══════════════════════════════════════════════════╝" >&2

if [ $FAIL -gt 0 ]; then
    echo "" >&2
    echo -e "${RED}失败的测试:${NC}" >&2
    echo -e "$ERRORS" >&2
    echo "" >&2
    exit 1
else
    echo "" >&2
    echo -e "${GREEN}🎉 所有测试通过！${NC}" >&2
    echo "" >&2
    exit 0
fi
