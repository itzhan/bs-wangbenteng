import cloneDeep from 'lodash/cloneDeep';
import { defineStore } from 'pinia';

import { fixedRouterList, homepageRouterList } from '@/router';
import { store } from '@/store';

export const usePermissionStore = defineStore('permission', {
  state: () => ({
    whiteListRouters: ['/login'],
    routers: [],
  }),
  actions: {
    async initRoutes() {
      // 当前项目使用静态路由，这里只负责初始化菜单数据
      this.routers = cloneDeep([...homepageRouterList, ...fixedRouterList]);
    },
    async restoreRoutes() {
      this.routers = [];
    },
  },
});

export function getPermissionStore() {
  return usePermissionStore(store);
}
