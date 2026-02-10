FROM python:3.9-slim

# Установка рабочей директории
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Переменные окружения
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Установка системных зависимостей (включая Chrome для Selenium)
RUN apt-get update && apt-get install -y \
    gettext \
    wget \
    xvfb \
    unzip \
    gnupg \
    curl \
    ca-certificates \
    --no-install-recommends

# Установка Google Chrome
RUN wget -q -O /tmp/google-chrome-key.pub https://dl-ssl.google.com/linux/linux_signing_key.pub && \
    mkdir -p /etc/apt/keyrings && \
    cat /tmp/google-chrome-key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable --no-install-recommends && \
    rm /tmp/google-chrome-key.pub

# Установка ChromeDriver (совместимой версии с Chrome)
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') && \
    CHROME_MAJOR_VERSION=$(echo $CHROME_VERSION | cut -d'.' -f1) && \
    echo "Chrome version: $CHROME_VERSION (Major: $CHROME_MAJOR_VERSION)" && \
    wget -q "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}" -O /tmp/chromedriver_version || \
    wget -q "https://chromedriver.storage.googleapis.com/LATEST_RELEASE" -O /tmp/chromedriver_version && \
    CHROMEDRIVER_VERSION=$(cat /tmp/chromedriver_version) && \
    echo "ChromeDriver version: $CHROMEDRIVER_VERSION" && \
    wget -q "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" -O /tmp/chromedriver.zip && \
    unzip -q /tmp/chromedriver.zip -d /tmp/ && \
    mv /tmp/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip /tmp/chromedriver_version && \
    chromedriver --version

# Очистка кэша apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Обновление pip
RUN pip install --no-cache-dir --upgrade pip

# Копирование requirements.txt
COPY requirements.txt .

# Установка Python зависимостей
RUN pip install --no-cache-dir -r requirements.txt

# Копирование приложения
COPY app.py .
COPY yandex_library_parser.py .
COPY yandex_fixed_parser.py .

# Создание непривилегированного пользователя
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /usr/src/app

# Переключение на непривилегированного пользователя
USER appuser

# Экспозиция порта
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Запуск приложения с помощью gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "1800", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
