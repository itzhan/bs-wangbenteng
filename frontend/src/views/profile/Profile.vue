<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  NCard,
  NForm,
  NFormItem,
  NInput,
  NButton,
  NSpace,
  NAvatar,
  NDivider,
  NGrid,
  NGi,
} from 'naive-ui'
import type { FormInst, FormRules } from 'naive-ui'
import { useUserStore } from '@/stores/user'
import { updateProfile, updatePassword } from '@/api/user'

const userStore = useUserStore()

const profileFormRef = ref<FormInst | null>(null)
const profileLoading = ref(false)
const profileData = ref({
  realName: '',
  phone: '',
  email: '',
})

const pwdFormRef = ref<FormInst | null>(null)
const pwdLoading = ref(false)
const pwdData = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: '',
})

const pwdRules: FormRules = {
  oldPassword: { required: true, message: '请输入当前密码', trigger: 'blur' },
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' },
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator(_rule: any, value: string) {
        if (value !== pwdData.value.newPassword) {
          return new Error('两次输入密码不一致')
        }
        return true
      },
      trigger: 'blur',
    },
  ],
}

async function handleUpdateProfile() {
  profileLoading.value = true
  try {
    await updateProfile(profileData.value)
    window.$message?.success('个人信息更新成功')
    await userStore.getUserInfo()
  } catch {
    // handled
  } finally {
    profileLoading.value = false
  }
}

async function handleUpdatePassword() {
  try {
    await pwdFormRef.value?.validate()
  } catch {
    return
  }
  pwdLoading.value = true
  try {
    await updatePassword({
      oldPassword: pwdData.value.oldPassword,
      newPassword: pwdData.value.newPassword,
    })
    window.$message?.success('密码修改成功，请重新登录')
    userStore.logout()
    window.location.href = '/login'
  } catch {
    // handled
  } finally {
    pwdLoading.value = false
  }
}

onMounted(async () => {
  if (!userStore.userId) {
    await userStore.getUserInfo()
  }
  profileData.value = {
    realName: userStore.realName,
    phone: userStore.phone,
    email: userStore.email,
  }
})
</script>

<template>
  <div>
    <h2 style="font-size: 22px; font-weight: 600; color: #333; margin: 0 0 20px">个人中心</h2>

    <n-grid :x-gap="20" :y-gap="20" cols="1 m:2" responsive="screen">
      <n-gi>
        <n-card style="border-radius: 12px">
          <template #header>个人信息</template>

          <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 24px">
            <n-avatar
              v-if="userStore.avatar"
              :src="userStore.avatar"
              :size="64"
              round
            />
            <n-avatar v-else :size="64" round style="background: #18a058; color: #fff; font-size: 24px">
              {{ (userStore.realName || userStore.username || '用').charAt(0) }}
            </n-avatar>
            <div>
              <div style="font-size: 18px; font-weight: 600; color: #333">
                {{ userStore.realName || userStore.username }}
              </div>
              <div style="font-size: 13px; color: #999; margin-top: 4px">
                用户名：{{ userStore.username }}
              </div>
            </div>
          </div>

          <n-form ref="profileFormRef" :model="profileData" label-placement="left" label-width="80">
            <n-form-item label="真实姓名">
              <n-input v-model:value="profileData.realName" placeholder="真实姓名" />
            </n-form-item>
            <n-form-item label="手机号">
              <n-input v-model:value="profileData.phone" placeholder="手机号" />
            </n-form-item>
            <n-form-item label="邮箱">
              <n-input v-model:value="profileData.email" placeholder="邮箱" />
            </n-form-item>
          </n-form>

          <n-button type="primary" :loading="profileLoading" @click="handleUpdateProfile">
            保存修改
          </n-button>
        </n-card>
      </n-gi>

      <n-gi>
        <n-card style="border-radius: 12px">
          <template #header>修改密码</template>

          <n-form ref="pwdFormRef" :model="pwdData" :rules="pwdRules" label-placement="left" label-width="90">
            <n-form-item label="当前密码" path="oldPassword">
              <n-input
                v-model:value="pwdData.oldPassword"
                type="password"
                show-password-on="click"
                placeholder="请输入当前密码"
              />
            </n-form-item>
            <n-form-item label="新密码" path="newPassword">
              <n-input
                v-model:value="pwdData.newPassword"
                type="password"
                show-password-on="click"
                placeholder="请输入新密码"
              />
            </n-form-item>
            <n-form-item label="确认新密码" path="confirmPassword">
              <n-input
                v-model:value="pwdData.confirmPassword"
                type="password"
                show-password-on="click"
                placeholder="请再次输入新密码"
              />
            </n-form-item>
          </n-form>

          <n-button type="warning" :loading="pwdLoading" @click="handleUpdatePassword">
            修改密码
          </n-button>
        </n-card>
      </n-gi>
    </n-grid>
  </div>
</template>
