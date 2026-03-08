<script setup lang="ts">
import { NLayout, NIcon } from 'naive-ui'
import { LeafOutline } from '@vicons/ionicons5'
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<template>
  <n-layout style="min-height: 100vh; background: linear-gradient(135deg, #f0f7e6 0%, #e8f5e1 50%, #f8faf5 100%); display: flex; flex-direction: column; align-items: center; justify-content: center">
    <!-- Logo -->
    <div
      style="display: flex; align-items: center; margin-bottom: 32px; cursor: pointer"
      @click="router.push('/')"
    >
      <n-icon :size="36" color="#18a058">
        <LeafOutline />
      </n-icon>
      <span style="margin-left: 10px; font-size: 22px; font-weight: 600; color: #18a058">
        农作物种植管理系统
      </span>
    </div>

    <!-- Content -->
    <div style="width: 100%; max-width: 420px; padding: 0 16px">
      <router-view />
    </div>

    <!-- Footer -->
    <div style="margin-top: 48px; color: #999; font-size: 12px">
      农作物种植生产管理系统 &copy; 2026
    </div>
  </n-layout>
</template>
