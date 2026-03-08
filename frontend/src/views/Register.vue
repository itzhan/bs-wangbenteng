<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { NCard, NForm, NFormItem, NInput, NButton } from 'naive-ui'
import { register } from '@/api/auth'
import type { FormInst, FormRules } from 'naive-ui'

const router = useRouter()

const formRef = ref<FormInst | null>(null)
const loading = ref(false)
const formData = ref({
  username: '',
  password: '',
  confirmPassword: '',
  realName: '',
  phone: '',
  email: '',
})

const rules: FormRules = {
  username: { required: true, message: '请输入用户名', trigger: 'blur' },
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' },
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator(_rule: any, value: string) {
        if (value !== formData.value.password) {
          return new Error('两次输入密码不一致')
        }
        return true
      },
      trigger: 'blur',
    },
  ],
  realName: { required: true, message: '请输入真实姓名', trigger: 'blur' },
}

async function handleRegister() {
  try {
    await formRef.value?.validate()
  } catch {
    return
  }

  loading.value = true
  try {
    await register({
      username: formData.value.username,
      password: formData.value.password,
      realName: formData.value.realName,
      phone: formData.value.phone || undefined,
      email: formData.value.email || undefined,
    })
    window.$message?.success('注册成功，请登录')
    router.push('/login')
  } catch {
    // Error handled in interceptor
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <n-card style="border-radius: 16px; box-shadow: 0 4px 24px rgba(0,0,0,0.08)">
    <h2 style="text-align: center; font-size: 22px; font-weight: 600; color: #333; margin: 0 0 24px">
      用户注册
    </h2>
    <n-form ref="formRef" :model="formData" :rules="rules" label-placement="left" label-width="0">
      <n-form-item path="username">
        <n-input v-model:value="formData.username" placeholder="用户名" size="large" />
      </n-form-item>
      <n-form-item path="realName">
        <n-input v-model:value="formData.realName" placeholder="真实姓名" size="large" />
      </n-form-item>
      <n-form-item path="password">
        <n-input
          v-model:value="formData.password"
          type="password"
          show-password-on="click"
          placeholder="密码（至少6位）"
          size="large"
        />
      </n-form-item>
      <n-form-item path="confirmPassword">
        <n-input
          v-model:value="formData.confirmPassword"
          type="password"
          show-password-on="click"
          placeholder="确认密码"
          size="large"
        />
      </n-form-item>
      <n-form-item path="phone">
        <n-input v-model:value="formData.phone" placeholder="手机号（选填）" size="large" />
      </n-form-item>
      <n-form-item path="email">
        <n-input v-model:value="formData.email" placeholder="邮箱（选填）" size="large" />
      </n-form-item>
      <n-button
        type="primary"
        block
        size="large"
        :loading="loading"
        style="margin-top: 8px; border-radius: 8px"
        @click="handleRegister"
      >
        注 册
      </n-button>
    </n-form>
    <div style="text-align: center; margin-top: 16px; font-size: 14px; color: #666">
      已有账号？
      <router-link to="/login" style="color: #18a058; font-weight: 500">去登录</router-link>
    </div>
  </n-card>
</template>
