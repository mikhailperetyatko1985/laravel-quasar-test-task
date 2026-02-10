import { boot } from 'quasar/wrappers';
import axios, { AxiosInstance } from 'axios';

declare module '@vue/runtime-core' {
    interface ComponentCustomProperties {
        $axios: AxiosInstance;
        $api: AxiosInstance;
    }
}

const api = axios.create({
    baseURL: process.env.API_URL || 'https://localhost',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
});

export default boot(({ app, router }) => {
    app.config.globalProperties.$axios = axios;
    app.config.globalProperties.$api = api;

    // Добавляем токен к каждому запросу
    api.interceptors.request.use(
        (config) => {
            const token = localStorage.getItem('auth_token');
            if (token) {
                config.headers.Authorization = `Bearer ${token}`;
            }
            return config;
        },
        (error) => {
            return Promise.reject(error);
        }
    );

    // Обработка 401 ошибок (неавторизован)
    api.interceptors.response.use(
        (response) => response,
        async (error) => {
            if (error.response?.status === 401) {
                // Импортируем динамически, чтобы избежать проблем с циклическими зависимостями
                const { useUserStore } = await import('src/stores/user.store');
                const userStore = useUserStore();
                userStore.clearUser();
                userStore.clearToken();
                void router.push('/login');
            }
            return Promise.reject(error);
        }
    );
});

export { api };