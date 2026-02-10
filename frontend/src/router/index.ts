import { route } from 'quasar/wrappers';
import {
    createMemoryHistory,
    createRouter,
    createWebHashHistory,
    createWebHistory,
} from 'vue-router';
import { useUserStore } from 'src/stores/user.store';
import routes from './routes';
import { pinia } from 'src/boot/pinia';

export default route(function (/* { store, ssrContext } */) {
    const createHistory = process.env.SERVER
        ? createMemoryHistory
        : (process.env.VUE_ROUTER_MODE === 'history' ? createWebHistory : createWebHashHistory);

    const Router = createRouter({
        scrollBehavior: () => ({ left: 0, top: 0 }),
        routes,
        history: createHistory(process.env.VUE_ROUTER_BASE),
    });

    // Navigation guard для проверки аутентификации
    Router.beforeEach(async (to, from, next) => {
        const userStore = useUserStore(pinia);

        // Инициализируем токен из localStorage если еще не инициализирован
        if (!userStore.token) {
            userStore.initialize();
        }

        // Если есть токен, но нет данных пользователя, загружаем их
        if (userStore.token && !userStore.user) {
            try {
                await userStore.fetchUser();
            } catch (error) {
                // Если токен невалиден, очищаем его
                userStore.clearToken();
                userStore.clearUser();
            }
        }

        // Публичные роуты
        const publicPages = ['/login', '/register'];
        const authRequired = !publicPages.includes(to.path);

        // Если требуется аутентификация, но пользователь не авторизован
        if (authRequired && !userStore.isAuthenticated) {
            return next('/login');
        }

        // Если пользователь авторизован и пытается попасть на login/register
        if (userStore.isAuthenticated && publicPages.includes(to.path)) {
            return next('/');
        }

        next();
    });

    return Router;
});