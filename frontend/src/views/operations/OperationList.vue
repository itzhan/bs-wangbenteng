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
  NSelect,
  NDatePicker,
  NPagination,
  NTag,
} from 'naive-ui'
import type { DataTableColumns, FormInst } from 'naive-ui'
import { getOperations, createOperation, updateOperation, deleteOperation } from '@/api/operation'
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
  operationType: '',
  operationDate: null,
  description: '',
  remark: '',
})
let editId: number | null = null

const planOptions = ref<any[]>([])

const operationTypeOptions = [
  { label: '播种', value: '播种' },
  { label: '施肥', value: '施肥' },
  { label: '灌溉', value: '灌溉' },
  { label: '除草', value: '除草' },
  { label: '病虫害防治', value: '病虫害防治' },
  { label: '修剪', value: '修剪' },
  { label: '收获', value: '收获' },
  { label: '其他', value: '其他' },
]

const typeColorMap: Record<string, string> = {
  '播种': 'success',
  '施肥': 'warning',
  '灌溉': 'info',
  '除草': 'default',
  '病虫害防治': 'error',
  '修剪': 'default',
  '收获': 'success',
}

const columns: DataTableColumns<any> = [
  { title: '所属计划', key: 'planName', ellipsis: { tooltip: true } },
  {
    title: '操作类型',
    key: 'operationType',
    width: 120,
    render: (row) => h(NTag, { type: (typeColorMap[row.operationType] || 'default') as any, size: 'small', round: true }, { default: () => row.operationType }),
  },
  { title: '操作日期', key: 'operationDate', width: 110 },
  { title: '描述', key: 'description', ellipsis: { tooltip: true } },
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
    const res: any = await getOperations({ page: page.value, size: pageSize.value })
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
  formData.value = { planId: null, operationType: '', operationDate: null, description: '', remark: '' }
  showModal.value = true
}

function handleEdit(row: any) {
  isEdit.value = true
  editId = row.id
  formData.value = {
    planId: row.planId,
    operationType: row.operationType,
    operationDate: row.operationDate ? new Date(row.operationDate).getTime() : null,
    description: row.description || '',
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
      operationDate: formData.value.operationDate ? new Date(formData.value.operationDate).toISOString().split('T')[0] : null,
    }
    if (isEdit.value && editId) {
      await updateOperation(editId, payload)
      window.$message?.success('更新成功')
    } else {
      await createOperation(payload)
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
    await deleteOperation(id)
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
      <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0">农事操作记录</h2>
      <n-button type="primary" @click="handleAdd">新增操作</n-button>
    </div>

    <n-data-table :columns="columns" :data="data" :loading="loading" :bordered="false" :single-line="false" />

    <div v-if="total > pageSize" style="display: flex; justify-content: flex-end; margin-top: 16px">
      <n-pagination :page="page" :page-size="pageSize" :item-count="total" @update:page="handlePageChange" />
    </div>

    <n-modal v-model:show="showModal" :title="isEdit ? '编辑操作' : '新增操作'" preset="card" style="max-width: 500px; border-radius: 12px">
      <n-form ref="formRef" :model="formData" label-placement="left" label-width="80">
        <n-form-item label="所属计划" path="planId" :rule="{ required: true, type: 'number', message: '请选择计划' }">
          <n-select v-model:value="formData.planId" :options="planOptions" placeholder="请选择计划" filterable />
        </n-form-item>
        <n-form-item label="操作类型" path="operationType" :rule="{ required: true, message: '请选择操作类型' }">
          <n-select v-model:value="formData.operationType" :options="operationTypeOptions" placeholder="请选择操作类型" />
        </n-form-item>
        <n-form-item label="操作日期" path="operationDate" :rule="{ required: true, type: 'number', message: '请选择日期' }">
          <n-date-picker v-model:value="formData.operationDate" type="date" style="width: 100%" />
        </n-form-item>
        <n-form-item label="描述">
          <n-input v-model:value="formData.description" type="textarea" placeholder="操作描述" :rows="3" />
        </n-form-item>
        <n-form-item label="备注">
          <n-input v-model:value="formData.remark" placeholder="备注" />
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
