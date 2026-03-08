<template>
  <div>
    <!-- 统计卡片 -->
    <t-row :gutter="16" style="margin-bottom: 16px">
      <t-col :span="3">
        <t-card :bordered="false" style="text-align: center">
          <div class="stat-card">
            <t-icon name="user" size="32px" style="color: var(--td-brand-color); margin-bottom: 8px" />
            <div class="stat-value">{{ dashboardData.userCount || 0 }}</div>
            <div class="stat-label">用户总数</div>
          </div>
        </t-card>
      </t-col>
      <t-col :span="3">
        <t-card :bordered="false" style="text-align: center">
          <div class="stat-card">
            <t-icon name="flower" size="32px" style="color: var(--td-success-color); margin-bottom: 8px" />
            <div class="stat-value">{{ dashboardData.cropCount || 0 }}</div>
            <div class="stat-label">作物种类</div>
          </div>
        </t-card>
      </t-col>
      <t-col :span="3">
        <t-card :bordered="false" style="text-align: center">
          <div class="stat-card">
            <t-icon name="calendar" size="32px" style="color: var(--td-warning-color); margin-bottom: 8px" />
            <div class="stat-value">{{ dashboardData.planCount || 0 }}</div>
            <div class="stat-label">种植计划</div>
          </div>
        </t-card>
      </t-col>
      <t-col :span="3">
        <t-card :bordered="false" style="text-align: center">
          <div class="stat-card">
            <t-icon name="tools" size="32px" style="color: var(--td-error-color); margin-bottom: 8px" />
            <div class="stat-value">{{ dashboardData.operationCount || 0 }}</div>
            <div class="stat-label">田间作业</div>
          </div>
        </t-card>
      </t-col>
    </t-row>

    <!-- 图表行 -->
    <t-row :gutter="16" style="margin-bottom: 16px">
      <t-col :span="6">
        <t-card title="计划状态分布" :bordered="false">
          <div class="chart-container">
            <div v-if="planStatusData.length" class="simple-chart">
              <div v-for="(item, index) in planStatusData" :key="index" class="chart-bar-item">
                <span class="chart-label">{{ item.name }}</span>
                <div class="chart-bar-bg">
                  <div class="chart-bar-fill" :style="{ width: getPercent(item.value, planStatusTotal) + '%', backgroundColor: pieColors[index % pieColors.length] }"></div>
                </div>
                <span class="chart-count">{{ item.value }}</span>
              </div>
            </div>
            <t-empty v-else description="暂无数据" />
          </div>
        </t-card>
      </t-col>
      <t-col :span="6">
        <t-card title="作业类型统计" :bordered="false">
          <div class="chart-container">
            <div v-if="operationTypeData.length" class="simple-chart">
              <div v-for="(item, index) in operationTypeData" :key="index" class="chart-bar-item">
                <span class="chart-label">{{ item.name }}</span>
                <div class="chart-bar-bg">
                  <div class="chart-bar-fill" :style="{ width: getPercent(item.value, operationTypeTotal) + '%', backgroundColor: barColors[index % barColors.length] }"></div>
                </div>
                <span class="chart-count">{{ item.value }}</span>
              </div>
            </div>
            <t-empty v-else description="暂无数据" />
          </div>
        </t-card>
      </t-col>
    </t-row>

    <t-row :gutter="16" style="margin-bottom: 16px">
      <t-col :span="6">
        <t-card title="月度产量趋势" :bordered="false">
          <div class="chart-container">
            <div v-if="monthlyYieldData.length" class="simple-chart">
              <div v-for="(item, index) in monthlyYieldData" :key="index" class="chart-bar-item">
                <span class="chart-label">{{ item.month }}</span>
                <div class="chart-bar-bg">
                  <div class="chart-bar-fill" :style="{ width: getPercent(item.yield, maxYield) + '%', backgroundColor: '#0052d9' }"></div>
                </div>
                <span class="chart-count">{{ item.yield }}kg</span>
              </div>
            </div>
            <t-empty v-else description="暂无数据" />
          </div>
        </t-card>
      </t-col>
      <t-col :span="6">
        <t-card title="月度成本趋势" :bordered="false">
          <div class="chart-container">
            <div v-if="monthlyCostData.length" class="simple-chart">
              <div v-for="(item, index) in monthlyCostData" :key="index" class="chart-bar-item">
                <span class="chart-label">{{ item.month }}</span>
                <div class="chart-bar-bg">
                  <div class="chart-bar-fill" :style="{ width: getPercent(item.cost, maxCost) + '%', backgroundColor: '#e37318' }"></div>
                </div>
                <span class="chart-count">¥{{ item.cost }}</span>
              </div>
            </div>
            <t-empty v-else description="暂无数据" />
          </div>
        </t-card>
      </t-col>
    </t-row>

    <!-- 库存预警 -->
    <t-card title="库存预警" :bordered="false">
      <t-table :data="warningList" :columns="warningColumns" row-key="id" :loading="warningLoading">
        <template #quantity="{ row }">
          <span style="color: var(--td-error-color); font-weight: bold">{{ row.quantity }}</span>
        </template>
      </t-table>
    </t-card>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { computed, onMounted, ref } from 'vue';

import { getDashboard } from '@/api/dashboard';
import { getWarnings } from '@/api/inventory';

defineOptions({ name: 'DashboardBase' });

const dashboardData = ref<any>({});
const warningList = ref([]);
const warningLoading = ref(false);

const pieColors = ['#0052d9', '#2ba471', '#e37318', '#d54941', '#029cd4'];
const barColors = ['#0052d9', '#2ba471', '#e37318', '#d54941', '#029cd4', '#8b5cf6'];

const planStatusData = computed(() => {
  const data = dashboardData.value.planStatusStats;
  if (!data) return [];
  const statusNames: Record<string, string> = { '0': '待审核', '1': '已通过', '2': '已驳回', '3': '进行中', '4': '已完成' };
  if (Array.isArray(data)) return data;
  return Object.entries(data).map(([key, value]) => ({ name: statusNames[key] || key, value: value as number }));
});

const planStatusTotal = computed(() => planStatusData.value.reduce((s: number, i: any) => s + i.value, 0) || 1);

const operationTypeData = computed(() => {
  const data = dashboardData.value.operationTypeStats;
  if (!data) return [];
  const typeNames: Record<string, string> = { '1': '灌溉', '2': '施肥', '3': '打药', '4': '除草', '5': '收获', '6': '其他' };
  if (Array.isArray(data)) return data;
  return Object.entries(data).map(([key, value]) => ({ name: typeNames[key] || key, value: value as number }));
});

const operationTypeTotal = computed(() => operationTypeData.value.reduce((s: number, i: any) => s + i.value, 0) || 1);

const monthlyYieldData = computed(() => dashboardData.value.monthlyYield || []);
const maxYield = computed(() => Math.max(...monthlyYieldData.value.map((i: any) => i.yield || 0), 1));

const monthlyCostData = computed(() => dashboardData.value.monthlyCost || []);
const maxCost = computed(() => Math.max(...monthlyCostData.value.map((i: any) => i.cost || 0), 1));

function getPercent(value: number, total: number) {
  return Math.min(Math.round((value / total) * 100), 100);
}

const warningColumns = [
  { colKey: 'materialName', title: '农资名称', width: 200 },
  { colKey: 'materialType', title: '类型', width: 120 },
  { colKey: 'quantity', title: '当前库存', width: 120, cell: 'quantity' },
  { colKey: 'warningThreshold', title: '预警阈值', width: 120 },
  { colKey: 'unit', title: '单位', width: 80 },
];

async function loadDashboard() {
  try {
    const res: any = await getDashboard();
    dashboardData.value = res || {};
  } catch (e: any) {
    MessagePlugin.error(e.message || '获取仪表盘数据失败');
  }
}

async function loadWarnings() {
  warningLoading.value = true;
  try {
    const res: any = await getWarnings();
    warningList.value = Array.isArray(res) ? res : (res?.records || []);
  } catch (e: any) {
    // Silently fail - warnings may not exist yet
    warningList.value = [];
  } finally {
    warningLoading.value = false;
  }
}

onMounted(() => {
  loadDashboard();
  loadWarnings();
});
</script>

<style scoped>
.stat-card {
  padding: 16px 0;
}
.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: var(--td-text-color-primary);
  line-height: 36px;
}
.stat-label {
  font-size: 14px;
  color: var(--td-text-color-secondary);
  margin-top: 4px;
}
.chart-container {
  min-height: 200px;
}
.simple-chart {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.chart-bar-item {
  display: flex;
  align-items: center;
  gap: 8px;
}
.chart-label {
  width: 60px;
  font-size: 13px;
  color: var(--td-text-color-secondary);
  text-align: right;
  flex-shrink: 0;
}
.chart-bar-bg {
  flex: 1;
  height: 20px;
  background: var(--td-bg-color-secondarycontainer);
  border-radius: 4px;
  overflow: hidden;
}
.chart-bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.6s ease;
}
.chart-count {
  width: 60px;
  font-size: 13px;
  color: var(--td-text-color-primary);
  font-weight: 500;
  flex-shrink: 0;
}
</style>
