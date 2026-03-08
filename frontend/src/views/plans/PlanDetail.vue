<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  NCard,
  NDescriptions,
  NDescriptionsItem,
  NTag,
  NButton,
  NSpace,
  NDataTable,
  NSpin,
  NEmpty,
  NGrid,
  NGi,
  NStatistic,
} from 'naive-ui'
import type { DataTableColumns } from 'naive-ui'
import { getPlanById } from '@/api/plan'
import { getOperations } from '@/api/operation'
import { getYields } from '@/api/yield'
import { getCosts } from '@/api/cost'

const route = useRoute()
const router = useRouter()
const planId = Number(route.params.id)

const plan = ref<any>(null)
const loading = ref(true)
const operations = ref<any[]>([])
const yields = ref<any[]>([])
const costs = ref<any[]>([])

const statusMap: Record<string, { label: string; type: 'default' | 'info' | 'success' | 'warning' | 'error' }> = {
  DRAFT: { label: '草稿', type: 'default' },
  PENDING: { label: '待审核', type: 'info' },
  APPROVED: { label: '已通过', type: 'success' },
  IN_PROGRESS: { label: '进行中', type: 'warning' },
  COMPLETED: { label: '已完成', type: 'success' },
  CANCELLED: { label: '已取消', type: 'error' },
}

const opColumns: DataTableColumns<any> = [
  { title: '操作类型', key: 'operationType' },
  { title: '操作日期', key: 'operationDate' },
  { title: '描述', key: 'description', ellipsis: { tooltip: true } },
]

const yieldColumns: DataTableColumns<any> = [
  { title: '收获日期', key: 'harvestDate' },
  { title: '产量(kg)', key: 'actualYield' },
  { title: '质量等级', key: 'qualityLevel' },
  { title: '备注', key: 'remark', ellipsis: { tooltip: true } },
]

const costColumns: DataTableColumns<any> = [
  { title: '费用类型', key: 'costType' },
  { title: '金额(元)', key: 'amount' },
  { title: '日期', key: 'costDate' },
  { title: '备注', key: 'remark', ellipsis: { tooltip: true } },
]

async function loadData() {
  loading.value = true
  try {
    const [planData, opsData, yieldsData, costsData]: any[] = await Promise.all([
      getPlanById(planId),
      getOperations({ planId, page: 1, size: 100 }).catch(() => ({ records: [] })),
      getYields({ planId, page: 1, size: 100 }).catch(() => ({ records: [] })),
      getCosts({ planId, page: 1, size: 100 }).catch(() => ({ records: [] })),
    ])
    plan.value = planData
    operations.value = opsData.records || opsData || []
    yields.value = yieldsData.records || yieldsData || []
    costs.value = costsData.records || costsData || []
  } catch {
    plan.value = null
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <div>
    <n-space style="margin-bottom: 16px">
      <n-button @click="router.push('/plans')">返回列表</n-button>
    </n-space>

    <n-spin :show="loading">
      <template v-if="plan">
        <n-card style="border-radius: 12px; margin-bottom: 20px">
          <template #header>
            <div style="display: flex; align-items: center; gap: 12px">
              <span style="font-size: 18px; font-weight: 600">{{ plan.planName }}</span>
              <n-tag
                :type="(statusMap[plan.status] || { type: 'default' }).type"
                size="small"
                round
              >
                {{ (statusMap[plan.status] || { label: plan.status }).label }}
              </n-tag>
            </div>
          </template>

          <n-grid :x-gap="16" :y-gap="16" cols="2 m:4" responsive="screen" style="margin-bottom: 20px">
            <n-gi>
              <n-statistic label="种植面积" :value="plan.plantingArea || 0">
                <template #suffix>亩</template>
              </n-statistic>
            </n-gi>
            <n-gi>
              <n-statistic label="预期产量" :value="plan.expectedYield || 0">
                <template #suffix>kg</template>
              </n-statistic>
            </n-gi>
            <n-gi>
              <n-statistic label="开始日期">
                <template #default>{{ plan.startDate || '-' }}</template>
              </n-statistic>
            </n-gi>
            <n-gi>
              <n-statistic label="结束日期">
                <template #default>{{ plan.endDate || '-' }}</template>
              </n-statistic>
            </n-gi>
          </n-grid>

          <n-descriptions :column="2" label-placement="left" bordered>
            <n-descriptions-item label="作物">{{ plan.cropName || '-' }}</n-descriptions-item>
            <n-descriptions-item label="地块">{{ plan.plotName || '-' }}</n-descriptions-item>
            <n-descriptions-item label="描述" :span="2">{{ plan.description || '-' }}</n-descriptions-item>
          </n-descriptions>
        </n-card>

        <!-- Operations -->
        <n-card style="border-radius: 12px; margin-bottom: 20px">
          <template #header>农事操作记录</template>
          <n-data-table
            v-if="operations.length"
            :columns="opColumns"
            :data="operations"
            :bordered="false"
            size="small"
          />
          <n-empty v-else description="暂无操作记录" style="padding: 24px 0" />
        </n-card>

        <!-- Yields -->
        <n-card style="border-radius: 12px; margin-bottom: 20px">
          <template #header>产量记录</template>
          <n-data-table
            v-if="yields.length"
            :columns="yieldColumns"
            :data="yields"
            :bordered="false"
            size="small"
          />
          <n-empty v-else description="暂无产量记录" style="padding: 24px 0" />
        </n-card>

        <!-- Costs -->
        <n-card style="border-radius: 12px">
          <template #header>成本记录</template>
          <n-data-table
            v-if="costs.length"
            :columns="costColumns"
            :data="costs"
            :bordered="false"
            size="small"
          />
          <n-empty v-else description="暂无成本记录" style="padding: 24px 0" />
        </n-card>
      </template>

      <n-empty v-else-if="!loading" description="未找到该种植计划" style="padding: 60px 0" />
    </n-spin>
  </div>
</template>
