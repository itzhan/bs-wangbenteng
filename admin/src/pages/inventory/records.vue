<template>
  <div>
    <t-card title="库存记录" :bordered="false">
      <t-row :gutter="16" style="margin-bottom: 16px">
        <t-col :span="3">
          <t-select v-model="searchForm.materialId" placeholder="选择农资" clearable>
            <t-option v-for="m in materialOptions" :key="m.id" :value="m.id" :label="m.name" />
          </t-select>
        </t-col>
        <t-col :span="3">
          <t-select v-model="searchForm.type" placeholder="操作类型" clearable>
            <t-option :value="1" label="入库" />
            <t-option :value="2" label="出库" />
          </t-select>
        </t-col>
        <t-col :span="3">
          <t-button theme="primary" variant="outline" @click="fetchData">查询</t-button>
          <t-button variant="outline" style="margin-left: 8px" @click="handleReset">重置</t-button>
        </t-col>
      </t-row>

      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
        <template #type="{ row }">
          <t-tag :theme="row.type === 1 ? 'success' : 'warning'">{{ row.type === 1 ? '入库' : '出库' }}</t-tag>
        </template>
      </t-table>
    </t-card>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { getRecords } from '@/api/inventory';
import { getMaterials } from '@/api/material';

const loading = ref(false);
const list = ref([]);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const materialOptions = ref<any[]>([]);

const searchForm = reactive({
  materialId: undefined as number | undefined,
  type: undefined as number | undefined,
});

const columns = [
  { colKey: 'materialName', title: '农资名称', width: 150 },
  { colKey: 'type', title: '操作类型', width: 100, cell: 'type' },
  { colKey: 'quantity', title: '数量', width: 100 },
  { colKey: 'operatorName', title: '操作人', width: 120 },
  { colKey: 'remark', title: '备注', ellipsis: true },
  { colKey: 'createTime', title: '操作时间', width: 180 },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getRecords({ page: pagination.current, size: pagination.pageSize, ...searchForm });
    list.value = res.records || [];
    pagination.total = res.total || 0;
  } catch (e: any) {
    MessagePlugin.error(e.message || '获取数据失败');
  } finally {
    loading.value = false;
  }
}

async function loadMaterials() {
  try {
    const res: any = await getMaterials({ page: 1, size: 1000 });
    materialOptions.value = res.records || [];
  } catch (e) {
    console.error('加载农资列表失败', e);
  }
}

function onPageChange(pageInfo: { current: number; pageSize: number }) {
  pagination.current = pageInfo.current;
  pagination.pageSize = pageInfo.pageSize;
  fetchData();
}

function handleReset() {
  searchForm.materialId = undefined;
  searchForm.type = undefined;
  pagination.current = 1;
  fetchData();
}

onMounted(() => {
  fetchData();
  loadMaterials();
});
</script>
