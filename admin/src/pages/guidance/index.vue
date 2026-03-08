<template>
  <div>
    <t-card title="技术指导" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增指导
        </t-button>
      </template>

      <t-row :gutter="16" style="margin-bottom: 16px">
        <t-col :span="4">
          <t-input v-model="searchKeyword" placeholder="请输入标题关键词" clearable @enter="fetchData">
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

    <t-dialog v-model:visible="dialogVisible" :header="isEdit ? '编辑指导' : '新增指导'" :width="650" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="80px">
        <t-form-item label="标题" name="title">
          <t-input v-model="formData.title" placeholder="请输入标题" />
        </t-form-item>
        <t-form-item label="作物" name="cropId">
          <t-select v-model="formData.cropId" placeholder="请选择相关作物" clearable>
            <t-option v-for="c in cropOptions" :key="c.id" :value="c.id" :label="c.name" />
          </t-select>
        </t-form-item>
        <t-form-item label="内容" name="content">
          <t-textarea v-model="formData.content" placeholder="请输入技术指导内容" :autosize="{ minRows: 5 }" />
        </t-form-item>
      </t-form>
    </t-dialog>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { getCrops } from '@/api/crop';
import { createGuidance, deleteGuidance, getGuidances, updateGuidance } from '@/api/guidance';

const loading = ref(false);
const list = ref([]);
const searchKeyword = ref('');
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref();
const cropOptions = ref<any[]>([]);

const formData = reactive({
  id: undefined as number | undefined,
  title: '',
  cropId: undefined as number | undefined,
  content: '',
});

const formRules = {
  title: [{ required: true, message: '请输入标题' }],
  content: [{ required: true, message: '请输入内容' }],
};

const columns = [
  { colKey: 'title', title: '标题', ellipsis: true },
  { colKey: 'cropName', title: '相关作物', width: 120 },
  { colKey: 'authorName', title: '作者', width: 120 },
  { colKey: 'createTime', title: '创建时间', width: 180 },
  { colKey: 'operation', title: '操作', width: 150, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getGuidances({ page: pagination.current, size: pagination.pageSize, keyword: searchKeyword.value || undefined });
    list.value = res.records || [];
    pagination.total = res.total || 0;
  } catch (e: any) {
    MessagePlugin.error(e.message || '获取数据失败');
  } finally {
    loading.value = false;
  }
}

async function loadCrops() {
  try {
    const res: any = await getCrops({ page: 1, size: 1000 });
    cropOptions.value = res.records || [];
  } catch (e) {
    console.error('加载作物列表失败', e);
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
  formData.title = '';
  formData.cropId = undefined;
  formData.content = '';
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
      await updateGuidance(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createGuidance({ ...formData });
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
    await deleteGuidance(row.id);
    MessagePlugin.success('删除成功');
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '删除失败');
  }
}

onMounted(() => {
  fetchData();
  loadCrops();
});
</script>
