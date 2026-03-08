import { request } from '@/utils/request';

/** 获取用户列表 */
export function getUsers(params?: { page?: number; size?: number; keyword?: string }) {
  return request.request({ url: '/users', method: 'get', params });
}

/** 获取用户详情 */
export function getUserById(id: number) {
  return request.request({ url: `/users/${id}`, method: 'get' });
}

/** 创建用户 */
export function createUser(data: Record<string, any>) {
  return request.request({ url: '/users', method: 'post', data });
}

/** 更新用户 */
export function updateUser(id: number, data: Record<string, any>) {
  return request.request({ url: `/users/${id}`, method: 'put', data });
}

/** 删除用户 */
export function deleteUser(id: number) {
  return request.request({ url: `/users/${id}`, method: 'delete' });
}

/** 获取当前用户信息 */
export function getCurrentUser() {
  return request.request({ url: '/users/current', method: 'get' });
}

/** 更新个人资料 */
export function updateProfile(data: Record<string, any>) {
  return request.request({ url: '/users/current/profile', method: 'put', data });
}

/** 修改密码 */
export function updatePassword(data: { oldPassword: string; newPassword: string }) {
  return request.request({ url: '/users/current/password', method: 'put', data });
}
