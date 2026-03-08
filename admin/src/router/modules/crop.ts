import type { RouteRecordRaw } from 'vue-router';

import Layout from '@/layouts/index.vue';

export default [
  {
    path: '/crop',
    component: Layout,
    redirect: '/crop/index',
    name: 'crop',
    meta: {
      title: { zh_CN: '作物管理', en_US: 'Crop Management' },
      icon: 'flower',
      orderNo: 10,
    },
    children: [
      {
        path: 'index',
        name: 'CropList',
        component: () => import('@/pages/crop/index.vue'),
        meta: { title: { zh_CN: '作物列表', en_US: 'Crop List' } },
      },
    ],
  },
] satisfies RouteRecordRaw[];
