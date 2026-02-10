<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import { useUserStore } from 'src/stores/user.store';

const userStore = useUserStore();

onMounted(async () => {
  // Инициализируем store при загрузке приложения
  userStore.initialize();
  
  // Если есть токен, загружаем данные пользователя
  if (userStore.token) {
    try {
      await userStore.fetchUser();
    } catch (error) {
      console.error('Failed to fetch user:', error);
    }
  }
});
</script>
