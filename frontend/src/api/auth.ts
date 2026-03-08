import request from '@/utils/request'

export function login(username: string, password: string) {
  return request.post('/auth/login', { username, password })
}

export function register(data: {
  username: string
  password: string
  realName: string
  phone?: string
  email?: string
}) {
  return request.post('/auth/register', data)
}
