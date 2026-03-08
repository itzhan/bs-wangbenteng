<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  NDataTable,
  NCard,
  NPagination,
  NTag,
  NEmpty,
} from 'naive-ui'
import type { DataTableColumns } from 'naive-ui'
import { getInventory } from '@/api/inventory'

const data = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const columns: DataTableColumns<any> = [
  { title: '物资名称', key: 'materialName' },
  { title: '类别', key: 'category' },
  { title: '规格', key: 'specification' },
  { title: '单位', key: 'unit', width: 80 },
  { title: '库存数量', key: 'quantity', width: 100 },
  { title: '仓库', key: 'warehouseName' },
  { title: '更新时间', key: 'updateTime', width: 160 },
]

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

onMounted(() => {
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
