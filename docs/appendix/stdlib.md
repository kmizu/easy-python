# 付録B：標準ライブラリ重要モジュール一覧

この付録では、Python標準ライブラリの中でも特に重要で頻繁に使用されるモジュールを分野別に整理して紹介します。

## 内蔵関数とビルトイン型

### 主要な内蔵関数

| 関数名 | 用途 | 使用例 |
|--------|------|--------|
| `len()` | オブジェクトの長さを取得 | `len([1, 2, 3])` → `3` |
| `range()` | 連続する整数を生成 | `range(5)` → `0, 1, 2, 3, 4` |
| `enumerate()` | インデックス付きイテレーション | `enumerate(['a', 'b'])` → `(0, 'a'), (1, 'b')` |
| `zip()` | 複数のイテラブルを結合 | `zip([1, 2], ['a', 'b'])` → `(1, 'a'), (2, 'b')` |
| `map()` | 関数を各要素に適用 | `map(str, [1, 2, 3])` → `['1', '2', '3']` |
| `filter()` | 条件に合う要素を抽出 | `filter(lambda x: x > 0, [-1, 0, 1, 2])` → `[1, 2]` |
| `sorted()` | ソートされたリストを返す | `sorted([3, 1, 2])` → `[1, 2, 3]` |
| `reversed()` | 逆順のイテレータを返す | `list(reversed([1, 2, 3]))` → `[3, 2, 1]` |
| `all()` | 全ての要素が真か判定 | `all([True, True, False])` → `False` |
| `any()` | いずれかの要素が真か判定 | `any([False, True, False])` → `True` |
| `sum()` | 数値の合計を計算 | `sum([1, 2, 3])` → `6` |
| `min()` / `max()` | 最小値/最大値を取得 | `min([3, 1, 2])` → `1` |

### 型変換関数

| 関数名 | 用途 | 使用例 |
|--------|------|--------|
| `int()` | 整数に変換 | `int('123')` → `123` |
| `float()` | 浮動小数点数に変換 | `float('3.14')` → `3.14` |
| `str()` | 文字列に変換 | `str(123)` → `'123'` |
| `bool()` | ブール値に変換 | `bool(0)` → `False` |
| `list()` | リストに変換 | `list('abc')` → `['a', 'b', 'c']` |
| `tuple()` | タプルに変換 | `tuple([1, 2, 3])` → `(1, 2, 3)` |
| `set()` | セットに変換 | `set([1, 2, 2, 3])` → `{1, 2, 3}` |
| `dict()` | 辞書に変換 | `dict([('a', 1), ('b', 2)])` → `{'a': 1, 'b': 2}` |

### オブジェクト操作関数

| 関数名 | 用途 | 使用例 |
|--------|------|--------|
| `type()` | オブジェクトの型を取得 | `type(123)` → `<class 'int'>` |
| `isinstance()` | 型の判定 | `isinstance(123, int)` → `True` |
| `hasattr()` | 属性の存在確認 | `hasattr(obj, 'method')` |
| `getattr()` | 属性値の取得 | `getattr(obj, 'attr', default)` |
| `setattr()` | 属性値の設定 | `setattr(obj, 'attr', value)` |
| `delattr()` | 属性の削除 | `delattr(obj, 'attr')` |
| `dir()` | オブジェクトの属性一覧 | `dir(obj)` |
| `vars()` | オブジェクトの`__dict__`を取得 | `vars(obj)` |
| `id()` | オブジェクトのIDを取得 | `id(obj)` |

## 文字列処理

### `string` モジュール

```python
import string

# 定数
string.ascii_letters    # 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
string.ascii_lowercase  # 'abcdefghijklmnopqrstuvwxyz'
string.ascii_uppercase  # 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
string.digits          # '0123456789'
string.punctuation     # '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
string.printable       # 印刷可能文字すべて
string.whitespace      # ' \t\n\r\x0b\x0c'

# テンプレート文字列
template = string.Template('Hello, $name!')
template.substitute(name='World')  # 'Hello, World!'
```

### `re` モジュール（正規表現）

```python
import re

# 基本的な関数
re.match(pattern, string)     # 文字列の先頭からマッチ
re.search(pattern, string)    # 文字列全体からマッチを検索
re.findall(pattern, string)   # すべてのマッチを検索
re.finditer(pattern, string)  # すべてのマッチのイテレータ
re.sub(pattern, repl, string) # マッチした部分を置換
re.split(pattern, string)     # パターンで文字列を分割

# コンパイルされたパターンオブジェクト
pattern = re.compile(r'\d+')
pattern.findall('123 abc 456')  # ['123', '456']

# 主要なフラグ
re.IGNORECASE  # 大文字小文字を無視
re.MULTILINE   # 複数行モード
re.DOTALL      # . が改行文字にもマッチ
re.VERBOSE     # 詳細モード（コメント可能）
```

## 数値計算

### `math` モジュール

```python
import math

# 定数
math.pi        # 円周率
math.e         # 自然対数の底
math.inf       # 正の無限大
math.nan       # NaN（Not a Number）

# 基本的な関数
math.ceil(x)   # 天井関数（切り上げ）
math.floor(x)  # 床関数（切り下げ）
math.trunc(x)  # 0に向かって切り捨て
math.fabs(x)   # 絶対値
math.gcd(a, b) # 最大公約数

# 冪と対数
math.pow(x, y)    # x の y 乗
math.sqrt(x)      # 平方根
math.log(x, base) # 対数
math.log10(x)     # 常用対数
math.log2(x)      # 二進対数

# 三角関数
math.sin(x)    # サイン
math.cos(x)    # コサイン
math.tan(x)    # タンジェント
math.asin(x)   # アークサイン
math.acos(x)   # アークコサイン
math.atan(x)   # アークタンジェント
math.degrees(x) # ラジアンを度に変換
math.radians(x) # 度をラジアンに変換
```

### `random` モジュール

```python
import random

# 基本的な乱数生成
random.random()           # 0.0以上1.0未満の浮動小数点数
random.randint(a, b)      # a以上b以下の整数
random.uniform(a, b)      # a以上b以下の浮動小数点数
random.choice(sequence)   # シーケンスからランダムに選択
random.choices(sequence, k=n)  # 重複ありでn個選択
random.sample(sequence, k=n)   # 重複なしでn個選択

# シーケンスの操作
random.shuffle(sequence)  # シーケンスをシャッフル（破壊的）

# 分布関数
random.gauss(mu, sigma)   # ガウス分布
random.expovariate(lambd) # 指数分布
random.normalvariate(mu, sigma) # 正規分布

# シード設定
random.seed(42)  # 再現可能な乱数のためのシード設定
```

### `decimal` モジュール（高精度小数）

```python
from decimal import Decimal, getcontext

# 精度の設定
getcontext().prec = 50  # 50桁の精度

# Decimalオブジェクトの作成
d1 = Decimal('0.1')
d2 = Decimal('0.2')
print(d1 + d2)  # 0.3（浮動小数点数の誤差なし）

# 文字列から作成（推奨）
price = Decimal('19.99')
tax_rate = Decimal('0.08')
total = price * (1 + tax_rate)
```

## 日付と時刻

### `datetime` モジュール

```python
from datetime import datetime, date, time, timedelta

# 現在の日時
now = datetime.now()
today = date.today()

# 日時の作成
dt = datetime(2023, 12, 25, 15, 30, 0)
d = date(2023, 12, 25)
t = time(15, 30, 0)

# 文字列からの変換
dt = datetime.strptime('2023-12-25 15:30:00', '%Y-%m-%d %H:%M:%S')

# 文字列への変換
dt_str = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# 時間差の計算
delta = timedelta(days=7, hours=3, minutes=30)
future = datetime.now() + delta

# 比較
if datetime.now() > dt:
    print("現在時刻は指定時刻より後です")
```

### `time` モジュール

```python
import time

# 現在時刻の取得
current_time = time.time()        # UNIX タイムスタンプ
local_time = time.localtime()     # ローカル時刻
utc_time = time.gmtime()          # UTC時刻

# 時刻の表示
formatted = time.strftime('%Y-%m-%d %H:%M:%S', local_time)

# 処理の一時停止
time.sleep(1)  # 1秒間停止

# 処理時間の計測
start = time.time()
# 何らかの処理
elapsed = time.time() - start
```

## ファイルとディレクトリ操作

### `os` モジュール

```python
import os

# 現在のディレクトリ
current_dir = os.getcwd()
os.chdir('/path/to/directory')  # ディレクトリ変更

# ディレクトリ操作
os.mkdir('new_directory')       # ディレクトリ作成
os.makedirs('path/to/dir')      # 再帰的にディレクトリ作成
os.rmdir('directory')           # 空のディレクトリ削除
os.removedirs('path/to/dir')    # 再帰的にディレクトリ削除

# ファイル操作
os.remove('file.txt')           # ファイル削除
os.rename('old.txt', 'new.txt') # ファイル名変更

# ディレクトリ一覧
files = os.listdir('.')         # カレントディレクトリのファイル一覧

# パス操作
os.path.join('path', 'to', 'file.txt')  # パスの結合
os.path.exists('file.txt')              # ファイル存在確認
os.path.isfile('file.txt')              # ファイルかどうか
os.path.isdir('directory')              # ディレクトリかどうか
os.path.basename('/path/to/file.txt')   # ファイル名部分
os.path.dirname('/path/to/file.txt')    # ディレクトリ部分
os.path.splitext('file.txt')            # 拡張子の分離

# 環境変数
home = os.environ.get('HOME')
os.environ['MY_VAR'] = 'value'
```

### `pathlib` モジュール（Python 3.4+）

```python
from pathlib import Path

# Pathオブジェクトの作成
p = Path('.')
home = Path.home()
tmp = Path('/tmp')

# パス操作
file_path = Path('data') / 'file.txt'  # パスの結合
parent = file_path.parent              # 親ディレクトリ
name = file_path.name                  # ファイル名
stem = file_path.stem                  # 拡張子なしのファイル名
suffix = file_path.suffix              # 拡張子

# ファイル・ディレクトリ操作
file_path.exists()        # 存在確認
file_path.is_file()       # ファイルかどうか
file_path.is_dir()        # ディレクトリかどうか
file_path.mkdir()         # ディレクトリ作成
file_path.touch()         # 空ファイル作成
file_path.unlink()        # ファイル削除

# ファイル読み書き
content = file_path.read_text()
file_path.write_text('Hello, World!')
```

### `shutil` モジュール（高レベルファイル操作）

```python
import shutil

# ファイル・ディレクトリのコピー
shutil.copy('src.txt', 'dst.txt')                    # ファイルコピー
shutil.copy2('src.txt', 'dst.txt')                   # メタデータも含めてコピー
shutil.copytree('src_dir', 'dst_dir')                # ディレクトリツリーのコピー

# ファイル・ディレクトリの移動
shutil.move('src.txt', 'dst.txt')                    # ファイル移動

# ディレクトリの削除
shutil.rmtree('directory')                           # ディレクトリツリーの削除

# アーカイブ操作
shutil.make_archive('archive', 'zip', 'directory')   # ZIPアーカイブ作成
shutil.unpack_archive('archive.zip', 'extract_dir')  # アーカイブ展開

# ディスク使用量
total, used, free = shutil.disk_usage('/')           # ディスク使用量取得
```

## データ構造とアルゴリズム

### `collections` モジュール

```python
from collections import (
    Counter, defaultdict, deque, namedtuple,
    OrderedDict, ChainMap
)

# Counter: 要素の出現回数をカウント
count = Counter('hello world')
print(count)  # Counter({'l': 3, 'o': 2, 'h': 1, 'e': 1, ' ': 1, 'w': 1, 'r': 1, 'd': 1})
count.most_common(2)  # [('l', 3), ('o', 2)]

# defaultdict: デフォルト値を持つ辞書
dd = defaultdict(list)
dd['key'].append('value')  # KeyErrorが発生しない

# deque: 両端キュー
dq = deque([1, 2, 3])
dq.appendleft(0)     # 左端に追加
dq.append(4)         # 右端に追加
dq.popleft()         # 左端から削除
dq.pop()             # 右端から削除

# namedtuple: 名前付きタプル
Point = namedtuple('Point', ['x', 'y'])
p = Point(1, 2)
print(p.x, p.y)      # 1 2

# OrderedDict: 順序を保持する辞書（Python 3.7+では通常のdictも順序保持）
od = OrderedDict([('a', 1), ('b', 2)])
od.move_to_end('a')  # 'a'を末尾に移動

# ChainMap: 複数の辞書を連鎖
dict1 = {'a': 1, 'b': 2}
dict2 = {'c': 3, 'd': 4}
cm = ChainMap(dict1, dict2)
print(cm['a'])       # 1
```

### `heapq` モジュール（ヒープキュー）

```python
import heapq

# ヒープの作成と操作
heap = [3, 1, 4, 1, 5, 9, 2, 6]
heapq.heapify(heap)               # リストをヒープに変換

heapq.heappush(heap, 0)           # 要素を追加
smallest = heapq.heappop(heap)    # 最小要素を取得・削除

# n番目に小さい/大きい要素
smallest_3 = heapq.nsmallest(3, heap)
largest_3 = heapq.nlargest(3, heap)

# 要素の置換
heapq.heapreplace(heap, 7)        # ポップしてからプッシュ
heapq.heappushpop(heap, 8)        # プッシュしてからポップ
```

### `bisect` モジュール（二分探索）

```python
import bisect

# ソート済みリストへの挿入位置を探索
sorted_list = [1, 3, 5, 7, 9]
pos = bisect.bisect_left(sorted_list, 6)   # 挿入位置（左側）
pos = bisect.bisect_right(sorted_list, 6)  # 挿入位置（右側）

# ソート済みリストに要素を挿入
bisect.insort_left(sorted_list, 6)         # 左側に挿入
bisect.insort_right(sorted_list, 6)        # 右側に挿入
```

## システムと環境

### `sys` モジュール

```python
import sys

# Pythonの情報
sys.version        # Pythonのバージョン情報
sys.version_info   # バージョン情報のタプル
sys.platform       # プラットフォーム名

# コマンドライン引数
sys.argv          # コマンドライン引数のリスト

# モジュール検索パス
sys.path          # モジュール検索パスのリスト

# 標準入出力
sys.stdin         # 標準入力
sys.stdout        # 標準出力
sys.stderr        # 標準エラー出力

# プログラムの終了
sys.exit(0)       # プログラムを終了

# その他
sys.maxsize       # 最大整数値
sys.float_info    # 浮動小数点数の情報
sys.getsizeof(obj) # オブジェクトのメモリサイズ
```

### `platform` モジュール

```python
import platform

# システム情報
platform.system()     # OS名（'Windows', 'Linux', 'Darwin'など）
platform.platform()   # プラットフォーム文字列
platform.machine()    # マシンタイプ（'x86_64'など）
platform.processor()  # プロセッサ名
platform.node()       # ネットワーク名

# Pythonの情報
platform.python_version()        # Pythonバージョン
platform.python_implementation() # Python実装（'CPython'など）
```

## ネットワークとインターネット

### `urllib` モジュール

```python
from urllib import request, parse, error
from urllib.request import urlopen

# URLからデータを取得
response = urlopen('https://httpbin.org/json')
data = response.read().decode('utf-8')

# URLエンコード
params = {'key1': 'value1', 'key2': 'value2'}
encoded = parse.urlencode(params)

# URLの解析
parsed = parse.urlparse('https://example.com/path?query=value')
print(parsed.scheme)  # https
print(parsed.netloc)  # example.com
print(parsed.path)    # /path
print(parsed.query)   # query=value
```

### `json` モジュール

```python
import json

# PythonオブジェクトをJSONに変換
data = {'name': 'Alice', 'age': 30, 'city': 'Tokyo'}
json_string = json.dumps(data, indent=2, ensure_ascii=False)

# JSONをPythonオブジェクトに変換
json_data = '{"name": "Bob", "age": 25}'
python_obj = json.loads(json_data)

# ファイルとの読み書き
with open('data.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

with open('data.json', 'r') as f:
    loaded_data = json.load(f)
```

## データ永続化

### `pickle` モジュール

```python
import pickle

# オブジェクトのシリアライズ
data = {'list': [1, 2, 3], 'tuple': (4, 5, 6)}
with open('data.pickle', 'wb') as f:
    pickle.dump(data, f)

# オブジェクトのデシリアライズ
with open('data.pickle', 'rb') as f:
    loaded_data = pickle.load(f)

# バイト列への変換
serialized = pickle.dumps(data)
deserialized = pickle.loads(serialized)
```

### `csv` モジュール

```python
import csv

# CSVファイルの読み込み
with open('data.csv', 'r') as f:
    reader = csv.reader(f)
    for row in reader:
        print(row)

# 辞書としてCSVを読み込み
with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row['column_name'])

# CSVファイルの書き込み
with open('output.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['Name', 'Age', 'City'])
    writer.writerow(['Alice', 30, 'Tokyo'])

# 辞書としてCSVを書き込み
with open('output.csv', 'w', newline='') as f:
    fieldnames = ['Name', 'Age', 'City']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerow({'Name': 'Bob', 'Age': 25, 'City': 'Osaka'})
```

## 関数型プログラミング

### `functools` モジュール

```python
from functools import (
    reduce, partial, wraps, lru_cache,
    singledispatch, total_ordering
)

# reduce: リストの要素を累積的に処理
result = reduce(lambda x, y: x + y, [1, 2, 3, 4])  # 10

# partial: 部分適用
def multiply(x, y):
    return x * y

double = partial(multiply, 2)
print(double(5))  # 10

# wraps: デコレータ作成時のメタデータ保持
def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

# lru_cache: 最近使用したキャッシュ
@lru_cache(maxsize=128)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# singledispatch: 型に基づく関数の分岐
@singledispatch
def process(arg):
    print(f"Processing {arg}")

@process.register
def _(arg: int):
    print(f"Processing integer: {arg}")

@process.register
def _(arg: str):
    print(f"Processing string: {arg}")
```

### `itertools` モジュール

```python
import itertools

# 無限イテレータ
count_iter = itertools.count(10, 2)      # 10, 12, 14, 16, ...
cycle_iter = itertools.cycle('ABC')      # A, B, C, A, B, C, ...
repeat_iter = itertools.repeat('X', 3)   # X, X, X

# 有限イテレータ
chain_iter = itertools.chain([1, 2], [3, 4])  # 1, 2, 3, 4
compress_iter = itertools.compress('ABCD', [1, 0, 1, 0])  # A, C

# 組み合わせとループ
combinations = itertools.combinations('ABCD', 2)     # AB, AC, AD, BC, BD, CD
permutations = itertools.permutations('ABC', 2)      # AB, AC, BA, BC, CA, CB
product = itertools.product('AB', '12')              # A1, A2, B1, B2

# グループ化
data = [('a', 1), ('a', 2), ('b', 3), ('b', 4)]
grouped = itertools.groupby(data, key=lambda x: x[0])
for key, group in grouped:
    print(key, list(group))
```

## テストとデバッグ

### `unittest` モジュール

```python
import unittest

class TestMathOperations(unittest.TestCase):
    
    def setUp(self):
        """テスト前の準備"""
        self.a = 10
        self.b = 5
    
    def tearDown(self):
        """テスト後の片付け"""
        pass
    
    def test_addition(self):
        """加算のテスト"""
        result = self.a + self.b
        self.assertEqual(result, 15)
    
    def test_division(self):
        """除算のテスト"""
        result = self.a / self.b
        self.assertEqual(result, 2.0)
    
    def test_division_by_zero(self):
        """ゼロ除算のテスト"""
        with self.assertRaises(ZeroDivisionError):
            self.a / 0

if __name__ == '__main__':
    unittest.main()
```

### `doctest` モジュール

```python
def add(a, b):
    """
    二つの数を加算する関数
    
    >>> add(2, 3)
    5
    >>> add(-1, 1)
    0
    >>> add(0, 0)
    0
    """
    return a + b

if __name__ == '__main__':
    import doctest
    doctest.testmod()
```

### `pdb` モジュール（デバッガ）

```python
import pdb

def problematic_function(x, y):
    result = x + y
    pdb.set_trace()  # ここでデバッガが起動
    return result * 2

# コマンドラインでの実行
# python -m pdb script.py
```

## プロファイリングとパフォーマンス

### `timeit` モジュール

```python
import timeit

# 単純なコードの計測
elapsed_time = timeit.timeit('sum([1, 2, 3, 4, 5])', number=100000)

# 複数行のコードの計測
code = """
data = list(range(100))
result = sum(data)
"""
elapsed_time = timeit.timeit(code, number=10000)

# 関数の計測
def test_function():
    return sum(range(100))

elapsed_time = timeit.timeit(test_function, number=10000)

# コマンドラインでの使用
# python -m timeit "sum([1, 2, 3, 4, 5])"
```

### `cProfile` モジュール

```python
import cProfile

def expensive_function():
    total = 0
    for i in range(1000000):
        total += i * i
    return total

# プロファイリング実行
cProfile.run('expensive_function()')

# ファイルに出力
cProfile.run('expensive_function()', 'profile_results.prof')
```

## 並行処理とマルチプロセッシング

### `threading` モジュール

```python
import threading
import time

def worker(name, duration):
    print(f"Worker {name} starting")
    time.sleep(duration)
    print(f"Worker {name} finished")

# スレッドの作成と実行
thread1 = threading.Thread(target=worker, args=("A", 2))
thread2 = threading.Thread(target=worker, args=("B", 3))

thread1.start()
thread2.start()

thread1.join()  # スレッドの終了を待機
thread2.join()

# ロック
lock = threading.Lock()

def safe_function():
    with lock:
        # クリティカルセクション
        pass
```

### `multiprocessing` モジュール

```python
import multiprocessing
import time

def worker_process(name, duration):
    print(f"Process {name} starting")
    time.sleep(duration)
    print(f"Process {name} finished")
    return f"Result from {name}"

if __name__ == '__main__':
    # プロセスの作成と実行
    process1 = multiprocessing.Process(target=worker_process, args=("A", 2))
    process2 = multiprocessing.Process(target=worker_process, args=("B", 3))
    
    process1.start()
    process2.start()
    
    process1.join()
    process2.join()
    
    # プロセスプールの使用
    with multiprocessing.Pool(processes=4) as pool:
        results = pool.map(lambda x: x**2, range(10))
        print(results)
```

## ロギング

### `logging` モジュール

```python
import logging

# 基本的な設定
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)

# ロガーの作成
logger = logging.getLogger(__name__)

# ログレベル
logger.debug('デバッグ情報')
logger.info('情報メッセージ')
logger.warning('警告メッセージ')
logger.error('エラーメッセージ')
logger.critical('致命的エラー')

# 例外情報の記録
try:
    1 / 0
except ZeroDivisionError:
    logger.exception('ゼロ除算エラーが発生しました')
```

この標準ライブラリ一覧は、Python開発で頻繁に使用される重要なモジュールを網羅しています。実際の開発では、これらのモジュールを組み合わせて効率的なプログラムを作成できます。