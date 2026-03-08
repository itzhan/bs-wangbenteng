<template>
  <div>
    <t-card title="作物管理" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增作物
        </t-button>
      </template>

      <!-- 搜索栏 -->
      <t-row :gutter="16" style="margin-bottom: 16px">
        <t-col :span="4">
          <t-input v-model="searchKeyword" placeholder="请输入作物名称" clearable @enter="fetchData">
            <template #suffix-icon><t-icon name="search" /></template>
          </t-input>
        </t-col>
        <t-col :span="2">
          <t-button theme="primary" variant="outline" @click="fetchData">查询</t-button>
          <t-button variant="outline" style="margin-left: 8px" @click="handleReset">重置</t-button>
        </t-col>
      </t-row>

      <!-- 数据表格 -->
      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
        <template #operation="{ row }">
          <t-space>
            <t-link theme="primary" @click="handleEdit(row)">编辑</t-link>
            <t-popconfirm content="确定删除该作物？" @confirm="handleDelete(row)">
              <t-link theme="danger">删除</t-link>
            </t-popconfirm>
          </t-space>
        </template>
      </t-table>
    </t-card>

    <!-- 新增/编辑弹窗 -->
    <t-dialog v-model:visible="dialogVisible" :header="isEdit ? '编辑作物' : '新增作物'" :width="600" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="100px">
        <t-form-item label="作物名称" name="name">
          <t-input v-model="formData.name" placeholder="请输入作物名称" />
        </t-form-item>
        <t-form-item label="品种" name="variety">
          <t-input v-model="formData.variety" placeholder="请输入品种" />
        </t-form-item>
        <t-form-item label="生长周期(天)" name="growthCycle">
          <t-input-number v-model="formData.growthCycle" :min="1" placeholder="请输入生长周期" style="width: 100%" />
        </t-form-item>
        <t-form-item label="种植季节" name="plantingSeason">
          <t-input v-model="formData.plantingSeason" placeholder="请输入种植季节" />
        </t-form-item>
        <t-form-item label="适宜区域" name="suitableRegion">
          <t-input v-model="formData.suitableRegion" placeholder="请输入适宜区域" />
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

import { createCrop, deleteCrop, getCrops, updateCrop } from '@/api/crop';

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
  variety: '',
  growthCycle: undefined as number | undefined,
  plantingSeason: '',
  suitableRegion: '',
  description: '',
});

const formRules = {
  name: [{ required: true, message: '请输入作物名称' }],
};

const columns = [
  { colKey: 'name', title: '作物名称', width: 150 },
  { colKey: 'variety', title: '品种', width: 150 },
  { colKey: 'growthCycle', title: '生长周期(天)', width: 120 },
  { colKey: 'plantingSeason', title: '种植季节', width: 120 },
  { colKey: 'suitableRegion', title: '适宜区域', width: 150 },
  { colKey: 'operation', title: '操作', width: 150, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getCrops({ page: pagination.current, size: pagination.pageSize, keyword: searchKeyword.value || undefined });
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
  formData.variety = '';
  formData.growthCycle = undefined;
  formData.plantingSeason = '';
  formData.suitableRegion = '';
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
      await updateCrop(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createCrop({ ...formData });
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
    await deleteCrop(row.id);
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
