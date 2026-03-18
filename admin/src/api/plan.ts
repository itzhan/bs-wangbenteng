import { request } from '@/utils/request';

/** 获取种植计划列表 */
export function getPlans(params?: { page?: number; size?: number; userId?: number; cropId?: number; status?: number }) {
  return request.request({ url: '/plans', method: 'get', params });
}

/** 获取种植计划详情 */
export function getPlanById(id: number) {
  return request.request({ url: `/plans/${id}`, method: 'get' });
}

/** 创建种植计划 */
export function createPlan(data: Record<string, any>) {
  return request.request({ url: '/plans', method: 'post', data });
}

/** 更新种植计划 */
export function updatePlan(id: number, data: Record<string, any>) {
  return request.request({ url: `/plans/${id}`, method: 'put', data });
}

/** 删除种植计划 */
export function deletePlan(id: number) {
  return request.request({ url: `/plans/${id}`, method: 'delete' });
}

/** 审核种植计划 */
export function reviewPlan(id: number, data: { status: number; reviewNote?: string }) {
  return request.request({ url: `/plans/${id}/review`, method: 'put', data });
}

/** 开始种植计划 */
export function startPlan(id: number) {
  return request.request({ url: `/plans/${id}/start`, method: 'put' });
}

/** 完成种植计划 */
export function completePlan(id: number) {
  return request.request({ url: `/plans/${id}/complete`, method: 'put' });
}
