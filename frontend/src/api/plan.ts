import request from '@/utils/request'

export function getPlans(params: Record<string, any>) {
  return request.get('/plans', { params })
}

export function getMyPlans(page: number, size: number) {
  return request.get('/plans/my', { params: { page, size } })
}

export function getPlanById(id: number) {
  return request.get(`/plans/${id}`)
}

export function createPlan(data: Record<string, any>) {
  return request.post('/plans', data)
}

export function updatePlan(id: number, data: Record<string, any>) {
  return request.put(`/plans/${id}`, data)
}

export function deletePlan(id: number) {
  return request.delete(`/plans/${id}`)
}
