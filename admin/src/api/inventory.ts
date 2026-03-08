import { request } from '@/utils/request';

/** 获取库存列表 */
export function getInventory(params?: { page?: number; size?: number }) {
  return request.request({ url: '/inventory', method: 'get', params });
}

/** 获取库存预警 */
export function getWarnings() {
  return request.request({ url: '/inventory/warnings', method: 'get' });
}

/** 库存操作（入库/出库） */
export function operate(data: { materialId: number; type: number; quantity: number; remark?: string }) {
  return request.request({ url: '/inventory/operate', method: 'post', data });
}

/** 获取库存记录 */
export function getRecords(params?: { page?: number; size?: number; materialId?: number; type?: number }) {
  return request.request({ url: '/inventory/records', method: 'get', params });
}
