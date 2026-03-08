import { request } from '@/utils/request';

/** 获取地块列表 */
export function getPlots(params?: { page?: number; size?: number; keyword?: string }) {
  return request.request({ url: '/plots', method: 'get', params });
}

/** 获取地块详情 */
export function getPlotById(id: number) {
  return request.request({ url: `/plots/${id}`, method: 'get' });
}

/** 创建地块 */
export function createPlot(data: Record<string, any>) {
  return request.request({ url: '/plots', method: 'post', data });
}

/** 更新地块 */
export function updatePlot(id: number, data: Record<string, any>) {
  return request.request({ url: `/plots/${id}`, method: 'put', data });
}

/** 删除地块 */
export function deletePlot(id: number) {
  return request.request({ url: `/plots/${id}`, method: 'delete' });
}
