<template>
  <div>
    <t-card title="田间作业" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增作业
        </t-button>
      </template>

      <!-- 搜索栏 -->
      <t-row :gutter="16" style="margin-bottom: 16px">
        <t-col :span="3">
          <t-select v-model="searchForm.operationType" placeholder="作业类型" clearable>
            <t-option v-for="t in typeOptions" :key="t.value" :value="t.value" :label="t.label" />
          </t-select>
        </t-col>
        <t-col :span="3">
          <t-date-picker v-model="searchForm.startDate" placeholder="开始日期" style="width: 100%" />
        </t-col>
        <t-col :span="3">
          <t-date-picker v-model="searchForm.endDate" placeholder="结束日期" style="width: 100%" />
        </t-col>
        <t-col :span="3">
          <t-button theme="primary" variant="outline" @click="fetchData">查询</t-button>
          <t-button variant="outline" style="margin-left: 8px" @click="handleReset">重置</t-button>
        </t-col>
      </t-row>

      <!-- 数据表格 -->
      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
        <template #operationType="{ row }">
          <t-tag>{{ typeMap[row.operationType] || '其他' }}</t-tag>
        </template>
        <template #userName="{ row }">{{ row.user?.realName || row.userName || '-' }}</template>
        <template #planName="{ row }">{{ row.plan?.planName || row.planName || '-' }}</template>
        <template #operation="{ row }">
          <t-space>
            <t-link theme="primary" @click="handleEdit(row)">编辑</t-link>
            <t-popconfirm content="确定删除该记录？" @confirm="handleDelete(row)">
              <t-link theme="danger">删除</t-link>
            </t-popconfirm>
          </t-space>
        </template>
      </t-table>
    </t-card>

    <!-- 新增/编辑弹窗 -->
    <t-dialog v-model:visible="dialogVisible" :header="isEdit ? '编辑作业' : '新增作业'" :width="600" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="100px">
        <t-form-item label="种植计划" name="planId">
          <t-select v-model="formData.planId" placeholder="请选择种植计划">
            <t-option v-for="p in planOptions" :key="p.id" :value="p.id" :label="p.planName" />
          </t-select>
        </t-form-item>
        <t-form-item label="作业类型" name="operationType">
          <t-select v-model="formData.operationType" placeholder="请选择作业类型">
            <t-option v-for="t in typeOptions" :key="t.value" :value="t.value" :label="t.label" />
          </t-select>
        </t-form-item>
        <t-form-item label="作业日期" name="operationDate">
          <t-date-picker v-model="formData.operationDate" placeholder="请选择日期" style="width: 100%" />
        </t-form-item>
        <t-form-item label="描述" name="description">
          <t-textarea v-model="formData.description" placeholder="请输入描述" :autosize="{ minRows: 3 }" />
        </t-form-item>
      </t-form>
    </t-dialog>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { createOperation, deleteOperation, getOperations, updateOperation } from '@/api/operation';
import { getPlans } from '@/api/plan';

const loading = ref(false);
const list = ref([]);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref();

const planOptions = ref<any[]>([]);

const typeOptions = [
  { value: 1, label: '灌溉' },
  { value: 2, label: '施肥' },
  { value: 3, label: '打药' },
  { value: 4, label: '除草' },
  { value: 5, label: '收获' },
  { value: 6, label: '其他' },
];
const typeMap: Record<number, string> = { 1: '灌溉', 2: '施肥', 3: '打药', 4: '除草', 5: '收获', 6: '其他' };

const searchForm = reactive({
  operationType: undefined as number | undefined,
  startDate: '',
  endDate: '',
});

const formData = reactive({
  id: undefined as number | undefined,
  planId: undefined as number | undefined,
  operationType: undefined as number | undefined,
  operationDate: '',
  description: '',
});

const formRules = {
  planId: [{ required: true, message: '请选择种植计划' }],
  operationType: [{ required: true, message: '请选择作业类型' }],
  operationDate: [{ required: true, message: '请选择作业日期' }],
};

const columns = [
  { colKey: 'planName', title: '种植计划', width: 150, cell: 'planName' },
  { colKey: 'userName', title: '操作人', width: 100, cell: 'userName' },
  { colKey: 'operationType', title: '作业类型', width: 100, cell: 'operationType' },
  { colKey: 'operationDate', title: '作业日期', width: 120 },
  { colKey: 'description', title: '描述', ellipsis: true },
  { colKey: 'operation', title: '操作', width: 150, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getOperations({
      page: pagination.current,
      size: pagination.pageSize,
      ...searchForm,
      startDate: searchForm.startDate || undefined,
      endDate: searchForm.endDate || undefined,
    });
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

function handleReset() {
  searchForm.operationType = undefined;
  searchForm.startDate = '';
  searchForm.endDate = '';
  pagination.current = 1;
  fetchData();
}

function resetForm() {
  formData.id = undefined;
  formData.planId = undefined;
  formData.operationType = undefined;
  formData.operationDate = '';
  formData.description = '';
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
      await updateOperation(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createOperation({ ...formData });
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
    await deleteOperation(row.id);
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
