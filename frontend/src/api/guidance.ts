import request from '@/utils/request'

export function getGuidances(params: Record<string, any>) {
  return request.get('/guidance', { params })
}

export function getGuidanceById(id: number) {
  return request.get(`/guidance/${id}`)
}
