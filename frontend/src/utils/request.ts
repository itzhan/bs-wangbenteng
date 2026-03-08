import axios from 'axios'
import { useRouter } from 'vue-router'

const request = axios.create({
  baseURL: '/api',
  timeout: 15000,
})

// Request interceptor: attach Bearer token
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error),
)

// Response interceptor: unwrap data, handle errors
request.interceptors.response.use(
  (response) => {
    const res = response.data
    if (res.code === 200) {
      return res.data
    }
    // Business error
    window.$message?.error(res.message || '请求失败')
    return Promise.reject(new Error(res.message || '请求失败'))
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.$message?.error('登录已过期，请重新登录')
      // Redirect to login
      const currentPath = window.location.pathname
      if (currentPath !== '/login') {
        window.location.href = '/login'
      }
    } else {
      window.$message?.error(error.response?.data?.message || error.message || '网络错误')
    }
    return Promise.reject(error)
  },
)

export default request
