<template>
  <div class="flex flex-center bg-grey-3" :class="$style.container">
    <q-card :class="$style.registerCard">
      <q-card-section class="bg-primary text-white text-center">
        <div class="text-h5">Регистрация</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit="onSubmit" class="q-gutter-md">
          <q-banner
            v-if="validationErrors && Object.keys(validationErrors).length > 0"
            class="bg-negative text-white q-mb-md"
            rounded
          >
            <template v-slot:avatar>
              <q-icon name="error" color="white" />
            </template>
            <div class="text-weight-bold q-mb-xs">Ошибки валидации:</div>
            <ul class="q-pl-md q-my-none">
              <li v-for="(errors, field) in validationErrors" :key="field">
                <strong>{{ getFieldLabel(field) }}:</strong>
                <span v-for="(error, index) in errors" :key="index">
                  {{ error }}<span v-if="index < errors.length - 1">, </span>
                </span>
              </li>
            </ul>
          </q-banner>

          <q-input
            v-model="name"
            label="Имя"
            autocomplete="name"
            :rules="nameRules"
            :error="!!validationErrors?.name"
            :error-message="validationErrors?.name?.[0]"
            outlined
            dense
          />

          <q-input
            v-model="email"
            type="email"
            label="Email"
            autocomplete="email"
            :rules="emailRules"
            :error="!!validationErrors?.email"
            :error-message="validationErrors?.email?.[0]"
            outlined
            dense
          />

          <q-input
            v-model="password"
            type="password"
            label="Пароль"
            autocomplete="new-password"
            :rules="passwordRules"
            :error="!!validationErrors?.password"
            :error-message="validationErrors?.password?.[0]"
            outlined
            dense
          />

          <q-input
            v-model="passwordConfirmation"
            type="password"
            label="Подтверждение пароля"
            autocomplete="new-password"
            :rules="passwordConfirmationRules"
            :error="!!validationErrors?.password_confirmation"
            :error-message="validationErrors?.password_confirmation?.[0]"
            outlined
            dense
          />

          <q-btn
            type="submit"
            label="Зарегистрироваться"
            color="primary"
            class="full-width"
            :loading="isLoading"
          />
        </q-form>

        <div class="q-mt-md text-center">
          <router-link :to="{ name: ROUTE_NAMES.LOGIN }" class="text-primary">
            Уже есть аккаунт? Войдите
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

const name = ref('');
const email = ref('');
const password = ref('');
const passwordConfirmation = ref('');
const isLoading = ref(false);
const validationErrors = ref<Record<string, string[]> | null>(null);

const nameRules = computed(() => [
  (val: string) => !!val || 'Поле обязательно для заполнения'
]);

const emailRules = computed(() => [
  (val: string) => !!val || 'Поле обязательно для заполнения',
  (val: string) => /.+@.+\..+/.test(val) || 'Email не валиден'
]);

const passwordRules = computed(() => [
  (val: string) => !!val || 'Поле обязательно для заполнения',
  (val: string) => val.length >= 8 || 'Пароль должен быть не менее 8 символов'
]);

const passwordConfirmationRules = computed(() => [
  (val: string) => !!val || 'Поле обязательно для заполнения',
  (val: string) => val === password.value || 'Пароли не совпадают'
]);

function getFieldLabel(field: string): string {
  const fieldLabels: Record<string, string> = {
    name: 'Имя',
    email: 'Email',
    password: 'Пароль',
    password_confirmation: 'Подтверждение пароля',
  };
  return fieldLabels[field] || field;
}

async function onSubmit() {
  validationErrors.value = null;
  
  isLoading.value = true;
  try {
    await userStore.register({
      name: name.value,
      email: email.value,
      password: password.value,
      password_confirmation: passwordConfirmation.value,
    });

    $q.notify({
      type: 'positive',
      message: 'Регистрация прошла успешно!',
      position: 'top',
    });

    await router.replace({ name: ROUTE_NAMES.HOME });
  } catch (error: any) {
    if (error.response?.status === 422 && error.response?.data?.errors) {
      validationErrors.value = error.response.data.errors;

      return;
    }
    const errorMessage = error.response?.data?.message || 'Ошибка при регистрации';

    $q.notify({
      type: 'negative',
      message: errorMessage,
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

.registerCard {
  width: 400px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}
</style>
