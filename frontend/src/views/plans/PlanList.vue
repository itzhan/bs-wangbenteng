<script setup lang="ts">
import { ref, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import {
  NDataTable,
  NButton,
  NSpace,
  NTag,
  NModal,
  NForm,
  NFormItem,
  NInput,
  NInputNumber,
  NDatePicker,
  NSelect,
  NPagination,
} from 'naive-ui'
import type { DataTableColumns, FormInst } from 'naive-ui'
import { getMyPlans, createPlan, updatePlan, deletePlan } from '@/api/plan'
import { getCrops } from '@/api/crop'
import { getMyPlots } from '@/api/plot'

const router = useRouter()
const plans = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const showModal = ref(false)
const isEdit = ref(false)
const formRef = ref<FormInst | null>(null)
const formLoading = ref(false)
const formData = ref<Record<string, any>>({
  cropId: null,
  plotId: null,
  planName: '',
  plantingArea: null,
  expectedYield: null,
  startDate: null,
  endDate: null,
  description: '',
})

const cropOptions = ref<any[]>([])
const plotOptions = ref<any[]>([])
let editId: number | null = null

const statusMap: Record<string, { label: string; type: 'default' | 'info' | 'success' | 'warning' | 'error' }> = {
  DRAFT: { label: '草稿', type: 'default' },
  PENDING: { label: '待审核', type: 'info' },
  APPROVED: { label: '已通过', type: 'success' },
  IN_PROGRESS: { label: '进行中', type: 'warning' },
  COMPLETED: { label: '已完成', type: 'success' },
  CANCELLED: { label: '已取消', type: 'error' },
}

const columns: DataTableColumns<any> = [
  { title: '计划名称', key: 'planName', ellipsis: { tooltip: true } },
  { title: '作物', key: 'cropName' },
  { title: '地块', key: 'plotName' },
  {
    title: '面积(亩)',
    key: 'plantingArea',
    width: 90,
    render: (row) => row.plantingArea ?? '-',
  },
  {
    title: '预期产量(kg)',
    key: 'expectedYield',
    width: 110,
    render: (row) => row.expectedYield ?? '-',
  },
  { title: '开始日期', key: 'startDate', width: 110 },
  { title: '结束日期', key: 'endDate', width: 110 },
  {
    title: '状态',
    key: 'status',
    width: 90,
    render: (row) => {
      const s = statusMap[row.status] || { label: row.status, type: 'default' as const }
      return h(NTag, { type: s.type, size: 'small', round: true }, { default: () => s.label })
    },
  },
  {
    title: '操作',
    key: 'actions',
    width: 200,
    render: (row) =>
      h(NSpace, { size: 'small' }, {
        default: () => [
          h(NButton, { size: 'small', type: 'info', quaternary: true, onClick: () => router.push(`/plans/${row.id}`) }, { default: () => '详情' }),
          h(NButton, { size: 'small', type: 'warning', quaternary: true, onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'small', type: 'error', quaternary: true, onClick: () => handleDelete(row.id) }, { default: () => '删除' }),
        ],
      }),
  },
]

async function loadPlans() {
  loading.value = true
  try {
    const data: any = await getMyPlans(page.value, pageSize.value)
    // Backend /plans/my returns a plain array (not paginated)
    if (Array.isArray(data)) {
      plans.value = data
      total.value = data.length
    } else {
      plans.value = data.records || []
      total.value = data.total || 0
    }
  } catch {
    plans.value = []
  } finally {
    loading.value = false
  }
}

async function loadOptions() {
  try {
    const [cropsData, plotsData]: any[] = await Promise.all([
      getCrops(1, 100),
      getMyPlots(),
    ])
    cropOptions.value = (cropsData.records || cropsData || []).map((c: any) => ({
      label: c.name,
      value: c.id,
    }))
    plotOptions.value = (plotsData || []).map((p: any) => ({
      label: p.name || p.plotName,
      value: p.id,
    }))
  } catch {
    // ignore
  }
}

function handleAdd() {
  isEdit.value = false
  editId = null
  formData.value = {
    cropId: null,
    plotId: null,
    planName: '',
    plantingArea: null,
    expectedYield: null,
    startDate: null,
    endDate: null,
    description: '',
  }
  showModal.value = true
}

function handleEdit(row: any) {
  isEdit.value = true
  editId = row.id
  formData.value = {
    cropId: row.cropId,
    plotId: row.plotId,
    planName: row.planName,
    plantingArea: row.plantingArea,
    expectedYield: row.expectedYield,
    startDate: row.startDate ? new Date(row.startDate).getTime() : null,
    endDate: row.endDate ? new Date(row.endDate).getTime() : null,
    description: row.description || '',
  }
  showModal.value = true
}

async function handleSubmit() {
  try {
    await formRef.value?.validate()
  } catch {
    return
  }

  formLoading.value = true
  try {
    const payload = {
      ...formData.value,
      startDate: formData.value.startDate ? new Date(formData.value.startDate).toISOString().split('T')[0] : null,
      endDate: formData.value.endDate ? new Date(formData.value.endDate).toISOString().split('T')[0] : null,
    }
    if (isEdit.value && editId) {
      await updatePlan(editId, payload)
      window.$message?.success('更新成功')
    } else {
      await createPlan(payload)
      window.$message?.success('创建成功')
    }
    showModal.value = false
    loadPlans()
  } catch {
    // handled
  } finally {
    formLoading.value = false
  }
}

async function handleDelete(id: number) {
  try {
    await deletePlan(id)
    window.$message?.success('删除成功')
    loadPlans()
  } catch {
    // handled
  }
}

function handlePageChange(p: number) {
  page.value = p
  loadPlans()
}

onMounted(() => {
  loadPlans()
  loadOptions()
})
</script>

<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px">
      <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0">我的种植计划</h2>
      <n-button type="primary" @click="handleAdd">新增计划</n-button>
    </div>

    <n-data-table
      :columns="columns"
      :data="plans"
      :loading="loading"
      :bordered="false"
      :single-line="false"
      style="border-radius: 8px"
    />

    <div v-if="total > pageSize" style="display: flex; justify-content: flex-end; margin-top: 16px">
      <n-pagination
        :page="page"
        :page-size="pageSize"
        :item-count="total"
        @update:page="handlePageChange"
      />
    </div>

    <!-- Add/Edit Modal -->
    <n-modal v-model:show="showModal" :title="isEdit ? '编辑种植计划' : '新增种植计划'" preset="card" style="max-width: 520px; border-radius: 12px">
      <n-form ref="formRef" :model="formData" label-placement="left" label-width="90">
        <n-form-item label="计划名称" path="planName" :rule="{ required: true, message: '请输入计划名称' }">
          <n-input v-model:value="formData.planName" placeholder="请输入计划名称" />
        </n-form-item>
        <n-form-item label="作物" path="cropId" :rule="{ required: true, type: 'number', message: '请选择作物' }">
          <n-select v-model:value="formData.cropId" :options="cropOptions" placeholder="请选择作物" filterable />
        </n-form-item>
        <n-form-item label="地块" path="plotId">
          <n-select v-model:value="formData.plotId" :options="plotOptions" placeholder="请选择地块" filterable clearable />
        </n-form-item>
        <n-form-item label="种植面积">
          <n-input-number v-model:value="formData.plantingArea" placeholder="亩" :min="0" style="width: 100%" />
        </n-form-item>
        <n-form-item label="预期产量">
          <n-input-number v-model:value="formData.expectedYield" placeholder="kg" :min="0" style="width: 100%" />
        </n-form-item>
        <n-form-item label="开始日期">
          <n-date-picker v-model:value="formData.startDate" type="date" style="width: 100%" />
        </n-form-item>
        <n-form-item label="结束日期">
          <n-date-picker v-model:value="formData.endDate" type="date" style="width: 100%" />
        </n-form-item>
        <n-form-item label="描述">
          <n-input v-model:value="formData.description" type="textarea" placeholder="计划描述" :rows="3" />
        </n-form-item>
      </n-form>
      <template #action>
        <n-space justify="end">
          <n-button @click="showModal = false">取消</n-button>
          <n-button type="primary" :loading="formLoading" @click="handleSubmit">确定</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>
