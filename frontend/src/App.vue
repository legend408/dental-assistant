<script setup>
import HelloWorld from './components/HelloWorld.vue'
import TheWelcome from './components/TheWelcome.vue'
import { ref } from 'vue'
const message = ref('请选择你的角色')
function selectRole(role){
  message.value = `你点击了: ${role}`
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

    <p>{{message}}</p>
  </main>
</template>

<style scoped>
</style>
