import { request } from '@/utils/request';

/** 获取成本记录列表 */
export function getCosts(params?: { page?: number; size?: number; planId?: number }) {
  return request.request({ url: '/costs', method: 'get', params });
}

/** 创建成本记录 */
export function createCost(data: Record<string, any>) {
  return request.request({ url: '/costs', method: 'post', data });
}

/** 更新成本记录 */
export function updateCost(id: number, data: Record<string, any>) {
  return request.request({ url: `/costs/${id}`, method: 'put', data });
}

/** 删除成本记录 */
export function deleteCost(id: number) {
  return request.request({ url: `/costs/${id}`, method: 'delete' });
}
