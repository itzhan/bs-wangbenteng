import { request } from '@/utils/request';

/** 登录 */
export function login(data: { username: string; password: string }) {
  return request.request({ url: '/auth/login', method: 'post', data });
}

/** 注册 */
export function register(data: { username: string; password: string; realName?: string; phone?: string }) {
  return request.request({ url: '/auth/register', method: 'post', data });
}
