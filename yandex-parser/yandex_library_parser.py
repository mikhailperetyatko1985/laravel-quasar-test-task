#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Парсер отзывов с Yandex Карт на основе исправленного парсера
Использует yandex_fixed_parser.py с обновленными CSS-селекторами
"""

import logging
import sys
from typing import Dict, Any, Optional
from yandex_fixed_parser import YandexFixedParser

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)


class YandexLibraryParser:
    """
    Класс-обертка для библиотеки yandex-reviews-parser
    Обеспечивает удобный интерфейс для парсинга отзывов
    """
    
    def __init__(self, company_id: int, limit: Optional[int] = None):
        """
        Инициализация парсера
        
        Args:
            company_id (int): ID компании в Yandex Картах
            limit (int, optional): Максимальное количество отзывов для парсинга (None = без ограничений)
        """
        self.company_id = company_id
        self.limit = limit
        self.parser = None
        self._cached_result = None  # Кеш результата парсинга
        logger.info(f"Инициализация парсера для компании с ID: {company_id}, лимит: {limit if limit else 'без ограничений'}")
        
    def _ensure_parser(self):
        """Ленивая инициализация парсера"""
        if self.parser is None:
            try:
                self.parser = YandexFixedParser(self.company_id, limit=self.limit)
                logger.info("Исправленный парсер успешно инициализирован")
            except Exception as e:
                logger.error(f"Ошибка инициализации парсера: {str(e)}")
                raise
    
    def _get_data(self) -> Dict[str, Any]:
        """
        Внутренний метод для получения данных с кешированием
        
        Returns:
            Dict: Полные данные парсинга
        """
        if self._cached_result is None:
            try:
                self._ensure_parser()
                logger.info("Начало парсинга данных с Яндекс.Карт")
                self._cached_result = self.parser.parse()
                
                reviews_count = len(self._cached_result.get('company_reviews', []))
                company_name = self._cached_result.get('company_info', {}).get('name', 'N/A')
                
                logger.info(f"Парсинг завершен. Компания: {company_name}, Отзывов: {reviews_count}")
            except Exception as e:
                logger.error(f"Ошибка при парсинге: {str(e)}")
                raise
        
        return self._cached_result
    
    def parse_all_data(self) -> Dict[str, Any]:
        """
        Получить все данные (информацию о компании и отзывы)
        
        Библиотека yandex-reviews-parser всегда возвращает полный набор данных.
        
        Returns:
            Dict: Словарь с полными данными
        """
        return self._get_data()
    
    def parse_company_info(self) -> Dict[str, Any]:
        """
        Получить только информацию о компании
        
        Returns:
            Dict: Словарь с информацией о компании
        """
        result = self._get_data()
        logger.info("Возврат только company_info")
        return {"company_info": result.get("company_info", {})}
    
    def parse_reviews(self) -> Dict[str, Any]:
        """
        Получить только отзывы
        
        Returns:
            Dict: Словарь с отзывами
        """
        result = self._get_data()
        reviews_count = len(result.get("company_reviews", []))
        logger.info(f"Возврат только company_reviews ({reviews_count} отзывов)")
        return {"company_reviews": result.get("company_reviews", [])}
    
    def parse(self) -> Dict[str, Any]:
        """
        Alias для parse_all_data() для обратной совместимости
        """
        return self.parse_all_data()


def parse_yandex_reviews(company_id: int) -> Dict[str, Any]:
    """
    Утилитарная функция для быстрого парсинга отзывов
    
    Args:
        company_id (int): ID компании в Yandex Картах
    
    Returns:
        Dict: Результат парсинга с полными данными
        {
            "company_info": {...},
            "company_reviews": [...]
        }
    
    Example:
        >>> result = parse_yandex_reviews(1234)
        >>> print(result['company_info']['name'])
        >>> print(f"Отзывов: {len(result['company_reviews'])}")
    """
    parser = YandexLibraryParser(company_id)
    return parser.parse()


if __name__ == '__main__':
    """
    Пример использования скрипта
    """
    print("=" * 70)
    print("Пример использования YandexLibraryParser")
    print("=" * 70)
    print("\nВНИМАНИЕ: Замените company_id = 1234 на реальный ID компании")
    print("из Яндекс.Карт перед запуском!")
    print("=" * 70)
    
    try:
        company_id = 1234  # Замените на реальный ID компании
        
        # Способ 1: Использование класса
        print("\n>>> Способ 1: Использование класса")
        parser = YandexLibraryParser(company_id)
        data = parser.parse()
        
        # Выводим информацию о компании
        print(f"\nНазвание: {data['company_info']['name']}")
        print(f"Рейтинг: {data['company_info']['rating']}")
        print(f"Количество оценок: {data['company_info']['count_rating']}")
        print(f"Звезд: {data['company_info']['stars']}")
        
        # Выводим информацию об отзывах
        reviews = data['company_reviews']
        print(f"\nВсего отзывов: {len(reviews)}")
        
        if reviews:
            # Статистика по оценкам
            stars_count = {}
            answered_count = 0
            
            for review in reviews:
                stars = review['stars']
                stars_count[stars] = stars_count.get(stars, 0) + 1
                if review.get('answer'):
                    answered_count += 1
            
            print(f"Отзывов с ответом: {answered_count}")
            
            print("\nРаспределение по оценкам:")
            for stars in sorted(stars_count.keys(), reverse=True):
                print(f"  {stars} звезд: {stars_count[stars]} отзывов")
            
            # Пример первого отзыва
            print(f"\nПример отзыва:")
            review = reviews[0]
            print(f"  Автор: {review['name']}")
            print(f"  Оценка: {review['stars']} звезд")
            print(f"  Текст: {review['text'][:100]}...")
            print(f"  Ответ: {'Да' if review.get('answer') else 'Нет'}")
        
        # Способ 2: Использование утилитарной функции
        print("\n" + "=" * 70)
        print(">>> Способ 2: Использование утилитарной функции")
        
        result = parse_yandex_reviews(company_id)
        print(f"\nКомпания: {result['company_info']['name']}")
        print(f"Отзывов: {len(result['company_reviews'])}")
        
        print("\n" + "=" * 70)
        print("✅ Примеры успешно выполнены!")
        print("=" * 70)
        
    except Exception as e:
        logger.error(f"❌ Ошибка в примерах: {str(e)}")
        print(f"\n❌ Ошибка: {str(e)}")
        print("\nУбедитесь, что:")
        print("  1. Указан корректный ID компании")
        print("  2. Установлен Google Chrome")
        print("  3. Установлен ChromeDriver")
        print("  4. Установлена библиотека yandex-reviews-parser")
