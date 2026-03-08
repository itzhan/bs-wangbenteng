import { defineStore } from 'pinia'
import { ref } from 'vue'
import { login as loginApi, register as registerApi } from '@/api/auth'
import { getCurrentUser } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userId = ref<number | null>(null)
  const username = ref('')
  const realName = ref('')
  const role = ref('')
  const avatar = ref('')
  const phone = ref('')
  const email = ref('')

  async function login(usernameVal: string, password: string) {
    const data: any = await loginApi(usernameVal, password)
    token.value = data.token
    localStorage.setItem('token', data.token)
    // Load user info after login
    await getUserInfo()
  }

  async function getUserInfo() {
    try {
      const data: any = await getCurrentUser()
      userId.value = data.id
      username.value = data.username
      realName.value = data.realName || ''
      role.value = data.role || ''
      avatar.value = data.avatar || ''
      phone.value = data.phone || ''
      email.value = data.email || ''
    } catch {
      // If fetching user info fails, clear token
      logout()
    }
  }

  function logout() {
    token.value = ''
    userId.value = null
    username.value = ''
    realName.value = ''
    role.value = ''
    avatar.value = ''
    phone.value = ''
    email.value = ''
    localStorage.removeItem('token')
  }

  return {
    token,
    userId,
    username,
    realName,
    role,
    avatar,
    phone,
    email,
    login,
    getUserInfo,
    logout,
  }
})
