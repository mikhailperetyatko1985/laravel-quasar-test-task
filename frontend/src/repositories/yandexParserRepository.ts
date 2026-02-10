import { api } from 'src/boot/axios';
import type {
  ParseYandexUrlRequest,
  YandexParserApiResponse,
  YandexParserErrorResponse
} from 'src/types/yandex-parser.types';

export const yandexParserRepository = {
  /**
   * Парсинг данных компании и отзывов из Яндекс.Карт
   */
  async parseFromUrl(
    request: ParseYandexUrlRequest
  ): Promise<YandexParserApiResponse> {
    const response = await api.post<
      YandexParserApiResponse | YandexParserErrorResponse
    >('/api/yandex-parser/parse', request);

    if (!response.data.success) {
      throw new Error(
        (response.data as YandexParserErrorResponse).error ||
          'Неизвестная ошибка при парсинге'
      );
    }

    return response.data as YandexParserApiResponse;
  },
};
