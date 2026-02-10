<template>
  <div class="fullscreen bg-blue text-white text-center q-pa-md flex flex-center">
    <div>
      <div :class="$style.errorCode">
        404
      </div>

      <div class="text-h2" :class="$style.errorMessage">
        Упс. Ничего не найдено...
      </div>

      <q-btn
        class="q-mt-xl"
        color="white"
        text-color="blue"
        unelevated
        :to="{ name: ROUTE_NAMES.HOME }"
        label="Вернуться на главную"
        no-caps
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ROUTE_NAMES } from 'src/router/routes';
</script>

<style module lang="scss">
.errorCode {
  font-size: 30vh;
}

.errorMessage {
  opacity: 0.4;
}
</style>
