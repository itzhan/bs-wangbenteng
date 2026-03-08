<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { NCard, NGrid, NGi, NButton, NIcon, NSpace, NStatistic } from 'naive-ui'
import {
  LeafOutline,
  CalendarOutline,
  BarChartOutline,
  BookOutline,
  PeopleOutline,
  LayersOutline,
} from '@vicons/ionicons5'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const features = [
  {
    icon: CalendarOutline,
    title: '种植计划管理',
    desc: '制定和管理作物种植计划，追踪进度',
    route: '/plans',
    auth: true,
  },
  {
    icon: LeafOutline,
    title: '作物品种查询',
    desc: '浏览丰富的作物品种信息与种植建议',
    route: '/crops',
    auth: false,
  },
  {
    icon: BarChartOutline,
    title: '产量与成本分析',
    desc: '记录产量数据，分析种植成本效益',
    route: '/dashboard',
    auth: true,
  },
  {
    icon: BookOutline,
    title: '技术指导',
    desc: '获取专业的农作物种植技术指导',
    route: '/guidance',
    auth: false,
  },
]

// Try to load user info if token exists
onMounted(async () => {
  if (userStore.token && !userStore.userId) {
    try {
      await userStore.getUserInfo()
    } catch {
      // ignore
    }
  }
})
</script>

<template>
  <div>
    <!-- Hero Section -->
    <div style="text-align: center; padding: 60px 0 48px; background: linear-gradient(135deg, #e8f5e1 0%, #f0f7e6 100%); border-radius: 16px; margin-bottom: 48px">
      <n-icon :size="64" color="#18a058" style="margin-bottom: 16px">
        <LeafOutline />
      </n-icon>
      <h1 style="font-size: 36px; font-weight: 700; color: #1a1a1a; margin: 0 0 12px">
        农作物种植管理系统
      </h1>
      <p style="font-size: 16px; color: #666; margin: 0 0 32px; max-width: 500px; margin-left: auto; margin-right: auto">
        科学管理种植过程，提高农作物产量与效益，助力现代农业发展
      </p>
      <n-space justify="center">
        <n-button
          v-if="!userStore.token"
          type="primary"
          size="large"
          round
          @click="router.push('/register')"
        >
          立即注册
        </n-button>
        <n-button
          v-if="!userStore.token"
          size="large"
          round
          @click="router.push('/login')"
        >
          登录
        </n-button>
        <n-button
          v-if="userStore.token"
          type="primary"
          size="large"
          round
          @click="router.push('/dashboard')"
        >
          进入数据看板
        </n-button>
        <n-button
          v-if="userStore.token"
          size="large"
          round
          @click="router.push('/plans')"
        >
          我的种植计划
        </n-button>
      </n-space>
    </div>

    <!-- Feature Cards -->
    <h2 style="text-align: center; font-size: 24px; font-weight: 600; color: #333; margin-bottom: 32px">
      系统功能
    </h2>
    <n-grid :x-gap="20" :y-gap="20" cols="1 s:2 m:4" responsive="screen">
      <n-gi v-for="f in features" :key="f.title">
        <n-card
          hoverable
          style="cursor: pointer; height: 100%; border-radius: 12px"
          @click="router.push(f.route)"
        >
          <div style="text-align: center; padding: 16px 0">
            <n-icon :size="40" color="#18a058" style="margin-bottom: 12px">
              <component :is="f.icon" />
            </n-icon>
            <h3 style="font-size: 16px; font-weight: 600; color: #333; margin: 0 0 8px">
              {{ f.title }}
            </h3>
            <p style="font-size: 13px; color: #888; margin: 0">
              {{ f.desc }}
            </p>
          </div>
        </n-card>
      </n-gi>
    </n-grid>

    <!-- Quick Stats -->
    <div style="margin-top: 48px; text-align: center">
      <h2 style="font-size: 24px; font-weight: 600; color: #333; margin-bottom: 32px">
        平台数据
      </h2>
      <n-grid :x-gap="20" :y-gap="20" cols="1 s:3" responsive="screen">
        <n-gi>
          <n-card style="border-radius: 12px">
            <n-statistic label="作物品种">
              <template #prefix>
                <n-icon :size="20" color="#18a058"><LeafOutline /></n-icon>
              </template>
              50+
            </n-statistic>
          </n-card>
        </n-gi>
        <n-gi>
          <n-card style="border-radius: 12px">
            <n-statistic label="注册用户">
              <template #prefix>
                <n-icon :size="20" color="#d4a259"><PeopleOutline /></n-icon>
              </template>
              100+
            </n-statistic>
          </n-card>
        </n-gi>
        <n-gi>
          <n-card style="border-radius: 12px">
            <n-statistic label="种植计划">
              <template #prefix>
                <n-icon :size="20" color="#18a058"><LayersOutline /></n-icon>
              </template>
              200+
            </n-statistic>
          </n-card>
        </n-gi>
      </n-grid>
    </div>
  </div>
</template>
