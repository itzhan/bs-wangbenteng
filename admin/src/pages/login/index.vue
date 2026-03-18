<template>
  <div class="login-page">
    <!-- 左侧展示区 -->
    <div class="login-showcase">
      <div class="showcase-overlay"></div>
      <div class="showcase-content">
        <div class="showcase-icon">
          <t-icon name="broccoli" size="48px" />
        </div>
        <h1 class="showcase-title">农作物种植生产管理系统</h1>
        <p class="showcase-subtitle">Crop Planting & Production Management System</p>
        <div class="showcase-features">
          <div class="feature-item">
            <t-icon name="calendar" size="20px" />
            <span>智能种植计划管理</span>
          </div>
          <div class="feature-item">
            <t-icon name="chart-bar" size="20px" />
            <span>产量与成本数据分析</span>
          </div>
          <div class="feature-item">
            <t-icon name="tools" size="20px" />
            <span>田间作业全流程追踪</span>
          </div>
          <div class="feature-item">
            <t-icon name="shop" size="20px" />
            <span>农资库存实时预警</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 右侧登录区 -->
    <div class="login-form-area">
      <div class="form-wrapper">
        <div class="form-header">
          <div class="brand-icon">
            <t-icon name="broccoli" size="36px" style="color: #2ba471" />
          </div>
          <h2 class="form-title">管理后台</h2>
          <p class="form-desc">欢迎回来，请登录您的账户</p>
        </div>

        <t-form
          ref="form"
          :data="formData"
          :rules="FORM_RULES"
          label-width="0"
          @submit="onSubmit"
        >
          <t-form-item name="account">
            <t-input v-model="formData.account" size="large" placeholder="请输入用户名">
              <template #prefix-icon>
                <t-icon name="user" />
              </template>
            </t-input>
          </t-form-item>

          <t-form-item name="password">
            <t-input
              v-model="formData.password"
              size="large"
              :type="showPsw ? 'text' : 'password'"
              clearable
              placeholder="请输入密码"
            >
              <template #prefix-icon>
                <t-icon name="lock-on" />
              </template>
              <template #suffix-icon>
                <t-icon :name="showPsw ? 'browse' : 'browse-off'" @click="showPsw = !showPsw" />
              </template>
            </t-input>
          </t-form-item>

          <div class="form-options">
            <t-checkbox v-model="rememberMe">记住密码</t-checkbox>
          </div>

          <t-form-item class="btn-container">
            <t-button block size="large" type="submit" :loading="loading">
              登 录
            </t-button>
          </t-form-item>
        </t-form>

        <div class="form-footer">
          <div class="test-accounts">
            <p class="accounts-title">测试账号</p>
            <div class="account-tags">
              <t-tag theme="primary" variant="light" @click="fillAccount('admin', '123456')">管理员: admin</t-tag>
              <t-tag theme="success" variant="light" @click="fillAccount('tech01', '123456')">技术员: tech01</t-tag>
              <t-tag theme="warning" variant="light" @click="fillAccount('farmer01', '123456')">种植户: farmer01</t-tag>
            </div>
            <p class="accounts-hint">密码均为 123456，点击可快速填充</p>
          </div>
        </div>
      </div>

      <footer class="login-copyright">
        农作物种植生产管理系统 &copy; 2025 毕业设计
      </footer>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { FormInstanceFunctions, FormRule, SubmitContext } from 'tdesign-vue-next';
import { MessagePlugin } from 'tdesign-vue-next';
import { ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';

import { useUserStore } from '@/store';

defineOptions({ name: 'LoginPage' });

const userStore = useUserStore();
const router = useRouter();
const route = useRoute();

const formData = ref({
  account: 'admin',
  password: '123456',
});

const FORM_RULES: Record<string, FormRule[]> = {
  account: [{ required: true, message: '请输入用户名', type: 'error' }],
  password: [{ required: true, message: '请输入密码', type: 'error' }],
};

const form = ref<FormInstanceFunctions>();
const showPsw = ref(false);
const loading = ref(false);
const rememberMe = ref(true);

const fillAccount = (account: string, password: string) => {
  formData.value.account = account;
  formData.value.password = password;
};

const onSubmit = async (ctx: SubmitContext) => {
  if (ctx.validateResult === true) {
    loading.value = true;
    try {
      await userStore.login(formData.value);
      MessagePlugin.success('登录成功');
      const redirect = route.query.redirect as string;
      const redirectUrl = redirect ? decodeURIComponent(redirect) : '/dashboard/base';
      router.push(redirectUrl);
    } catch (e: any) {
      MessagePlugin.error(e.message || '登录失败');
    } finally {
      loading.value = false;
    }
  }
};
</script>

<style lang="less" scoped>
.login-page {
  display: flex;
  min-height: 100vh;
  background: #f0f5eb;
}

/* 左侧展示区 */
.login-showcase {
  flex: 1;
  position: relative;
  background-image: url('https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1200&h=900&fit=crop');
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;

  @media screen and (max-width: 900px) {
    display: none;
  }
}

.showcase-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(34, 120, 60, 0.85) 0%, rgba(24, 100, 50, 0.75) 50%, rgba(20, 80, 40, 0.65) 100%);
}

.showcase-content {
  position: relative;
  z-index: 1;
  color: white;
  padding: 48px;
  max-width: 480px;
}

.showcase-icon {
  width: 72px;
  height: 72px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.15);
}

.showcase-title {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.3;
  margin: 0 0 12px;
  letter-spacing: 1px;
}

.showcase-subtitle {
  font-size: 14px;
  opacity: 0.8;
  margin: 0 0 48px;
  font-weight: 300;
  letter-spacing: 0.5px;
}

.showcase-features {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 14px;
  font-size: 15px;
  opacity: 0.9;
  padding: 12px 18px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  backdrop-filter: blur(5px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  transition: all 0.3s;

  &:hover {
    background: rgba(255, 255, 255, 0.18);
    transform: translateX(4px);
  }
}

/* 右侧登录区 */
.login-form-area {
  width: 480px;
  min-width: 420px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px;
  background: white;
  position: relative;

  @media screen and (max-width: 900px) {
    width: 100%;
    min-width: auto;
  }
}

.form-wrapper {
  width: 100%;
  max-width: 380px;
}

.form-header {
  text-align: center;
  margin-bottom: 40px;
}

.brand-icon {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #e8f5e1 0%, #d4edcc 100%);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
}

.form-title {
  font-size: 24px;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 8px;
}

.form-desc {
  font-size: 14px;
  color: #999;
  margin: 0;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.btn-container {
  margin-bottom: 0;

  :deep(.t-button) {
    height: 44px;
    font-size: 16px;
    border-radius: 8px;
    background: linear-gradient(135deg, #2ba471 0%, #18a058 100%);
    border: none;

    &:hover {
      background: linear-gradient(135deg, #36ad6a 0%, #22b05e 100%);
    }
  }
}

.form-footer {
  margin-top: 32px;
}

.test-accounts {
  background: #f8faf6;
  border-radius: 10px;
  padding: 16px;
  border: 1px solid #e8f0e4;
}

.accounts-title {
  font-size: 13px;
  font-weight: 600;
  color: #666;
  margin: 0 0 10px;
}

.account-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;

  :deep(.t-tag) {
    cursor: pointer;
    transition: all 0.2s;

    &:hover {
      transform: scale(1.05);
    }
  }
}

.accounts-hint {
  font-size: 12px;
  color: #aaa;
  margin: 10px 0 0;
}

.login-copyright {
  position: absolute;
  bottom: 24px;
  font-size: 13px;
  color: #bbb;
}
</style>
