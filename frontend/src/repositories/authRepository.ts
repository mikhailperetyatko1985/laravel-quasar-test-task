/**
 * Репозиторий для работы с API аутентификации
 */

import { api } from 'src/boot/axios';
import type {
  LoginCredentials,
  RegisterData,
  AuthResponse,
  User,
} from 'src/types/auth.types';

export const authRepository = {
  /**
   * Регистрация нового пользователя
   */
  async register(data: RegisterData): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/api/auth/register', data);
    return response.data;
  },

  /**
   * Вход пользователя
   */
  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>(
      '/api/auth/login',
      credentials
    );
    return response.data;
  },

  /**
   * Выход пользователя
   */
  async logout(): Promise<void> {
    await api.post('/api/auth/logout');
  },

  /**
   * Получение информации о текущем пользователе
   */
  async getUser(): Promise<User> {
    const response = await api.get<{ user: User }>('/api/auth/user');
    return response.data.user;
  },
};
