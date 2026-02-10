<template>
  <div :class="$style.sidebarContainer">
    <div class="q-pa-md">
      <img :src="logoSrc" alt="DailyGrow" :class="$style.logo" />
      <div :class="$style.accountName" class="q-mt-sm text-grey-7">
        {{ userStore.currentUser?.name }}
      </div>
    </div>

    <div :class="$style.menuList">
      <div :class="$style.menuGroup">
        <!-- Родительский элемент -->
        <div 
          :class="[
            $style.parentItem,
            { [$style.parentItemActive]: isReviewsGroupActive }
          ]"
          @click="toggleReviewsExpanded"
        >
          <img :src="toolIconSrc" alt="" :class="$style.menuIcon" />
          <span>Отзывы</span>
        </div>

        <!-- Подменю -->
        <div v-if="reviewsExpanded" :class="$style.submenuList">
          <div
            :class="[
              $style.submenuItem,
              { [$style.submenuItemActive]: $route.name === ROUTE_NAMES.REVIEWS }
            ]"
            @click="navigateTo({ name: ROUTE_NAMES.REVIEWS })"
          >
            <span>Отзывы</span>
          </div>

          <div
            :class="[
              $style.submenuItem,
              { [$style.submenuItemActive]: $route.name === ROUTE_NAMES.SETTINGS }
            ]"
            @click="navigateTo({ name: ROUTE_NAMES.SETTINGS })"
          >
            <span>Настройки</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useUserStore } from 'src/stores/user.store';
import { ROUTE_NAMES } from 'src/router/routes';
import logoSrc from 'src/assets/images/daily-grow-logo.svg';
import toolIconSrc from 'src/assets/images/tool.svg';

const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const reviewsExpanded = ref(true);

const isReviewsGroupActive = computed(() => {
  return route.name === ROUTE_NAMES.REVIEWS || route.name === ROUTE_NAMES.SETTINGS;
});

function navigateTo(routeLocation: { name: string }) {
  router.push(routeLocation);
}

function toggleReviewsExpanded() {
  reviewsExpanded.value = !reviewsExpanded.value;
}
</script>

<style module lang="scss">
.sidebarContainer {
  height: 100%;
  display: flex;
  flex-direction: column;
  background-color: #FAFBFC;
}

.logo {
  width: 161px;
  height: 28px;
}

.accountName {
  font-size: 16px;
  font-weight: 700;
  line-height: 20px;
  letter-spacing: 0.2px;
  color: #9CA4AB;
}

.menuList {
  padding: 15px;
}

.menuGroup {
  margin-bottom: 4px;
}

.menuIcon {
  width: 24px;
  height: 24px;
  margin-right: 12px;
}

.parentItem {
  display: flex;
  align-items: center;
  padding: 14px 16px;
  min-height: 52px;
  border-radius: 12px;
  cursor: pointer;
  transition: background-color 0.2s ease;
  font-size: 15px;
  font-weight: 500;
  margin-bottom: 4px;

  &:hover {
    background-color: rgba(255, 255, 255, 0.5);
  }

  &.parentItemActive {
    background-color: #ffffff;
    box-shadow: 0px 2px 1px rgba(0, 0, 0, 0.02);
  }
}

.submenuList {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding-left: 0;
}

.submenuItem {
  display: flex;
  align-items: center;
  padding: 4px 16px 4px 52px;
  min-height: 24px;
  border-radius: 12px;
  font-size: 14px;
  color: #616161;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover {
    background-color: rgba(255, 255, 255, 0.5);
  }

  &.submenuItemActive {
    background-color: #ffffff;
    font-weight: 500;
    box-shadow: 0px 2px 1px rgba(0, 0, 0, 0.02);
  }
}
</style>
