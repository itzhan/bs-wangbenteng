import { request } from '@/utils/request';

/** 上传文件 */
export function upload(file: File) {
  const formData = new FormData();
  formData.append('file', file);
  return request.request({
    url: '/files/upload',
    method: 'post',
    data: formData,
    headers: { 'Content-Type': 'multipart/form-data' },
  } as any);
}
