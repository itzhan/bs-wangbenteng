import cloneDeep from 'lodash/cloneDeep';
import { defineStore } from 'pinia';
import type { RouteRecordRaw } from 'vue-router';

import router, { fixedRouterList, homepageRouterList } from '@/router';
import { store } from '@/store';

export const usePermissionStore = defineStore('permission', {
  state: () => ({
    whiteListRouters: ['/login'],
    routers: [] as RouteRecordRaw[],
    removeRoutes: [] as RouteRecordRaw[],
    asyncRoutes: [] as RouteRecordRaw[],
  }),
  actions: {
    async initRoutes() {
      // 在菜单展示全部路由
      this.routers = cloneDeep([...homepageRouterList, ...this.asyncRoutes, ...fixedRouterList]);
    },
    async buildAsyncRoutes() {
      // 当前使用静态路由，无需从后端获取菜单
      await this.initRoutes();
      return this.asyncRoutes;
    },
    async restoreRoutes() {
      this.asyncRoutes.forEach((item: RouteRecordRaw) => {
        if (item.name) {
          router.removeRoute(item.name);
        }
      });
      this.asyncRoutes = [];
    },
  },
});

export function getPermissionStore() {
  return usePermissionStore(store);
}
