from flask import Flask, render_template_string, request, send_file
import yt_dlp
import os
import tempfile

app = Flask(__name__)

# フロントエンドのHTML
base_dir = os.path.dirname(os.path.abspath(__file__))
html_path = os.path.join(base_dir, "index.html")
HTML = open(html_path, encoding="utf-8").read()

@app.route('/')
def index():
    return render_template_string(HTML)

@app.route('/download', methods=['POST'])
def download():
    url = request.form.get('url')
    if not url:
        return "URLを入力してください", 400

    # 一時的なディレクトリを作成して保存
    tmpdir = tempfile.mkdtemp()
    ydl_opts = {
        # 映像のベストと音声のベストを組み合わせてマージする
        'format': 'bestvideo+bestaudio/best',
        'outtmpl': f'{tmpdir}/%(title)s.%(ext)s',
        # 互換性のためにプロトコルを指定することもあります
        'http_chunk_size': 1048576,
    }
    
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)
            
            return send_file(filename, as_attachment=True)
    except Exception as e:
        return f"ダウンロード中にエラーが発生しました: {str(e)}", 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    