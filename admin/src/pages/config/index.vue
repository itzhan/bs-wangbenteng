<template>
  <div>
    <t-card title="系统配置" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增配置
        </t-button>
      </template>

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

    <t-dialog v-model:visible="dialogVisible" :header="isEdit ? '编辑配置' : '新增配置'" :width="600" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="80px">
        <t-form-item label="配置键" name="configKey">
          <t-input v-model="formData.configKey" placeholder="请输入配置键" :disabled="isEdit" />
        </t-form-item>
        <t-form-item label="配置值" name="configValue">
          <t-input v-model="formData.configValue" placeholder="请输入配置值" />
        </t-form-item>
        <t-form-item label="说明" name="description">
          <t-textarea v-model="formData.description" placeholder="请输入说明" />
        </t-form-item>
      </t-form>
    </t-dialog>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { createConfig, deleteConfig, getConfigs, updateConfig } from '@/api/config';

const loading = ref(false);
const list = ref([]);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref();

const formData = reactive({
  id: undefined as number | undefined,
  configKey: '',
  configValue: '',
  description: '',
});

const formRules = {
  configKey: [{ required: true, message: '请输入配置键' }],
  configValue: [{ required: true, message: '请输入配置值' }],
};

const columns = [
  { colKey: 'configKey', title: '配置键', width: 200 },
  { colKey: 'configValue', title: '配置值', width: 250 },
  { colKey: 'description', title: '说明', ellipsis: true },
  { colKey: 'updateTime', title: '更新时间', width: 180 },
  { colKey: 'operation', title: '操作', width: 150, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getConfigs({ page: pagination.current, size: pagination.pageSize });
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

function resetForm() {
  formData.id = undefined;
  formData.configKey = '';
  formData.configValue = '';
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
      await updateConfig(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createConfig({ ...formData });
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
    await deleteConfig(row.id);
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
