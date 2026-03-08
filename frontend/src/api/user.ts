import request from '@/utils/request'

export function getCurrentUser() {
  return request.get('/users/current')
}

export function updateProfile(data: Record<string, any>) {
  return request.put('/users/current/profile', data)
}

export function updatePassword(data: { oldPassword: string; newPassword: string }) {
  return request.put('/users/current/password', data)
}
