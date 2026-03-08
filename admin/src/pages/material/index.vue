<template>
  <div>
    <t-card title="农资信息" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增农资
        </t-button>
      </template>

      <t-row :gutter="16" style="margin-bottom: 16px">
        <t-col :span="4">
          <t-input v-model="searchKeyword" placeholder="请输入农资名称" clearable @enter="fetchData">
            <template #suffix-icon><t-icon name="search" /></template>
          </t-input>
        </t-col>
        <t-col :span="2">
          <t-button theme="primary" variant="outline" @click="fetchData">查询</t-button>
          <t-button variant="outline" style="margin-left: 8px" @click="handleReset">重置</t-button>
        </t-col>
      </t-row>

      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
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

    <t-dialog v-model:visible="dialogVisible" :header="isEdit ? '编辑农资' : '新增农资'" :width="600" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="100px">
        <t-form-item label="名称" name="name">
          <t-input v-model="formData.name" placeholder="请输入名称" />
        </t-form-item>
        <t-form-item label="类型" name="type">
          <t-select v-model="formData.type" placeholder="请选择类型">
            <t-option label="种子" value="种子" />
            <t-option label="化肥" value="化肥" />
            <t-option label="农药" value="农药" />
            <t-option label="农具" value="农具" />
            <t-option label="其他" value="其他" />
          </t-select>
        </t-form-item>
        <t-form-item label="规格" name="specification">
          <t-input v-model="formData.specification" placeholder="请输入规格" />
        </t-form-item>
        <t-form-item label="单位" name="unit">
          <t-input v-model="formData.unit" placeholder="请输入单位（如kg、袋、瓶）" />
        </t-form-item>
        <t-form-item label="单价" name="price">
          <t-input-number v-model="formData.price" :min="0" :decimal-places="2" placeholder="请输入单价" style="width: 100%" />
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

import { createMaterial, deleteMaterial, getMaterials, updateMaterial } from '@/api/material';

const loading = ref(false);
const list = ref([]);
const searchKeyword = ref('');
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref();
const formData = reactive({
  id: undefined as number | undefined,
  name: '',
  type: '',
  specification: '',
  unit: '',
  price: undefined as number | undefined,
  description: '',
});

const formRules = {
  name: [{ required: true, message: '请输入名称' }],
  type: [{ required: true, message: '请选择类型' }],
};

const columns = [
  { colKey: 'name', title: '名称', width: 150 },
  { colKey: 'type', title: '类型', width: 100 },
  { colKey: 'specification', title: '规格', width: 120 },
  { colKey: 'unit', title: '单位', width: 80 },
  { colKey: 'price', title: '单价(元)', width: 100 },
  { colKey: 'description', title: '描述', ellipsis: true },
  { colKey: 'operation', title: '操作', width: 150, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getMaterials({ page: pagination.current, size: pagination.pageSize, keyword: searchKeyword.value || undefined });
    list.value = res.records || [];
    pagination.total = res.total || 0;
  } catch (e: any) {
    MessagePlugin.error(e.message || '获取数据失败');
  } finally {
    loading.value = false;
  }
}

function onPageChange(pageInfo: { current: number; pageSize: number }) {
  pagination.current = pageInfo.current;
  pagination.pageSize = pageInfo.pageSize;
  fetchData();
}

function handleReset() {
  searchKeyword.value = '';
  pagination.current = 1;
  fetchData();
}

function resetForm() {
  formData.id = undefined;
  formData.name = '';
  formData.type = '';
  formData.specification = '';
  formData.unit = '';
  formData.price = undefined;
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
      await updateMaterial(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createMaterial({ ...formData });
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
    await deleteMaterial(row.id);
    MessagePlugin.success('删除成功');
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '删除失败');
  }
}

onMounted(() => {
  fetchData();
});
</script>
