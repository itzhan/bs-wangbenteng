import request from '@/utils/request'

export function getMyPlots() {
  return request.get('/plots/my')
}

export function createPlot(data: Record<string, any>) {
  return request.post('/plots', data)
}

export function updatePlot(id: number, data: Record<string, any>) {
  return request.put(`/plots/${id}`, data)
}

export function deletePlot(id: number) {
  return request.delete(`/plots/${id}`)
}
