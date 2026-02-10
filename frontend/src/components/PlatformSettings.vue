<template>
  <q-card :class="$style.platformCard">
    <div :class="$style.cardContent">
      <div :class="$style.connectionForm">
        <div :class="$style.formLabel" class="q-mb-sm">Подключить Яндекс</div>
        
        <div :class="$style.formDescription" class="q-mb-md">
          Укажите ссылку на Яндекс, пример:
          <a
            href="#"
            :class="$style.exampleLink"
            @click.prevent="insertExampleUrl"
          >
            https://yandex.ru/maps/org/samoye_populyarnoye_kafe/1010501395/reviews/
          </a>
        </div>

        <q-input
          v-model="yandexUrl"
          outlined
          dense
          placeholder="https://yandex.ru/maps/org/samoye_populyarnoye_kafe/1010501395/reviews/"
          :class="$style.urlInput"
          class="q-mb-md"
          :disable="yandexParserStore.isLoading"
          :error="!!yandexParserStore.error"
          :error-message="yandexParserStore.error || undefined"
        />

        <div :class="$style.formLabel" class="q-mb-sm">Количество отзывов</div>
        
        <div :class="$style.formDescription" class="q-mb-md">
          Укажите количество отзывов для загрузки (от 1 до 100)
        </div>

        <q-input
          v-model.number="reviewsCount"
          outlined
          dense
          type="number"
          placeholder="20"
          :class="$style.reviewsInput"
          class="q-mb-md"
          :disable="yandexParserStore.isLoading"
          :min="1"
          :max="100"
        />

        <div :class="$style.actionButtons">
          <q-btn
            color="primary"
            label="Сохранить"
            unelevated
            :class="$style.saveBtn"
            :disable="!yandexUrl || yandexParserStore.isLoading"
            @click="saveYandexUrl"
          />
        </div>

        <div v-if="yandexParserStore.hasData && !yandexParserStore.isLoading" :class="$style.dataInfo" class="q-mt-md">
          <q-icon name="check_circle" color="positive" size="18px" />
          <span :class="$style.dataInfoText">
            Загружено {{ yandexParserStore.reviewsCount }} отзывов
            <template v-if="yandexParserStore.companyInfo">
              для компании "{{ yandexParserStore.companyInfo.name }}"
            </template>
          </span>
        </div>

        <div v-if="yandexParserStore.isLoading" :class="$style.loadingInfo" class="q-mt-md">
          <q-spinner color="primary" size="18px" />
          <span :class="$style.loadingText">
            Загрузка данных из Яндекс.Карт... Это может занять 2-3 минуты
          </span>
        </div>
      </div>
    </div>
  </q-card>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useYandexParserStore } from 'src/stores/yandex-parser.store';
import { useQuasar } from 'quasar';

const $q = useQuasar();
const yandexParserStore = useYandexParserStore();
const yandexUrl = ref('');
const reviewsCount = ref<number>(20);
const exampleUrl = 'https://yandex.ru/maps/org/samoye_populyarnoye_kafe/1010501395/reviews/';

onMounted(() => {
  if (yandexParserStore.yandexMapsUrl) {
    yandexUrl.value = yandexParserStore.yandexMapsUrl;
  }
});

function insertExampleUrl() {
  yandexUrl.value = exampleUrl;
}

async function saveYandexUrl() {
  if (!yandexUrl.value) return;

  // Валидация количества отзывов
  const validReviewsCount = Math.min(Math.max(reviewsCount.value || 20, 1), 100);

  try {
    await yandexParserStore.parseFromUrl({
      url: yandexUrl.value,
      force_refresh: false,
      reviews_count: validReviewsCount,
    });

    $q.notify({
      type: 'positive',
      message: 'Данные успешно загружены из Яндекс.Карт',
      caption: `Загружено ${yandexParserStore.reviewsCount} отзывов`,
      position: 'top-right',
    });
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Ошибка при загрузке данных',
      caption: error instanceof Error ? error.message : 'Неизвестная ошибка',
      position: 'top-right',
    });
  }
}
</script>

<style module lang="scss">
.platformCard {
  background: white;
  border: none;
  box-shadow: none;
}

.cardContent {
  padding-left: 40px;
  padding-top: 20px;
}

.cardTitle {
  font-size: 20px;
  font-weight: 600;
  color: #1a1a1a;
}

.platformHeader {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.platformLogo {
  display: inline-flex;
  align-items: center;
  background: linear-gradient(135deg, #ff2c2c 0%, #ffcc00 100%);
  padding: 8px 16px;
  border-radius: 6px;
  
  .platformText {
    color: white;
    font-weight: 600;
    font-size: 14px;
  }
}

.connectionForm {
  .formLabel {
    font-size: 16px;
    font-weight: 600;
    color: #1a1a1a;
  }

  .formDescription {
    font-size: 13px;
    color: #666;
    line-height: 1.5;
  }

  .exampleLink {
    color: #1976d2;
    text-decoration: none;
    word-break: break-all;
    
    &:hover {
      text-decoration: underline;
    }
  }
}

.urlInput {
  max-width: 520px;

  :deep(.q-field__control) {
    font-size: 13px;
    height: 20px;
  }
  
  :deep(.q-field__native) {
    padding: 8px 12px;
    height: 24px;
  }
}

.reviewsInput {
  max-width: 200px;

  :deep(.q-field__control) {
    font-size: 13px;
    height: 20px;
  }
  
  :deep(.q-field__native) {
    padding: 8px 12px;
    height: 24px;
  }
}

.actionButtons {
  display: flex;
  gap: 12px;
}

.saveBtn {
  background: #2196f3;
  text-transform: none;
  width: 148px;
  height: 24px!important;
  font-size: 14px;
  border-radius: 7px;
}

.dataInfo,
.loadingInfo {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: #f5f5f5;
  border-radius: 6px;
}

.dataInfo {
  .dataInfoText {
    font-size: 13px;
    color: #2e7d32;
    font-weight: 500;
  }
}

.loadingInfo {
  .loadingText {
    font-size: 13px;
    color: #666;
  }
}
</style>
