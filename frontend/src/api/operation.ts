import request from '@/utils/request'

export function getOperations(params: Record<string, any>) {
  return request.get('/operations', { params })
}

export function createOperation(data: Record<string, any>) {
  return request.post('/operations', data)
}

export function updateOperation(id: number, data: Record<string, any>) {
  return request.put(`/operations/${id}`, data)
}

export function deleteOperation(id: number) {
  return request.delete(`/operations/${id}`)
}
