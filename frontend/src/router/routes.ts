import { RouteRecordRaw } from 'vue-router';

// Route names
export const ROUTE_NAMES = {
  HOME: 'home',
  REVIEWS: 'reviews',
  SETTINGS: 'settings',
  LOGIN: 'login',
  REGISTER: 'register',
  NOT_FOUND: 'not-found',
} as const;

const routes: RouteRecordRaw[] = [
    {
        path: '/',
        name: ROUTE_NAMES.HOME,
        component: () => import('layouts/MainLayout.vue'),
        children: [
            { path: '', redirect: { name: ROUTE_NAMES.REVIEWS } },
            { 
                path: 'reviews',
                name: ROUTE_NAMES.REVIEWS,
                component: () => import('pages/ReviewsPage.vue'),
                meta: { title: 'Отзывы' }
            },
            { 
                path: 'settings',
                name: ROUTE_NAMES.SETTINGS,
                component: () => import('pages/SettingsPage.vue'),
                meta: { title: 'Подключение площадок' }
            }
        ],
        meta: { requiresAuth: true }
    },
    {
        path: '/login',
        name: ROUTE_NAMES.LOGIN,
        component: () => import('pages/Login.vue'),
        meta: { requiresAuth: false }
    },
    {
        path: '/register',
        name: ROUTE_NAMES.REGISTER,
        component: () => import('pages/Register.vue'),
        meta: { requiresAuth: false }
    },
    {
        path: '/:catchAll(.*)*',
        name: ROUTE_NAMES.NOT_FOUND,
        component: () => import('pages/ErrorNotFound.vue'),
    },
];

export default routes;