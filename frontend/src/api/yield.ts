import request from '@/utils/request'

export function getYields(params: Record<string, any>) {
  return request.get('/yields', { params })
}

export function createYield(data: Record<string, any>) {
  return request.post('/yields', data)
}

export function updateYield(id: number, data: Record<string, any>) {
  return request.put(`/yields/${id}`, data)
}

export function deleteYield(id: number) {
  return request.delete(`/yields/${id}`)
}
