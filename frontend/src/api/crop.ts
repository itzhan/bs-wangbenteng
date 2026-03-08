import request from '@/utils/request'

export function getCrops(page: number, size: number, keyword?: string) {
  return request.get('/crops', { params: { page, size, keyword } })
}

export function getCropById(id: number) {
  return request.get(`/crops/${id}`)
}
