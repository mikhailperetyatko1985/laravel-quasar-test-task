/**
 * Store для управления состоянием пользователя
 */

import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { authRepository } from 'src/repositories/authRepository';
import type {
  User,
  LoginCredentials,
  RegisterData,
} from 'src/types/auth.types';

export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null);
  const token = ref<string | null>(null);
  const isLoading = ref<boolean>(false);

  // Getters
  const isAuthenticated = computed(() => user.value !== null && token.value !== null);
  const currentUser = computed(() => user.value);
  const userName = computed(() => user.value?.name ?? '');
  const userEmail = computed(() => user.value?.email ?? '');

  // Actions
  /**
   * Установка токена и его сохранение в localStorage
   */
  function setToken(newToken: string) {
    token.value = newToken;
    localStorage.setItem('auth_token', newToken);
    // Устанавливаем токен в заголовки axios
    if (window.$axios) {
      window.$axios.defaults.headers.common['Authorization'] = `Bearer ${newToken}`;
    }
  }

  /**
   * Удаление токена
   */
  function clearToken() {
    token.value = null;
    localStorage.removeItem('auth_token');
    if (window.$axios) {
      delete window.$axios.defaults.headers.common['Authorization'];
    }
  }

  /**
   * Установка данных пользователя
   */
  function setUser(userData: User) {
    user.value = userData;
  }

  /**
   * Очистка данных пользователя
   */
  function clearUser() {
    user.value = null;
  }

  /**
   * Регистрация нового пользователя
   */
  async function register(data: RegisterData): Promise<void> {
    isLoading.value = true;
    try {
      const response = await authRepository.register(data);
      setUser(response.user);
      setToken(response.token);
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * Вход пользователя
   */
  async function login(credentials: LoginCredentials): Promise<void> {
    isLoading.value = true;
    try {
      const response = await authRepository.login(credentials);
      setUser(response.user);
      setToken(response.token);
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * Выход пользователя
   */
  async function logout(): Promise<void> {
    isLoading.value = true;
    try {
      await authRepository.logout();
    } catch (error) {
      console.error('Error during logout:', error);
    } finally {
      clearUser();
      clearToken();
      isLoading.value = false;
    }
  }

  /**
   * Загрузка информации о текущем пользователе
   */
  async function fetchUser(): Promise<void> {
    isLoading.value = true;
    try {
      const userData = await authRepository.getUser();
      setUser(userData);
    } catch (error) {
      clearUser();
      clearToken();
      throw error;
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * Инициализация store при загрузке приложения
   */
  function initialize() {
    const savedToken = localStorage.getItem('auth_token');
    if (savedToken) {
      token.value = savedToken;
      if (window.$axios) {
        window.$axios.defaults.headers.common['Authorization'] = `Bearer ${savedToken}`;
      }
    }
  }

  return {
    // State
    user,
    token,
    isLoading,
    // Getters
    isAuthenticated,
    currentUser,
    userName,
    userEmail,
    // Actions
    setToken,
    clearToken,
    setUser,
    clearUser,
    register,
    login,
    logout,
    fetchUser,
    initialize,
  };
});
