import type { RouteRecordRaw } from 'vue-router';

import Layout from '@/layouts/index.vue';

export default [
  {
    path: '/operation',
    component: Layout,
    redirect: '/operation/index',
    name: 'operation',
    meta: {
      title: { zh_CN: '田间作业', en_US: 'Field Operations' },
      icon: 'tools',
      orderNo: 30,
    },
    children: [
      {
        path: 'index',
        name: 'OperationList',
        component: () => import('@/pages/operation/index.vue'),
        meta: { title: { zh_CN: '作业列表', en_US: 'Operation List' } },
      },
    ],
  },
] satisfies RouteRecordRaw[];
