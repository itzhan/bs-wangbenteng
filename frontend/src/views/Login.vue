<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { NButton, NCheckbox, NForm, NFormItem, NIcon, NInput } from 'naive-ui'
import { ArrowForwardOutline, LeafOutline, TrendingUpOutline, WaterOutline } from '@vicons/ionicons5'
import { useUserStore } from '@/stores/user'
import type { FormInst, FormRules } from 'naive-ui'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const formRef = ref<FormInst | null>(null)
const loading = ref(false)
const rememberMe = ref(true)
const formData = ref({
  username: '',
  password: '',
})

const quickAccounts = [
  { label: '管理员', username: 'admin', hint: '查看全局数据与计划审批' },
  { label: '技术员', username: 'tech01', hint: '跟踪指导记录与现场作业' },
  { label: '农户', username: 'farmer01', hint: '提交计划并查看种植进度' },
]

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

function fillAccount(username: string) {
  formData.value.username = username
  formData.value.password = '123456'
}
</script>

<template>
  <div class="login-shell">
    <section class="login-stage">
      <aside class="login-hero">
        <div class="login-hero__topbar">
          <button class="login-hero__brand" type="button" @click="router.push('/')">
            <n-icon :size="24"><LeafOutline /></n-icon>
            <span>CropFlow</span>
          </button>
          <div class="login-hero__tag">用户端登录</div>
        </div>

        <div class="login-hero__content">
          <div class="login-hero__eyebrow">智慧农事协同平台</div>
          <h1>把计划、投入、产量和作业节奏放在同一张农业驾驶舱里。</h1>
          <p>
            从种植户日报到技术指导复盘，登录后即可查看计划进度、物资库存、成本走势与产量表现。
          </p>

          <div class="login-hero__metrics">
            <div class="metric-card">
              <div class="metric-card__label">计划履约率</div>
              <div class="metric-card__value">94%</div>
              <div class="metric-card__hint">持续跟踪关键节点</div>
            </div>
            <div class="metric-card metric-card--accent">
              <div class="metric-card__label">田间作业回填</div>
              <div class="metric-card__value">1,286</div>
              <div class="metric-card__hint">覆盖灌溉、施肥、收获</div>
            </div>
          </div>

          <div class="login-hero__feature-list">
            <div class="feature-item">
              <div class="feature-item__icon">
                <n-icon :size="18"><TrendingUpOutline /></n-icon>
              </div>
              <div>
                <div class="feature-item__title">趋势看板</div>
                <div class="feature-item__desc">成本、产量与计划状态一屏联动</div>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-item__icon feature-item__icon--warm">
                <n-icon :size="18"><WaterOutline /></n-icon>
              </div>
              <div>
                <div class="feature-item__title">现场协同</div>
                <div class="feature-item__desc">技术员与农户统一记录田间操作</div>
              </div>
            </div>
          </div>
        </div>
      </aside>

      <section class="login-panel">
        <div class="login-card">
          <div class="login-card__header">
            <div class="login-card__badge">
              <n-icon :size="20"><LeafOutline /></n-icon>
            </div>
            <div>
              <div class="login-card__title">欢迎回来</div>
              <div class="login-card__subtitle">输入账号密码，进入农场工作台</div>
            </div>
          </div>

          <n-form ref="formRef" :model="formData" :rules="rules" label-placement="top" size="large" class="login-form">
            <n-form-item path="username" label="账号">
              <n-input
                v-model:value="formData.username"
                class="login-input"
                placeholder="请输入用户名"
                @keydown.enter="handleLogin"
              />
            </n-form-item>
            <n-form-item path="password" label="密码">
              <n-input
                v-model:value="formData.password"
                class="login-input"
                type="password"
                show-password-on="click"
                placeholder="请输入密码"
                @keydown.enter="handleLogin"
              />
            </n-form-item>

            <div class="login-form__row">
              <n-checkbox v-model:checked="rememberMe">记住登录偏好</n-checkbox>
              <span class="login-form__tip">测试密码统一为 123456</span>
            </div>

            <n-button
              type="primary"
              block
              size="large"
              :loading="loading"
              class="login-submit"
              @click="handleLogin"
            >
              进入系统
              <template #icon>
                <n-icon><ArrowForwardOutline /></n-icon>
              </template>
            </n-button>
          </n-form>

          <div class="login-accounts">
            <div class="login-accounts__title">快速填充账号</div>
            <button
              v-for="account in quickAccounts"
              :key="account.username"
              class="account-pill"
              type="button"
              @click="fillAccount(account.username)"
            >
              <span class="account-pill__label">{{ account.label }}</span>
              <span class="account-pill__username">{{ account.username }}</span>
              <span class="account-pill__hint">{{ account.hint }}</span>
            </button>
          </div>

          <div class="login-card__footer">
            <span>还没有账号？</span>
            <router-link to="/register">立即注册</router-link>
          </div>
        </div>
      </section>
    </section>
  </div>
</template>

<style scoped>
.login-shell {
  height: 100%;
}

.login-stage {
  position: relative;
  min-height: 100vh;
  display: grid;
  grid-template-columns: minmax(0, 1.22fr) minmax(420px, 0.9fr);
  background:
    radial-gradient(circle at 18% 16%, rgba(188, 221, 154, 0.26), transparent 24%),
    linear-gradient(135deg, #f4f0de 0%, #edf5e6 48%, #f8f5ea 100%);
}

.login-stage::after {
  content: '';
  position: absolute;
  inset: 22px;
  border: 1px solid rgba(76, 96, 55, 0.08);
  border-radius: 30px;
  pointer-events: none;
}

.login-hero {
  position: relative;
  padding: 40px 42px 48px 54px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  background:
    linear-gradient(160deg, rgba(28, 57, 35, 0.92) 0%, rgba(37, 78, 44, 0.9) 54%, rgba(92, 112, 44, 0.88) 100%);
  color: #f6f4ea;
  overflow: hidden;
}

.login-hero::before {
  content: '';
  position: absolute;
  inset: auto -12% -18% auto;
  width: 420px;
  height: 420px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(240, 189, 107, 0.24), transparent 62%);
}

.login-hero::after {
  content: '';
  position: absolute;
  left: -110px;
  top: 110px;
  width: 260px;
  height: 260px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(194, 227, 156, 0.18), transparent 66%);
}

.login-hero__topbar,
.login-hero__content {
  position: relative;
  z-index: 1;
}

.login-hero__topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.login-hero__brand {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 0;
  border: 0;
  background: transparent;
  color: inherit;
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 0.04em;
  cursor: pointer;
}

.login-hero__tag {
  padding: 8px 14px;
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.08);
  font-size: 12px;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

.login-hero__content {
  max-width: 620px;
}

.login-hero__eyebrow {
  display: inline-flex;
  margin-bottom: 18px;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.1);
  color: #dae9c8;
  font-size: 12px;
  letter-spacing: 0.16em;
  text-transform: uppercase;
}

.login-hero h1 {
  margin: 0;
  font-size: clamp(38px, 4.3vw, 64px);
  line-height: 1.04;
  letter-spacing: -0.03em;
  max-width: 12ch;
}

.login-hero p {
  margin: 22px 0 0;
  max-width: 560px;
  color: rgba(246, 244, 234, 0.84);
  font-size: 16px;
  line-height: 1.85;
}

.login-hero__metrics {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin-top: 34px;
}

.metric-card {
  padding: 22px 22px 20px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(8px);
}

.metric-card--accent {
  background: rgba(233, 192, 111, 0.16);
}

.metric-card__label {
  color: rgba(246, 244, 234, 0.72);
  font-size: 12px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.metric-card__value {
  margin-top: 10px;
  font-size: 34px;
  font-weight: 700;
  letter-spacing: -0.03em;
}

.metric-card__hint {
  margin-top: 8px;
  font-size: 13px;
  color: rgba(246, 244, 234, 0.74);
}

.login-hero__feature-list {
  display: grid;
  gap: 16px;
  margin-top: 34px;
}

.feature-item {
  display: flex;
  align-items: flex-start;
  gap: 14px;
}

.feature-item__icon {
  width: 40px;
  height: 40px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 14px;
  background: rgba(194, 227, 156, 0.16);
  color: #d8efbe;
}

.feature-item__icon--warm {
  background: rgba(234, 190, 108, 0.18);
  color: #f3d28a;
}

.feature-item__title {
  font-size: 15px;
  font-weight: 700;
}

.feature-item__desc {
  margin-top: 4px;
  font-size: 13px;
  color: rgba(246, 244, 234, 0.72);
}

.login-panel {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 30px;
}

.login-card {
  position: relative;
  z-index: 1;
  width: min(460px, 100%);
  padding: 34px 32px 28px;
  border-radius: 30px;
  background: rgba(255, 255, 255, 0.82);
  border: 1px solid rgba(99, 113, 85, 0.12);
  box-shadow: 0 24px 60px rgba(33, 52, 28, 0.12);
  backdrop-filter: blur(14px);
}

.login-card__header {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 28px;
}

.login-card__badge {
  width: 46px;
  height: 46px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 16px;
  background: linear-gradient(135deg, #264f2c 0%, #66883c 100%);
  color: #fffaf0;
  box-shadow: 0 12px 28px rgba(73, 101, 46, 0.18);
}

.login-card__title {
  font-size: 28px;
  font-weight: 700;
  color: #203019;
  letter-spacing: -0.03em;
}

.login-card__subtitle {
  margin-top: 4px;
  font-size: 14px;
  color: #6c7661;
}

.login-form :deep(.n-form-item-label__text) {
  font-size: 13px;
  font-weight: 600;
  color: #55614b;
}

.login-input :deep(.n-input) {
  --n-border: 1px solid rgba(104, 122, 84, 0.18);
  --n-border-hover: 1px solid rgba(72, 121, 64, 0.38);
  --n-border-focus: 1px solid #5f8b46;
  --n-box-shadow-focus: 0 0 0 3px rgba(95, 139, 70, 0.14);
  --n-color: rgba(250, 249, 244, 0.96);
  border-radius: 18px;
}

.login-input :deep(.n-input-wrapper) {
  padding-left: 4px;
  min-height: 52px;
}

.login-form__row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-top: -4px;
  margin-bottom: 18px;
}

.login-form__tip {
  color: #7b866f;
  font-size: 12px;
}

.login-submit {
  --n-height: 54px;
  --n-border-radius: 18px;
  --n-color: linear-gradient(135deg, #2e5b31 0%, #759942 100%);
  --n-color-hover: linear-gradient(135deg, #356a39 0%, #7fa748 100%);
  --n-color-pressed: linear-gradient(135deg, #294c2b 0%, #688839 100%);
  box-shadow: 0 18px 32px rgba(73, 106, 46, 0.22);
  font-size: 15px;
  font-weight: 700;
}

.login-accounts {
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid rgba(99, 113, 85, 0.12);
}

.login-accounts__title {
  margin-bottom: 12px;
  color: #596451;
  font-size: 13px;
  font-weight: 700;
}

.account-pill {
  width: 100%;
  display: grid;
  grid-template-columns: auto auto 1fr;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
  padding: 14px 16px;
  border: 1px solid rgba(87, 104, 67, 0.12);
  border-radius: 18px;
  background: rgba(248, 246, 239, 0.88);
  text-align: left;
  cursor: pointer;
  transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
}

.account-pill:hover {
  transform: translateY(-2px);
  border-color: rgba(95, 139, 70, 0.28);
  box-shadow: 0 14px 28px rgba(43, 61, 32, 0.08);
}

.account-pill__label {
  color: #1f3220;
  font-size: 14px;
  font-weight: 700;
}

.account-pill__username {
  color: #66883c;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.04em;
}

.account-pill__hint {
  color: #73806b;
  font-size: 12px;
  justify-self: end;
}

.login-card__footer {
  margin-top: 18px;
  color: #6f7a66;
  font-size: 14px;
  text-align: center;
}

.login-card__footer a {
  margin-left: 6px;
  color: #365f2f;
  font-weight: 700;
}

@media (max-width: 1100px) {
  .login-stage {
    grid-template-columns: 1fr;
  }

  .login-stage::after {
    inset: 16px;
  }

  .login-hero {
    min-height: 420px;
    padding: 28px 24px 34px;
  }

  .login-panel {
    padding: 22px 18px 34px;
    margin-top: -42px;
  }

  .login-card {
    width: min(560px, 100%);
  }
}

@media (max-width: 700px) {
  .login-stage::after {
    display: none;
  }

  .login-hero {
    min-height: auto;
  }

  .login-hero__topbar {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .login-hero h1 {
    max-width: none;
    font-size: 34px;
  }

  .login-hero p {
    font-size: 15px;
  }

  .login-hero__metrics {
    grid-template-columns: 1fr;
  }

  .login-panel {
    margin-top: 0;
    padding: 18px 14px 28px;
  }

  .login-card {
    padding: 24px 18px 20px;
    border-radius: 22px;
  }

  .login-card__title {
    font-size: 24px;
  }

  .login-form__row {
    flex-direction: column;
    align-items: flex-start;
  }

  .account-pill {
    grid-template-columns: 1fr;
  }

  .account-pill__hint {
    justify-self: start;
  }
}
</style>
