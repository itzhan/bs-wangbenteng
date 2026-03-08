<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  NCard,
  NTag,
  NSpace,
  NModal,
  NPagination,
  NEmpty,
  NSpin,
  NTime,
} from 'naive-ui'
import { getPublishedAnnouncements, getAnnouncementById } from '@/api/announcement'

const announcements = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const showDetail = ref(false)
const currentItem = ref<any>(null)
const detailLoading = ref(false)

async function loadData() {
  loading.value = true
  try {
    const res: any = await getPublishedAnnouncements(page.value, pageSize.value)
    announcements.value = res.records || []
    total.value = res.total || 0
  } catch {
    announcements.value = []
  } finally {
    loading.value = false
  }
}

async function viewDetail(id: number) {
  showDetail.value = true
  detailLoading.value = true
  try {
    currentItem.value = await getAnnouncementById(id)
  } catch {
    currentItem.value = null
  } finally {
    detailLoading.value = false
  }
}

function handlePageChange(p: number) {
  page.value = p
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <div>
    <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0 0 20px">通知公告</h2>

    <n-spin :show="loading">
      <n-empty v-if="!loading && announcements.length === 0" description="暂无公告" style="padding: 60px 0" />
      <div v-else style="display: flex; flex-direction: column; gap: 12px">
        <n-card
          v-for="item in announcements"
          :key="item.id"
          hoverable
          style="cursor: pointer; border-radius: 10px"
          @click="viewDetail(item.id)"
        >
          <div style="display: flex; justify-content: space-between; align-items: flex-start">
            <div style="flex: 1">
              <h3 style="font-size: 16px; font-weight: 600; color: #333; margin: 0 0 6px">
                {{ item.title }}
              </h3>
              <p style="font-size: 13px; color: #888; margin: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">
                {{ item.summary || item.content?.slice(0, 80) || '' }}
              </p>
            </div>
            <div style="flex-shrink: 0; text-align: right; margin-left: 16px">
              <span style="font-size: 12px; color: #999">
                {{ item.publishTime || item.createTime || '' }}
              </span>
            </div>
          </div>
        </n-card>
      </div>
    </n-spin>

    <div v-if="total > pageSize" style="display: flex; justify-content: center; margin-top: 24px">
      <n-pagination :page="page" :page-size="pageSize" :item-count="total" @update:page="handlePageChange" />
    </div>

    <n-modal v-model:show="showDetail" preset="card" title="公告详情" style="max-width: 640px; border-radius: 12px">
      <n-spin :show="detailLoading">
        <template v-if="currentItem">
          <h2 style="font-size: 20px; font-weight: 600; margin: 0 0 8px">{{ currentItem.title }}</h2>
          <p style="font-size: 12px; color: #999; margin: 0 0 16px">
            发布时间：{{ currentItem.publishTime || currentItem.createTime || '-' }}
          </p>
          <div style="line-height: 1.8; color: #444; white-space: pre-wrap">{{ currentItem.content }}</div>
        </template>
        <n-empty v-else-if="!detailLoading" description="加载失败" />
      </n-spin>
    </n-modal>
  </div>
</template>
