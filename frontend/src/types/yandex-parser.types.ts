export interface YandexCompanyInfo {
  name: string;
  rating: number;
  count_rating: number;
  stars: number;
  total_reviews: number;
}

export interface YandexReview {
  name: string;
  icon_href: string | null;
  user_link: string | null;
  date: number;
  text: string;
  stars: number;
  answer: string | null;
}

export interface YandexParserResponse {
  company_info: YandexCompanyInfo | null;
  company_reviews: YandexReview[];
  reviews_count: number;
}

export interface YandexParserApiResponse {
  success: boolean;
  data: YandexParserResponse;
}

export interface YandexParserErrorResponse {
  success: false;
  error: string;
}

export interface ParseYandexUrlRequest {
  url: string;
  force_refresh?: boolean;
  reviews_count?: number;
}
