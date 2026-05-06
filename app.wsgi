import sys
import os

# アプリケーションのディレクトリをパスに追加
sys.path.insert(0, '/app')

# app.py から Flask アプリケーションインスタンスをインポート
# mod_wsgi は application という名前の呼び出し可能オブジェクトを期待します
from app import app as application
