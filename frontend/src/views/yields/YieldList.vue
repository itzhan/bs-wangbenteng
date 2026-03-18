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
} from 'naive-ui'
import type { DataTableColumns, FormInst } from 'naive-ui'
import { getYields, createYield, updateYield, deleteYield } from '@/api/yield'
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
  harvestDate: null,
  actualYield: null,
  qualityLevel: '',
  remark: '',
})
let editId: number | null = null

const planOptions = ref<any[]>([])
const qualityOptions = [
  { label: '优', value: '优' },
  { label: '良', value: '良' },
  { label: '中', value: '中' },
  { label: '差', value: '差' },
]

const planMap = ref<Record<number, string>>({})

const columns: DataTableColumns<any> = [
  {
    title: '所属计划',
    key: 'planId',
    ellipsis: { tooltip: true },
    render: (row) => planMap.value[row.planId] || `计划#${row.planId}`,
  },
  { title: '收获日期', key: 'harvestDate', width: 110 },
  { title: '产量(kg)', key: 'quantity', width: 100, render: (row) => row.quantity ?? row.actualYield ?? '-' },
  { title: '质量等级', key: 'quality', width: 90, render: (row) => row.quality || row.qualityLevel || '-' },
  { title: '备注', key: 'notes', ellipsis: { tooltip: true }, render: (row) => row.notes || row.remark || '-' },
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
    const res: any = await getYields({ page: page.value, size: pageSize.value })
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
    const list = Array.isArray(res) ? res : (res.records || [])
    planOptions.value = list.map((p: any) => ({ label: p.planName, value: p.id }))
    planMap.value = Object.fromEntries(list.map((p: any) => [p.id, p.planName]))
  } catch {
    // ignore
  }
}

function handleAdd() {
  isEdit.value = false
  editId = null
  formData.value = { planId: null, harvestDate: null, actualYield: null, qualityLevel: '', remark: '' }
  showModal.value = true
}

function handleEdit(row: any) {
  isEdit.value = true
  editId = row.id
  formData.value = {
    planId: row.planId,
    harvestDate: row.harvestDate ? new Date(row.harvestDate).getTime() : null,
    actualYield: row.quantity ?? row.actualYield,
    qualityLevel: row.quality || row.qualityLevel || '',
    remark: row.notes || row.remark || '',
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
      planId: formData.value.planId,
      quantity: formData.value.actualYield,
      quality: formData.value.qualityLevel,
      notes: formData.value.remark,
      harvestDate: formData.value.harvestDate ? new Date(formData.value.harvestDate).toISOString().split('T')[0] : null,
    }
    if (isEdit.value && editId) {
      await updateYield(editId, payload)
      window.$message?.success('更新成功')
    } else {
      await createYield(payload)
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
    await deleteYield(id)
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
      <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0">产量记录</h2>
      <n-button type="primary" @click="handleAdd">新增记录</n-button>
    </div>

    <n-data-table :columns="columns" :data="data" :loading="loading" :bordered="false" :single-line="false" />

    <div v-if="total > pageSize" style="display: flex; justify-content: flex-end; margin-top: 16px">
      <n-pagination :page="page" :page-size="pageSize" :item-count="total" @update:page="handlePageChange" />
    </div>

    <n-modal v-model:show="showModal" :title="isEdit ? '编辑产量记录' : '新增产量记录'" preset="card" style="max-width: 500px; border-radius: 12px">
      <n-form ref="formRef" :model="formData" label-placement="left" label-width="80">
        <n-form-item label="所属计划" path="planId" :rule="{ required: true, type: 'number', message: '请选择计划' }">
          <n-select v-model:value="formData.planId" :options="planOptions" placeholder="请选择计划" filterable />
        </n-form-item>
        <n-form-item label="收获日期" path="harvestDate" :rule="{ required: true, type: 'number', message: '请选择日期' }">
          <n-date-picker v-model:value="formData.harvestDate" type="date" style="width: 100%" />
        </n-form-item>
        <n-form-item label="产量(kg)" path="actualYield" :rule="{ required: true, type: 'number', message: '请输入产量' }">
          <n-input-number v-model:value="formData.actualYield" placeholder="产量" :min="0" style="width: 100%" />
        </n-form-item>
        <n-form-item label="质量等级">
          <n-select v-model:value="formData.qualityLevel" :options="qualityOptions" placeholder="请选择" clearable />
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
