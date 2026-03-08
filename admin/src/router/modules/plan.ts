import type { RouteRecordRaw } from 'vue-router';

import Layout from '@/layouts/index.vue';

export default [
  {
    path: '/plan',
    component: Layout,
    redirect: '/plan/index',
    name: 'plan',
    meta: {
      title: { zh_CN: '种植计划', en_US: 'Planting Plan' },
      icon: 'calendar',
      orderNo: 20,
    },
    children: [
      {
        path: 'index',
        name: 'PlanList',
        component: () => import('@/pages/plan/index.vue'),
        meta: { title: { zh_CN: '计划列表', en_US: 'Plan List' } },
      },
    ],
  },
] satisfies RouteRecordRaw[];
