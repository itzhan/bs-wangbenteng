import { defineStore } from 'pinia';

import { request } from '@/utils/request';
import { usePermissionStore } from '@/store';
import type { UserInfo } from '@/types/interface';

const InitUserInfo: UserInfo = {
  name: '',
  roles: [],
};

export const useUserStore = defineStore('user', {
  state: () => ({
    token: '',
    userInfo: { ...InitUserInfo },
    userId: 0,
    role: 0,
    realName: '',
    avatar: '',
  }),
  getters: {
    roles: (state) => {
      return state.userInfo?.roles;
    },
  },
  actions: {
    async login(userInfo: Record<string, unknown>) {
      const res: any = await request.request({
        url: '/auth/login',
        method: 'post',
        data: {
          username: userInfo.account,
          password: userInfo.password,
        },
      });
      this.token = res.token;
      this.userId = res.userId;
      this.role = res.role;
      this.realName = res.realName;
      this.avatar = res.avatar;
      this.userInfo = {
        name: res.realName || res.username,
        roles: ['all'],
      };
    },
    async getUserInfo() {
      if (this.token && !this.userInfo.name) {
        try {
          const res: any = await request.request({
            url: '/users/current',
            method: 'get',
          });
          this.userInfo = {
            name: res.realName || res.username,
            roles: ['all'],
          };
          this.realName = res.realName;
          this.role = res.role;
          this.avatar = res.avatar;
        } catch (e) {
          this.token = '';
          this.userInfo = { ...InitUserInfo };
        }
      }
    },
    async logout() {
      this.token = '';
      this.userInfo = { ...InitUserInfo };
      const permissionStore = usePermissionStore();
      permissionStore.restoreRoutes();
    },
  },
  persist: {
    afterHydrate: () => {
      const permissionStore = usePermissionStore();
      permissionStore.initRoutes();
    },
    key: 'user',
    pick: ['token', 'userId', 'role', 'realName'],
  },
});
