#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Тестовый скрипт для проверки вывода библиотеки yandex-reviews-parser
"""

import json
from yandex_reviews_parser.utils import YandexParser

# Используем тестовый ID компании
company_id = 1010501395

print(f"Тестирование парсера для company_id: {company_id}")
print("=" * 70)

try:
    parser = YandexParser(company_id)
    result = parser.parse()
    
    print("\n📋 ПОЛНЫЙ ВЫВОД БИБЛИОТЕКИ:")
    print("=" * 70)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    print("=" * 70)
    
    print("\n📊 АНАЛИЗ СТРУКТУРЫ:")
    print("=" * 70)
    
    # Проверяем типы данных
    print(f"\nТип result: {type(result)}")
    print(f"Ключи в result: {list(result.keys()) if isinstance(result, dict) else 'N/A'}")
    
    # Проверяем company_info
    if 'company_info' in result:
        print(f"\n✅ company_info найден")
        company_info = result['company_info']
        print(f"   Тип: {type(company_info)}")
        print(f"   Ключи: {list(company_info.keys()) if isinstance(company_info, dict) else 'N/A'}")
        print(f"   Содержимое:")
        print(json.dumps(company_info, ensure_ascii=False, indent=4))
    
    # Проверяем company_reviews
    if 'company_reviews' in result:
        print(f"\n✅ company_reviews найден")
        reviews = result['company_reviews']
        print(f"   Тип: {type(reviews)}")
        print(f"   Количество отзывов: {len(reviews) if isinstance(reviews, list) else 'N/A'}")
        
        if reviews and len(reviews) > 0:
            print(f"\n   📝 Первый отзыв (для анализа структуры):")
            first_review = reviews[0]
            print(f"   Тип: {type(first_review)}")
            print(f"   Ключи: {list(first_review.keys()) if isinstance(first_review, dict) else 'N/A'}")
            print(f"   Содержимое:")
            print(json.dumps(first_review, ensure_ascii=False, indent=4))
    
    print("\n" + "=" * 70)
    print("✅ Тест завершен успешно!")
    
except Exception as e:
    print(f"\n❌ ОШИБКА: {str(e)}")
    import traceback
    traceback.print_exc()
