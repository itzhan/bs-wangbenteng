import { request } from '@/utils/request';

/** 获取产量记录列表 */
export function getYields(params?: { page?: number; size?: number; planId?: number }) {
  return request.request({ url: '/yields', method: 'get', params });
}

/** 创建产量记录 */
export function createYield(data: Record<string, any>) {
  return request.request({ url: '/yields', method: 'post', data });
}

/** 更新产量记录 */
export function updateYield(id: number, data: Record<string, any>) {
  return request.request({ url: `/yields/${id}`, method: 'put', data });
}

/** 删除产量记录 */
export function deleteYield(id: number) {
  return request.request({ url: `/yields/${id}`, method: 'delete' });
}
