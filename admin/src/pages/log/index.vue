<template>
  <div>
    <t-card title="系统日志" :bordered="false">
      <t-row :gutter="16" style="margin-bottom: 16px">
        <t-col :span="3">
          <t-input v-model="searchForm.username" placeholder="操作用户" clearable />
        </t-col>
        <t-col :span="3">
          <t-input v-model="searchForm.module" placeholder="操作模块" clearable />
        </t-col>
        <t-col :span="3">
          <t-date-picker v-model="searchForm.startDate" placeholder="开始日期" style="width: 100%" />
        </t-col>
        <t-col :span="3">
          <t-date-picker v-model="searchForm.endDate" placeholder="结束日期" style="width: 100%" />
        </t-col>
      </t-row>
      <t-row :gutter="16" style="margin-bottom: 16px">
        <t-col :span="3">
          <t-button theme="primary" variant="outline" @click="fetchData">查询</t-button>
          <t-button variant="outline" style="margin-left: 8px" @click="handleReset">重置</t-button>
        </t-col>
      </t-row>

      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
      </t-table>
    </t-card>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { getLogs } from '@/api/log';

const loading = ref(false);
const list = ref([]);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });

const searchForm = reactive({
  username: '',
  module: '',
  startDate: '',
  endDate: '',
});

const columns = [
  { colKey: 'username', title: '操作用户', width: 120 },
  { colKey: 'module', title: '操作模块', width: 120 },
  { colKey: 'action', title: '操作内容', ellipsis: true },
  { colKey: 'ip', title: 'IP地址', width: 140 },
  { colKey: 'createTime', title: '操作时间', width: 180 },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getLogs({
      page: pagination.current,
      size: pagination.pageSize,
      username: searchForm.username || undefined,
      module: searchForm.module || undefined,
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

function onPageChange(pageInfo: { current: number; pageSize: number }) {
  pagination.current = pageInfo.current;
  pagination.pageSize = pageInfo.pageSize;
  fetchData();
}

function handleReset() {
  searchForm.username = '';
  searchForm.module = '';
  searchForm.startDate = '';
  searchForm.endDate = '';
  pagination.current = 1;
  fetchData();
}

onMounted(() => {
  fetchData();
});
</script>
