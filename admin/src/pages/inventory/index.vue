<template>
  <div>
    <t-card title="库存管理" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleOperate">
          <template #icon><t-icon name="add" /></template>
          入库/出库
        </t-button>
      </template>

      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
        <template #quantity="{ row }">
          <span :style="{ color: row.quantity <= (row.warningThreshold || 0) ? 'var(--td-error-color)' : '' }">
            {{ row.quantity }}
          </span>
        </template>
        <template #warningTag="{ row }">
          <t-tag v-if="row.quantity <= (row.warningThreshold || 0)" theme="danger" variant="light">库存预警</t-tag>
          <t-tag v-else theme="success" variant="light">正常</t-tag>
        </template>
      </t-table>
    </t-card>

    <!-- 入库/出库弹窗 -->
    <t-dialog v-model:visible="dialogVisible" header="库存操作" :width="500" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="80px">
        <t-form-item label="农资" name="materialId">
          <t-select v-model="formData.materialId" placeholder="请选择农资">
            <t-option v-for="m in materialOptions" :key="m.id" :value="m.id" :label="m.name" />
          </t-select>
        </t-form-item>
        <t-form-item label="类型" name="type">
          <t-select v-model="formData.type" placeholder="请选择操作类型">
            <t-option :value="1" label="入库" />
            <t-option :value="2" label="出库" />
          </t-select>
        </t-form-item>
        <t-form-item label="数量" name="quantity">
          <t-input-number v-model="formData.quantity" :min="1" placeholder="请输入数量" style="width: 100%" />
        </t-form-item>
        <t-form-item label="备注" name="reason">
          <t-textarea v-model="formData.reason" placeholder="请输入备注" />
        </t-form-item>
      </t-form>
    </t-dialog>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { getInventory, operate } from '@/api/inventory';
import { getMaterials } from '@/api/material';

const loading = ref(false);
const list = ref([]);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const dialogVisible = ref(false);
const formRef = ref();
const materialOptions = ref<any[]>([]);

const formData = reactive({
  materialId: undefined as number | undefined,
  type: undefined as number | undefined,
  quantity: undefined as number | undefined,
  reason: '',
});

const formRules = {
  materialId: [{ required: true, message: '请选择农资' }],
  type: [{ required: true, message: '请选择操作类型' }],
  quantity: [{ required: true, message: '请输入数量' }],
};

const columns = [
  { colKey: 'materialName', title: '农资名称', width: 150 },
  { colKey: 'materialType', title: '类型', width: 100 },
  { colKey: 'unit', title: '单位', width: 80 },
  { colKey: 'quantity', title: '库存数量', width: 120, cell: 'quantity' },
  { colKey: 'warningThreshold', title: '预警阈值', width: 100 },
  { colKey: 'warningTag', title: '状态', width: 100, cell: 'warningTag' },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getInventory({ page: pagination.current, size: pagination.pageSize });
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

function handleOperate() {
  formData.materialId = undefined;
  formData.type = undefined;
  formData.quantity = undefined;
  formData.reason = '';
  dialogVisible.value = true;
}

async function handleSubmit() {
  const valid = await formRef.value?.validate();
  if (valid !== true) return;
  try {
    await operate({
      materialId: formData.materialId!,
      type: formData.type!,
      quantity: formData.quantity!,
      reason: formData.reason || undefined,
    });
    MessagePlugin.success('操作成功');
    dialogVisible.value = false;
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '操作失败');
  }
}

onMounted(() => {
  fetchData();
  loadMaterials();
});
</script>
