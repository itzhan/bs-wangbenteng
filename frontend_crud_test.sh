#!/bin/bash
# ==========================================================
# 用户端全面 CRUD 测试脚本
# 测试所有用户侧的增删改查操作
# ==========================================================
set -e

BASE="http://localhost:8090"
PASS=0
FAIL=0
ERRORS=""

# 颜色输出
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

ok()   { ((PASS++)); echo -e "  ${GREEN}✓ PASS${NC} - $1"; }
fail() { ((FAIL++)); ERRORS+="  ✗ $1\n"; echo -e "  ${RED}✗ FAIL${NC} - $1"; }

# JSON 解析
jval()  { python3 -c "import sys,json; d=json.load(sys.stdin); print(d$1)" 2>/dev/null; }
jval2() { echo "$2" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d$1)" 2>/dev/null; }

section() { echo -e "\n${YELLOW}━━━ $1 ━━━${NC}"; }

# ==========================================================
# 等待后端启动
# ==========================================================
echo "等待后端启动 (localhost:8090)..."
for i in $(seq 1 30); do
  if curl -s "$BASE/api/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"123456"}' | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['code']==200" 2>/dev/null; then
    echo -e "${GREEN}后端已启动！${NC}"
    break
  fi
  if [ $i -eq 30 ]; then echo -e "${RED}后端启动超时！${NC}"; exit 1; fi
  sleep 2
done

# ==========================================================
# 登录获取 Token
# ==========================================================
section "1. 登录认证"

# farmer01 登录
RESP=$(curl -s "$BASE/api/auth/login" -X POST -H "Content-Type: application/json" \
  -d '{"username":"farmer01","password":"123456"}')
TOKEN=$(jval2 "['data']['token']" "$RESP")
if [ -n "$TOKEN" ] && [ "$TOKEN" != "None" ]; then
  ok "farmer01 登录成功"
else
  fail "farmer01 登录失败"
  echo "响应: $RESP"
  exit 1
fi
AUTH="Authorization: Bearer $TOKEN"

# ==========================================================
# 2. 种植计划 CRUD
# ==========================================================
section "2. 种植计划 (PlantingPlan)"

# 查询
RESP=$(curl -s "$BASE/api/plans/my" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
[ "$CODE" = "200" ] && ok "查询我的计划" || fail "查询我的计划: $RESP"

# 新增
RESP=$(curl -s "$BASE/api/plans" -X POST -H "$AUTH" -H "Content-Type: application/json" \
  -d '{
    "cropId": 1,
    "planName": "测试计划-自动化",
    "plannedArea": 5.5,
    "plannedStartDate": "2026-04-01",
    "plannedEndDate": "2026-09-30",
    "description": "自动化测试创建的计划"
  }')
CODE=$(jval2 "['code']" "$RESP")
if [ "$CODE" = "200" ]; then
  ok "新增种植计划"
else
  fail "新增种植计划: $(jval2 "['message']" "$RESP")"
fi

# 获取刚创建的计划ID
RESP=$(curl -s "$BASE/api/plans/my" -H "$AUTH")
PLAN_ID=$(echo "$RESP" | python3 -c "
import sys,json
d=json.load(sys.stdin)
plans=d.get('data',[])
for p in plans:
  if p.get('planName')=='测试计划-自动化':
    print(p['id']); break
" 2>/dev/null)

if [ -n "$PLAN_ID" ] && [ "$PLAN_ID" != "None" ]; then
  ok "获取新建计划ID: $PLAN_ID"

  # 修改
  RESP=$(curl -s "$BASE/api/plans/$PLAN_ID" -X PUT -H "$AUTH" -H "Content-Type: application/json" \
    -d '{"planName": "测试计划-已修改", "cropId": 1, "plannedArea": 8.0}')
  CODE=$(jval2 "['code']" "$RESP")
  [ "$CODE" = "200" ] && ok "修改种植计划" || fail "修改种植计划: $(jval2 "['message']" "$RESP")"

  # 删除
  RESP=$(curl -s "$BASE/api/plans/$PLAN_ID" -X DELETE -H "$AUTH")
  CODE=$(jval2 "['code']" "$RESP")
  [ "$CODE" = "200" ] && ok "删除种植计划" || fail "删除种植计划: $(jval2 "['message']" "$RESP")"
else
  fail "获取新建计划ID"
fi

# ==========================================================
# 3. 农事操作 CRUD
# ==========================================================
section "3. 农事操作 (FieldOperation)"

# 获取一个有效的 planId
RESP=$(curl -s "$BASE/api/plans/my" -H "$AUTH")
MY_PLAN_ID=$(echo "$RESP" | python3 -c "
import sys,json
d=json.load(sys.stdin)
plans=d.get('data',[])
if plans: print(plans[0]['id'])
" 2>/dev/null)

if [ -z "$MY_PLAN_ID" ] || [ "$MY_PLAN_ID" = "None" ]; then
  echo "  ⚠ 没有可用计划,使用planId=1"
  MY_PLAN_ID=1
fi

# 查询
RESP=$(curl -s "$BASE/api/operations?page=1&size=5" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
[ "$CODE" = "200" ] && ok "查询农事操作列表" || fail "查询农事操作列表: $RESP"

# 新增
RESP=$(curl -s "$BASE/api/operations" -X POST -H "$AUTH" -H "Content-Type: application/json" \
  -d "{
    \"planId\": $MY_PLAN_ID,
    \"operationType\": 2,
    \"operationDate\": \"2026-03-15\",
    \"description\": \"自动化测试-施肥操作\"
  }")
CODE=$(jval2 "['code']" "$RESP")
if [ "$CODE" = "200" ]; then
  ok "新增农事操作"
else
  fail "新增农事操作: $(jval2 "['message']" "$RESP")"
fi

# 获取最新操作ID
RESP=$(curl -s "$BASE/api/operations?page=1&size=50" -H "$AUTH")
OP_ID=$(echo "$RESP" | python3 -c "
import sys,json
d=json.load(sys.stdin)
recs=d.get('data',{}).get('records',[])
for r in recs:
  if r.get('description')=='自动化测试-施肥操作':
    print(r['id']); break
" 2>/dev/null)

if [ -n "$OP_ID" ] && [ "$OP_ID" != "None" ]; then
  ok "获取新建操作ID: $OP_ID"

  # 修改
  RESP=$(curl -s "$BASE/api/operations/$OP_ID" -X PUT -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"planId\": $MY_PLAN_ID, \"operationType\": 3, \"operationDate\": \"2026-03-16\", \"description\": \"已修改-打药\"}")
  CODE=$(jval2 "['code']" "$RESP")
  [ "$CODE" = "200" ] && ok "修改农事操作" || fail "修改农事操作: $(jval2 "['message']" "$RESP")"

  # 删除
  RESP=$(curl -s "$BASE/api/operations/$OP_ID" -X DELETE -H "$AUTH")
  CODE=$(jval2 "['code']" "$RESP")
  [ "$CODE" = "200" ] && ok "删除农事操作" || fail "删除农事操作: $(jval2 "['message']" "$RESP")"
else
  fail "获取新建操作ID"
fi

# ==========================================================
# 4. 成本记录 CRUD
# ==========================================================
section "4. 成本记录 (CostRecord)"

# 查询
RESP=$(curl -s "$BASE/api/costs?page=1&size=5" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
[ "$CODE" = "200" ] && ok "查询成本记录列表" || fail "查询成本记录列表: $RESP"

# 新增
RESP=$(curl -s "$BASE/api/costs" -X POST -H "$AUTH" -H "Content-Type: application/json" \
  -d "{
    \"planId\": $MY_PLAN_ID,
    \"type\": 3,
    \"amount\": 150.50,
    \"costDate\": \"2026-03-15\",
    \"description\": \"自动化测试-农药费用\"
  }")
CODE=$(jval2 "['code']" "$RESP")
if [ "$CODE" = "200" ]; then
  ok "新增成本记录"
else
  fail "新增成本记录: $(jval2 "['message']" "$RESP")"
fi

# 获取最新成本ID
RESP=$(curl -s "$BASE/api/costs?page=1&size=50" -H "$AUTH")
COST_ID=$(echo "$RESP" | python3 -c "
import sys,json
d=json.load(sys.stdin)
recs=d.get('data',{}).get('records',[])
for r in recs:
  if r.get('description')=='自动化测试-农药费用':
    print(r['id']); break
" 2>/dev/null)

if [ -n "$COST_ID" ] && [ "$COST_ID" != "None" ]; then
  ok "获取新建成本ID: $COST_ID"

  # 修改
  RESP=$(curl -s "$BASE/api/costs/$COST_ID" -X PUT -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"planId\": $MY_PLAN_ID, \"type\": 4, \"amount\": 200, \"description\": \"已修改-人工费\"}")
  CODE=$(jval2 "['code']" "$RESP")
  [ "$CODE" = "200" ] && ok "修改成本记录" || fail "修改成本记录: $(jval2 "['message']" "$RESP")"

  # 删除
  RESP=$(curl -s "$BASE/api/costs/$COST_ID" -X DELETE -H "$AUTH")
  CODE=$(jval2 "['code']" "$RESP")
  [ "$CODE" = "200" ] && ok "删除成本记录" || fail "删除成本记录: $(jval2 "['message']" "$RESP")"
else
  fail "获取新建成本ID"
fi

# ==========================================================
# 5. 产量记录 CRUD
# ==========================================================
section "5. 产量记录 (YieldRecord)"

# 查询
RESP=$(curl -s "$BASE/api/yields?page=1&size=5" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
[ "$CODE" = "200" ] && ok "查询产量记录列表" || fail "查询产量记录列表: $RESP"

# 新增
RESP=$(curl -s "$BASE/api/yields" -X POST -H "$AUTH" -H "Content-Type: application/json" \
  -d "{
    \"planId\": $MY_PLAN_ID,
    \"quantity\": 500,
    \"unit\": \"kg\",
    \"harvestDate\": \"2026-03-15\",
    \"quality\": \"优\",
    \"notes\": \"自动化测试-产量记录\"
  }")
CODE=$(jval2 "['code']" "$RESP")
if [ "$CODE" = "200" ]; then
  ok "新增产量记录"
else
  fail "新增产量记录: $(jval2 "['message']" "$RESP")"
fi

# 获取最新产量ID
RESP=$(curl -s "$BASE/api/yields?page=1&size=50" -H "$AUTH")
YIELD_ID=$(echo "$RESP" | python3 -c "
import sys,json
d=json.load(sys.stdin)
recs=d.get('data',{}).get('records',[])
for r in recs:
  if r.get('notes')=='自动化测试-产量记录':
    print(r['id']); break
" 2>/dev/null)

if [ -n "$YIELD_ID" ] && [ "$YIELD_ID" != "None" ]; then
  ok "获取新建产量ID: $YIELD_ID"

  # 修改
  RESP=$(curl -s "$BASE/api/yields/$YIELD_ID" -X PUT -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"planId\": $MY_PLAN_ID, \"quantity\": 600, \"unit\": \"kg\", \"harvestDate\": \"2026-03-16\", \"quality\": \"良\", \"notes\": \"已修改\"}")
  CODE=$(jval2 "['code']" "$RESP")
  [ "$CODE" = "200" ] && ok "修改产量记录" || fail "修改产量记录: $(jval2 "['message']" "$RESP")"

  # 删除
  RESP=$(curl -s "$BASE/api/yields/$YIELD_ID" -X DELETE -H "$AUTH")
  CODE=$(jval2 "['code']" "$RESP")
  [ "$CODE" = "200" ] && ok "删除产量记录" || fail "删除产量记录: $(jval2 "['message']" "$RESP")"
else
  fail "获取新建产量ID"
fi

# ==========================================================
# 6. 物资库存 (只读)
# ==========================================================
section "6. 物资库存 (Inventory)"

RESP=$(curl -s "$BASE/api/inventory?page=1&size=5" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
[ "$CODE" = "200" ] && ok "查询库存列表" || fail "查询库存列表: $RESP"

RESP=$(curl -s "$BASE/api/materials?page=1&size=5" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
[ "$CODE" = "200" ] && ok "查询物资列表" || fail "查询物资列表: $RESP"

# ==========================================================
# 7. 作物品种 (只读)
# ==========================================================
section "7. 作物品种 (Crop)"

RESP=$(curl -s "$BASE/api/crops?page=1&size=5" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
TOTAL=$(jval2 "['data']['total']" "$RESP")
[ "$CODE" = "200" ] && ok "查询作物列表 (total=$TOTAL)" || fail "查询作物列表: $RESP"

RESP=$(curl -s "$BASE/api/crops/1" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
[ "$CODE" = "200" ] && ok "查询单个作物详情" || fail "查询单个作物详情: $RESP"

# ==========================================================
# 8. 通知公告 (只读)
# ==========================================================
section "8. 通知公告 (Announcement)"

RESP=$(curl -s "$BASE/api/announcements/published?page=1&size=5" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
TOTAL=$(jval2 "['data']['total']" "$RESP")
[ "$CODE" = "200" ] && ok "查询已发布公告 (total=$TOTAL)" || fail "查询已发布公告: $RESP"

# ==========================================================
# 9. 技术指导 (只读)
# ==========================================================
section "9. 技术指导 (Guidance)"

RESP=$(curl -s "$BASE/api/guidance?page=1&size=5" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
TOTAL=$(jval2 "['data']['total']" "$RESP")
[ "$CODE" = "200" ] && ok "查询技术指导 (total=$TOTAL)" || fail "查询技术指导: $RESP"

# ==========================================================
# 10. 数据看板
# ==========================================================
section "10. 数据看板 (Dashboard)"

RESP=$(curl -s "$BASE/api/dashboard" -H "$AUTH")
CODE=$(jval2 "['code']" "$RESP")
PLANS=$(jval2 "['data']['planCount']" "$RESP")
CROPS=$(jval2 "['data']['cropCount']" "$RESP")
[ "$CODE" = "200" ] && ok "数据看板 (plans=$PLANS, crops=$CROPS)" || fail "数据看板: $RESP"

# ==========================================================
# 结果汇总
# ==========================================================
echo ""
echo "╔══════════════════════════════════════╗"
echo "║    用 户 端 C R U D 测 试 报 告      ║"
echo "╠══════════════════════════════════════╣"
printf "║  ${GREEN}通过: %-3d${NC}  ${RED}失败: %-3d${NC}  总计: %-3d    ║\n" $PASS $FAIL $((PASS+FAIL))
echo "╚══════════════════════════════════════╝"

if [ $FAIL -gt 0 ]; then
  echo -e "\n${RED}失败项:${NC}"
  echo -e "$ERRORS"
  exit 1
else
  echo -e "\n${GREEN}✅ 全部通过！所有用户端操作均正常工作。${NC}"
fi
