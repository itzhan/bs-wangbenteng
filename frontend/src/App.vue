<script setup lang="ts">
import { useMessage, zhCN, dateZhCN } from 'naive-ui'
import type { GlobalThemeOverrides } from 'naive-ui'
import { onMounted } from 'vue'

const themeOverrides: GlobalThemeOverrides = {
  common: {
    primaryColor: '#18a058',
    primaryColorHover: '#36ad6a',
    primaryColorPressed: '#0c7a43',
    primaryColorSuppl: '#36ad6a',
    bodyColor: '#f8faf5',
  },
  Button: {
    borderRadiusMedium: '8px',
  },
  Card: {
    borderRadius: '12px',
  },
  Input: {
    borderRadius: '8px',
  },
}

// Expose message API to window for request.ts
onMounted(() => {
  // Will be set by MessageApiExposer below
})
</script>

<script lang="ts">
import { defineComponent, h } from 'vue'
import { NConfigProvider, NMessageProvider, NDialogProvider } from 'naive-ui'
import MessageApiExposer from '@/components/MessageApiExposer.vue'

export default defineComponent({
  name: 'App',
})
</script>

<template>
  <n-config-provider :theme-overrides="themeOverrides" :locale="zhCN" :date-locale="dateZhCN">
    <n-message-provider>
      <n-dialog-provider>
        <MessageApiExposer />
        <router-view />
      </n-dialog-provider>
    </n-message-provider>
  </n-config-provider>
</template>

<style>
html, body {
  margin: 0;
  padding: 0;
  background-color: #f8faf5;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'PingFang SC', 'Microsoft YaHei', sans-serif;
}
</style>
