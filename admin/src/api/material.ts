import { request } from '@/utils/request';

/** 获取农资列表 */
export function getMaterials(params?: { page?: number; size?: number; keyword?: string }) {
  return request.request({ url: '/materials', method: 'get', params });
}

/** 获取农资详情 */
export function getMaterialById(id: number) {
  return request.request({ url: `/materials/${id}`, method: 'get' });
}

/** 创建农资 */
export function createMaterial(data: Record<string, any>) {
  return request.request({ url: '/materials', method: 'post', data });
}

/** 更新农资 */
export function updateMaterial(id: number, data: Record<string, any>) {
  return request.request({ url: `/materials/${id}`, method: 'put', data });
}

/** 删除农资 */
export function deleteMaterial(id: number) {
  return request.request({ url: `/materials/${id}`, method: 'delete' });
}
