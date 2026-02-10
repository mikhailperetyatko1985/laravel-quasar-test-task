<template>
  <q-page :class="$style.pageContainer">
    <div v-if="yandexParserStore.isLoading" :class="$style.loadingContainer">
      <q-card :class="$style.loadingCard">
        <q-card-section class="text-center">
          <q-spinner color="primary" size="60px" />
          <div class="q-mt-md text-h6">Загрузка данных из Яндекс.Карт...</div>
          <div class="q-mt-sm text-caption text-grey-7">
            Это может занять 2-3 минуты
          </div>
        </q-card-section>
      </q-card>
    </div>

    <div v-else-if="yandexParserStore.error" :class="$style.errorContainer">
      <q-card :class="$style.errorCard">
        <q-card-section>
          <div class="q-mb-md">
            <q-icon name="error" color="negative" size="48px" />
          </div>
          <div class="text-h6 q-mb-sm">Ошибка при загрузке данных</div>
          <div class="text-body2 text-grey-7 q-mb-md">
            {{ yandexParserStore.error }}
          </div>
          <q-btn
            color="primary"
            label="Перейти к настройкам"
            unelevated
            @click="$router.push({ name: ROUTE_NAMES.SETTINGS })"
          />
        </q-card-section>
      </q-card>
    </div>

    <div v-else-if="!yandexParserStore.hasData" :class="$style.emptyContainer">
      <q-card :class="$style.emptyCard">
        <q-card-section class="text-center">
          <q-icon name="rate_review" color="grey-5" size="64px" class="q-mb-md" />
          <div class="text-h6 q-mb-sm">Отзывы не загружены</div>
          <div class="text-body2 text-grey-7 q-mb-md">
            Подключите Яндекс.Карты в настройках, чтобы загрузить отзывы
          </div>
          <q-btn
            color="primary"
            label="Перейти к настройкам"
            unelevated
            @click="$router.push({ name: ROUTE_NAMES.SETTINGS })"
          />
        </q-card-section>
      </q-card>
    </div>

    <ReviewsList
      v-else
      :reviews="mappedReviews"
      :overall-rating="yandexParserStore.companyInfo?.rating || 0"
      :total-reviews="yandexParserStore.companyInfo?.total_reviews || 0"
    />
  </q-page>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import ReviewsList from 'src/components/Reviews/ReviewsList.vue';
import { useYandexParserStore } from 'src/stores/yandex-parser.store';
import { ROUTE_NAMES } from 'src/router/routes';
import type { Review } from 'src/types/review.types';

const $router = useRouter();
const yandexParserStore = useYandexParserStore();

const mappedReviews = computed<Review[]>(() => {
  if (!yandexParserStore.reviews.length) return [];

  return yandexParserStore.reviews.map((yandexReview, index) => ({
    id: index + 1,
    date: new Date(yandexReview.date * 1000),
    branch: yandexParserStore.companyInfo?.name || 'Яндекс.Карты',
    rating: yandexReview.stars || 5,
    author: yandexReview.name,
    userLink: yandexReview.user_link || null,
    phone: '',
    text: yandexReview.text,
    answer: yandexReview.answer || undefined,
  }));
});
</script>

<style module lang="scss">
.pageContainer {
  padding: 24px;
}

.pageHeader {
  .pageTitle {
    font-size: 28px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 8px 0;
  }

  .pageSubtitle {
    font-size: 14px;
    color: #757575;
    margin: 0;
  }
}

.loadingContainer,
.errorContainer,
.emptyContainer {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.loadingCard,
.errorCard,
.emptyCard {
  max-width: 500px;
  width: 100%;
}

.errorCard {
  text-align: center;
}

@media (max-width: 768px) {
  .pageContainer {
    padding: 16px;
  }

  .pageHeader {
    .pageTitle {
      font-size: 24px;
    }
  }
}
</style>
