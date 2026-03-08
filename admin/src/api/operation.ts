import { request } from '@/utils/request';

/** 获取田间作业列表 */
export function getOperations(params?: {
  page?: number;
  size?: number;
  planId?: number;
  userId?: number;
  operationType?: number;
  startDate?: string;
  endDate?: string;
}) {
  return request.request({ url: '/operations', method: 'get', params });
}

/** 创建田间作业 */
export function createOperation(data: Record<string, any>) {
  return request.request({ url: '/operations', method: 'post', data });
}

/** 更新田间作业 */
export function updateOperation(id: number, data: Record<string, any>) {
  return request.request({ url: `/operations/${id}`, method: 'put', data });
}

/** 删除田间作业 */
export function deleteOperation(id: number) {
  return request.request({ url: `/operations/${id}`, method: 'delete' });
}
