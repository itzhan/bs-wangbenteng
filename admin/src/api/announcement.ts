import { request } from '@/utils/request';

/** 获取公告列表 */
export function getAnnouncements(params?: { page?: number; size?: number; keyword?: string }) {
  return request.request({ url: '/announcements', method: 'get', params });
}

/** 创建公告 */
export function createAnnouncement(data: Record<string, any>) {
  return request.request({ url: '/announcements', method: 'post', data });
}

/** 更新公告 */
export function updateAnnouncement(id: number, data: Record<string, any>) {
  return request.request({ url: `/announcements/${id}`, method: 'put', data });
}

/** 删除公告 */
export function deleteAnnouncement(id: number) {
  return request.request({ url: `/announcements/${id}`, method: 'delete' });
}

/** 发布公告 */
export function publishAnnouncement(id: number) {
  return request.request({ url: `/announcements/${id}/publish`, method: 'put' });
}
