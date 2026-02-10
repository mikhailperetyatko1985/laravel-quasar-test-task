#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Flask API для парсера отзывов с Yandex Карт
"""

from flask import Flask, request, jsonify
from yandex_library_parser import YandexLibraryParser
import logging
import sys

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

app = Flask(__name__)


@app.route('/health', methods=['GET'])
def health_check():
    """Проверка здоровья сервиса"""
    return jsonify({
        'status': 'ok',
        'service': 'yandex-reviews-parser'
    }), 200


@app.route('/parse', methods=['POST'])
def parse_reviews():
    """
    Парсинг отзывов с Yandex Карт через библиотеку yandex-reviews-parser
    
    Ожидаемые параметры:
    - company_id (int): ID компании в Yandex Картах
    - type_parse (str, optional): Тип парсинга ('default', 'company', 'reviews'). По умолчанию 'default'
    - limit (int, optional): Максимальное количество отзывов для парсинга (None = без ограничений)
    
    Возвращает JSON с результатами парсинга
    """
    try:
        # Получаем данные из запроса
        data = request.get_json()
        
        if not data:
            logger.warning("Получен пустой запрос")
            return jsonify({
                'success': False,
                'error': 'Отсутствуют данные в запросе'
            }), 400
        
        # Получаем ID компании
        company_id = data.get('company_id')
        if not company_id:
            logger.warning("Отсутствует company_id в запросе")
            return jsonify({
                'success': False,
                'error': 'Параметр company_id обязателен'
            }), 400
        
        # Проверяем, что company_id - число
        try:
            company_id = int(company_id)
        except (ValueError, TypeError):
            logger.warning(f"Некорректный company_id: {company_id}")
            return jsonify({
                'success': False,
                'error': 'Параметр company_id должен быть числом'
            }), 400
        
        # Получаем тип парсинга
        type_parse = data.get('type_parse', 'default')
        
        # Валидация типа парсинга
        valid_types = ['default', 'company', 'reviews']
        if type_parse not in valid_types:
            logger.warning(f"Некорректный тип парсинга: {type_parse}")
            return jsonify({
                'success': False,
                'error': f'Параметр type_parse должен быть одним из: {", ".join(valid_types)}'
            }), 400
        
        # Получаем лимит отзывов (опционально)
        limit = data.get('limit')
        if limit is not None:
            try:
                limit = int(limit)
                if limit <= 0:
                    logger.warning(f"Некорректный лимит: {limit}")
                    return jsonify({
                        'success': False,
                        'error': 'Параметр limit должен быть положительным числом'
                    }), 400
            except (ValueError, TypeError):
                logger.warning(f"Некорректный лимит: {limit}")
                return jsonify({
                    'success': False,
                    'error': 'Параметр limit должен быть числом'
                }), 400
        
        logger.info(f"Начало парсинга через библиотеку. Company ID: {company_id}, Type: {type_parse}, Limit: {limit if limit else 'без ограничений'}")
        
        # Создаем парсер библиотеки с лимитом
        parser = YandexLibraryParser(company_id, limit=limit)
        
        # Выполняем парсинг
        if type_parse == 'default':
            result = parser.parse_all_data()
        elif type_parse == 'company':
            result = parser.parse_company_info()
        elif type_parse == 'reviews':
            result = parser.parse_reviews()
        
        logger.info(f"Парсинг через библиотеку успешно завершен для company_id: {company_id}")
        
        # Возвращаем результат
        return jsonify({
            'success': True,
            'data': result
        }), 200
        
    except Exception as e:
        logger.error(f"Ошибка при парсинге через библиотеку: {str(e)}", exc_info=True)
        return jsonify({
            'success': False,
            'error': f'Внутренняя ошибка сервера: {str(e)}'
        }), 500


@app.errorhandler(404)
def not_found(error):
    """Обработчик 404 ошибки"""
    return jsonify({
        'success': False,
        'error': 'Endpoint не найден'
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Обработчик 500 ошибки"""
    logger.error(f"Внутренняя ошибка сервера: {str(error)}", exc_info=True)
    return jsonify({
        'success': False,
        'error': 'Внутренняя ошибка сервера'
    }), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
