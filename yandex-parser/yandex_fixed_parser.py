#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Исправленный парсер отзывов с Yandex Карт
Форк библиотеки yandex-reviews-parser с обновленными селекторами
"""

import time
import logging
from dataclasses import dataclass, asdict
from typing import Optional, Dict, List, Any
from datetime import datetime

import undetected_chromedriver
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException

logger = logging.getLogger(__name__)


@dataclass
class Review:
    """Структура отзыва"""
    name: Optional[str]
    icon_href: Optional[str]
    user_link: Optional[str]
    date: Optional[float]
    text: Optional[str]
    stars: float
    answer: Optional[str]


@dataclass
class CompanyInfo:
    """Структура информации о компании"""
    name: Optional[str]
    rating: float
    count_rating: int
    stars: float
    total_reviews: int


class YandexFixedParser:
    """
    Исправленный парсер с обновленными CSS-селекторами для Яндекс.Карт
    """
    
    def __init__(self, company_id: int, limit: Optional[int] = None):
        """
        Инициализация парсера
        
        Args:
            company_id: ID компании в Yandex Картах
            limit: Максимальное количество отзывов для парсинга (None = без ограничений)
        """
        self.company_id = company_id
        self.limit = limit
        self.driver = None
        
    def _init_driver(self):
        """Инициализация Chrome драйвера"""
        if self.driver is None:
            url = f'https://yandex.ru/maps/org/{self.company_id}/reviews/'
            opts = undetected_chromedriver.ChromeOptions()
            opts.add_argument('--no-sandbox')
            opts.add_argument('--disable-dev-shm-usage')
            opts.add_argument('headless')
            opts.add_argument('--disable-gpu')
            
            logger.info(f"Открываем URL: {url}")
            self.driver = undetected_chromedriver.Chrome(options=opts)
            self.driver.get(url)
            time.sleep(4)  # Даем время странице загрузиться
    
    def _scroll_to_bottom(self, elem, current_count: int = 0):
        """
        Скроллим список до последнего отзыва или до достижения лимита
        
        Args:
            elem: Последний отзыв в списке
            current_count: Текущее количество отзывов
        """
        # Проверяем лимит
        if self.limit is not None and current_count >= self.limit:
            logger.info(f"Достигнут лимит отзывов: {self.limit}")
            return
            
        self.driver.execute_script("arguments[0].scrollIntoView();", elem)
        time.sleep(1)
        new_elem = self.driver.find_elements(By.CLASS_NAME, "business-reviews-card-view__review")[-1]
        
        if elem == new_elem:
            return
            
        # Получаем текущее количество отзывов
        current_elements = self.driver.find_elements(By.CLASS_NAME, "business-reviews-card-view__review")
        self._scroll_to_bottom(new_elem, len(current_elements))
    
    @staticmethod
    def _format_rating(elements: list) -> float:
        """
        Форматирует рейтинг в число с плавающей точкой
        
        Args:
            elements: Массив элементов рейтинга
            
        Returns:
            Число с плавающей точкой (рейтинг)
        """
        if len(elements) <= 0:
            return 0.0
        return float(''.join(x.text for x in elements).replace(',', '.'))
    
    @staticmethod
    def _get_star_count(star_elements: list) -> float:
        """
        Считаем рейтинг по звездам
        
        Args:
            star_elements: Массив элементов звезд
            
        Returns:
            Количество звезд (float)
        """
        star_count = 0.0
        for star in star_elements:
            class_attr = star.get_attribute('class')
            if '_empty' in class_attr:
                continue
            if '_half' in class_attr:
                star_count += 0.5
                continue
            star_count += 1.0
        return star_count
    
    @staticmethod
    def _parse_date(date_string: str) -> Optional[float]:
        """
        Приводим дату в формат Timestamp
        
        Args:
            date_string: Дата в формате ISO
            
        Returns:
            Timestamp
        """
        try:
            dt = datetime.strptime(date_string, "%Y-%m-%dT%H:%M:%S.%fZ")
            return dt.timestamp()
        except Exception:
            return None
    
    @staticmethod
    def _extract_number(text: str) -> int:
        """
        Извлекает число из текста
        
        Args:
            text: Текст содержащий число
            
        Returns:
            Число
        """
        import re
        numbers = re.findall(r'\d+', text.replace(' ', ''))
        if numbers:
            return int(numbers[0])
        return 0
    
    def _parse_review(self, elem) -> Dict[str, Any]:
        """
        Парсит один отзыв
        
        Args:
            elem: Элемент отзыва
            
        Returns:
            Словарь с данными отзыва
        """
        # Имя автора
        try:
            name = elem.find_element(By.XPATH, ".//span[@itemprop='name']").text
        except NoSuchElementException:
            name = None
        
        # Аватар
        try:
            icon_href = elem.find_element(By.XPATH, ".//div[@class='user-icon-view__icon']").get_attribute('style')
            icon_href = icon_href.split('"')[1] if '"' in icon_href else None
        except NoSuchElementException:
            icon_href = None
        
        # Ссылка на профиль пользователя
        user_link = None
        try:
            link_elem = elem.find_element(By.XPATH, ".//a[@class='business-review-view__link']")
            user_link = link_elem.get_attribute('href')
        except NoSuchElementException:
            try:
                # Альтернативный селектор
                link_elem = elem.find_element(By.XPATH, ".//a[contains(@class, 'business-review-view__link')]")
                user_link = link_elem.get_attribute('href')
            except NoSuchElementException:
                logger.debug("Ссылка на профиль не найдена")
        
        # Дата
        try:
            date_str = elem.find_element(By.XPATH, ".//meta[@itemprop='datePublished']").get_attribute('content')
            date = self._parse_date(date_str)
        except NoSuchElementException:
            date = None
        
        # Текст отзыва - обновленные селекторы на основе реальной структуры
        text = None
        
        # Сначала пытаемся раскрыть текст, если есть кнопка "Ещё"
        expand_clicked = False
        
        # Пробуем разные варианты кнопки раскрытия
        expand_selectors = [
            ".//span[@class='business-review-view__expand']",
            ".//span[contains(@class, 'business-review-view__expand')]",
            ".//span[@class='spoiler-view__button']//span[@role='button']",
            ".//span[contains(@aria-label, 'Ещё')]",
            ".//span[contains(text(), 'Ещё')]",
            ".//button[contains(@class, 'spoiler-view__expand-btn')]",
            ".//button[contains(@class, 'business-review-view__expand')]",
        ]
        
        for selector in expand_selectors:
            try:
                expand_btn = elem.find_element(By.XPATH, selector)
                if expand_btn and expand_btn.is_displayed():
                    # Прокручиваем к кнопке перед кликом
                    self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", expand_btn)
                    time.sleep(0.2)
                    # Кликаем
                    self.driver.execute_script("arguments[0].click()", expand_btn)
                    time.sleep(0.7)  # Увеличенная задержка для раскрытия текста
                    logger.debug(f"Текст отзыва раскрыт с помощью селектора: {selector}")
                    expand_clicked = True
                    break
            except (NoSuchElementException, Exception) as e:
                logger.debug(f"Selector {selector} failed: {str(e)}")
                continue
        
        if not expand_clicked:
            logger.debug("Кнопка раскрытия не найдена или текст уже полный")
        
        try:
            # Основной селектор - текст в spoiler-view__text-container
            text_elem = elem.find_element(By.XPATH, ".//span[@class='spoiler-view__text-container']")
            text = text_elem.text
        except NoSuchElementException:
            try:
                # Альтернативный селектор с contains
                text_elem = elem.find_element(By.XPATH, ".//span[contains(@class, 'spoiler-view__text-container')]")
                text = text_elem.text
            except NoSuchElementException:
                try:
                    # Старый селектор для совместимости
                    text_elem = elem.find_element(By.XPATH, ".//span[@class='business-review-view__body-text']")
                    text = text_elem.text
                except NoSuchElementException:
                    try:
                        # Общий поиск в business-review-view__body
                        text_elem = elem.find_element(By.XPATH, ".//div[@class='business-review-view__body']//span")
                        text = text_elem.text
                    except NoSuchElementException:
                        logger.debug("Текст отзыва не найден")
        
        # Звезды отзыва - обновленные селекторы для SVG звезд
        stars = 0.0
        try:
            # Ищем спаны с классом business-rating-badge-view__star
            star_elements = elem.find_elements(By.XPATH, ".//span[contains(@class, 'business-rating-badge-view__star')]")
            if star_elements:
                stars = self._get_star_count(star_elements)
        except NoSuchElementException:
            try:
                # Альтернативный поиск через родительский контейнер
                star_elements = elem.find_elements(By.XPATH, ".//div[contains(@class, 'business-rating-badge-view__stars')]//span[contains(@class, 'icon')]")
                if star_elements:
                    stars = self._get_star_count(star_elements)
            except NoSuchElementException:
                logger.debug("Звезды отзыва не найдены")
        
        # Ответ компании
        answer = None
        try:
            answer_btn = elem.find_element(By.CLASS_NAME, "business-review-view__comment-expand")
            if answer_btn:
                self.driver.execute_script("arguments[0].click()", answer_btn)
                time.sleep(0.5)
                answer = elem.find_element(By.CLASS_NAME, "business-review-comment-content__bubble").text
        except NoSuchElementException:
            pass
        
        review = Review(
            name=name,
            icon_href=icon_href,
            user_link=user_link,
            date=date,
            text=text,
            stars=stars,
            answer=answer
        )
        
        return asdict(review)
    
    def _parse_company_info(self) -> Dict[str, Any]:
        """
        Парсит информацию о компании
        
        Returns:
            Словарь с данными о компании
        """
        # Название
        try:
            name = self.driver.find_element(By.XPATH, ".//h1[@class='orgpage-header-view__header']").text
        except NoSuchElementException:
            name = None
        
        # Рейтинг и количество отзывов
        rating = 0.0
        count_rating = 0
        stars = 0.0
        total_reviews = 0
        
        try:
            rating_block = self.driver.find_element(
                By.XPATH,
                ".//div[@class='business-summary-rating-badge-view__rating-and-stars']"
            )
            
            # Рейтинг (число)
            try:
                rating_elements = rating_block.find_elements(
                    By.XPATH,
                    ".//div[@class='business-summary-rating-badge-view__rating']/span[contains(@class, 'business-summary-rating-badge-view__rating-text')]"
                )
                rating = self._format_rating(rating_elements)
            except NoSuchElementException:
                logger.debug("Рейтинг не найден")
            
            # Количество оценок
            try:
                count_text = rating_block.find_element(
                    By.XPATH,
                    ".//div[@class='business-summary-rating-badge-view__rating-count']/span[@class='business-rating-amount-view _summary']"
                ).text
                count_rating = self._extract_number(count_text)
            except NoSuchElementException:
                logger.debug("Количество оценок не найдено")
            
            # Звезды компании
            try:
                star_elements = rating_block.find_elements(
                    By.XPATH,
                    ".//span[contains(@class, 'business-rating-badge-view__star')]"
                )
                if star_elements:
                    stars = self._get_star_count(star_elements)
            except NoSuchElementException:
                logger.debug("Звезды компании не найдены")
                
        except NoSuchElementException:
            logger.warning("Блок с рейтингом не найден")
        
        # Общее количество отзывов
        try:
            total_reviews_elem = self.driver.find_element(
                By.XPATH,
                ".//h2[@class='card-section-header__title _wide']"
            )
            total_reviews = self._extract_number(total_reviews_elem.text)
        except NoSuchElementException:
            try:
                # Альтернативный селектор
                total_reviews_elem = self.driver.find_element(
                    By.XPATH,
                    ".//h2[contains(@class, 'card-section-header__title')]"
                )
                total_reviews = self._extract_number(total_reviews_elem.text)
            except NoSuchElementException:
                logger.debug("Общее количество отзывов не найдено")
        
        info = CompanyInfo(
            name=name,
            rating=rating,
            count_rating=count_rating,
            stars=stars,
            total_reviews=total_reviews
        )
        
        return asdict(info)
    
    def _parse_reviews(self) -> List[Dict[str, Any]]:
        """
        Парсит все отзывы с учетом лимита
        
        Returns:
            Список словарей с отзывами
        """
        reviews = []
        elements = self.driver.find_elements(By.CLASS_NAME, "business-reviews-card-view__review")
        
        if len(elements) > 1:
            initial_count = len(elements)
            logger.info(f"Найдено {initial_count} отзывов, начинаем скроллинг...")
            
            # Скроллим только если нет лимита или текущее количество меньше лимита
            if self.limit is None or initial_count < self.limit:
                self._scroll_to_bottom(elements[-1], initial_count)
                elements = self.driver.find_elements(By.CLASS_NAME, "business-reviews-card-view__review")
                logger.info(f"После скроллинга: {len(elements)} отзывов")
            else:
                logger.info(f"Лимит {self.limit} достигнут, скроллинг не требуется")
            
            # Обрезаем список до лимита если он установлен
            if self.limit is not None and len(elements) > self.limit:
                elements = elements[:self.limit]
                logger.info(f"Ограничено до {self.limit} отзывов")
            
            for i, elem in enumerate(elements):
                review = self._parse_review(elem)
                reviews.append(review)
                
                if (i + 1) % 100 == 0:
                    logger.info(f"Обработано {i + 1} отзывов")
            
            logger.info(f"Всего обработано: {len(reviews)} отзывов")
        
        return reviews
    
    def parse(self) -> Dict[str, Any]:
        """
        Главный метод парсинга
        
        Returns:
            Словарь с полными данными
        """
        try:
            self._init_driver()
            
            # Проверяем, что страница загрузилась
            try:
                self.driver.find_element(By.XPATH, ".//h1[@class='orgpage-header-view__header']")
            except NoSuchElementException:
                logger.error("Страница компании не найдена")
                return {'error': 'Страница не найдена'}
            
            logger.info("Парсим информацию о компании...")
            company_info = self._parse_company_info()
            
            logger.info("Парсим отзывы...")
            company_reviews = self._parse_reviews()
            
            result = {
                'company_info': company_info,
                'company_reviews': company_reviews,
                'reviews_count': len(company_reviews)
            }
            
            return result
            
        except Exception as e:
            logger.error(f"Ошибка парсинга: {str(e)}", exc_info=True)
            return {'error': str(e)}
            
        finally:
            if self.driver:
                self.driver.close()
                self.driver.quit()
