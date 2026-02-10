import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import type {
  YandexCompanyInfo,
  YandexReview,
  ParseYandexUrlRequest
} from 'src/types/yandex-parser.types';
import { yandexParserRepository } from 'src/repositories/yandexParserRepository';

export const useYandexParserStore = defineStore('yandexParser', () => {
  // State
  const companyInfo = ref<YandexCompanyInfo | null>(null);
  const reviews = ref<YandexReview[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);
  const yandexMapsUrl = ref<string>('');

  // Getters
  const hasData = computed(() => companyInfo.value !== null || reviews.value.length > 0);
  const reviewsCount = computed(() => reviews.value.length);

  // Actions
  async function parseFromUrl(request: ParseYandexUrlRequest) {
    isLoading.value = true;
    error.value = null;

    try {
      const response = await yandexParserRepository.parseFromUrl(request);

      companyInfo.value = response.data.company_info;
      reviews.value = response.data.company_reviews;
      yandexMapsUrl.value = request.url;

      return response;
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Произошла ошибка при парсинге';
      throw err;
    } finally {
      isLoading.value = false;
    }
  }

  function clearData() {
    companyInfo.value = null;
    reviews.value = [];
    error.value = null;
    yandexMapsUrl.value = '';
  }

  function clearError() {
    error.value = null;
  }

  return {
    // State
    companyInfo,
    reviews,
    isLoading,
    error,
    yandexMapsUrl,

    // Getters
    hasData,
    reviewsCount,

    // Actions
    parseFromUrl,
    clearData,
    clearError,
  };
});
