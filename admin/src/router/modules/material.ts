import type { RouteRecordRaw } from 'vue-router';

import Layout from '@/layouts/index.vue';

export default [
  {
    path: '/material',
    component: Layout,
    redirect: '/material/index',
    name: 'material',
    meta: {
      title: { zh_CN: '农资管理', en_US: 'Material Management' },
      icon: 'shop',
      orderNo: 40,
    },
    children: [
      {
        path: 'index',
        name: 'MaterialList',
        component: () => import('@/pages/material/index.vue'),
        meta: { title: { zh_CN: '农资信息', en_US: 'Material List' } },
      },
      {
        path: 'inventory',
        name: 'InventoryList',
        component: () => import('@/pages/inventory/index.vue'),
        meta: { title: { zh_CN: '库存管理', en_US: 'Inventory' } },
      },
      {
        path: 'records',
        name: 'InventoryRecords',
        component: () => import('@/pages/inventory/records.vue'),
        meta: { title: { zh_CN: '库存记录', en_US: 'Inventory Records' } },
      },
    ],
  },
] satisfies RouteRecordRaw[];
