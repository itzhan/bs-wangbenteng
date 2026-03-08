import { request } from '@/utils/request';

/** 获取技术指导列表 */
export function getGuidances(params?: { page?: number; size?: number; keyword?: string }) {
  return request.request({ url: '/guidance', method: 'get', params });
}

/** 创建技术指导 */
export function createGuidance(data: Record<string, any>) {
  return request.request({ url: '/guidance', method: 'post', data });
}

/** 更新技术指导 */
export function updateGuidance(id: number, data: Record<string, any>) {
  return request.request({ url: `/guidance/${id}`, method: 'put', data });
}

/** 删除技术指导 */
export function deleteGuidance(id: number) {
  return request.request({ url: `/guidance/${id}`, method: 'delete' });
}
