<template>
  <div class="dashboard-page">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div class="welcome-text">
        <h2>欢迎回来，{{ userName }}</h2>
        <p>{{ todayStr }} · 以下是您的农场管理概况</p>
      </div>
      <div class="welcome-actions">
        <t-button theme="primary" variant="outline" @click="refreshData">
          <template #icon><t-icon name="refresh" /></template>
          刷新数据
        </t-button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stat-cards">
      <div class="stat-card" style="--card-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%)">
        <div class="stat-icon"><t-icon name="user" size="28px" /></div>
        <div class="stat-info">
          <div class="stat-value">{{ dashboardData.userCount || 0 }}</div>
          <div class="stat-label">用户总数</div>
        </div>
      </div>
      <div class="stat-card" style="--card-gradient: linear-gradient(135deg, #2ba471 0%, #36ad6a 100%)">
        <div class="stat-icon"><t-icon name="broccoli" size="28px" /></div>
        <div class="stat-info">
          <div class="stat-value">{{ dashboardData.cropCount || 0 }}</div>
          <div class="stat-label">作物种类</div>
        </div>
      </div>
      <div class="stat-card" style="--card-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%)">
        <div class="stat-icon"><t-icon name="map-location" size="28px" /></div>
        <div class="stat-info">
          <div class="stat-value">{{ dashboardData.plotCount || 0 }}</div>
          <div class="stat-label">管理地块</div>
        </div>
      </div>
      <div class="stat-card" style="--card-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)">
        <div class="stat-icon"><t-icon name="calendar" size="28px" /></div>
        <div class="stat-info">
          <div class="stat-value">{{ dashboardData.planCount || 0 }}</div>
          <div class="stat-label">种植计划</div>
        </div>
      </div>
      <div class="stat-card" style="--card-gradient: linear-gradient(135deg, #fa709a 0%, #fee140 100%)">
        <div class="stat-icon"><t-icon name="tools" size="28px" /></div>
        <div class="stat-info">
          <div class="stat-value">{{ dashboardData.operationCount || 0 }}</div>
          <div class="stat-label">田间作业</div>
        </div>
      </div>
      <div class="stat-card" style="--card-gradient: linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)">
        <div class="stat-icon"><t-icon name="shop" size="28px" /></div>
        <div class="stat-info">
          <div class="stat-value">{{ dashboardData.materialCount || 0 }}</div>
          <div class="stat-label">农资种类</div>
        </div>
      </div>
    </div>

    <!-- 快捷操作 -->
    <t-card class="quick-actions-card" :bordered="false" title="快捷操作" style="margin-bottom: 16px">
      <div class="quick-actions">
        <div class="quick-btn" @click="$router.push('/plan')">
          <div class="quick-icon" style="background: #e8f5e1; color: #2ba471"><t-icon name="calendar" size="22px" /></div>
          <span>种植计划</span>
        </div>
        <div class="quick-btn" @click="$router.push('/crop')">
          <div class="quick-icon" style="background: #fef3e5; color: #e37318"><t-icon name="broccoli" size="22px" /></div>
          <span>作物管理</span>
        </div>
        <div class="quick-btn" @click="$router.push('/operation')">
          <div class="quick-icon" style="background: #e8f0fe; color: #0052d9"><t-icon name="tools" size="22px" /></div>
          <span>田间作业</span>
        </div>
        <div class="quick-btn" @click="$router.push('/material')">
          <div class="quick-icon" style="background: #fce8ea; color: #d54941"><t-icon name="shop" size="22px" /></div>
          <span>农资管理</span>
        </div>
        <div class="quick-btn" @click="$router.push('/inventory')">
          <div class="quick-icon" style="background: #e5f5fd; color: #029cd4"><t-icon name="chart-pie" size="22px" /></div>
          <span>库存管理</span>
        </div>
        <div class="quick-btn" @click="$router.push('/announcement')">
          <div class="quick-icon" style="background: #f3e8fd; color: #8b5cf6"><t-icon name="notification" size="22px" /></div>
          <span>公告管理</span>
        </div>
      </div>
    </t-card>

    <!-- 图表行1: 计划状态 + 作业类型 -->
    <t-row :gutter="16" style="margin-bottom: 16px">
      <t-col :span="6">
        <t-card title="计划状态分布" :bordered="false">
          <div ref="planChartRef" class="chart-box"></div>
        </t-card>
      </t-col>
      <t-col :span="6">
        <t-card title="作业类型统计" :bordered="false">
          <div ref="operationChartRef" class="chart-box"></div>
        </t-card>
      </t-col>
    </t-row>

    <!-- 图表行2: 月度产量 + 月度成本 -->
    <t-row :gutter="16" style="margin-bottom: 16px">
      <t-col :span="6">
        <t-card title="月度产量趋势" :bordered="false">
          <div ref="yieldChartRef" class="chart-box"></div>
        </t-card>
      </t-col>
      <t-col :span="6">
        <t-card title="月度成本趋势" :bordered="false">
          <div ref="costChartRef" class="chart-box"></div>
        </t-card>
      </t-col>
    </t-row>

    <!-- 库存预警 -->
    <t-card title="库存预警" :bordered="false">
      <template #actions>
        <t-tag v-if="warningList.length > 0" theme="danger" variant="light">{{ warningList.length }} 项预警</t-tag>
        <t-tag v-else theme="success" variant="light">库存正常</t-tag>
      </template>
      <t-table :data="warningList" :columns="warningColumns" row-key="id" :loading="warningLoading" size="small" stripe>
        <template #quantity="{ row }">
          <t-tag theme="danger" variant="light" size="small">{{ row.quantity }}</t-tag>
        </template>
      </t-table>
    </t-card>
  </div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts/core';
import { PieChart, BarChart, LineChart } from 'echarts/charts';
import { TitleComponent, TooltipComponent, LegendComponent, GridComponent } from 'echarts/components';
import { CanvasRenderer } from 'echarts/renderers';
import { MessagePlugin } from 'tdesign-vue-next';
import { computed, onMounted, onUnmounted, ref, nextTick, watch } from 'vue';

import { getDashboard } from '@/api/dashboard';
import { getWarnings } from '@/api/inventory';
import { useUserStore } from '@/store';

echarts.use([PieChart, BarChart, LineChart, TitleComponent, TooltipComponent, LegendComponent, GridComponent, CanvasRenderer]);

defineOptions({ name: 'DashboardBase' });

const userStore = useUserStore();
const userName = computed(() => userStore.realName || userStore.userInfo?.name || '管理员');
const todayStr = new Date().toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' });

const dashboardData = ref<any>({});
const warningList = ref<any[]>([]);
const warningLoading = ref(false);

// Chart refs
const planChartRef = ref<HTMLElement>();
const operationChartRef = ref<HTMLElement>();
const yieldChartRef = ref<HTMLElement>();
const costChartRef = ref<HTMLElement>();
let chartInstances: echarts.ECharts[] = [];

const statusNames: Record<string, string> = { '0': '待审核', '1': '已通过', '2': '已驳回', '3': '进行中', '4': '已完成' };
const typeNames: Record<string, string> = { '1': '灌溉', '2': '施肥', '3': '打药', '4': '除草', '5': '收获', '6': '其他' };
const statusColors = ['#4facfe', '#2ba471', '#d54941', '#e37318', '#667eea'];
const typeColors = ['#4facfe', '#2ba471', '#e37318', '#d54941', '#8b5cf6', '#999'];

type ChartItem = {
  name: string;
  value: number;
};

function normalizeDistribution(
  rawData: any,
  nameMap: Record<string, string> = {},
): ChartItem[] {
  if (!rawData) return [];

  if (Array.isArray(rawData)) {
    return rawData.map((item: any, index: number) => ({
      name: item?.name || nameMap[String(item?.type ?? item?.status ?? index)] || `分类${index + 1}`,
      value: Number(item?.value ?? 0),
    }));
  }

  return Object.entries(rawData).map(([key, value]) => ({
    name: nameMap[key] || key,
    value: Number(value ?? 0),
  }));
}

function normalizeTrend(rawData: any, valueKey: string) {
  if (!Array.isArray(rawData)) return [];

  return rawData.map((item: any) => ({
    month: item?.month || '',
    [valueKey]: Number(item?.[valueKey] ?? item?.value ?? 0),
  }));
}

function renderCharts() {
  // 计划状态饼图
  if (planChartRef.value) {
    const chart = echarts.init(planChartRef.value);
    chartInstances.push(chart);
    const pieData = dashboardData.value.planStatusStats || [];
    chart.setOption({
      tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
      legend: { bottom: 0, left: 'center', textStyle: { fontSize: 12 } },
      series: [{
        type: 'pie',
        radius: ['40%', '65%'],
        center: ['50%', '42%'],
        data: pieData,
        emphasis: { itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.2)' } },
        itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
        color: statusColors,
        label: { show: false },
      }],
    });
  }

  // 作业类型柱状图
  if (operationChartRef.value) {
    const chart = echarts.init(operationChartRef.value);
    chartInstances.push(chart);
    const barData = dashboardData.value.operationTypeStats || [];
    chart.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '12%', right: '5%', bottom: '15%', top: '10%' },
      xAxis: { type: 'category', data: barData.map((d: ChartItem) => d.name), axisLabel: { fontSize: 12, color: '#666' } },
      yAxis: { type: 'value', axisLabel: { fontSize: 12, color: '#999' } },
      series: [{
        type: 'bar',
        data: barData.map((d: ChartItem, i: number) => ({ value: d.value, itemStyle: { color: typeColors[i % typeColors.length] } })),
        barWidth: '40%',
        itemStyle: { borderRadius: [4, 4, 0, 0] },
      }],
    });
  }

  // 月度产量趋势
  if (yieldChartRef.value) {
    const chart = echarts.init(yieldChartRef.value);
    chartInstances.push(chart);
    const data = dashboardData.value.monthlyYield || [];
    chart.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '12%', right: '5%', bottom: '12%', top: '10%' },
      xAxis: { type: 'category', data: data.map((d: any) => d.month), axisLabel: { fontSize: 12, color: '#666' } },
      yAxis: { type: 'value', name: 'kg', axisLabel: { fontSize: 12, color: '#999' } },
      series: [{
        type: 'line',
        data: data.map((d: any) => d.yield),
        smooth: true,
        lineStyle: { color: '#2ba471', width: 3 },
        areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(43,164,113,0.3)' }, { offset: 1, color: 'rgba(43,164,113,0.02)' }] } },
        itemStyle: { color: '#2ba471' },
        symbol: 'circle',
        symbolSize: 8,
      }],
    });
  }

  // 月度成本趋势
  if (costChartRef.value) {
    const chart = echarts.init(costChartRef.value);
    chartInstances.push(chart);
    const data = dashboardData.value.monthlyCost || [];
    chart.setOption({
      tooltip: { trigger: 'axis', formatter: (params: any) => `${params[0].name}<br/>成本: ¥${params[0].value}` },
      grid: { left: '15%', right: '5%', bottom: '12%', top: '10%' },
      xAxis: { type: 'category', data: data.map((d: any) => d.month), axisLabel: { fontSize: 12, color: '#666' } },
      yAxis: { type: 'value', name: '¥', axisLabel: { fontSize: 12, color: '#999' } },
      series: [{
        type: 'bar',
        data: data.map((d: any) => d.cost),
        barWidth: '50%',
        itemStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: '#f093fb' }, { offset: 1, color: '#f5576c' }] }, borderRadius: [4, 4, 0, 0] },
      }],
    });
  }
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
    chartInstances.forEach(c => c.dispose());
    chartInstances = [];

    dashboardData.value = {
      ...(res || {}),
      planStatusStats: normalizeDistribution(res?.planStatusStats ?? res?.planStatusDistribution, statusNames),
      operationTypeStats: normalizeDistribution(res?.operationTypeStats ?? res?.operationTypeDistribution, typeNames),
      monthlyYield: normalizeTrend(res?.monthlyYield ?? res?.monthlyYieldTrend, 'yield'),
      monthlyCost: normalizeTrend(res?.monthlyCost ?? res?.monthlyCostTrend, 'cost'),
    };
    await nextTick();
    renderCharts();
  } catch (e: any) {
    MessagePlugin.error(e.message || '获取仪表盘数据失败');
  }
}

async function loadWarnings() {
  warningLoading.value = true;
  try {
    const res: any = await getWarnings();
    warningList.value = Array.isArray(res) ? res : (res?.records || []);
  } catch {
    warningList.value = [];
  } finally {
    warningLoading.value = false;
  }
}

function refreshData() {
  chartInstances.forEach(c => c.dispose());
  chartInstances = [];
  loadDashboard();
  loadWarnings();
  MessagePlugin.success('数据已刷新');
}

function handleResize() {
  chartInstances.forEach(c => c.resize());
}

onMounted(() => {
  loadDashboard();
  loadWarnings();
  window.addEventListener('resize', handleResize);
});

onUnmounted(() => {
  chartInstances.forEach(c => c.dispose());
  window.removeEventListener('resize', handleResize);
});
</script>

<style scoped>
.dashboard-page {
  padding: 0;
}

/* 欢迎横幅 */
.welcome-banner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 28px;
  margin-bottom: 16px;
  background: linear-gradient(135deg, #e8f5e1 0%, #d4edcc 50%, #c7e8b4 100%);
  border-radius: 12px;
  border: 1px solid #c4e0b4;
}

.welcome-text h2 {
  font-size: 20px;
  font-weight: 700;
  color: #1a5c2e;
  margin: 0 0 6px;
}

.welcome-text p {
  font-size: 13px;
  color: #4a8a5c;
  margin: 0;
}

/* 统计卡片 */
.stat-cards {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 16px;
  margin-bottom: 16px;
}

@media screen and (max-width: 1200px) {
  .stat-cards { grid-template-columns: repeat(3, 1fr); }
}

@media screen and (max-width: 768px) {
  .stat-cards { grid-template-columns: repeat(2, 1fr); }
}

.stat-card {
  background: var(--card-gradient);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  color: white;
  transition: transform 0.3s, box-shadow 0.3s;
  cursor: default;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  width: 52px;
  height: 52px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  line-height: 1.2;
}

.stat-label {
  font-size: 13px;
  opacity: 0.85;
  margin-top: 2px;
}

/* 快捷操作 */
.quick-actions {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
}

.quick-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: transform 0.2s;
  min-width: 72px;
}

.quick-btn:hover {
  transform: translateY(-2px);
}

.quick-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: box-shadow 0.2s;
}

.quick-btn:hover .quick-icon {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.quick-btn span {
  font-size: 12px;
  color: var(--td-text-color-secondary);
}

/* 图表 */
.chart-box {
  height: 280px;
  width: 100%;
}
</style>
