<template>
  <div>
    <t-card title="种植计划" :bordered="false">
      <template #actions>
        <t-button theme="primary" @click="handleAdd">
          <template #icon><t-icon name="add" /></template>
          新增计划
        </t-button>
      </template>

      <!-- 搜索栏 -->
      <t-row :gutter="16" style="margin-bottom: 16px">
        <t-col :span="3">
          <t-select v-model="searchForm.userId" placeholder="选择用户" clearable>
            <t-option v-for="u in userOptions" :key="u.id" :value="u.id" :label="u.realName || u.username" />
          </t-select>
        </t-col>
        <t-col :span="3">
          <t-select v-model="searchForm.cropId" placeholder="选择作物" clearable>
            <t-option v-for="c in cropOptions" :key="c.id" :value="c.id" :label="c.name" />
          </t-select>
        </t-col>
        <t-col :span="3">
          <t-select v-model="searchForm.status" placeholder="选择状态" clearable>
            <t-option v-for="s in statusOptions" :key="s.value" :value="s.value" :label="s.label" />
          </t-select>
        </t-col>
        <t-col :span="3">
          <t-button theme="primary" variant="outline" @click="fetchData">查询</t-button>
          <t-button variant="outline" style="margin-left: 8px" @click="handleReset">重置</t-button>
        </t-col>
      </t-row>

      <!-- 数据表格 -->
      <t-table :data="list" :columns="columns" :loading="loading" row-key="id" :pagination="pagination" @page-change="onPageChange">
        <template #status="{ row }">
          <t-tag :theme="statusTheme[row.status] || 'default'">{{ statusMap[row.status] || '未知' }}</t-tag>
        </template>
        <template #cropName="{ row }">{{ row.crop?.name || row.cropName || '-' }}</template>
        <template #plotName="{ row }">{{ row.plot?.name || row.plotName || '-' }}</template>
        <template #userName="{ row }">{{ row.user?.realName || row.userName || '-' }}</template>
        <template #operation="{ row }">
          <t-space>
            <t-link theme="primary" @click="handleEdit(row)">编辑</t-link>
            <t-popconfirm content="确定删除该计划？" @confirm="handleDelete(row)">
              <t-link theme="danger">删除</t-link>
            </t-popconfirm>
            <t-link v-if="row.status === 0" theme="warning" @click="handleReview(row, true)">通过</t-link>
            <t-link v-if="row.status === 0" theme="danger" @click="handleReview(row, false)">驳回</t-link>
            <t-link v-if="row.status === 1" theme="primary" @click="handleStart(row)">开始</t-link>
            <t-link v-if="row.status === 3" theme="success" @click="handleComplete(row)">完成</t-link>
          </t-space>
        </template>
      </t-table>
    </t-card>

    <!-- 新增/编辑弹窗 -->
    <t-dialog v-model:visible="dialogVisible" :header="isEdit ? '编辑计划' : '新增计划'" :width="650" :on-confirm="handleSubmit">
      <t-form ref="formRef" :data="formData" :rules="formRules" label-width="100px">
        <t-form-item label="计划名称" name="planName">
          <t-input v-model="formData.planName" placeholder="请输入计划名称" />
        </t-form-item>
        <t-form-item label="负责人" name="userId">
          <t-select v-model="formData.userId" placeholder="请选择负责人">
            <t-option v-for="u in userOptions" :key="u.id" :value="u.id" :label="u.realName || u.username" />
          </t-select>
        </t-form-item>
        <t-form-item label="作物" name="cropId">
          <t-select v-model="formData.cropId" placeholder="请选择作物">
            <t-option v-for="c in cropOptions" :key="c.id" :value="c.id" :label="c.name" />
          </t-select>
        </t-form-item>
        <t-form-item label="地块" name="plotId">
          <t-select v-model="formData.plotId" placeholder="请选择地块">
            <t-option v-for="p in plotOptions" :key="p.id" :value="p.id" :label="p.name" />
          </t-select>
        </t-form-item>
        <t-form-item label="计划面积(亩)" name="plannedArea">
          <t-input-number v-model="formData.plannedArea" :min="0" :decimal-places="2" placeholder="请输入面积" style="width: 100%" />
        </t-form-item>
        <t-form-item label="计划开始日期" name="plannedStartDate">
          <t-date-picker v-model="formData.plannedStartDate" placeholder="请选择日期" style="width: 100%" />
        </t-form-item>
        <t-form-item label="计划结束日期" name="plannedEndDate">
          <t-date-picker v-model="formData.plannedEndDate" placeholder="请选择日期" style="width: 100%" />
        </t-form-item>
        <t-form-item label="备注" name="description">
          <t-textarea v-model="formData.description" placeholder="请输入备注" :autosize="{ minRows: 3 }" />
        </t-form-item>
      </t-form>
    </t-dialog>
  </div>
</template>

<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, reactive, ref } from 'vue';

import { getCrops } from '@/api/crop';
import { getPlans, createPlan, updatePlan, deletePlan, reviewPlan, startPlan, completePlan } from '@/api/plan';
import { getPlots } from '@/api/plot';
import { getUsers } from '@/api/user';

const loading = ref(false);
const list = ref([]);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref();

const searchForm = reactive({ userId: undefined as number | undefined, cropId: undefined as number | undefined, status: undefined as number | undefined });

const userOptions = ref<any[]>([]);
const cropOptions = ref<any[]>([]);
const plotOptions = ref<any[]>([]);

const statusOptions = [
  { value: 0, label: '待审核' },
  { value: 1, label: '已通过' },
  { value: 2, label: '已驳回' },
  { value: 3, label: '进行中' },
  { value: 4, label: '已完成' },
];

const statusMap: Record<number, string> = { 0: '待审核', 1: '已通过', 2: '已驳回', 3: '进行中', 4: '已完成' };
const statusTheme: Record<number, 'default' | 'success' | 'danger' | 'warning' | 'primary'> = { 0: 'default', 1: 'success', 2: 'danger', 3: 'warning', 4: 'primary' };

const formData = reactive({
  id: undefined as number | undefined,
  planName: '',
  userId: undefined as number | undefined,
  cropId: undefined as number | undefined,
  plotId: undefined as number | undefined,
  plannedArea: undefined as number | undefined,
  plannedStartDate: '',
  plannedEndDate: '',
  description: '',
});

const formRules = {
  planName: [{ required: true, message: '请输入计划名称' }],
  userId: [{ required: true, message: '请选择负责人' }],
  cropId: [{ required: true, message: '请选择作物' }],
};

const columns = [
  { colKey: 'planName', title: '计划名称', width: 150 },
  { colKey: 'userName', title: '负责人', width: 100, cell: 'userName' },
  { colKey: 'cropName', title: '作物', width: 100, cell: 'cropName' },
  { colKey: 'plotName', title: '地块', width: 100, cell: 'plotName' },
  { colKey: 'plannedArea', title: '面积(亩)', width: 100 },
  { colKey: 'plannedStartDate', title: '计划开始', width: 120 },
  { colKey: 'plannedEndDate', title: '计划结束', width: 120 },
  { colKey: 'status', title: '状态', width: 100, cell: 'status' },
  { colKey: 'operation', title: '操作', width: 260, fixed: 'right' as const },
];

async function fetchData() {
  loading.value = true;
  try {
    const res: any = await getPlans({ page: pagination.current, size: pagination.pageSize, ...searchForm });
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
    const [usersRes, cropsRes, plotsRes]: any[] = await Promise.all([
      getUsers({ page: 1, size: 1000 }),
      getCrops({ page: 1, size: 1000 }),
      getPlots({ page: 1, size: 1000 }),
    ]);
    userOptions.value = usersRes.records || [];
    cropOptions.value = cropsRes.records || [];
    plotOptions.value = plotsRes.records || [];
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
  searchForm.userId = undefined;
  searchForm.cropId = undefined;
  searchForm.status = undefined;
  pagination.current = 1;
  fetchData();
}

function resetForm() {
  formData.id = undefined;
  formData.planName = '';
  formData.userId = undefined;
  formData.cropId = undefined;
  formData.plotId = undefined;
  formData.plannedArea = undefined;
  formData.plannedStartDate = '';
  formData.plannedEndDate = '';
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
      await updatePlan(formData.id!, { ...formData });
      MessagePlugin.success('更新成功');
    } else {
      await createPlan({ ...formData });
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
    await deletePlan(row.id);
    MessagePlugin.success('删除成功');
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '删除失败');
  }
}

async function handleReview(row: any, approved: boolean) {
  try {
    await reviewPlan(row.id, { status: approved ? 1 : 2 });
    MessagePlugin.success(approved ? '审核通过' : '已驳回');
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '操作失败');
  }
}

async function handleStart(row: any) {
  try {
    await startPlan(row.id);
    MessagePlugin.success('已开始执行');
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '操作失败');
  }
}

async function handleComplete(row: any) {
  try {
    await completePlan(row.id);
    MessagePlugin.success('已完成');
    fetchData();
  } catch (e: any) {
    MessagePlugin.error(e.message || '操作失败');
  }
}

onMounted(() => {
  fetchData();
  loadOptions();
});
</script>
