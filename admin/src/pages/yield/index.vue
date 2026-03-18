<template>
  <div>
    <t-card title="产量记录" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增记录
        </t-button>
      </template>

      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
        <template #planName="{ row }">{{ row.plan?.planName || row.planName || '-' }}</template>
        <template #cropName="{ row }">{{ row.crop?.name || row.cropName || '-' }}</template>
        <template #operation="{ row }">
          <t-space>
            <t-link theme="primary" @click="handleEdit(row)">编辑</t-link>
            <t-popconfirm content="确定删除？" @confirm="handleDelete(row)">
              <t-link theme="danger">删除</t-link>
            </t-popconfirm>
          </t-space>
        </template>
      </t-table>
    </t-card>

    <t-dialog v-model:visible="dialogVisible" :header="isEdit ? '编辑记录' : '新增记录'" :width="600" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="100px">
        <t-form-item label="种植计划" name="planId">
          <t-select v-model="formData.planId" placeholder="请选择种植计划">
            <t-option v-for="p in planOptions" :key="p.id" :value="p.id" :label="p.planName" />
          </t-select>
        </t-form-item>
        <t-form-item label="产量(kg)" name="quantity">
          <t-input-number v-model="formData.quantity" :min="0" :decimal-places="2" placeholder="请输入产量" style="width: 100%" />
        </t-form-item>
        <t-form-item label="收获日期" name="harvestDate">
          <t-date-picker v-model="formData.harvestDate" placeholder="请选择日期" style="width: 100%" />
        </t-form-item>
        <t-form-item label="备注" name="notes">
          <t-textarea v-model="formData.notes" placeholder="请输入备注" />
        </t-form-item>
      </t-form>
    </t-dialog>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { getPlans } from '@/api/plan';
import { createYield, deleteYield, getYields, updateYield } from '@/api/yield';

const loading = ref(false);
const list = ref([]);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref();
const planOptions = ref<any[]>([]);

const formData = reactive({
  id: undefined as number | undefined,
  planId: undefined as number | undefined,
  quantity: undefined as number | undefined,
  harvestDate: '',
  notes: '',
});

const formRules = {
  planId: [{ required: true, message: '请选择种植计划' }],
  quantity: [{ required: true, message: '请输入产量' }],
};

const columns = [
  { colKey: 'planName', title: '种植计划', width: 150, cell: 'planName' },
  { colKey: 'cropName', title: '作物', width: 120, cell: 'cropName' },
  { colKey: 'quantity', title: '产量(kg)', width: 120 },
  { colKey: 'harvestDate', title: '收获日期', width: 120 },
  { colKey: 'notes', title: '备注', ellipsis: true },
  { colKey: 'operation', title: '操作', width: 150, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getYields({ page: pagination.current, size: pagination.pageSize });
    list.value = res.records || [];
    pagination.total = res.total || 0;
  } catch (e: any) {
    MessagePlugin.error(e.message || '获取数据失败');
  } finally {
    loading.value = false;
  }
}

async function loadOptions() {
  try {
    const res: any = await getPlans({ page: 1, size: 1000 });
    planOptions.value = res.records || [];
  } catch (e) {
    console.error('加载选项失败', e);
  }
}

function onPageChange(pageInfo: { current: number; pageSize: number }) {
  pagination.current = pageInfo.current;
  pagination.pageSize = pageInfo.pageSize;
  fetchData();
}

function resetForm() {
  formData.id = undefined;
  formData.planId = undefined;
  formData.quantity = undefined;
  formData.harvestDate = '';
  formData.notes = '';
}

function handleAdd() {
  isEdit.value = false;
  resetForm();
  dialogVisible.value = true;
}

function handleEdit(row: any) {
  isEdit.value = true;
  Object.assign(formData, row);
  dialogVisible.value = true;
}

async function handleSubmit() {
  const valid = await formRef.value?.validate();
  if (valid !== true) return;
  try {
    if (isEdit.value) {
      await updateYield(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createYield({ ...formData });
      MessagePlugin.success('创建成功');
    }
    dialogVisible.value = false;
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '操作失败');
  }
}

async function handleDelete(row: any) {
  try {
    await deleteYield(row.id);
    MessagePlugin.success('删除成功');
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '删除失败');
  }
}

onMounted(() => {
  fetchData();
  loadOptions();
});
</script>
