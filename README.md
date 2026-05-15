# yt-app
yt-dlp webIF

``` bash:
podman run --rm -d -p 8080:80 --name test-yt-app yt-app
```


``` bash:
podman run -d \
  --name yt-webdav-app \
  -p 8443:443 \
  -v /etc/pki/tls/certs:/etc/pki/tls/certs:Z \
  -v /etc/pki/tls/private:/etc/pki/tls/private:Z \
  -v /var/www/webdav:/var/www/webdav:Z,U \
  -v /etc/httpd/conf/.htpasswd:/etc/httpd/conf/.htpasswd:Z \
  yt-dlp_dav
```
