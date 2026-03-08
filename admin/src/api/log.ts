import { request } from '@/utils/request';

/** 获取系统日志列表 */
export function getLogs(params?: {
  page?: number;
  size?: number;
  username?: string;
  module?: string;
  startDate?: string;
  endDate?: string;
}) {
  return request.request({ url: '/logs', method: 'get', params });
}
