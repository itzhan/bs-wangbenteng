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
import { SearchOutline, LeafOutline } from '@vicons/ionicons5'
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

const fallbackCropImage = 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=640&h=480&fit=crop'

// All URLs verified accessible via HTTP HEAD on 2026-03-17
const cropImageMap: Record<string, string> = {
  '水稻': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=640&h=480&fit=crop',
  '稻':   'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=640&h=480&fit=crop',
  '小麦': 'https://images.unsplash.com/photo-1437252611977-07f74518abd7?w=640&h=480&fit=crop',
  '麦':   'https://images.unsplash.com/photo-1437252611977-07f74518abd7?w=640&h=480&fit=crop',
  '玉米': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=640&h=480&fit=crop',
  '大豆': 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=640&h=480&fit=crop',
  '花生': 'https://images.unsplash.com/photo-1543158266-0066955047b1?w=640&h=480&fit=crop',
  '棉花': 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=640&h=480&fit=crop',
  '土豆': 'https://images.unsplash.com/photo-1508313880080-c4bef0730395?w=640&h=480&fit=crop',
  '马铃薯': 'https://images.unsplash.com/photo-1508313880080-c4bef0730395?w=640&h=480&fit=crop',
  '番茄': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=640&h=480&fit=crop',
  '西红柿': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=640&h=480&fit=crop',
  '黄瓜': 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=640&h=480&fit=crop',
  '辣椒': 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=640&h=480&fit=crop',
  '白菜': 'https://images.unsplash.com/photo-1598030343246-eec71cb44231?w=640&h=480&fit=crop',
  '红薯': 'https://images.unsplash.com/photo-1590165482129-1b8b27698780?w=640&h=480&fit=crop',
  '甘薯': 'https://images.unsplash.com/photo-1590165482129-1b8b27698780?w=640&h=480&fit=crop',
  '油菜': 'https://images.unsplash.com/photo-1560717789-0ac7c58ac90a?w=640&h=480&fit=crop',
}

function getCropImage(crop: any) {
  // Always use frontend verified image map (DB images may be broken)
  const name = crop?.name || ''
  for (const [key, url] of Object.entries(cropImageMap)) {
    if (name.includes(key)) return url
  }
  return fallbackCropImage
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
                    <LeafOutline />
                  </n-icon>
                </div>
              </div>
              <h3 style="font-size: 16px; font-weight: 600; color: #333; margin: 0 0 6px">
                {{ crop.name }}
              </h3>
              <n-tag v-if="crop.variety" size="small" type="success" round>
                {{ crop.variety }}
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
            <n-descriptions-item label="品种">{{ currentCrop.variety || '-' }}</n-descriptions-item>
            <n-descriptions-item label="生长周期">{{ currentCrop.growthCycle ? `${currentCrop.growthCycle}天` : '-' }}</n-descriptions-item>
            <n-descriptions-item label="种植季节">{{ currentCrop.plantingSeason || '-' }}</n-descriptions-item>
            <n-descriptions-item label="适宜地区">{{ currentCrop.suitableRegion || '-' }}</n-descriptions-item>
            <n-descriptions-item label="描述">{{ currentCrop.description || '-' }}</n-descriptions-item>
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
