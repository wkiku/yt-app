FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# パッケージのインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    apache2 \
    libapache2-mod-wsgi-py3 \
    ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 仮想環境を作成して依存関係をインストール
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# Apacheの設定
COPY apache-site.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod wsgi

# パーミッション設定
RUN chown -R www-data:www-data /app

EXPOSE 80

# Apacheをフォアグラウンドで起動
CMD ["apachectl", "-D", "FOREGROUND"]
