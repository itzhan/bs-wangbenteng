<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  NCard,
  NTag,
  NSpace,
  NInput,
  NButton,
  NSelect,
  NModal,
  NPagination,
  NEmpty,
  NSpin,
  NIcon,
} from 'naive-ui'
import { SearchOutline } from '@vicons/ionicons5'
import { getGuidances, getGuidanceById } from '@/api/guidance'
import { getCrops } from '@/api/crop'

const data = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const keyword = ref('')
const cropId = ref<number | null>(null)

const cropOptions = ref<any[]>([])
const cropMap = ref<Record<number, string>>({})

const showDetail = ref(false)
const currentItem = ref<any>(null)
const detailLoading = ref(false)

async function loadData() {
  loading.value = true
  try {
    const params: Record<string, any> = { page: page.value, size: pageSize.value }
    if (keyword.value) params.keyword = keyword.value
    if (cropId.value) params.cropId = cropId.value
    const res: any = await getGuidances(params)
    data.value = res.records || []
    total.value = res.total || 0
  } catch {
    data.value = []
  } finally {
    loading.value = false
  }
}

async function loadCropOptions() {
  try {
    const res: any = await getCrops(1, 100)
    const list = res.records || []
    cropOptions.value = [
      { label: '全部作物', value: null },
      ...list.map((c: any) => ({ label: c.name, value: c.id })),
    ]
    cropMap.value = Object.fromEntries(list.map((c: any) => [c.id, c.name]))
  } catch {
    // ignore
  }
}

async function viewDetail(id: number) {
  showDetail.value = true
  detailLoading.value = true
  try {
    currentItem.value = await getGuidanceById(id)
  } catch {
    currentItem.value = null
  } finally {
    detailLoading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadData()
}

function handlePageChange(p: number) {
  page.value = p
  loadData()
}

onMounted(() => {
  loadData()
  loadCropOptions()
})
</script>

<template>
  <div>
    <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0 0 20px">技术指导</h2>

    <!-- Filters -->
    <n-space style="margin-bottom: 20px">
      <n-input
        v-model:value="keyword"
        placeholder="搜索指导文章..."
        clearable
        style="width: 240px"
        @keydown.enter="handleSearch"
      >
        <template #prefix>
          <n-icon><SearchOutline /></n-icon>
        </template>
      </n-input>
      <n-select
        v-model:value="cropId"
        :options="cropOptions"
        placeholder="筛选作物"
        style="width: 160px"
        clearable
        @update:value="handleSearch"
      />
      <n-button type="primary" @click="handleSearch">搜索</n-button>
    </n-space>

    <n-spin :show="loading">
      <n-empty v-if="!loading && data.length === 0" description="暂无技术指导" style="padding: 60px 0" />
      <div v-else style="display: flex; flex-direction: column; gap: 12px">
        <n-card
          v-for="item in data"
          :key="item.id"
          hoverable
          style="cursor: pointer; border-radius: 10px"
          @click="viewDetail(item.id)"
        >
          <div>
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px">
              <h3 style="font-size: 16px; font-weight: 600; color: #333; margin: 0">
                {{ item.title }}
              </h3>
              <n-tag v-if="item.cropId" size="small" type="success" round>{{ cropMap[item.cropId] || '作物' }}</n-tag>
            </div>
            <p style="font-size: 13px; color: #888; margin: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">
              {{ item.content?.slice(0, 100) || '' }}
            </p>
            <div style="margin-top: 8px; font-size: 12px; color: #aaa">
              {{ item.createTime || '' }}
            </div>
          </div>
        </n-card>
      </div>
    </n-spin>

    <div v-if="total > pageSize" style="display: flex; justify-content: center; margin-top: 24px">
      <n-pagination :page="page" :page-size="pageSize" :item-count="total" @update:page="handlePageChange" />
    </div>

    <n-modal v-model:show="showDetail" preset="card" title="技术指导详情" style="max-width: 700px; border-radius: 12px">
      <n-spin :show="detailLoading">
        <template v-if="currentItem">
          <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px">
            <h2 style="font-size: 20px; font-weight: 600; margin: 0">{{ currentItem.title }}</h2>
            <n-tag v-if="currentItem.cropId" size="small" type="success" round>{{ cropMap[currentItem.cropId] || '作物' }}</n-tag>
          </div>
          <p style="font-size: 12px; color: #999; margin: 0 0 16px">
            {{ currentItem.createTime || '' }}
          </p>
          <div style="line-height: 1.8; color: #444; white-space: pre-wrap">{{ currentItem.content }}</div>
        </template>
        <n-empty v-else-if="!detailLoading" description="加载失败" />
      </n-spin>
    </n-modal>
  </div>
</template>
