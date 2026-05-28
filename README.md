# yt-app
yt-dlp webIF

``` 
podman build . -t yt-app
podman run --rm -d -p 8080:80 --name test-yt-app yt-app
```