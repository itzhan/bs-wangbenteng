<script setup lang="ts">
import { ref, onMounted, h } from 'vue'
import {
  NDataTable,
  NButton,
  NSpace,
  NModal,
  NForm,
  NFormItem,
  NInput,
  NInputNumber,
  NSelect,
  NDatePicker,
  NPagination,
  NTag,
} from 'naive-ui'
import type { DataTableColumns, FormInst } from 'naive-ui'
import { getCosts, createCost, updateCost, deleteCost } from '@/api/cost'
import { getMyPlans } from '@/api/plan'

const data = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const showModal = ref(false)
const isEdit = ref(false)
const formRef = ref<FormInst | null>(null)
const formLoading = ref(false)
const formData = ref<Record<string, any>>({
  planId: null,
  costType: '',
  amount: null,
  costDate: null,
  remark: '',
})
let editId: number | null = null

const planOptions = ref<any[]>([])
const costTypeOptions = [
  { label: '种子', value: '种子' },
  { label: '肥料', value: '肥料' },
  { label: '农药', value: '农药' },
  { label: '人工', value: '人工' },
  { label: '机械', value: '机械' },
  { label: '灌溉', value: '灌溉' },
  { label: '其他', value: '其他' },
]

const typeColorMap: Record<string, string> = {
  '种子': 'success',
  '肥料': 'warning',
  '农药': 'error',
  '人工': 'info',
  '机械': 'default',
  '灌溉': 'info',
}

const columns: DataTableColumns<any> = [
  { title: '所属计划', key: 'planName', ellipsis: { tooltip: true } },
  {
    title: '费用类型',
    key: 'costType',
    width: 100,
    render: (row) => h(NTag, { type: (typeColorMap[row.costType] || 'default') as any, size: 'small', round: true }, { default: () => row.costType }),
  },
  {
    title: '金额(元)',
    key: 'amount',
    width: 110,
    render: (row) => `¥${(row.amount || 0).toFixed(2)}`,
  },
  { title: '日期', key: 'costDate', width: 110 },
  { title: '备注', key: 'remark', ellipsis: { tooltip: true } },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    render: (row) =>
      h(NSpace, { size: 'small' }, {
        default: () => [
          h(NButton, { size: 'small', type: 'warning', quaternary: true, onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'small', type: 'error', quaternary: true, onClick: () => handleDelete(row.id) }, { default: () => '删除' }),
        ],
      }),
  },
]

async function loadData() {
  loading.value = true
  try {
    const res: any = await getCosts({ page: page.value, size: pageSize.value })
    data.value = res.records || []
    total.value = res.total || 0
  } catch {
    data.value = []
  } finally {
    loading.value = false
  }
}

async function loadPlanOptions() {
  try {
    const res: any = await getMyPlans(1, 100)
    // Backend /plans/my returns a plain array (not paginated)
    const list = Array.isArray(res) ? res : (res.records || [])
    planOptions.value = list.map((p: any) => ({
      label: p.planName,
      value: p.id,
    }))
  } catch {
    // ignore
  }
}

function handleAdd() {
  isEdit.value = false
  editId = null
  formData.value = { planId: null, costType: '', amount: null, costDate: null, remark: '' }
  showModal.value = true
}

function handleEdit(row: any) {
  isEdit.value = true
  editId = row.id
  formData.value = {
    planId: row.planId,
    costType: row.costType,
    amount: row.amount,
    costDate: row.costDate ? new Date(row.costDate).getTime() : null,
    remark: row.remark || '',
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
      costDate: formData.value.costDate ? new Date(formData.value.costDate).toISOString().split('T')[0] : null,
    }
    if (isEdit.value && editId) {
      await updateCost(editId, payload)
      window.$message?.success('更新成功')
    } else {
      await createCost(payload)
      window.$message?.success('创建成功')
    }
    showModal.value = false
    loadData()
  } catch {
    // handled
  } finally {
    formLoading.value = false
  }
}

async function handleDelete(id: number) {
  try {
    await deleteCost(id)
    window.$message?.success('删除成功')
    loadData()
  } catch {
    // handled
  }
}

function handlePageChange(p: number) {
  page.value = p
  loadData()
}

onMounted(() => {
  loadData()
  loadPlanOptions()
})
</script>

<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px">
      <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0">成本记录</h2>
      <n-button type="primary" @click="handleAdd">新增记录</n-button>
    </div>

    <n-data-table :columns="columns" :data="data" :loading="loading" :bordered="false" :single-line="false" />

    <div v-if="total > pageSize" style="display: flex; justify-content: flex-end; margin-top: 16px">
      <n-pagination :page="page" :page-size="pageSize" :item-count="total" @update:page="handlePageChange" />
    </div>

    <n-modal v-model:show="showModal" :title="isEdit ? '编辑成本记录' : '新增成本记录'" preset="card" style="max-width: 500px; border-radius: 12px">
      <n-form ref="formRef" :model="formData" label-placement="left" label-width="80">
        <n-form-item label="所属计划" path="planId" :rule="{ required: true, type: 'number', message: '请选择计划' }">
          <n-select v-model:value="formData.planId" :options="planOptions" placeholder="请选择计划" filterable />
        </n-form-item>
        <n-form-item label="费用类型" path="costType" :rule="{ required: true, message: '请选择费用类型' }">
          <n-select v-model:value="formData.costType" :options="costTypeOptions" placeholder="请选择费用类型" />
        </n-form-item>
        <n-form-item label="金额(元)" path="amount" :rule="{ required: true, type: 'number', message: '请输入金额' }">
          <n-input-number v-model:value="formData.amount" placeholder="金额" :min="0" :precision="2" style="width: 100%" />
        </n-form-item>
        <n-form-item label="日期" path="costDate">
          <n-date-picker v-model:value="formData.costDate" type="date" style="width: 100%" />
        </n-form-item>
        <n-form-item label="备注">
          <n-input v-model:value="formData.remark" type="textarea" placeholder="备注" :rows="2" />
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
