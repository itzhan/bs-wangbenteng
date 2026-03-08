import type { RouteRecordRaw } from 'vue-router';

import Layout from '@/layouts/index.vue';

export default [
  {
    path: '/system',
    component: Layout,
    redirect: '/system/log',
    name: 'system',
    meta: {
      title: { zh_CN: '系统管理', en_US: 'System Management' },
      icon: 'setting',
      orderNo: 100,
    },
    children: [
      {
        path: 'log',
        name: 'LogList',
        component: () => import('@/pages/log/index.vue'),
        meta: { title: { zh_CN: '日志管理', en_US: 'System Logs' } },
      },
      {
        path: 'config',
        name: 'ConfigList',
        component: () => import('@/pages/config/index.vue'),
        meta: { title: { zh_CN: '系统配置', en_US: 'System Config' } },
      },
    ],
  },
] satisfies RouteRecordRaw[];
