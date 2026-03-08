<template>
  <div>
    <t-card title="公告管理" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增公告
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
        <template #status="{ row }">
          <t-tag :theme="row.status === 1 ? 'success' : 'default'">{{ row.status === 1 ? '已发布' : '草稿' }}</t-tag>
        </template>
        <template #operation="{ row }">
          <t-space>
            <t-link theme="primary" @click="handleEdit(row)">编辑</t-link>
            <t-link v-if="row.status !== 1" theme="warning" @click="handlePublish(row)">发布</t-link>
            <t-popconfirm content="确定删除？" @confirm="handleDelete(row)">
              <t-link theme="danger">删除</t-link>
            </t-popconfirm>
          </t-space>
        </template>
      </t-table>
    </t-card>

    <t-dialog v-model:visible="dialogVisible" :header="isEdit ? '编辑公告' : '新增公告'" :width="650" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="80px">
        <t-form-item label="标题" name="title">
          <t-input v-model="formData.title" placeholder="请输入标题" />
        </t-form-item>
        <t-form-item label="内容" name="content">
          <t-textarea v-model="formData.content" placeholder="请输入公告内容" :autosize="{ minRows: 5 }" />
        </t-form-item>
      </t-form>
    </t-dialog>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { createAnnouncement, deleteAnnouncement, getAnnouncements, publishAnnouncement, updateAnnouncement } from '@/api/announcement';

const loading = ref(false);
const list = ref([]);
const searchKeyword = ref('');
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref();

const formData = reactive({
  id: undefined as number | undefined,
  title: '',
  content: '',
});

const formRules = {
  title: [{ required: true, message: '请输入标题' }],
  content: [{ required: true, message: '请输入内容' }],
};

const columns = [
  { colKey: 'title', title: '标题', ellipsis: true },
  { colKey: 'authorName', title: '作者', width: 120 },
  { colKey: 'status', title: '状态', width: 100, cell: 'status' },
  { colKey: 'createTime', title: '创建时间', width: 180 },
  { colKey: 'operation', title: '操作', width: 200, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getAnnouncements({ page: pagination.current, size: pagination.pageSize, keyword: searchKeyword.value || undefined });
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
  formData.title = '';
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
      await updateAnnouncement(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createAnnouncement({ ...formData });
      MessagePlugin.success('创建成功');
    }
    dialogVisible.value = false;
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '操作失败');
  }
}

async function handlePublish(row: any) {
  try {
    await publishAnnouncement(row.id);
    MessagePlugin.success('发布成功');
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '发布失败');
  }
}

async function handleDelete(row: any) {
  try {
    await deleteAnnouncement(row.id);
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
