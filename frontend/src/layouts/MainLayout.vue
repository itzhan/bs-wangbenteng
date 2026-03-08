<script setup lang="ts">
import { computed, h, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import {
  NLayout,
  NLayoutHeader,
  NLayoutContent,
  NLayoutFooter,
  NMenu,
  NAvatar,
  NDropdown,
  NSpace,
  NButton,
  NIcon,
} from 'naive-ui'
import {
  LeafOutline,
  HomeOutline,
  CalendarOutline,
  ConstructOutline,
  CubeOutline,
  BarChartOutline,
  CashOutline,
  MegaphoneOutline,
  BookOutline,
  StatsChartOutline,
} from '@vicons/ionicons5'
import type { MenuOption } from 'naive-ui'
import type { Component } from 'vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isLoggedIn = computed(() => !!userStore.token)

function renderIcon(icon: Component) {
  return () => h(NIcon, null, { default: () => h(icon) })
}

const publicMenuOptions: MenuOption[] = [
  { label: '首页', key: '/', icon: renderIcon(HomeOutline) },
  { label: '作物品种', key: '/crops', icon: renderIcon(LeafOutline) },
  { label: '通知公告', key: '/announcements', icon: renderIcon(MegaphoneOutline) },
  { label: '技术指导', key: '/guidance', icon: renderIcon(BookOutline) },
]

const authMenuOptions: MenuOption[] = [
  { label: '首页', key: '/', icon: renderIcon(HomeOutline) },
  { label: '种植计划', key: '/plans', icon: renderIcon(CalendarOutline) },
  { label: '农事操作', key: '/operations', icon: renderIcon(ConstructOutline) },
  { label: '物资库存', key: '/inventory', icon: renderIcon(CubeOutline) },
  { label: '产量记录', key: '/yields', icon: renderIcon(BarChartOutline) },
  { label: '成本记录', key: '/costs', icon: renderIcon(CashOutline) },
  { label: '数据看板', key: '/dashboard', icon: renderIcon(StatsChartOutline) },
  { label: '通知公告', key: '/announcements', icon: renderIcon(MegaphoneOutline) },
  { label: '技术指导', key: '/guidance', icon: renderIcon(BookOutline) },
]

const menuOptions = computed(() => (isLoggedIn.value ? authMenuOptions : publicMenuOptions))

const activeKey = computed(() => {
  const path = route.path
  // Match exact path or parent path
  if (path === '/') return '/'
  const match = menuOptions.value.find(
    (opt) => opt.key !== '/' && path.startsWith(opt.key as string),
  )
  return match ? (match.key as string) : '/'
})

function handleMenuSelect(key: string) {
  router.push(key)
}

const userDropdownOptions = [
  { label: '个人中心', key: 'profile' },
  { label: '退出登录', key: 'logout' },
]

function handleUserAction(key: string) {
  if (key === 'profile') {
    router.push('/profile')
  } else if (key === 'logout') {
    userStore.logout()
    router.push('/login')
  }
}
</script>

<template>
  <n-layout style="min-height: 100vh">
    <!-- Header -->
    <n-layout-header bordered style="height: 64px; padding: 0 24px; display: flex; align-items: center; background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,0.06)">
      <div style="display: flex; align-items: center; width: 100%; max-width: 1200px; margin: 0 auto">
        <!-- Logo -->
        <div
          style="display: flex; align-items: center; cursor: pointer; margin-right: 32px; flex-shrink: 0"
          @click="router.push('/')"
        >
          <n-icon :size="28" color="#18a058">
            <LeafOutline />
          </n-icon>
          <span style="margin-left: 8px; font-size: 18px; font-weight: 600; color: #18a058; white-space: nowrap">
            农作物种植管理系统
          </span>
        </div>

        <!-- Navigation -->
        <n-menu
          mode="horizontal"
          :value="activeKey"
          :options="menuOptions"
          style="flex: 1; border-bottom: none"
          @update:value="handleMenuSelect"
        />

        <!-- User area -->
        <div style="flex-shrink: 0; margin-left: 16px">
          <template v-if="isLoggedIn">
            <n-dropdown :options="userDropdownOptions" @select="handleUserAction">
              <div style="display: flex; align-items: center; cursor: pointer; gap: 8px">
                <n-avatar
                  v-if="userStore.avatar"
                  :src="userStore.avatar"
                  :size="32"
                  round
                />
                <n-avatar v-else :size="32" round style="background: #18a058; color: #fff; font-size: 14px">
                  {{ (userStore.realName || userStore.username || '用').charAt(0) }}
                </n-avatar>
                <span style="font-size: 14px; color: #333; max-width: 80px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">
                  {{ userStore.realName || userStore.username }}
                </span>
              </div>
            </n-dropdown>
          </template>
          <template v-else>
            <n-space>
              <n-button quaternary size="small" @click="router.push('/login')">登录</n-button>
              <n-button type="primary" size="small" @click="router.push('/register')">注册</n-button>
            </n-space>
          </template>
        </div>
      </div>
    </n-layout-header>

    <!-- Content -->
    <n-layout-content style="min-height: calc(100vh - 64px - 64px); max-width: 1200px; margin: 0 auto; width: 100%; padding: 24px">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </n-layout-content>

    <!-- Footer -->
    <n-layout-footer bordered style="height: 64px; display: flex; align-items: center; justify-content: center; background: #fff; color: #999; font-size: 13px">
      农作物种植生产管理系统 &copy; 2026 &nbsp;|&nbsp; 毕业设计
    </n-layout-footer>
  </n-layout>
</template>
