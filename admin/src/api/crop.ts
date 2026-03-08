import { request } from '@/utils/request';

/** 获取作物列表 */
export function getCrops(params?: { page?: number; size?: number; keyword?: string }) {
  return request.request({ url: '/crops', method: 'get', params });
}

/** 获取作物详情 */
export function getCropById(id: number) {
  return request.request({ url: `/crops/${id}`, method: 'get' });
}

/** 创建作物 */
export function createCrop(data: Record<string, any>) {
  return request.request({ url: '/crops', method: 'post', data });
}

/** 更新作物 */
export function updateCrop(id: number, data: Record<string, any>) {
  return request.request({ url: `/crops/${id}`, method: 'put', data });
}

/** 删除作物 */
export function deleteCrop(id: number) {
  return request.request({ url: `/crops/${id}`, method: 'delete' });
}
