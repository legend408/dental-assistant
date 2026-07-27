<script setup>
import HelloWorld from './components/HelloWorld.vue'
import TheWelcome from './components/TheWelcome.vue'
import { ref } from 'vue'
const message = ref('请选择你的角色')
function selectRole(role){
  message.value = `你点击了: ${role}`
}
async function checkHealth() {
  message.value = '正在检查...'
  try {
    const res = await fetch('http://127.0.0.1:8000/api/health')
    const data = await res.json()
    message.value = data.message
  } catch (err) {
    message.value = '连接后端失败，请检查后端是否已启动'
    console.error(err)
  }
}
</script>

<template>
  <header>
    <h1>牙科诊疗助手</h1>
  </header>

  <main>
    <button @click="selectRole('患者端')">患者端</button>
    <button @click="selectRole('医生端')">医生端</button>
    <button @click="selectRole('管理端')">管理端</button>
    <button @click="checkHealth">检查系统状态</button>
    <p>{{message}}</p>
  </main>
</template>

<style scoped>
</style>
