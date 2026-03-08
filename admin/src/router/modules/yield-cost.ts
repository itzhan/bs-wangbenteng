import type { RouteRecordRaw } from 'vue-router';

import Layout from '@/layouts/index.vue';

export default [
  {
    path: '/yield-cost',
    component: Layout,
    redirect: '/yield-cost/yield',
    name: 'yieldCost',
    meta: {
      title: { zh_CN: '产量成本', en_US: 'Yield & Cost' },
      icon: 'chart-bar',
      orderNo: 50,
    },
    children: [
      {
        path: 'yield',
        name: 'YieldList',
        component: () => import('@/pages/yield/index.vue'),
        meta: { title: { zh_CN: '产量记录', en_US: 'Yield Records' } },
      },
      {
        path: 'cost',
        name: 'CostList',
        component: () => import('@/pages/cost/index.vue'),
        meta: { title: { zh_CN: '成本记录', en_US: 'Cost Records' } },
      },
    ],
  },
] satisfies RouteRecordRaw[];
