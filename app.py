from flask import Flask, render_template_string, request, send_file
import yt_dlp
import os
import tempfile

app = Flask(__name__)

# フロントエンドのHTML
HTML = open("index.html").read()

@app.route('/')
def index():
    return render_template_string(HTML)

@app.route('/download', methods=['POST'])
def download():
    url = request.form.get('url')
    if not url:
        return "URLを入力してください", 400

    # 一時的なディレクトリを作成して保存
    with tempfile.TemporaryDirectory() as tmpdir:
        ydl_opts = {
            # 映像のベストと音声のベストを組み合わせてマージする
            'format': 'bestvideo+bestaudio/best',
            'outtmpl': f'{tmpdir}/%(title)s.%(ext)s',
            # 互換性のためにプロトコルを指定することもあります
            'http_chunk_size': 1048576,
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)
            
            return send_file(filename, as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    