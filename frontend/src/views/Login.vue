<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { NCard, NForm, NFormItem, NInput, NButton, NSpace } from 'naive-ui'
import { useUserStore } from '@/stores/user'
import type { FormInst, FormRules } from 'naive-ui'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const formRef = ref<FormInst | null>(null)
const loading = ref(false)
const formData = ref({
  username: '',
  password: '',
})

const rules: FormRules = {
  username: { required: true, message: '请输入用户名', trigger: 'blur' },
  password: { required: true, message: '请输入密码', trigger: 'blur' },
}

async function handleLogin() {
  try {
    await formRef.value?.validate()
  } catch {
    return
  }

  loading.value = true
  try {
    await userStore.login(formData.value.username, formData.value.password)
    window.$message?.success('登录成功')
    const redirect = (route.query.redirect as string) || '/'
    router.push(redirect)
  } catch {
    // Error already handled in request interceptor
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <n-card style="border-radius: 16px; box-shadow: 0 4px 24px rgba(0,0,0,0.08)">
    <h2 style="text-align: center; font-size: 22px; font-weight: 600; color: #333; margin: 0 0 24px">
      用户登录
    </h2>
    <n-form ref="formRef" :model="formData" :rules="rules" label-placement="left" label-width="0">
      <n-form-item path="username">
        <n-input
          v-model:value="formData.username"
          placeholder="请输入用户名"
          size="large"
          @keydown.enter="handleLogin"
        />
      </n-form-item>
      <n-form-item path="password">
        <n-input
          v-model:value="formData.password"
          type="password"
          show-password-on="click"
          placeholder="请输入密码"
          size="large"
          @keydown.enter="handleLogin"
        />
      </n-form-item>
      <n-button
        type="primary"
        block
        size="large"
        :loading="loading"
        style="margin-top: 8px; border-radius: 8px"
        @click="handleLogin"
      >
        登 录
      </n-button>
    </n-form>
    <div style="text-align: center; margin-top: 16px; font-size: 14px; color: #666">
      还没有账号？
      <router-link to="/register" style="color: #18a058; font-weight: 500">立即注册</router-link>
    </div>
  </n-card>
</template>
