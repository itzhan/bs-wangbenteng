import request from '@/utils/request'

export function getInventory(page: number, size: number) {
  return request.get('/inventory', { params: { page, size } })
}

export function getInventoryRecords(page: number, size: number, materialId?: number, type?: number) {
  return request.get('/inventory/records', { params: { page, size, materialId, type } })
}
