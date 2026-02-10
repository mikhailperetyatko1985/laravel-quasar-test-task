<template>
  <div class="flex flex-center bg-grey-3" :class="$style.container">
    <q-card :class="$style.loginCard">
      <q-card-section class="bg-primary text-white text-center">
        <div class="text-h5">Вход в систему</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit="onSubmit" class="q-gutter-md">
          <q-input
            v-model="email"
            type="email"
            label="Email"
            autocomplete="email"
            :rules="emailRules"
            outlined
            dense
          />

          <q-input
            v-model="password"
            type="password"
            label="Пароль"
            autocomplete="current-password"
            :rules="passwordRules"
            outlined
            dense
          />

          <q-btn
            type="submit"
            label="Войти"
            color="primary"
            class="full-width"
            :loading="isLoading"
          />
        </q-form>

        <div class="q-mt-md text-center">
          <router-link :to="{ name: ROUTE_NAMES.REGISTER }" class="text-primary">
            Нет аккаунта? Зарегистрируйтесь
          </router-link>
        </div>
      </q-card-section>
    </q-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useQuasar } from 'quasar';
import { useUserStore } from 'src/stores/user.store';
import { ROUTE_NAMES } from 'src/router/routes';

const router = useRouter();
const $q = useQuasar();
const userStore = useUserStore();

const email = ref('');
const password = ref('');
const isLoading = ref(false);

const emailRules = computed(() => [
  (val: string) => !!val || 'Поле обязательно для заполнения'
]);

const passwordRules = computed(() => [
  (val: string) => !!val || 'Поле обязательно для заполнения'
]);

async function onSubmit() {
  isLoading.value = true;
  try {
    await userStore.login({
      email: email.value,
      password: password.value,
    });

    $q.notify({
      type: 'positive',
      message: 'Вход выполнен успешно!',
      position: 'top',
    });

    await router.replace({ name: ROUTE_NAMES.HOME });
  } catch (error: any) {
    $q.notify({
      type: 'negative',
      message: error.response?.data?.message || 'Ошибка при входе',
      position: 'top',
    });
  } finally {
    isLoading.value = false;
  }
}
</script>

<style module lang="scss">
.container {
  min-height: 100vh;
}

.loginCard {
  width: 400px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}
</style>
