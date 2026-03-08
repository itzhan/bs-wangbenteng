<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  NGrid,
  NGi,
  NCard,
  NInput,
  NButton,
  NSpace,
  NTag,
  NModal,
  NDescriptions,
  NDescriptionsItem,
  NEmpty,
  NSpin,
  NPagination,
  NIcon,
} from 'naive-ui'
import { SearchOutline } from '@vicons/ionicons5'
import { Wheat } from 'lucide-vue-next'
import { getCrops, getCropById } from '@/api/crop'

const crops = ref<any[]>([])
const loading = ref(false)
const keyword = ref('')
const page = ref(1)
const pageSize = ref(12)
const total = ref(0)

const showDetail = ref(false)
const currentCrop = ref<any>(null)
const detailLoading = ref(false)

const fallbackCropImage =
  'https://images.unsplash.com/photo-1429087969512-1e85aab2683d?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHx3aGVhdCUyMGZpZWxkfGVufDB8fHx8MTc2MTg0MzM0MXww&ixlib=rb-4.1.0&fit=fillmax&h=320&w=320'

const cropImageMap: Array<{ keywords: string[]; image: string }> = [
  {
    keywords: ['水稻', '稻', 'rice'],
    image:
      'https://images.unsplash.com/photo-1574691250077-03a929faece5?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHxyaWNlJTIwZmllbGR8ZW58MHx8fHwxNzYxODQzMzEyfDA&ixlib=rb-4.1.0&fit=fillmax&h=320&w=320',
  },
  {
    keywords: ['小麦', '麦', 'wheat'],
    image:
      'https://images.unsplash.com/photo-1429087969512-1e85aab2683d?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHx3aGVhdCUyMGZpZWxkfGVufDB8fHx8MTc2MTg0MzM0MXww&ixlib=rb-4.1.0&fit=fillmax&h=320&w=320',
  },
  {
    keywords: ['玉米', 'corn', 'maize'],
    image:
      'https://images.unsplash.com/photo-1663255743274-1f9f3f95ec03?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHxjb3JuJTIwZmllbGR8ZW58MHx8fHwxNzYxODQ0MzQxfDA&ixlib=rb-4.1.0&fit=fillmax&h=320&w=320',
  },
  {
    keywords: ['蔬菜', '番茄', '温室', 'vegetable', 'tomato'],
    image:
      'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHxncmVlbmhvdXNlfGVufDB8fHx8MTc2MTg0MzM0OXww&ixlib=rb-4.1.0&fit=fillmax&h=320&w=320',
  },
]

function getCropImage(crop: any) {
  const text = `${crop?.name || ''} ${crop?.category || ''}`.toLowerCase()
  const matched = cropImageMap.find((item) => item.keywords.some((keyword) => text.includes(keyword)))
  return matched?.image || fallbackCropImage
}

async function loadCrops() {
  loading.value = true
  try {
    const data: any = await getCrops(page.value, pageSize.value, keyword.value || undefined)
    crops.value = data.records || []
    total.value = data.total || 0
  } catch {
    crops.value = []
  } finally {
    loading.value = false
  }
}

async function viewDetail(id: number) {
  showDetail.value = true
  detailLoading.value = true
  try {
    currentCrop.value = await getCropById(id)
  } catch {
    currentCrop.value = null
  } finally {
    detailLoading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadCrops()
}

function handlePageChange(p: number) {
  page.value = p
  loadCrops()
}

onMounted(() => {
  loadCrops()
})
</script>

<template>
  <div>
    <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0 0 20px">作物品种</h2>

    <!-- Search -->
    <n-space style="margin-bottom: 20px">
      <n-input
        v-model:value="keyword"
        placeholder="搜索作物名称..."
        clearable
        style="width: 280px"
        @keydown.enter="handleSearch"
      >
        <template #prefix>
          <n-icon><SearchOutline /></n-icon>
        </template>
      </n-input>
      <n-button type="primary" @click="handleSearch">搜索</n-button>
    </n-space>

    <!-- Crop Grid -->
    <n-spin :show="loading">
      <n-empty v-if="!loading && crops.length === 0" description="暂无作物数据" style="padding: 60px 0" />
      <n-grid v-else :x-gap="16" :y-gap="16" cols="1 s:2 m:3 l:4" responsive="screen">
        <n-gi v-for="crop in crops" :key="crop.id">
          <n-card hoverable style="cursor: pointer; border-radius: 12px" @click="viewDetail(crop.id)">
            <div style="text-align: center; padding: 8px 0">
              <div class="crop-media">
                <img class="crop-image" :src="getCropImage(crop)" :alt="`${crop.name}图片`" loading="lazy" />
                <div class="crop-icon-badge" aria-hidden="true">
                  <n-icon :size="18">
                    <Wheat />
                  </n-icon>
                </div>
              </div>
              <h3 style="font-size: 16px; font-weight: 600; color: #333; margin: 0 0 6px">
                {{ crop.name }}
              </h3>
              <n-tag v-if="crop.category" size="small" type="success" round>
                {{ crop.category }}
              </n-tag>
              <p style="font-size: 13px; color: #888; margin: 8px 0 0; line-height: 1.5; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical">
                {{ crop.description || '暂无描述' }}
              </p>
            </div>
          </n-card>
        </n-gi>
      </n-grid>
    </n-spin>

    <!-- Pagination -->
    <div v-if="total > pageSize" style="display: flex; justify-content: center; margin-top: 24px">
      <n-pagination
        :page="page"
        :page-size="pageSize"
        :item-count="total"
        @update:page="handlePageChange"
      />
    </div>

    <!-- Detail Modal -->
    <n-modal v-model:show="showDetail" preset="card" title="作物详情" style="max-width: 560px; border-radius: 12px">
      <n-spin :show="detailLoading">
        <template v-if="currentCrop">
          <n-descriptions :column="1" label-placement="left" bordered>
            <n-descriptions-item label="作物名称">{{ currentCrop.name }}</n-descriptions-item>
            <n-descriptions-item label="分类">{{ currentCrop.category || '-' }}</n-descriptions-item>
            <n-descriptions-item label="生长周期">{{ currentCrop.growthCycle ? `${currentCrop.growthCycle}天` : '-' }}</n-descriptions-item>
            <n-descriptions-item label="适宜温度">{{ currentCrop.suitableTemp || '-' }}</n-descriptions-item>
            <n-descriptions-item label="适宜湿度">{{ currentCrop.suitableHumidity || '-' }}</n-descriptions-item>
            <n-descriptions-item label="描述">{{ currentCrop.description || '-' }}</n-descriptions-item>
            <n-descriptions-item label="种植建议">{{ currentCrop.plantingAdvice || '-' }}</n-descriptions-item>
          </n-descriptions>
        </template>
        <n-empty v-else-if="!detailLoading" description="加载失败" />
      </n-spin>
    </n-modal>
  </div>
</template>

<style scoped>
.crop-media {
  position: relative;
  width: 88px;
  height: 88px;
  margin: 0 auto 12px;
}

.crop-image {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.12);
}

.crop-icon-badge {
  position: absolute;
  right: -2px;
  bottom: -2px;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: #16a34a;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 10px rgba(22, 163, 74, 0.35);
}
</style>
