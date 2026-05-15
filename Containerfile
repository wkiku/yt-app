FROM registry.fedoraproject.org/fedora:latest

# パッケージのインストール
RUN dnf update -y && \
    dnf install -y \
    httpd \
    mod_ssl \
    mod_wsgi \
 #    python3 \
    python3-pip \
    python3-devel \
#    python3-wsgi \
    nodejs \
    ffmpeg && \
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
# SSLディレクトリ準備
RUN mkdir -p /etc/pki/tls/certs /etc/pki/tls/private

EXPOSE 443

# Apacheをフォアグラウンドで起動
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]