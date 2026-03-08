import request from '@/utils/request'

export function getCosts(params: Record<string, any>) {
  return request.get('/costs', { params })
}

export function createCost(data: Record<string, any>) {
  return request.post('/costs', data)
}

export function updateCost(id: number, data: Record<string, any>) {
  return request.put(`/costs/${id}`, data)
}

export function deleteCost(id: number) {
  return request.delete(`/costs/${id}`)
}
