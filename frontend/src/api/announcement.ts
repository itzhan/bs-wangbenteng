import request from '@/utils/request'

export function getPublishedAnnouncements(page: number, size: number) {
  return request.get('/announcements/published', { params: { page, size } })
}

export function getAnnouncementById(id: number) {
  return request.get(`/announcements/${id}`)
}
