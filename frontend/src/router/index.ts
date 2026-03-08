import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/Home.vue'),
        meta: { title: '首页', public: true },
      },
      {
        path: 'crops',
        name: 'Crops',
        component: () => import('@/views/crops/CropList.vue'),
        meta: { title: '作物品种', public: true },
      },
      {
        path: 'announcements',
        name: 'Announcements',
        component: () => import('@/views/announcements/AnnouncementList.vue'),
        meta: { title: '通知公告', public: true },
      },
      {
        path: 'guidance',
        name: 'Guidance',
        component: () => import('@/views/guidance/GuidanceList.vue'),
        meta: { title: '技术指导', public: true },
      },
      {
        path: 'plans',
        name: 'Plans',
        component: () => import('@/views/plans/PlanList.vue'),
        meta: { title: '种植计划' },
      },
      {
        path: 'plans/:id',
        name: 'PlanDetail',
        component: () => import('@/views/plans/PlanDetail.vue'),
        meta: { title: '计划详情' },
      },
      {
        path: 'operations',
        name: 'Operations',
        component: () => import('@/views/operations/OperationList.vue'),
        meta: { title: '农事操作' },
      },
      {
        path: 'inventory',
        name: 'Inventory',
        component: () => import('@/views/inventory/InventoryList.vue'),
        meta: { title: '物资库存' },
      },
      {
        path: 'yields',
        name: 'Yields',
        component: () => import('@/views/yields/YieldList.vue'),
        meta: { title: '产量记录' },
      },
      {
        path: 'costs',
        name: 'Costs',
        component: () => import('@/views/costs/CostList.vue'),
        meta: { title: '成本记录' },
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/profile/Profile.vue'),
        meta: { title: '个人中心' },
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/Dashboard.vue'),
        meta: { title: '数据看板' },
      },
    ],
  },
  {
    path: '/login',
    component: () => import('@/layouts/AuthLayout.vue'),
    children: [
      {
        path: '',
        name: 'Login',
        component: () => import('@/views/Login.vue'),
        meta: { title: '登录', public: true },
      },
    ],
  },
  {
    path: '/register',
    component: () => import('@/layouts/AuthLayout.vue'),
    children: [
      {
        path: '',
        name: 'Register',
        component: () => import('@/views/Register.vue'),
        meta: { title: '注册', public: true },
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  },
})

// Navigation guard
router.beforeEach((to, _from, next) => {
  // Update document title
  const title = to.meta.title as string
  document.title = title ? `${title} - 农作物种植管理系统` : '农作物种植管理系统'

  const token = localStorage.getItem('token')
  const isPublic = to.meta.public === true

  if (!token && !isPublic) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else {
    next()
  }
})

export default router
