import { request } from '@/utils/request';

/** 获取系统配置列表 */
export function getConfigs(params?: { page?: number; size?: number }) {
  return request.request({ url: '/config', method: 'get', params });
}

/** 根据key获取配置 */
export function getConfigByKey(key: string) {
  return request.request({ url: `/config/key/${key}`, method: 'get' });
}

/** 创建配置 */
export function createConfig(data: Record<string, any>) {
  return request.request({ url: '/config', method: 'post', data });
}

/** 更新配置 */
export function updateConfig(id: number, data: Record<string, any>) {
  return request.request({ url: `/config/${id}`, method: 'put', data });
}

/** 删除配置 */
export function deleteConfig(id: number) {
  return request.request({ url: `/config/${id}`, method: 'delete' });
}
