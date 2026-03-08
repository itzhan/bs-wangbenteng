import type { RouteRecordRaw } from 'vue-router';

import Layout from '@/layouts/index.vue';

export default [
  {
    path: '/content',
    component: Layout,
    redirect: '/content/announcement',
    name: 'content',
    meta: {
      title: { zh_CN: '内容管理', en_US: 'Content Management' },
      icon: 'edit',
      orderNo: 60,
    },
    children: [
      {
        path: 'announcement',
        name: 'AnnouncementList',
        component: () => import('@/pages/announcement/index.vue'),
        meta: { title: { zh_CN: '公告管理', en_US: 'Announcements' } },
      },
      {
        path: 'guidance',
        name: 'GuidanceList',
        component: () => import('@/pages/guidance/index.vue'),
        meta: { title: { zh_CN: '技术指导', en_US: 'Technical Guidance' } },
      },
    ],
  },
] satisfies RouteRecordRaw[];
