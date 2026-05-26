FROM registry.fedoraproject.org/fedora:latest

# パッケージのインストール
RUN dnf update -y && \
    dnf install -y \
    httpd \
    mod_ssl \
    mod_wsgi \
    python3-pip \
    python3-devel \
    ffmpeg \
    openssl && \
    dnf clean all

WORKDIR /app

# WebDAV 用ディレクトリの準備
# /var/www/webdav (データ本体)
# /var/lib/dav (ロックファイル管理用)
RUN mkdir -p /var/www/webdav /var/lib/dav && \
    chown -R apache:apache /var/www/webdav /var/lib/dav && \
    chmod 700 /var/lib/dav

# 仮想環境を作成して依存関係をインストール
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# Apacheの設定
COPY apache-site.conf /etc/httpd/conf.d/ytapp.conf

# ポート443でのリッスンを有効化
RUN echo "Listen 443 https" >> /etc/httpd/conf/httpd.conf

# SSL証明書生成（自己署名）
RUN mkdir -p /etc/pki/tls/certs /etc/pki/tls/private && \
    openssl req -x509 -nodes -days 365 \
      -newkey rsa:2048 \
      -keyout /etc/pki/tls/private/server.key \
      -out /etc/pki/tls/certs/localhost.crt \
      -subj "/CN=localhost" && \
    openssl req -x509 -nodes -days 365 \
      -key /etc/pki/tls/private/server.key \
      -out /etc/pki/tls/private/server.crt \
      -subj "/CN=localhost" && \
    chmod 644 /etc/pki/tls/certs/*.crt /etc/pki/tls/private/*.crt && \
    chmod 600 /etc/pki/tls/private/server.key && \
    rm -f /etc/httpd/conf.d/ssl.conf

EXPOSE 443

# Apacheをフォアグラウンドで起動
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]