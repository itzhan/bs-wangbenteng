<script setup lang="ts">
import { computed } from 'vue'
import { NIcon, NLayout } from 'naive-ui'
import { LeafOutline } from '@vicons/ionicons5'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const isLoginPage = computed(() => route.name === 'Login')
</script>

<template>
  <n-layout class="auth-layout" :class="{ 'auth-layout--login': isLoginPage }">
    <div class="auth-layout__glow auth-layout__glow--one" />
    <div class="auth-layout__glow auth-layout__glow--two" />

    <div v-if="!isLoginPage" class="auth-layout__brand" @click="router.push('/')">
      <n-icon :size="34" color="#204f2e">
        <LeafOutline />
      </n-icon>
      <div>
        <div class="auth-layout__brand-title">农作物种植管理系统</div>
        <div class="auth-layout__brand-subtitle">智慧农事 · 数据驱动 · 协同管理</div>
      </div>
    </div>

    <div class="auth-layout__content" :class="{ 'auth-layout__content--wide': isLoginPage }">
      <router-view />
    </div>

    <div v-if="!isLoginPage" class="auth-layout__footer">
      农作物种植生产管理系统 &copy; 2026
    </div>
  </n-layout>
</template>

<style scoped>
.auth-layout {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  background:
    radial-gradient(circle at top left, rgba(166, 211, 126, 0.32), transparent 28%),
    radial-gradient(circle at right 15%, rgba(232, 183, 109, 0.18), transparent 24%),
    linear-gradient(145deg, #eef5df 0%, #f8f4e8 48%, #eff6ee 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
}

.auth-layout--login {
  padding: 0;
}

.auth-layout__glow {
  position: absolute;
  border-radius: 999px;
  filter: blur(14px);
  pointer-events: none;
  opacity: 0.85;
}

.auth-layout__glow--one {
  top: 9%;
  left: 7%;
  width: 220px;
  height: 220px;
  background: rgba(115, 170, 92, 0.18);
}

.auth-layout__glow--two {
  right: 8%;
  bottom: 12%;
  width: 260px;
  height: 260px;
  background: rgba(224, 167, 87, 0.14);
}

.auth-layout__brand {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 28px;
  padding: 16px 22px;
  border: 1px solid rgba(78, 104, 62, 0.12);
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.66);
  box-shadow: 0 18px 40px rgba(40, 58, 34, 0.08);
  backdrop-filter: blur(12px);
  cursor: pointer;
}

.auth-layout__brand-title {
  font-size: 21px;
  font-weight: 700;
  color: #204f2e;
  line-height: 1.2;
}

.auth-layout__brand-subtitle {
  margin-top: 4px;
  font-size: 12px;
  color: #60715c;
  letter-spacing: 0.08em;
}

.auth-layout__content {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 460px;
}

.auth-layout__content--wide {
  max-width: none;
  height: 100vh;
}

.auth-layout__footer {
  position: relative;
  z-index: 1;
  margin-top: 28px;
  color: #77816d;
  font-size: 12px;
  letter-spacing: 0.04em;
}
</style>
