<template>
  <q-layout view="lHh LpR lFf">
    <q-drawer
      :model-value="true"
      :width="255"
      bordered
      class="bg-grey-2"
    >
      <SidebarMenu />
    </q-drawer>

    <q-header class="bg-white text-dark" bordered>
      <q-toolbar :class="[$style.toolbar, 'q-py-sm']">
        <q-space />

        <q-btn
          v-if="userStore.isAuthenticated"
          flat
          dense
          @click="logout"
          class="text-grey-7"
        >
          <q-icon :class="$style.logoutIcon">
            <img :src="logoutIcon" />
          </q-icon>
          <q-tooltip>Выйти</q-tooltip>
        </q-btn>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';
import { useUserStore } from 'src/stores/user.store';
import SidebarMenu from 'src/components/SidebarMenu.vue';
import logoutIcon from 'src/assets/images/logout.svg';

const router = useRouter();
const userStore = useUserStore();

async function logout() {
  await userStore.logout();
  router.push('/login');
}
</script>

<style module lang="scss">
.toolbar {
  min-height: 75px;
}

.logoutIcon {
  width: 44px;
  height: 44px;
}
</style>
