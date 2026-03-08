<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { NGrid, NGi, NCard, NSpin, NStatistic, NIcon, NEmpty } from 'naive-ui'
import {
  LeafOutline,
  CalendarOutline,
  BarChartOutline,
  CashOutline,
} from '@vicons/ionicons5'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, PieChart, BarChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
} from 'echarts/components'
import { getDashboard } from '@/api/dashboard'

use([
  CanvasRenderer,
  LineChart,
  PieChart,
  BarChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
])

const loading = ref(true)
const dashboardData = ref<any>(null)

// ECharts color palette
const colorPalette = ['#18a058', '#36ad6a', '#d4a259', '#e8b96a', '#5b8c6f', '#8bc34a', '#ff9800', '#795548']

// Yield trend line chart
const yieldTrendOption = computed(() => {
  const data = dashboardData.value?.yieldTrend || []
  return {
    title: { text: '月度产量趋势', left: 'center', textStyle: { fontSize: 14, color: '#333' } },
    tooltip: { trigger: 'axis' },
    grid: { left: '10%', right: '5%', bottom: '15%', top: '20%' },
    xAxis: {
      type: 'category',
      data: data.map((d: any) => d.month || d.label),
      axisLabel: { color: '#666' },
    },
    yAxis: { type: 'value', name: '产量(kg)', axisLabel: { color: '#666' } },
    series: [{
      name: '产量',
      type: 'line',
      data: data.map((d: any) => d.value || d.yield),
      smooth: true,
      lineStyle: { color: '#18a058', width: 3 },
      areaStyle: {
        color: {
          type: 'linear',
          x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: 'rgba(24,160,88,0.3)' },
            { offset: 1, color: 'rgba(24,160,88,0.02)' },
          ],
        },
      },
      itemStyle: { color: '#18a058' },
    }],
  }
})

// Cost breakdown pie chart
const costPieOption = computed(() => {
  const data = dashboardData.value?.costBreakdown || []
  return {
    title: { text: '成本构成分析', left: 'center', textStyle: { fontSize: 14, color: '#333' } },
    tooltip: { trigger: 'item', formatter: '{b}: ¥{c} ({d}%)' },
    legend: { bottom: '0%', left: 'center' },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '45%'],
      data: data.map((d: any) => ({ name: d.name || d.type, value: d.value || d.amount })),
      emphasis: {
        itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0,0,0,0.2)' },
      },
      itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
      color: colorPalette,
    }],
  }
})

// Operation type bar chart
const operationBarOption = computed(() => {
  const data = dashboardData.value?.operationDistribution || []
  return {
    title: { text: '农事操作分布', left: 'center', textStyle: { fontSize: 14, color: '#333' } },
    tooltip: { trigger: 'axis' },
    grid: { left: '15%', right: '5%', bottom: '15%', top: '20%' },
    xAxis: {
      type: 'category',
      data: data.map((d: any) => d.name || d.type),
      axisLabel: { color: '#666', rotate: 30 },
    },
    yAxis: { type: 'value', name: '次数', axisLabel: { color: '#666' } },
    series: [{
      name: '操作次数',
      type: 'bar',
      data: data.map((d: any) => d.value || d.count),
      itemStyle: {
        color: {
          type: 'linear',
          x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: '#36ad6a' },
            { offset: 1, color: '#18a058' },
          ],
        },
        borderRadius: [4, 4, 0, 0],
      },
      barWidth: '40%',
    }],
  }
})

async function loadDashboard() {
  loading.value = true
  try {
    dashboardData.value = await getDashboard()
  } catch {
    dashboardData.value = {
      totalPlans: 0,
      totalYield: 0,
      totalCost: 0,
      totalCrops: 0,
      yieldTrend: [],
      costBreakdown: [],
      operationDistribution: [],
    }
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDashboard()
})
</script>

<template>
  <div>
    <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0 0 20px">数据看板</h2>

    <n-spin :show="loading">
      <!-- Summary Cards -->
      <n-grid :x-gap="16" :y-gap="16" cols="2 m:4" responsive="screen" style="margin-bottom: 24px">
        <n-gi>
          <n-card style="border-radius: 12px">
            <n-statistic label="种植计划" :value="dashboardData?.totalPlans || 0">
              <template #prefix>
                <n-icon :size="20" color="#18a058"><CalendarOutline /></n-icon>
              </template>
              <template #suffix>个</template>
            </n-statistic>
          </n-card>
        </n-gi>
        <n-gi>
          <n-card style="border-radius: 12px">
            <n-statistic label="种植品种" :value="dashboardData?.totalCrops || 0">
              <template #prefix>
                <n-icon :size="20" color="#36ad6a"><LeafOutline /></n-icon>
              </template>
              <template #suffix>种</template>
            </n-statistic>
          </n-card>
        </n-gi>
        <n-gi>
          <n-card style="border-radius: 12px">
            <n-statistic label="总产量" :value="dashboardData?.totalYield || 0">
              <template #prefix>
                <n-icon :size="20" color="#d4a259"><BarChartOutline /></n-icon>
              </template>
              <template #suffix>kg</template>
            </n-statistic>
          </n-card>
        </n-gi>
        <n-gi>
          <n-card style="border-radius: 12px">
            <n-statistic label="总成本">
              <template #prefix>
                <n-icon :size="20" color="#e8b96a"><CashOutline /></n-icon>
              </template>
              ¥{{ (dashboardData?.totalCost || 0).toLocaleString() }}
            </n-statistic>
          </n-card>
        </n-gi>
      </n-grid>

      <!-- Charts -->
      <n-grid :x-gap="16" :y-gap="16" cols="1 m:2" responsive="screen">
        <n-gi :span="2">
          <n-card style="border-radius: 12px">
            <v-chart
              v-if="dashboardData?.yieldTrend?.length"
              :option="yieldTrendOption"
              autoresize
              style="height: 320px"
            />
            <n-empty v-else description="暂无产量趋势数据" style="padding: 60px 0" />
          </n-card>
        </n-gi>
        <n-gi>
          <n-card style="border-radius: 12px">
            <v-chart
              v-if="dashboardData?.costBreakdown?.length"
              :option="costPieOption"
              autoresize
              style="height: 320px"
            />
            <n-empty v-else description="暂无成本分析数据" style="padding: 60px 0" />
          </n-card>
        </n-gi>
        <n-gi>
          <n-card style="border-radius: 12px">
            <v-chart
              v-if="dashboardData?.operationDistribution?.length"
              :option="operationBarOption"
              autoresize
              style="height: 320px"
            />
            <n-empty v-else description="暂无操作分布数据" style="padding: 60px 0" />
          </n-card>
        </n-gi>
      </n-grid>
    </n-spin>
  </div>
</template>
