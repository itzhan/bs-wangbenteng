<template>
  <div>
    <t-card title="成本记录" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增记录
        </t-button>
      </template>

      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
        <template #planName="{ row }">{{ row.plan?.planName || row.planName || '-' }}</template>
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
        <t-form-item label="成本类型" name="costType">
          <t-select v-model="formData.costType" placeholder="请选择类型">
            <t-option label="种子" value="种子" />
            <t-option label="化肥" value="化肥" />
            <t-option label="农药" value="农药" />
            <t-option label="人工" value="人工" />
            <t-option label="机械" value="机械" />
            <t-option label="灌溉" value="灌溉" />
            <t-option label="其他" value="其他" />
          </t-select>
        </t-form-item>
        <t-form-item label="金额(元)" name="amount">
          <t-input-number v-model="formData.amount" :min="0" :decimal-places="2" placeholder="请输入金额" style="width: 100%" />
        </t-form-item>
        <t-form-item label="费用日期" name="costDate">
          <t-date-picker v-model="formData.costDate" placeholder="请选择日期" style="width: 100%" />
        </t-form-item>
        <t-form-item label="备注" name="remark">
          <t-textarea v-model="formData.remark" placeholder="请输入备注" />
        </t-form-item>
      </t-form>
    </t-dialog>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { createCost, deleteCost, getCosts, updateCost } from '@/api/cost';
import { getPlans } from '@/api/plan';

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
  costType: '',
  amount: undefined as number | undefined,
  costDate: '',
  remark: '',
});

const formRules = {
  planId: [{ required: true, message: '请选择种植计划' }],
  costType: [{ required: true, message: '请选择成本类型' }],
  amount: [{ required: true, message: '请输入金额' }],
};

const columns = [
  { colKey: 'planName', title: '种植计划', width: 150, cell: 'planName' },
  { colKey: 'costType', title: '成本类型', width: 100 },
  { colKey: 'amount', title: '金额(元)', width: 120 },
  { colKey: 'costDate', title: '费用日期', width: 120 },
  { colKey: 'remark', title: '备注', ellipsis: true },
  { colKey: 'operation', title: '操作', width: 150, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getCosts({ page: pagination.current, size: pagination.pageSize });
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
  formData.costType = '';
  formData.amount = undefined;
  formData.costDate = '';
  formData.remark = '';
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
      await updateCost(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createCost({ ...formData });
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
    await deleteCost(row.id);
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
