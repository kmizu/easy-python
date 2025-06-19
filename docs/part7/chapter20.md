# 第20章：外部システムとの連携

## この章で学ぶこと

- HTTP API クライアントの実装
- データベース操作とORM
- ファイル形式の処理（JSON、CSV、XML）
- 外部プロセスの実行
- ネットワークプログラミング
- C拡張との相互運用

## 20.1 【実行】HTTP API クライアント

```python
# http_api_client.py

import requests
import json
import time
from urllib.parse import urljoin, urlencode
from typing import Dict, Any, Optional

# 基本的なHTTP リクエスト
print("=== 基本的なHTTP リクエスト ===")

def basic_http_requests():
    """基本的なHTTPリクエストの例"""
    
    # GET リクエスト
    print("GET リクエスト:")
    response = requests.get('https://httpbin.org/get')
    print(f"ステータスコード: {response.status_code}")
    print(f"レスポンスヘッダー: {dict(list(response.headers.items())[:3])}")
    print(f"レスポンス内容: {response.json()['url']}")
    
    # POST リクエスト
    print("\nPOST リクエスト:")
    data = {'key': 'value', 'number': 42}
    response = requests.post('https://httpbin.org/post', json=data)
    print(f"送信データ: {response.json()['json']}")
    
    # クエリパラメータ
    print("\nクエリパラメータ:")
    params = {'param1': 'value1', 'param2': 'value2'}
    response = requests.get('https://httpbin.org/get', params=params)
    print(f"URL: {response.url}")
    
    # ヘッダーの設定
    print("\nカスタムヘッダー:")
    headers = {
        'User-Agent': 'MyApp/1.0',
        'Authorization': 'Bearer fake-token'
    }
    response = requests.get('https://httpbin.org/headers', headers=headers)
    print(f"送信ヘッダー: {response.json()['headers']['User-Agent']}")

basic_http_requests()

# API クライアントクラス
print("\n=== API クライアントクラス ===")

class APIClient:
    """再利用可能なAPIクライアント"""
    
    def __init__(self, base_url: str, api_key: Optional[str] = None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        
        # 共通ヘッダーの設定
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'Python-APIClient/1.0'
        })
        
        if api_key:
            self.session.headers['Authorization'] = f'Bearer {api_key}'
    
    def _make_url(self, endpoint: str) -> str:
        """エンドポイントから完全なURLを作成"""
        return urljoin(self.base_url + '/', endpoint.lstrip('/'))
    
    def _handle_response(self, response: requests.Response) -> Dict[str, Any]:
        """レスポンスの共通処理"""
        try:
            response.raise_for_status()
            return response.json()
        except requests.exceptions.HTTPError as e:
            print(f"HTTPエラー: {e}")
            raise
        except requests.exceptions.RequestException as e:
            print(f"リクエストエラー: {e}")
            raise
        except json.JSONDecodeError as e:
            print(f"JSONデコードエラー: {e}")
            raise
    
    def get(self, endpoint: str, params: Optional[Dict] = None) -> Dict[str, Any]:
        """GET リクエスト"""
        url = self._make_url(endpoint)
        response = self.session.get(url, params=params)
        return self._handle_response(response)
    
    def post(self, endpoint: str, data: Optional[Dict] = None) -> Dict[str, Any]:
        """POST リクエスト"""
        url = self._make_url(endpoint)
        response = self.session.post(url, json=data)
        return self._handle_response(response)
    
    def put(self, endpoint: str, data: Optional[Dict] = None) -> Dict[str, Any]:
        """PUT リクエスト"""
        url = self._make_url(endpoint)
        response = self.session.put(url, json=data)
        return self._handle_response(response)
    
    def delete(self, endpoint: str) -> Dict[str, Any]:
        """DELETE リクエスト"""
        url = self._make_url(endpoint)
        response = self.session.delete(url)
        return self._handle_response(response)
    
    def close(self):
        """セッションを閉じる"""
        self.session.close()

# APIクライアントの使用例
def api_client_demo():
    """APIクライアントのデモ"""
    client = APIClient('https://httpbin.org')
    
    try:
        # GET リクエスト
        result = client.get('/get', params={'test': 'value'})
        print(f"GET結果: {result['args']}")
        
        # POST リクエスト
        post_data = {'name': 'Alice', 'age': 30}
        result = client.post('/post', data=post_data)
        print(f"POST結果: {result['json']}")
        
        # エラーハンドリング
        try:
            client.get('/status/404')
        except requests.exceptions.HTTPError:
            print("404エラーを適切にキャッチしました")
        
    finally:
        client.close()

api_client_demo()

# レート制限とリトライ
print("\n=== レート制限とリトライ ===")

class RateLimitedAPIClient(APIClient):
    """レート制限とリトライ機能付きAPIクライアント"""
    
    def __init__(self, base_url: str, api_key: Optional[str] = None, 
                 rate_limit: float = 1.0, max_retries: int = 3):
        super().__init__(base_url, api_key)
        self.rate_limit = rate_limit  # 秒間リクエスト数
        self.max_retries = max_retries
        self.last_request_time = 0
    
    def _rate_limit(self):
        """レート制限の実装"""
        elapsed = time.time() - self.last_request_time
        min_interval = 1.0 / self.rate_limit
        
        if elapsed < min_interval:
            wait_time = min_interval - elapsed
            print(f"レート制限: {wait_time:.2f}秒待機")
            time.sleep(wait_time)
        
        self.last_request_time = time.time()
    
    def _retry_request(self, method: str, *args, **kwargs) -> requests.Response:
        """リトライ機能付きリクエスト"""
        for attempt in range(self.max_retries):
            try:
                self._rate_limit()
                response = getattr(self.session, method)(*args, **kwargs)
                
                # 429 Too Many Requests の場合はリトライ
                if response.status_code == 429:
                    retry_after = int(response.headers.get('Retry-After', 1))
                    print(f"リトライ {attempt + 1}: {retry_after}秒後")
                    time.sleep(retry_after)
                    continue
                
                return response
                
            except requests.exceptions.RequestException as e:
                if attempt == self.max_retries - 1:
                    raise
                wait_time = 2 ** attempt  # 指数バックオフ
                print(f"リトライ {attempt + 1}: {e}, {wait_time}秒後")
                time.sleep(wait_time)
        
        raise requests.exceptions.RequestException("最大リトライ回数に達しました")
    
    def get(self, endpoint: str, params: Optional[Dict] = None) -> Dict[str, Any]:
        """レート制限付きGET"""
        url = self._make_url(endpoint)
        response = self._retry_request('get', url, params=params)
        return self._handle_response(response)

# レート制限クライアントのテスト
def rate_limited_demo():
    """レート制限クライアントのデモ"""
    client = RateLimitedAPIClient('https://httpbin.org', rate_limit=2.0)
    
    try:
        # 複数のリクエストを素早く送信
        for i in range(3):
            result = client.get('/get', params={'request': i})
            print(f"リクエスト {i} 完了")
    
    finally:
        client.close()

rate_limited_demo()

# 非同期HTTPクライアント
print("\n=== 非同期HTTPクライアント ===")

import asyncio
import aiohttp

class AsyncAPIClient:
    """非同期APIクライアント"""
    
    def __init__(self, base_url: str, api_key: Optional[str] = None):
        self.base_url = base_url.rstrip('/')
        self.headers = {
            'Content-Type': 'application/json',
            'User-Agent': 'Python-AsyncAPIClient/1.0'
        }
        if api_key:
            self.headers['Authorization'] = f'Bearer {api_key}'
    
    async def get(self, endpoint: str, params: Optional[Dict] = None) -> Dict[str, Any]:
        """非同期GET"""
        url = self.base_url + '/' + endpoint.lstrip('/')
        
        async with aiohttp.ClientSession(headers=self.headers) as session:
            async with session.get(url, params=params) as response:
                response.raise_for_status()
                return await response.json()
    
    async def post(self, endpoint: str, data: Optional[Dict] = None) -> Dict[str, Any]:
        """非同期POST"""
        url = self.base_url + '/' + endpoint.lstrip('/')
        
        async with aiohttp.ClientSession(headers=self.headers) as session:
            async with session.post(url, json=data) as response:
                response.raise_for_status()
                return await response.json()

async def async_api_demo():
    """非同期APIクライアントのデモ"""
    client = AsyncAPIClient('https://httpbin.org')
    
    # 並行リクエスト
    tasks = []
    for i in range(5):
        task = client.get('/delay/1', params={'id': i})
        tasks.append(task)
    
    start_time = time.time()
    results = await asyncio.gather(*tasks)
    end_time = time.time()
    
    print(f"5つの並行リクエスト完了: {end_time - start_time:.2f}秒")
    print(f"結果数: {len(results)}")

# 実行
if __name__ == "__main__":
    try:
        asyncio.run(async_api_demo())
    except ImportError:
        print("aiohttp がインストールされていません")
```

## 20.2 【実行】データベース操作

```python
# database_operations.py

import sqlite3
import json
from contextlib import contextmanager
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime

# SQLite基本操作
print("=== SQLite基本操作 ===")

def basic_sqlite_operations():
    """SQLite基本操作"""
    
    # データベース接続
    conn = sqlite3.connect(':memory:')  # メモリ内データベース
    cursor = conn.cursor()
    
    try:
        # テーブル作成
        cursor.execute('''
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                age INTEGER,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # データ挿入
        users_data = [
            ('Alice', 'alice@example.com', 30),
            ('Bob', 'bob@example.com', 25),
            ('Charlie', 'charlie@example.com', 35)
        ]
        
        cursor.executemany(
            'INSERT INTO users (name, email, age) VALUES (?, ?, ?)',
            users_data
        )
        
        # データ読み取り
        cursor.execute('SELECT * FROM users WHERE age > ?', (25,))
        results = cursor.fetchall()
        
        print("年齢25歳以上のユーザー:")
        for row in results:
            print(f"  ID: {row[0]}, 名前: {row[1]}, メール: {row[2]}, 年齢: {row[3]}")
        
        # 集計
        cursor.execute('SELECT COUNT(*), AVG(age) FROM users')
        count, avg_age = cursor.fetchone()
        print(f"\n総ユーザー数: {count}, 平均年齢: {avg_age:.1f}")
        
        conn.commit()
        
    except sqlite3.Error as e:
        print(f"データベースエラー: {e}")
        conn.rollback()
    
    finally:
        conn.close()

basic_sqlite_operations()

# データベース接続管理
print("\n=== データベース接続管理 ===")

@contextmanager
def get_db_connection(db_path: str = ':memory:'):
    """データベース接続のコンテキストマネージャー"""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row  # 辞書風アクセス
    try:
        yield conn
    except Exception:
        conn.rollback()
        raise
    else:
        conn.commit()
    finally:
        conn.close()

class DatabaseManager:
    """データベース管理クラス"""
    
    def __init__(self, db_path: str = ':memory:'):
        self.db_path = db_path
        self._initialize_db()
    
    def _initialize_db(self):
        """データベースの初期化"""
        with get_db_connection(self.db_path) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS products (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    category TEXT NOT NULL,
                    price DECIMAL(10, 2) NOT NULL,
                    stock INTEGER DEFAULT 0,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
    
    def create_product(self, name: str, category: str, price: float, stock: int = 0) -> int:
        """商品を作成"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute(
                'INSERT INTO products (name, category, price, stock) VALUES (?, ?, ?, ?)',
                (name, category, price, stock)
            )
            return cursor.lastrowid
    
    def get_product(self, product_id: int) -> Optional[Dict[str, Any]]:
        """商品を取得"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute('SELECT * FROM products WHERE id = ?', (product_id,))
            row = cursor.fetchone()
            return dict(row) if row else None
    
    def get_products_by_category(self, category: str) -> List[Dict[str, Any]]:
        """カテゴリ別商品一覧"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute(
                'SELECT * FROM products WHERE category = ? ORDER BY name',
                (category,)
            )
            return [dict(row) for row in cursor.fetchall()]
    
    def update_stock(self, product_id: int, quantity: int) -> bool:
        """在庫を更新"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute(
                'UPDATE products SET stock = stock + ? WHERE id = ?',
                (quantity, product_id)
            )
            return cursor.rowcount > 0
    
    def delete_product(self, product_id: int) -> bool:
        """商品を削除"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute('DELETE FROM products WHERE id = ?', (product_id,))
            return cursor.rowcount > 0

# データベース管理クラスの使用
def database_manager_demo():
    """データベース管理クラスのデモ"""
    db = DatabaseManager()
    
    # 商品作成
    laptop_id = db.create_product("ノートPC", "電子機器", 80000, 5)
    mouse_id = db.create_product("マウス", "電子機器", 2000, 20)
    book_id = db.create_product("Python入門", "書籍", 3000, 10)
    
    print(f"作成された商品ID: {laptop_id}, {mouse_id}, {book_id}")
    
    # 商品取得
    laptop = db.get_product(laptop_id)
    print(f"ノートPC: {laptop}")
    
    # カテゴリ別取得
    electronics = db.get_products_by_category("電子機器")
    print(f"電子機器: {len(electronics)}商品")
    
    # 在庫更新
    db.update_stock(laptop_id, -1)  # 1台販売
    laptop_updated = db.get_product(laptop_id)
    print(f"販売後のノートPC在庫: {laptop_updated['stock']}")

database_manager_demo()

# ORM風のクラス
print("\n=== 簡単なORM実装 ===")

@dataclass
class User:
    """ユーザーモデル"""
    name: str
    email: str
    age: int
    id: Optional[int] = None
    created_at: Optional[datetime] = None

class SimpleORM:
    """シンプルなORM"""
    
    def __init__(self, db_path: str = ':memory:'):
        self.db_path = db_path
        self._setup_tables()
    
    def _setup_tables(self):
        """テーブル設定"""
        with get_db_connection(self.db_path) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    email TEXT UNIQUE NOT NULL,
                    age INTEGER,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
    
    def save_user(self, user: User) -> User:
        """ユーザーを保存"""
        with get_db_connection(self.db_path) as conn:
            if user.id is None:
                # 新規作成
                cursor = conn.execute(
                    'INSERT INTO users (name, email, age) VALUES (?, ?, ?)',
                    (user.name, user.email, user.age)
                )
                user.id = cursor.lastrowid
            else:
                # 更新
                conn.execute(
                    'UPDATE users SET name = ?, email = ?, age = ? WHERE id = ?',
                    (user.name, user.email, user.age, user.id)
                )
        
        return self.get_user(user.id)
    
    def get_user(self, user_id: int) -> Optional[User]:
        """ユーザーを取得"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute('SELECT * FROM users WHERE id = ?', (user_id,))
            row = cursor.fetchone()
            
            if row:
                return User(
                    id=row['id'],
                    name=row['name'],
                    email=row['email'],
                    age=row['age'],
                    created_at=datetime.fromisoformat(row['created_at'])
                )
            return None
    
    def find_users_by_age_range(self, min_age: int, max_age: int) -> List[User]:
        """年齢範囲でユーザーを検索"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute(
                'SELECT * FROM users WHERE age BETWEEN ? AND ? ORDER BY age',
                (min_age, max_age)
            )
            
            users = []
            for row in cursor.fetchall():
                users.append(User(
                    id=row['id'],
                    name=row['name'],
                    email=row['email'],
                    age=row['age'],
                    created_at=datetime.fromisoformat(row['created_at'])
                ))
            
            return users
    
    def delete_user(self, user_id: int) -> bool:
        """ユーザーを削除"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute('DELETE FROM users WHERE id = ?', (user_id,))
            return cursor.rowcount > 0

# ORM使用例
def orm_demo():
    """ORM使用例"""
    orm = SimpleORM()
    
    # ユーザー作成
    alice = User(name="Alice", email="alice@example.com", age=30)
    bob = User(name="Bob", email="bob@example.com", age=25)
    
    alice = orm.save_user(alice)
    bob = orm.save_user(bob)
    
    print(f"作成されたユーザー: {alice.name} (ID: {alice.id})")
    
    # ユーザー取得
    retrieved_user = orm.get_user(alice.id)
    print(f"取得したユーザー: {retrieved_user}")
    
    # 年齢範囲で検索
    young_users = orm.find_users_by_age_range(20, 30)
    print(f"20-30歳のユーザー: {[u.name for u in young_users]}")
    
    # ユーザー更新
    alice.age = 31
    updated_alice = orm.save_user(alice)
    print(f"更新後の年齢: {updated_alice.age}")

orm_demo()

# トランザクション処理
print("\n=== トランザクション処理 ===")

class BankAccount:
    """銀行口座（トランザクション例）"""
    
    def __init__(self, db_path: str = ':memory:'):
        self.db_path = db_path
        self._setup_tables()
    
    def _setup_tables(self):
        """テーブル設定"""
        with get_db_connection(self.db_path) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS accounts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    balance DECIMAL(10, 2) NOT NULL DEFAULT 0
                )
            ''')
            
            conn.execute('''
                CREATE TABLE IF NOT EXISTS transactions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    account_id INTEGER,
                    amount DECIMAL(10, 2) NOT NULL,
                    description TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (account_id) REFERENCES accounts (id)
                )
            ''')
    
    def create_account(self, name: str, initial_balance: float = 0) -> int:
        """口座作成"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute(
                'INSERT INTO accounts (name, balance) VALUES (?, ?)',
                (name, initial_balance)
            )
            account_id = cursor.lastrowid
            
            if initial_balance > 0:
                conn.execute(
                    'INSERT INTO transactions (account_id, amount, description) VALUES (?, ?, ?)',
                    (account_id, initial_balance, '初期入金')
                )
            
            return account_id
    
    def transfer(self, from_account: int, to_account: int, amount: float) -> bool:
        """振り込み（トランザクション）"""
        if amount <= 0:
            raise ValueError("振込金額は正の数である必要があります")
        
        with get_db_connection(self.db_path) as conn:
            # 送金元の残高確認
            cursor = conn.execute('SELECT balance FROM accounts WHERE id = ?', (from_account,))
            row = cursor.fetchone()
            if not row or row['balance'] < amount:
                raise ValueError("残高不足です")
            
            # 振り込み処理（原子性が保証される）
            conn.execute(
                'UPDATE accounts SET balance = balance - ? WHERE id = ?',
                (amount, from_account)
            )
            
            conn.execute(
                'UPDATE accounts SET balance = balance + ? WHERE id = ?',
                (amount, to_account)
            )
            
            # 取引記録
            conn.execute(
                'INSERT INTO transactions (account_id, amount, description) VALUES (?, ?, ?)',
                (from_account, -amount, f'振込先: {to_account}')
            )
            
            conn.execute(
                'INSERT INTO transactions (account_id, amount, description) VALUES (?, ?, ?)',
                (to_account, amount, f'振込元: {from_account}')
            )
            
            return True
    
    def get_balance(self, account_id: int) -> float:
        """残高取得"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute('SELECT balance FROM accounts WHERE id = ?', (account_id,))
            row = cursor.fetchone()
            return float(row['balance']) if row else 0.0
    
    def get_transactions(self, account_id: int) -> List[Dict[str, Any]]:
        """取引履歴取得"""
        with get_db_connection(self.db_path) as conn:
            cursor = conn.execute(
                'SELECT * FROM transactions WHERE account_id = ? ORDER BY created_at DESC',
                (account_id,)
            )
            return [dict(row) for row in cursor.fetchall()]

# 銀行口座システムのデモ
def bank_demo():
    """銀行口座システムのデモ"""
    bank = BankAccount()
    
    # 口座作成
    alice_account = bank.create_account("Alice", 10000)
    bob_account = bank.create_account("Bob", 5000)
    
    print(f"Alice口座残高: {bank.get_balance(alice_account)}")
    print(f"Bob口座残高: {bank.get_balance(bob_account)}")
    
    # 振り込み
    try:
        bank.transfer(alice_account, bob_account, 3000)
        print("\n振り込み成功")
        print(f"Alice口座残高: {bank.get_balance(alice_account)}")
        print(f"Bob口座残高: {bank.get_balance(bob_account)}")
        
        # 取引履歴
        alice_transactions = bank.get_transactions(alice_account)
        print(f"\nAliceの取引履歴: {len(alice_transactions)}件")
        for tx in alice_transactions:
            print(f"  {tx['amount']:+.0f}円 - {tx['description']}")
    
    except ValueError as e:
        print(f"振り込みエラー: {e}")

bank_demo()
```

## 20.3 【実行】ファイル形式の処理

```python
# file_format_processing.py

import json
import csv
import xml.etree.ElementTree as ET
import xml.dom.minidom
from io import StringIO
from typing import Dict, List, Any
import tempfile
import os

# JSON処理
print("=== JSON処理 ===")

def json_processing():
    """JSON処理の例"""
    
    # Pythonオブジェクト → JSON
    data = {
        'users': [
            {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
            {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'}
        ],
        'metadata': {
            'count': 2,
            'generated_at': '2023-01-01T12:00:00Z'
        }
    }
    
    # JSON文字列に変換
    json_string = json.dumps(data, indent=2, ensure_ascii=False)
    print("JSON文字列:")
    print(json_string)
    
    # JSON文字列 → Pythonオブジェクト
    parsed_data = json.loads(json_string)
    print(f"\nパースしたデータ: {parsed_data['metadata']['count']}件")
    
    # ファイルI/O
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        temp_file = f.name
    
    with open(temp_file, 'r') as f:
        loaded_data = json.load(f)
    
    print(f"ファイルから読み込み: {loaded_data['users'][0]['name']}")
    
    # カスタムJSONエンコーダー
    from datetime import datetime
    import decimal
    
    class CustomJSONEncoder(json.JSONEncoder):
        def default(self, obj):
            if isinstance(obj, datetime):
                return obj.isoformat()
            elif isinstance(obj, decimal.Decimal):
                return float(obj)
            return super().default(obj)
    
    complex_data = {
        'timestamp': datetime.now(),
        'price': decimal.Decimal('123.45'),
        'name': 'テスト商品'
    }
    
    custom_json = json.dumps(complex_data, cls=CustomJSONEncoder, ensure_ascii=False)
    print(f"\nカスタムエンコーダー: {custom_json}")
    
    # クリーンアップ
    os.unlink(temp_file)

json_processing()

# CSV処理
print("\n=== CSV処理 ===")

def csv_processing():
    """CSV処理の例"""
    
    # CSV書き込み
    csv_data = [
        ['ID', '名前', '年齢', '都市'],
        [1, 'Alice', 30, '東京'],
        [2, 'Bob', 25, '大阪'],
        [3, 'Charlie', 35, '名古屋']
    ]
    
    # StringIOを使用したメモリ内CSV
    csv_buffer = StringIO()
    csv_writer = csv.writer(csv_buffer)
    csv_writer.writerows(csv_data)
    csv_content = csv_buffer.getvalue()
    
    print("CSV内容:")
    print(csv_content)
    
    # CSV読み込み
    csv_buffer.seek(0)
    csv_reader = csv.reader(csv_buffer)
    
    print("CSV読み込み:")
    headers = next(csv_reader)
    print(f"ヘッダー: {headers}")
    
    for row in csv_reader:
        print(f"  {row}")
    
    # DictReader/DictWriter
    csv_buffer = StringIO()
    fieldnames = ['id', 'name', 'age', 'city']
    
    dict_writer = csv.DictWriter(csv_buffer, fieldnames=fieldnames)
    dict_writer.writeheader()
    dict_writer.writerows([
        {'id': 1, 'name': 'Alice', 'age': 30, 'city': '東京'},
        {'id': 2, 'name': 'Bob', 'age': 25, 'city': '大阪'}
    ])
    
    csv_buffer.seek(0)
    dict_reader = csv.DictReader(csv_buffer)
    
    print("\nDictReaderによる読み込み:")
    for row in dict_reader:
        print(f"  {row['name']}さん（{row['age']}歳）は{row['city']}在住")
    
    # カスタム区切り文字とクォート処理
    tsv_data = "名前\t年齢\t\"趣味、特技\"\nAlice\t30\t\"読書、プログラミング\"\nBob\t25\t\"映画鑑賞、料理\""
    
    tsv_reader = csv.reader(StringIO(tsv_data), delimiter='\t')
    print("\nTSV読み込み:")
    for row in tsv_reader:
        print(f"  {row}")

csv_processing()

# XML処理
print("\n=== XML処理 ===")

def xml_processing():
    """XML処理の例"""
    
    # XML作成
    root = ET.Element("catalog")
    
    # 書籍1
    book1 = ET.SubElement(root, "book", id="1")
    ET.SubElement(book1, "title").text = "Python入門"
    ET.SubElement(book1, "author").text = "田中太郎"
    ET.SubElement(book1, "price").text = "3000"
    ET.SubElement(book1, "category").text = "プログラミング"
    
    # 書籍2
    book2 = ET.SubElement(root, "book", id="2")
    ET.SubElement(book2, "title").text = "データサイエンス実践"
    ET.SubElement(book2, "author").text = "佐藤花子"
    ET.SubElement(book2, "price").text = "4500"
    ET.SubElement(book2, "category").text = "データ分析"
    
    # XML文字列に変換
    xml_string = ET.tostring(root, encoding='unicode')
    
    # 整形版
    dom = xml.dom.minidom.parseString(xml_string)
    pretty_xml = dom.toprettyxml(indent="  ")
    
    print("生成されたXML:")
    print(pretty_xml)
    
    # XML解析
    print("XML解析結果:")
    for book in root.findall('book'):
        book_id = book.get('id')
        title = book.find('title').text
        author = book.find('author').text
        price = int(book.find('price').text)
        category = book.find('category').text
        
        print(f"  書籍{book_id}: 「{title}」{author}著 {price}円 ({category})")
    
    # XPath風の検索
    programming_books = root.findall(".//book[category='プログラミング']")
    print(f"\nプログラミング関連書籍: {len(programming_books)}冊")
    
    # 名前空間付きXML
    ns_xml = '''<?xml version="1.0" encoding="UTF-8"?>
    <catalog xmlns="http://example.com/books" xmlns:meta="http://example.com/metadata">
        <book id="1">
            <title>Python入門</title>
            <meta:published>2023-01-01</meta:published>
        </book>
    </catalog>'''
    
    ns_root = ET.fromstring(ns_xml)
    
    # 名前空間を考慮した検索
    namespaces = {
        'books': 'http://example.com/books',
        'meta': 'http://example.com/metadata'
    }
    
    title = ns_root.find('.//books:title', namespaces)
    published = ns_root.find('.//meta:published', namespaces)
    
    if title is not None and published is not None:
        print(f"\n名前空間付きXML: {title.text} ({published.text})")

xml_processing()

# 設定ファイル処理
print("\n=== 設定ファイル処理 ===")

import configparser
from pathlib import Path

def config_file_processing():
    """設定ファイル処理の例"""
    
    # INI形式の設定ファイル
    config = configparser.ConfigParser()
    
    # 設定を追加
    config['DEFAULT'] = {
        'debug': 'false',
        'log_level': 'info'
    }
    
    config['database'] = {
        'host': 'localhost',
        'port': '5432',
        'name': 'myapp',
        'user': 'admin'
    }
    
    config['api'] = {
        'base_url': 'https://api.example.com',
        'timeout': '30',
        'retry_count': '3'
    }
    
    # StringIOに書き込み
    config_buffer = StringIO()
    config.write(config_buffer)
    config_content = config_buffer.getvalue()
    
    print("生成された設定ファイル:")
    print(config_content)
    
    # 設定読み込み
    config_buffer.seek(0)
    loaded_config = configparser.ConfigParser()
    loaded_config.read_file(config_buffer)
    
    print("設定読み込み:")
    print(f"  データベースホスト: {loaded_config['database']['host']}")
    print(f"  APIタイムアウト: {loaded_config.getint('api', 'timeout')}秒")
    print(f"  デバッグモード: {loaded_config.getboolean('DEFAULT', 'debug')}")
    
    # 環境変数による設定オーバーライド
    class EnvConfigParser(configparser.ConfigParser):
        """環境変数でオーバーライド可能な設定パーサー"""
        
        def get(self, section, option, **kwargs):
            # 環境変数名: SECTION_OPTION
            env_key = f"{section.upper()}_{option.upper()}"
            env_value = os.environ.get(env_key)
            
            if env_value is not None:
                return env_value
            
            return super().get(section, option, **kwargs)
    
    # 環境変数設定のテスト
    os.environ['DATABASE_HOST'] = 'production.example.com'
    
    env_config = EnvConfigParser()
    env_config.read_string(config_content)
    
    print(f"\n環境変数オーバーライド後のホスト: {env_config.get('database', 'host')}")
    
    # クリーンアップ
    del os.environ['DATABASE_HOST']

config_file_processing()

# バイナリファイル処理
print("\n=== バイナリファイル処理 ===")

def binary_file_processing():
    """バイナリファイル処理の例"""
    
    # 画像ファイルのメタデータ読み取り（シミュレーション）
    def read_image_header(file_path):
        """画像ファイルのヘッダー情報を読み取り"""
        with open(file_path, 'rb') as f:
            # PNG の場合の例
            header = f.read(8)
            if header.startswith(b'\x89PNG\r\n\x1a\n'):
                return {'format': 'PNG', 'valid': True}
            # JPEG の場合の例
            elif header.startswith(b'\xff\xd8\xff'):
                return {'format': 'JPEG', 'valid': True}
            else:
                return {'format': 'Unknown', 'valid': False}
    
    # テスト用バイナリファイル作成
    with tempfile.NamedTemporaryFile(delete=False) as f:
        # PNG風のヘッダーを書き込み
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(b'fake image data...')
        temp_image = f.name
    
    header_info = read_image_header(temp_image)
    print(f"画像ヘッダー情報: {header_info}")
    
    # バイナリデータの構造化読み書き
    import struct
    
    # 構造体形式でデータをパック
    data = struct.pack('!I2sH', 12345, b'AB', 678)  # ビッグエンディアン
    print(f"パックされたデータ: {data.hex()}")
    
    # データをアンパック
    unpacked = struct.unpack('!I2sH', data)
    print(f"アンパックされたデータ: {unpacked}")
    
    # バイナリファイルとしてデータ保存
    binary_data = {
        'version': 1,
        'count': 100,
        'values': [1.5, 2.7, 3.14]
    }
    
    with tempfile.NamedTemporaryFile(delete=False) as f:
        # ヘッダー
        f.write(struct.pack('!II', binary_data['version'], binary_data['count']))
        # 浮動小数点数配列
        for value in binary_data['values']:
            f.write(struct.pack('!f', value))
        temp_binary = f.name
    
    # バイナリファイル読み込み
    with open(temp_binary, 'rb') as f:
        version, count = struct.unpack('!II', f.read(8))
        values = []
        for _ in range(len(binary_data['values'])):
            value, = struct.unpack('!f', f.read(4))
            values.append(value)
    
    print(f"読み込んだバイナリデータ: version={version}, count={count}, values={values}")
    
    # クリーンアップ
    os.unlink(temp_image)
    os.unlink(temp_binary)

binary_file_processing()
```

## 20.4 【実行】外部プロセスの実行

```python
# external_process.py

import subprocess
import os
import sys
import threading
import time
from pathlib import Path

# 基本的なプロセス実行
print("=== 基本的なプロセス実行 ===")

def basic_subprocess():
    """基本的なsubprocess使用例"""
    
    # シンプルなコマンド実行
    result = subprocess.run(['python', '--version'], 
                          capture_output=True, text=True)
    
    print(f"Pythonバージョン: {result.stdout.strip()}")
    print(f"リターンコード: {result.returncode}")
    
    # 現在のディレクトリのファイル一覧
    if sys.platform.startswith('win'):
        cmd = ['dir']
        shell = True
    else:
        cmd = ['ls', '-la']
        shell = False
    
    result = subprocess.run(cmd, capture_output=True, text=True, shell=shell)
    print(f"\nディレクトリ一覧（最初の5行）:")
    lines = result.stdout.split('\n')[:5]
    for line in lines:
        print(f"  {line}")
    
    # エラー処理
    try:
        result = subprocess.run(['nonexistent_command'], 
                              capture_output=True, text=True, 
                              check=True)  # エラー時に例外発生
    except subprocess.CalledProcessError as e:
        print(f"\nコマンドエラー: {e}")
        print(f"stderr: {e.stderr}")
    except FileNotFoundError as e:
        print(f"\nファイルが見つかりません: {e}")

basic_subprocess()

# インタラクティブなプロセス
print("\n=== インタラクティブなプロセス ===")

def interactive_subprocess():
    """インタラクティブなプロセス通信"""
    
    # Pythonインタープリターとの通信
    print("Pythonインタープリターとの通信:")
    
    process = subprocess.Popen(
        [sys.executable, '-i'],  # インタラクティブモード
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    # コマンドを送信
    commands = [
        "print('Hello from subprocess!')\n",
        "x = 10 + 20\n",
        "print(f'計算結果: {x}')\n",
        "exit()\n"
    ]
    
    try:
        for cmd in commands:
            print(f"送信: {cmd.strip()}")
            process.stdin.write(cmd)
            process.stdin.flush()
            time.sleep(0.1)  # 出力待ち
        
        # プロセス終了を待つ
        stdout, stderr = process.communicate(timeout=5)
        
        print("出力:")
        print(stdout)
        
        if stderr:
            print("エラー:")
            print(stderr)
    
    except subprocess.TimeoutExpired:
        process.kill()
        print("プロセスがタイムアウトしました")
    
    finally:
        if process.poll() is None:
            process.terminate()

interactive_subprocess()

# 非同期プロセス実行
print("\n=== 非同期プロセス実行 ===")

def async_subprocess():
    """非同期でプロセスを実行"""
    
    def run_command(command, name):
        """コマンドを実行する関数"""
        print(f"{name}: 開始")
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        print(f"{name}: 完了 (終了コード: {result.returncode})")
        return result
    
    # 複数のコマンドを並列実行
    if sys.platform.startswith('win'):
        commands = [
            ('timeout 2', 'Command1'),  # 2秒待機
            ('timeout 1', 'Command2'),  # 1秒待機
            ('timeout 3', 'Command3'),  # 3秒待機
        ]
    else:
        commands = [
            ('sleep 2', 'Command1'),
            ('sleep 1', 'Command2'), 
            ('sleep 3', 'Command3'),
        ]
    
    threads = []
    results = {}
    
    def thread_worker(cmd, name):
        results[name] = run_command(cmd, name)
    
    start_time = time.time()
    
    # スレッドで並列実行
    for cmd, name in commands:
        thread = threading.Thread(target=thread_worker, args=(cmd, name))
        threads.append(thread)
        thread.start()
    
    # すべてのスレッドの完了を待つ
    for thread in threads:
        thread.join()
    
    end_time = time.time()
    print(f"\n並列実行時間: {end_time - start_time:.2f}秒")

async_subprocess()

# プロセス監視
print("\n=== プロセス監視 ===")

def process_monitoring():
    """プロセスの監視"""
    
    # 長時間実行されるプロセスを作成
    if sys.platform.startswith('win'):
        cmd = ['ping', '127.0.0.1', '-n', '10']
    else:
        cmd = ['ping', '-c', '10', '127.0.0.1']
    
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, 
                              stderr=subprocess.PIPE, text=True)
    
    print(f"プロセス開始 (PID: {process.pid})")
    
    # リアルタイムでの出力読み込み
    def read_output():
        """出力を読み込むスレッド"""
        for line in iter(process.stdout.readline, ''):
            if line.strip():
                print(f"出力: {line.strip()}")
        process.stdout.close()
    
    # 出力読み込み用スレッド
    output_thread = threading.Thread(target=read_output)
    output_thread.daemon = True
    output_thread.start()
    
    # プロセスの状態を監視
    while process.poll() is None:
        print(f"プロセス実行中... (PID: {process.pid})")
        time.sleep(2)
    
    print(f"プロセス終了 (終了コード: {process.returncode})")

# process_monitoring()  # 時間がかかるのでコメントアウト

# ファイル処理のプロセス化
print("\n=== ファイル処理のプロセス化 ===")

def file_processing_subprocess():
    """ファイル処理を外部プロセスで実行"""
    
    # 処理用のPythonスクリプトを作成
    processor_script = '''
import sys
import json
import time

def process_file(input_file, output_file):
    """ファイルを処理（時間のかかる処理をシミュレート）"""
    with open(input_file, 'r') as f:
        data = json.load(f)
    
    # 何らかの重い処理
    processed_data = []
    for item in data:
        time.sleep(0.1)  # 処理時間をシミュレート
        processed_item = {
            'id': item['id'],
            'name': item['name'],
            'processed': True,
            'timestamp': time.time()
        }
        processed_data.append(processed_item)
    
    with open(output_file, 'w') as f:
        json.dump(processed_data, f, indent=2)
    
    print(f"処理完了: {len(processed_data)}件")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("使用法: processor.py <input_file> <output_file>")
        sys.exit(1)
    
    process_file(sys.argv[1], sys.argv[2])
'''
    
    # テスト用のデータファイル作成
    test_data = [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
        {'id': 3, 'name': 'Charlie'}
    ]
    
    with open('input.json', 'w') as f:
        json.dump(test_data, f)
    
    with open('processor.py', 'w') as f:
        f.write(processor_script)
    
    # 外部プロセスでファイル処理を実行
    print("ファイル処理を外部プロセスで実行:")
    result = subprocess.run([
        sys.executable, 'processor.py', 'input.json', 'output.json'
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"処理成功: {result.stdout.strip()}")
        
        # 結果ファイルを確認
        with open('output.json', 'r') as f:
            processed_data = json.load(f)
        
        print(f"処理結果: {len(processed_data)}件")
        for item in processed_data:
            print(f"  {item['name']} (処理済み: {item['processed']})")
    
    else:
        print(f"処理エラー: {result.stderr}")
    
    # クリーンアップ
    for file in ['input.json', 'output.json', 'processor.py']:
        if os.path.exists(file):
            os.remove(file)

file_processing_subprocess()

# 環境変数とプロセス実行
print("\n=== 環境変数とプロセス実行 ===")

def subprocess_with_env():
    """環境変数を設定してプロセス実行"""
    
    # 環境変数を設定
    env = os.environ.copy()
    env['MY_CUSTOM_VAR'] = 'Hello from subprocess!'
    env['PYTHON_PATH'] = '/custom/path'
    
    # 環境変数を表示するPythonコード
    python_code = '''
import os
print(f"カスタム変数: {os.environ.get('MY_CUSTOM_VAR', '未設定')}")
print(f"Python PATH: {os.environ.get('PYTHON_PATH', '未設定')}")
print(f"現在のディレクトリ: {os.getcwd()}")
'''
    
    result = subprocess.run([sys.executable, '-c', python_code],
                          capture_output=True, text=True, env=env)
    
    print("環境変数付きプロセス実行:")
    print(result.stdout)
    
    # 作業ディレクトリを変更して実行
    temp_dir = Path.cwd() / 'temp_work'
    temp_dir.mkdir(exist_ok=True)
    
    try:
        result = subprocess.run([sys.executable, '-c', 'import os; print(os.getcwd())'],
                              capture_output=True, text=True, cwd=temp_dir)
        
        print(f"変更された作業ディレクトリ: {result.stdout.strip()}")
    
    finally:
        temp_dir.rmdir()

subprocess_with_env()

# プロセスプール
print("\n=== プロセスプール ===")

def subprocess_pool():
    """複数のプロセスを効率的に管理"""
    
    from concurrent.futures import ProcessPoolExecutor
    import multiprocessing
    
    def cpu_intensive_task(n):
        """CPU集約的なタスク"""
        total = 0
        for i in range(n):
            total += i ** 2
        return total
    
    numbers = [100000, 200000, 150000, 300000]
    
    # プロセスプールで並列実行
    print("プロセスプールでCPU集約的タスク実行:")
    
    with ProcessPoolExecutor(max_workers=multiprocessing.cpu_count()) as executor:
        start_time = time.time()
        results = list(executor.map(cpu_intensive_task, numbers))
        end_time = time.time()
    
    print(f"結果: {results}")
    print(f"実行時間: {end_time - start_time:.2f}秒")

subprocess_pool()
```

## 20.5 この章のまとめ

- HTTP APIクライアントはrequestsライブラリで効率的に実装できる
- データベース操作はトランザクション処理と適切なエラーハンドリングが重要
- JSON、CSV、XMLなど様々なファイル形式に対応した処理が可能
- subprocessモジュールで外部プロセスを制御できる
- 並行処理とプロセス間通信でシステム連携を効率化
- セキュリティとパフォーマンスを考慮した設計が必要

## 練習問題

1. **API集約サービス**
   複数のAPIからデータを取得して統合するサービスを作成してください。

2. **データ移行ツール**
   異なるデータベース間でデータを移行するツールを実装してください。

3. **ログ解析システム**
   様々な形式のログファイルを解析するシステムを作成してください。

4. **バッチ処理フレームワーク**
   大量のファイルを並列処理するフレームワークを実装してください。

5. **監視ダッシュボード**
   外部システムの状態を監視するダッシュボードを作成してください。

---

次章では、テストとデバッグについて学びます。

[第21章 テストとデバッグ →](../part8/chapter21.md)