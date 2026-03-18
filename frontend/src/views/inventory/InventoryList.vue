<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  NDataTable,
  NPagination,
  NTag,
  NEmpty,
} from 'naive-ui'
import type { DataTableColumns } from 'naive-ui'
import { getInventory } from '@/api/inventory'
import request from '@/utils/request'

const data = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const materialMap = ref<Record<number, any>>({})

const columns: DataTableColumns<any> = [
  {
    title: '物资名称',
    key: 'materialId',
    render: (row) => materialMap.value[row.materialId]?.name || `物资#${row.materialId}`,
  },
  {
    title: '类别',
    key: 'category',
    render: (row) => materialMap.value[row.materialId]?.type || '-',
  },
  {
    title: '规格',
    key: 'specification',
    render: (row) => materialMap.value[row.materialId]?.specification || '-',
  },
  {
    title: '单位',
    key: 'unit',
    width: 80,
    render: (row) => materialMap.value[row.materialId]?.unit || '-',
  },
  { title: '库存数量', key: 'quantity', width: 100 },
  {
    title: '预警阈值',
    key: 'warningThreshold',
    width: 100,
    render: (row) => row.warningThreshold ?? '-',
  },
  {
    title: '状态',
    key: 'status',
    width: 80,
    render: (row) => {
      if (row.warningThreshold && row.quantity <= row.warningThreshold) {
        return '库存不足'
      }
      return '正常'
    },
  },
  { title: '更新时间', key: 'updateTime', width: 160 },
]

async function loadMaterials() {
  try {
    const res: any = await request.get('/materials', { params: { page: 1, size: 100 } })
    const list = res.records || res || []
    materialMap.value = Object.fromEntries(list.map((m: any) => [m.id, m]))
  } catch {
    // ignore
  }
}

async function loadData() {
  loading.value = true
  try {
    const res: any = await getInventory(page.value, pageSize.value)
    data.value = res.records || []
    total.value = res.total || 0
  } catch {
    data.value = []
  } finally {
    loading.value = false
  }
}

function handlePageChange(p: number) {
  page.value = p
  loadData()
}

onMounted(async () => {
  await loadMaterials()
  loadData()
})
</script>

<template>
  <div>
    <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0 0 20px">物资库存</h2>

    <n-data-table
      :columns="columns"
      :data="data"
      :loading="loading"
      :bordered="false"
      :single-line="false"
    />

    <n-empty v-if="!loading && data.length === 0" description="暂无库存数据" style="padding: 40px 0" />

    <div v-if="total > pageSize" style="display: flex; justify-content: flex-end; margin-top: 16px">
      <n-pagination :page="page" :page-size="pageSize" :item-count="total" @update:page="handlePageChange" />
    </div>
  </div>
</template>
