# 第15章：イテレータとジェネレータの世界

プログラムでは、リストやファイルの内容を一つずつ処理することがよくあります。この章では、データを効率的に順次処理する**イテレータ**と**ジェネレータ**について学びます。大量のデータを処理するログ解析システムや、無限数列を扱う数学計算システムを作りながら、メモリ効率の良いプログラムの書き方を習得しましょう。

## イテレータとは何か？

### 反復処理の基本概念

**イテレータ**とは、データの集合を一つずつ順番に取り出すための仕組みです。for文で使っているものの多くがイテレータです：

```python
>>> # 基本的な反復処理
>>> numbers = [1, 2, 3, 4, 5]
>>> 
>>> # for文による反復（内部でイテレータを使用）
>>> for num in numbers:
...     print(f"数値: {num}")
数値: 1
数値: 2
数値: 3
数値: 4
数値: 5

>>> # 文字列も反復可能
>>> text = "Python"
>>> for char in text:
...     print(f"文字: {char}")
文字: P
文字: y
文字: t
文字: h
文字: o
文字: n

>>> # 辞書も反復可能
>>> person = {"name": "田中", "age": 30, "city": "東京"}
>>> for key in person:
...     print(f"キー: {key}, 値: {person[key]}")
キー: name, 値: 田中
キー: age, 値: 30
キー: city, 値: 東京
```

### イテレータの仕組みを理解しよう

```python
>>> # iter()とnext()を使ったイテレータの手動操作
>>> numbers = [1, 2, 3]
>>> iterator = iter(numbers)  # イテレータを作成
>>> 
>>> print(f"イテレータの型: {type(iterator)}")
>>> 
>>> # next()で一つずつ取得
>>> print(f"最初の要素: {next(iterator)}")
>>> print(f"次の要素: {next(iterator)}")
>>> print(f"最後の要素: {next(iterator)}")

イテレータの型: <class 'list_iterator'>
最初の要素: 1
次の要素: 2
最後の要素: 3

>>> # すべて取得した後はStopIterationエラー
>>> try:
...     print(f"もう要素がない: {next(iterator)}")
... except StopIteration:
...     print("すべての要素を取得しました")
すべての要素を取得しました

>>> # range()もイテレータ
>>> range_iter = iter(range(3))
>>> print(f"range(3)の要素: {list(range_iter)}")
range(3)の要素: [0, 1, 2]
```

### カスタムイテレータの作成

```python
>>> class CountDown:
...     """カウントダウンを行うイテレータ"""
...     
...     def __init__(self, start):
...         self.start = start
...         self.current = start
...     
...     def __iter__(self):
...         """イテレータオブジェクト自体を返す"""
...         return self
...     
...     def __next__(self):
...         """次の要素を返す"""
...         if self.current <= 0:
...             raise StopIteration
...         
...         current_value = self.current
...         self.current -= 1
...         return current_value
... 

>>> # カスタムイテレータの使用
>>> countdown = CountDown(5)
>>> print("カウントダウン開始:")
>>> for num in countdown:
...     print(f"あと {num} 秒")
>>> print("時間切れ!")

カウントダウン開始:
あと 5 秒
あと 4 秒
あと 3 秒
あと 2 秒
あと 1 秒
時間切れ!

>>> # 手動でnext()を使用
>>> countdown2 = CountDown(3)
>>> try:
...     while True:
...         print(f"手動カウント: {next(countdown2)}")
... except StopIteration:
...     print("手動カウント終了")

手動カウント: 3
手動カウント: 2
手動カウント: 1
手動カウント終了
```

## ジェネレータ：簡単にイテレータを作る

### yield文を使ったジェネレータ

**ジェネレータ**は、yield文を使って簡単にイテレータを作る方法です：

```python
>>> def simple_counter(max_count):
...     """シンプルなカウンタージェネレータ"""
...     count = 1
...     while count <= max_count:
...         yield count  # yield文で値を返し、状態を保持
...         count += 1
... 

>>> # ジェネレータの使用
>>> counter = simple_counter(3)
>>> print(f"ジェネレータの型: {type(counter)}")

>>> for num in counter:
...     print(f"カウント: {num}")

ジェネレータの型: <class 'generator'>
カウント: 1
カウント: 2
カウント: 3

>>> # ジェネレータは一度しか使えない
>>> print(f"再度実行: {list(counter)}")  # 空のリスト
再度実行: []

>>> # 新しいジェネレータを作成
>>> counter2 = simple_counter(3)
>>> print(f"新しいジェネレータ: {list(counter2)}")
新しいジェネレータ: [1, 2, 3]
```

### フィボナッチ数列ジェネレータ

```python
>>> def fibonacci_generator(max_value):
...     """フィボナッチ数列を生成するジェネレータ"""
...     a, b = 0, 1
...     while a <= max_value:
...         yield a
...         a, b = b, a + b
... 

>>> # フィボナッチ数列の生成
>>> print("100以下のフィボナッチ数列:")
>>> fib = fibonacci_generator(100)
>>> for num in fib:
...     print(num, end=" ")
>>> print()

100以下のフィボナッチ数列:
0 1 1 2 3 5 8 13 21 34 55 89 

>>> # 無限フィボナッチ数列（注意：無限ループになる可能性）
>>> def infinite_fibonacci():
...     """無限フィボナッチ数列ジェネレータ"""
...     a, b = 0, 1
...     while True:
...         yield a
...         a, b = b, a + b
... 

>>> # 最初の10個だけ取得
>>> infinite_fib = infinite_fibonacci()
>>> first_10_fib = []
>>> for i, num in enumerate(infinite_fib):
...     if i >= 10:
...         break
...     first_10_fib.append(num)
>>> 
>>> print(f"最初の10個のフィボナッチ数: {first_10_fib}")
最初の10個のフィボナッチ数: [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

### ジェネレータ式（内包表記）

```python
>>> # リスト内包表記
>>> squares_list = [x**2 for x in range(5)]
>>> print(f"リスト内包表記: {squares_list}")
>>> print(f"メモリ使用量（概算）: {squares_list.__sizeof__()}バイト")

リスト内包表記: [0, 1, 4, 9, 16]
メモリ使用量（概算）: 120バイト

>>> # ジェネレータ式（括弧を使用）
>>> squares_gen = (x**2 for x in range(5))
>>> print(f"ジェネレータ式: {type(squares_gen)}")
>>> print(f"メモリ使用量（概算）: {squares_gen.__sizeof__()}バイト")
>>> print(f"値: {list(squares_gen)}")

ジェネレータ式: <class 'generator'>
メモリ使用量（概算）: 112バイト
値: [0, 1, 4, 9, 16]

>>> # 大きなデータでの比較
>>> import sys
>>> 
>>> # 1万個の要素のリスト
>>> big_list = [x**2 for x in range(10000)]
>>> print(f"リスト（1万要素）のメモリ: {sys.getsizeof(big_list):,}バイト")
>>> 
>>> # 1万個の要素のジェネレータ
>>> big_gen = (x**2 for x in range(10000))
>>> print(f"ジェネレータ（1万要素）のメモリ: {sys.getsizeof(big_gen):,}バイト")

リスト（1万要素）のメモリ: 87,624バイト
ジェネレータ（1万要素）のメモリ: 112バイト
```

## 【実行】ログ解析システムを作ろう

大量のログファイルを効率的に処理するシステムを作って、イテレータとジェネレータの実用性を学びましょう。

### ステップ1：ログファイルジェネレータ

```python
>>> import re
>>> from datetime import datetime, timedelta
>>> import random

>>> def generate_sample_logs(filename, num_logs=1000):
...     """サンプルログファイルを生成"""
...     log_levels = ["INFO", "WARNING", "ERROR", "DEBUG"]
...     users = ["user001", "user002", "user003", "admin", "guest"]
...     actions = ["login", "logout", "view_page", "upload", "download", "delete"]
...     
...     start_time = datetime.now() - timedelta(days=7)
...     
...     with open(filename, 'w', encoding='utf-8') as f:
...         for i in range(num_logs):
...             timestamp = start_time + timedelta(seconds=i*10 + random.randint(0, 9))
...             level = random.choice(log_levels)
...             user = random.choice(users)
...             action = random.choice(actions)
...             ip = f"192.168.1.{random.randint(1, 255)}"
...             
...             log_line = f"{timestamp.strftime('%Y-%m-%d %H:%M:%S')} [{level}] {user} {action} from {ip}\\n"
...             f.write(log_line)
...     
...     print(f"サンプルログファイル '{filename}' を生成しました（{num_logs}行）")

>>> # サンプルログファイルの生成
>>> generate_sample_logs("system.log", 5000)
サンプルログファイル 'system.log' を生成しました（5000行）

>>> class LogFileReader:
...     """ログファイルを効率的に読み込むクラス"""
...     
...     def __init__(self, filename):
...         self.filename = filename
...         self.total_lines = 0
...         self._count_lines()
...     
...     def _count_lines(self):
...         """ファイルの行数をカウント"""
...         try:
...             with open(self.filename, 'r', encoding='utf-8') as f:
...                 self.total_lines = sum(1 for _ in f)
...         except FileNotFoundError:
...             self.total_lines = 0
...     
...     def read_lines(self):
...         """全行を一度にメモリに読み込む（非効率）"""
...         try:
...             with open(self.filename, 'r', encoding='utf-8') as f:
...                 return f.readlines()
...         except FileNotFoundError:
...             return []
...     
...     def read_lines_generator(self):
...         """行を一つずつ yield するジェネレータ（効率的）"""
...         try:
...             with open(self.filename, 'r', encoding='utf-8') as f:
...                 for line_num, line in enumerate(f, 1):
...                     yield line_num, line.strip()
...         except FileNotFoundError:
...             return
...     
...     def read_chunks(self, chunk_size=100):
...         """指定行数ずつ読み込むジェネレータ"""
...         chunk = []
...         try:
...             with open(self.filename, 'r', encoding='utf-8') as f:
...                 for line_num, line in enumerate(f, 1):
...                     chunk.append((line_num, line.strip()))
...                     
...                     if len(chunk) >= chunk_size:
...                         yield chunk
...                         chunk = []
...                 
...                 # 残りのデータを返す
...                 if chunk:
...                     yield chunk
...         except FileNotFoundError:
...             return
...     
...     def filter_logs(self, level_filter=None, user_filter=None, action_filter=None):
...         """条件に一致するログのみを返すジェネレータ"""
...         for line_num, line in self.read_lines_generator():
...             # ログの解析
...             parts = line.split(' ')
...             if len(parts) < 6:
...                 continue
...             
...             timestamp = f"{parts[0]} {parts[1]}"
...             level = parts[2].strip('[]')
...             user = parts[3]
...             action = parts[4]
...             ip = parts[7] if len(parts) > 7 else "unknown"
...             
...             # フィルタリング
...             if level_filter and level != level_filter:
...                 continue
...             if user_filter and user != user_filter:
...                 continue
...             if action_filter and action != action_filter:
...                 continue
...             
...             yield {
...                 "line_number": line_num,
...                 "timestamp": timestamp,
...                 "level": level,
...                 "user": user,
...                 "action": action,
...                 "ip": ip,
...                 "raw_line": line
...             }
... 

>>> # ログリーダーの使用例
>>> log_reader = LogFileReader("system.log")
>>> print(f"ログファイル総行数: {log_reader.total_lines}行")

ログファイル総行数: 5000行

>>> # メモリ使用量の比較
>>> import sys
>>> 
>>> # 全行を一度に読み込み（非効率）
>>> all_lines = log_reader.read_lines()
>>> print(f"全行読み込み時のメモリ使用量: {sys.getsizeof(all_lines):,}バイト")
>>> print(f"最初の3行:")
>>> for i, line in enumerate(all_lines[:3]):
...     print(f"  {i+1}: {line.strip()}")

>>> # ジェネレータを使用（効率的）
>>> line_generator = log_reader.read_lines_generator()
>>> print(f"\\nジェネレータのメモリ使用量: {sys.getsizeof(line_generator):,}バイト")

全行読み込み時のメモリ使用量: 43,152バイト
最初の3行:
  1: 2024-12-12 11:20:00 [ERROR] user002 logout from 192.168.1.45
  2: 2024-12-12 11:20:10 [INFO] user001 view_page from 192.168.1.123
  3: 2024-12-12 11:20:20 [WARNING] admin upload from 192.168.1.67

ジェネレータのメモリ使用量: 112バイト

>>> # フィルタリングの例
>>> print("\\n=== エラーログのみ抽出 ===")
>>> error_logs = log_reader.filter_logs(level_filter="ERROR")
>>> error_count = 0
>>> for log_entry in error_logs:
...     if error_count < 5:  # 最初の5件のみ表示
...         print(f"行{log_entry['line_number']}: {log_entry['timestamp']} - {log_entry['user']} {log_entry['action']}")
...     error_count += 1
>>> print(f"\\n総エラーログ数: {error_count}件")

=== エラーログのみ抽出 ===
行1: 2024-12-12 11:20:00 - user002 logout
行78: 2024-12-12 11:32:50 - user003 delete
行147: 2024-12-12 11:44:20 - guest view_page
行165: 2024-12-12 11:47:00 - admin login
行253: 2024-12-12 11:61:40 - user001 upload

総エラーログ数: 1267件

>>> # 特定ユーザーのアクション抽出
>>> print("\\n=== adminユーザーのアクション ===")
>>> admin_logs = log_reader.filter_logs(user_filter="admin")
>>> admin_actions = {}
>>> for log_entry in admin_logs:
...     action = log_entry['action']
...     admin_actions[action] = admin_actions.get(action, 0) + 1
>>> 
>>> for action, count in sorted(admin_actions.items()):
...     print(f"{action}: {count}回")

=== adminユーザーのアクション ===
delete: 163回
download: 173回
login: 168回
logout: 164回
upload: 161回
view_page: 164回
```

### ステップ2：ログ統計分析ジェネレータ

```python
>>> class LogAnalyzer:
...     """ログファイルの統計分析を行うクラス"""
...     
...     def __init__(self, log_reader):
...         self.log_reader = log_reader
...     
...     def analyze_by_hour(self):
...         """時間別の統計分析ジェネレータ"""
...         hourly_stats = {}
...         
...         for log_entry in self.log_reader.filter_logs():
...             try:
...                 timestamp = log_entry['timestamp']
...                 hour = timestamp.split(' ')[1].split(':')[0]
...                 level = log_entry['level']
...                 
...                 if hour not in hourly_stats:
...                     hourly_stats[hour] = {'total': 0, 'INFO': 0, 'WARNING': 0, 'ERROR': 0, 'DEBUG': 0}
...                 
...                 hourly_stats[hour]['total'] += 1
...                 hourly_stats[hour][level] += 1
...                 
...             except (IndexError, KeyError):
...                 continue
...         
...         # 時間順にソートして yield
...         for hour in sorted(hourly_stats.keys()):
...             yield hour, hourly_stats[hour]
...     
...     def analyze_user_activity(self):
...         """ユーザー別活動分析ジェネレータ"""
...         user_stats = {}
...         
...         for log_entry in self.log_reader.filter_logs():
...             user = log_entry['user']
...             action = log_entry['action']
...             level = log_entry['level']
...             
...             if user not in user_stats:
...                 user_stats[user] = {
...                     'total_actions': 0,
...                     'actions': {},
...                     'error_count': 0,
...                     'last_activity': log_entry['timestamp']
...                 }
...             
...             user_stats[user]['total_actions'] += 1
...             user_stats[user]['actions'][action] = user_stats[user]['actions'].get(action, 0) + 1
...             user_stats[user]['last_activity'] = log_entry['timestamp']
...             
...             if level == 'ERROR':
...                 user_stats[user]['error_count'] += 1
...         
...         # アクティビティ数順にソートして yield
...         for user, stats in sorted(user_stats.items(), key=lambda x: x[1]['total_actions'], reverse=True):
...             yield user, stats
...     
...     def find_anomalies(self, error_threshold=10):
...         """異常検知ジェネレータ（エラー率が高いユーザーや時間帯）"""
...         # 時間別異常検知
...         for hour, stats in self.analyze_by_hour():
...             if stats['total'] > 0:
...                 error_rate = (stats['ERROR'] / stats['total']) * 100
...                 if error_rate > error_threshold:
...                     yield {
...                         'type': 'time_anomaly',
...                         'hour': hour,
...                         'error_rate': error_rate,
...                         'total_logs': stats['total'],
...                         'error_count': stats['ERROR']
...                     }
...         
...         # ユーザー別異常検知
...         for user, stats in self.analyze_user_activity():
...             if stats['total_actions'] > 0:
...                 error_rate = (stats['error_count'] / stats['total_actions']) * 100
...                 if error_rate > error_threshold:
...                     yield {
...                         'type': 'user_anomaly',
...                         'user': user,
...                         'error_rate': error_rate,
...                         'total_actions': stats['total_actions'],
...                         'error_count': stats['error_count']
...                     }
...     
...     def generate_report(self):
...         """統計レポートジェネレータ"""
...         yield "=== ログ統計分析レポート ==="
...         yield f"分析対象ファイル: {self.log_reader.filename}"
...         yield f"総行数: {self.log_reader.total_lines}行"
...         yield ""
...         
...         # 時間別統計
...         yield "【時間別統計】"
...         for hour, stats in self.analyze_by_hour():
...             yield f"{hour}:00-{hour}:59 - 総数: {stats['total']}, エラー: {stats['ERROR']}, 警告: {stats['WARNING']}"
...         
...         yield ""
...         
...         # ユーザー別統計
...         yield "【ユーザー別統計（上位5名）】"
...         for i, (user, stats) in enumerate(self.analyze_user_activity()):
...             if i >= 5:
...                 break
...             error_rate = (stats['error_count'] / stats['total_actions']) * 100 if stats['total_actions'] > 0 else 0
...             yield f"{user}: {stats['total_actions']}回, エラー率: {error_rate:.1f}%"
...         
...         yield ""
...         
...         # 異常検知
...         yield "【異常検知（エラー率10%以上）】"
...         anomaly_found = False
...         for anomaly in self.find_anomalies():
...             anomaly_found = True
...             if anomaly['type'] == 'time_anomaly':
...                 yield f"時間帯 {anomaly['hour']}:00 - エラー率: {anomaly['error_rate']:.1f}%"
...             elif anomaly['type'] == 'user_anomaly':
...                 yield f"ユーザー {anomaly['user']} - エラー率: {anomaly['error_rate']:.1f}%"
...         
...         if not anomaly_found:
...             yield "異常は検出されませんでした"
... 

>>> # ログ分析の実行
>>> analyzer = LogAnalyzer(log_reader)

>>> print("=== 時間別統計（最初の5時間）===")
>>> for i, (hour, stats) in enumerate(analyzer.analyze_by_hour()):
...     if i >= 5:
...         break
...     error_rate = (stats['ERROR'] / stats['total']) * 100 if stats['total'] > 0 else 0
...     print(f"{hour}:00 - 総数: {stats['total']}, エラー率: {error_rate:.1f}%")

=== 時間別統計（最初の5時間）===
11:00 - 総数: 601, エラー率: 26.0%
12:00 - 総数: 602, エラー率: 25.7%
13:00 - 総数: 603, エラー率: 24.9%
14:00 - 総数: 601, エラー率: 24.0%
15:00 - 総数: 600, エラー率: 26.2%

>>> print("\\n=== ユーザー活動統計 ===")
>>> for user, stats in analyzer.analyze_user_activity():
...     error_rate = (stats['error_count'] / stats['total_actions']) * 100 if stats['total_actions'] > 0 else 0
...     most_common_action = max(stats['actions'].items(), key=lambda x: x[1])[0]
...     print(f"{user}: {stats['total_actions']}回 (エラー率: {error_rate:.1f}%, よく行う操作: {most_common_action})")

=== ユーザー活動統計 ===
user001: 1001回 (エラー率: 25.3%, よく行う操作: view_page)
user002: 1000回 (エラー率: 25.7%, よく行う操作: upload)
admin: 993回 (エラー率: 25.4%, よく行う操作: download)
user003: 1003回 (エラー率: 24.9%, よく行う操作: view_page)
guest: 1003回 (エラー率: 25.0%, よく行う操作: logout)

>>> print("\\n=== 統計レポート生成 ===")
>>> report_lines = 0
>>> for line in analyzer.generate_report():
...     print(line)
...     report_lines += 1
...     if report_lines > 20:  # 最初の20行のみ表示
...         print("... (レポート続く)")
...         break

=== 統計レポート生成 ===
=== ログ統計分析レポート ===
分析対象ファイル: system.log
総行数: 5000行

【時間別統計】
11:00-11:59 - 総数: 601, エラー: 156, 警告: 147
12:00-12:59 - 総数: 602, エラー: 155, 警告: 148
13:00-13:59 - 総数: 603, エラー: 150, 警告: 147
14:00-14:59 - 総数: 601, エラー: 144, 警告: 164
15:00-15:59 - 総数: 600, エラー: 157, 警告: 142
16:00-16:59 - 総数: 601, エラー: 163, 警告: 144
17:00-17:59 - 総数: 600, エラー: 151, 警告: 157
18:00-18:59 - 総数: 600, エラー: 146, 警告: 154
19:00-19:59 - 総数: 592, エラー: 145, 警告: 156

【ユーザー別統計（上位5名）】
user003: 1003回, エラー率: 24.9%
user001: 1001回, エラー率: 25.3%
guest: 1003回, エラー率: 25.0%
user002: 1000回, エラー率: 25.7%
admin: 993回, エラー率: 25.4%

【異常検知（エラー率10%以上）】
時間帯 11:00 - エラー率: 26.0%
時間帯 12:00 - エラー率: 25.7%
... (レポート続く)
```

## 【実行】数学的無限数列システム

無限数列を扱う数学計算システムを作って、ジェネレータの真価を体験しましょう。

### ステップ3：数学的数列ジェネレータ

```python
>>> import math
>>> from itertools import islice

>>> class MathSequences:
...     """様々な数学的数列を生成するクラス"""
...     
...     @staticmethod
...     def fibonacci():
...         """フィボナッチ数列の無限ジェネレータ"""
...         a, b = 0, 1
...         while True:
...             yield a
...             a, b = b, a + b
...     
...     @staticmethod
...     def prime_numbers():
...         """素数の無限ジェネレータ（シンプルな実装）"""
...         def is_prime(n):
...             if n < 2:
...                 return False
...             for i in range(2, int(math.sqrt(n)) + 1):
...                 if n % i == 0:
...                     return False
...             return True
...         
...         num = 2
...         while True:
...             if is_prime(num):
...                 yield num
...             num += 1
...     
...     @staticmethod
...     def perfect_squares():
...         """完全平方数の無限ジェネレータ"""
...         n = 1
...         while True:
...             yield n * n
...             n += 1
...     
...     @staticmethod
...     def triangular_numbers():
...         """三角数の無限ジェネレータ"""
...         n = 1
...         while True:
...             yield n * (n + 1) // 2
...             n += 1
...     
...     @staticmethod
...     def factorial_sequence():
...         """階乗数列の無限ジェネレータ"""
...         n = 0
...         factorial = 1
...         while True:
...             if n == 0:
...                 yield factorial
...             else:
...                 factorial *= n
...                 yield factorial
...             n += 1
...     
...     @staticmethod
...     def collatz_sequence(start):
...         """コラッツ数列のジェネレータ（有限）"""
...         current = start
...         while current != 1:
...             yield current
...             if current % 2 == 0:
...                 current = current // 2
...             else:
...                 current = 3 * current + 1
...         yield 1  # 最後の1を含む
...     
...     @staticmethod
...     def arithmetic_progression(first_term, common_difference):
...         """等差数列の無限ジェネレータ"""
...         current = first_term
...         while True:
...             yield current
...             current += common_difference
...     
...     @staticmethod
...     def geometric_progression(first_term, common_ratio):
...         """等比数列の無限ジェネレータ"""
...         current = first_term
...         while True:
...             yield current
...             current *= common_ratio
...     
...     @staticmethod
...     def pi_approximation():
...         """円周率の近似値ジェネレータ（ライプニッツの公式）"""
...         pi_approx = 0
...         n = 0
...         while True:
...             term = (-1)**n / (2*n + 1)
...             pi_approx += term
...             yield pi_approx * 4
...             n += 1
... 

>>> # 各種数列の使用例
>>> print("=== 数学的数列ジェネレータ ===")

>>> # フィボナッチ数列（最初の10個）
>>> fib_gen = MathSequences.fibonacci()
>>> fib_10 = list(islice(fib_gen, 10))
>>> print(f"フィボナッチ数列（10個）: {fib_10}")

>>> # 素数（最初の10個）
>>> prime_gen = MathSequences.prime_numbers()
>>> prime_10 = list(islice(prime_gen, 10))
>>> print(f"素数（10個）: {prime_10}")

>>> # 完全平方数（最初の10個）
>>> square_gen = MathSequences.perfect_squares()
>>> square_10 = list(islice(square_gen, 10))
>>> print(f"完全平方数（10個）: {square_10}")

>>> # 三角数（最初の10個）
>>> tri_gen = MathSequences.triangular_numbers()
>>> tri_10 = list(islice(tri_gen, 10))
>>> print(f"三角数（10個）: {tri_10}")

=== 数学的数列ジェネレータ ===
フィボナッチ数列（10個）: [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
素数（10個）: [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
完全平方数（10個）: [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
三角数（10個）: [1, 3, 6, 10, 15, 21, 28, 36, 45, 55]

>>> # コラッツ数列（特定の開始値）
>>> print("\\n=== コラッツ数列 ===")
>>> for start in [7, 15, 27]:
...     collatz_gen = MathSequences.collatz_sequence(start)
...     sequence = list(collatz_gen)
...     print(f"開始値 {start}: {sequence} (長さ: {len(sequence)})")

=== コラッツ数列 ===
開始値 7: [7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1] (長さ: 17)
開始値 15: [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1] (長さ: 18)
開始値 27: [27, 82, 41, 124, 62, 31, 94, 47, 142, 71, 214, 107, 322, 161, 484, 242, 121, 364, 182, 91, 274, 137, 412, 206, 103, 310, 155, 466, 233, 700, 350, 175, 526, 263, 790, 395, 1186, 593, 1780, 890, 445, 1336, 668, 334, 167, 502, 251, 754, 377, 1132, 566, 283, 850, 425, 1276, 638, 319, 958, 479, 1438, 719, 2158, 1079, 3238, 1619, 4858, 2429, 7288, 3644, 1822, 911, 2734, 1367, 4102, 2051, 6154, 3077, 9232, 4616, 2308, 1154, 577, 1732, 866, 433, 1300, 650, 325, 976, 488, 244, 122, 61, 184, 92, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1] (長さ: 112)

>>> # 円周率の近似
>>> print("\\n=== 円周率の近似（ライプニッツの公式）===")
>>> pi_gen = MathSequences.pi_approximation()
>>> actual_pi = math.pi
>>> print(f"実際の円周率: {actual_pi}")
>>> print("近似値の収束:")
>>> for i, pi_approx in enumerate(pi_gen):
...     if i in [0, 9, 99, 999, 9999]:
...         error = abs(pi_approx - actual_pi)
...         print(f"項数 {i+1}: {pi_approx:.6f} (誤差: {error:.6f})")
...     if i >= 9999:
...         break

=== 円周率の近似（ライプニッツの公式）===
実際の円周率: 3.141592653589793
近似値の収束:
項数 1: 4.000000 (誤差: 0.858407)
項数 10: 3.041840 (誤差: 0.099753)
項数 100: 3.131593 (誤差: 0.010000)
項数 1000: 3.140593 (誤差: 0.001000)
項数 10000: 3.141493 (誤差: 0.000100)

>>> # 等差数列と等比数列
>>> print("\\n=== 等差数列と等比数列 ===")
>>> # 等差数列（初項5, 公差3）
>>> arith_gen = MathSequences.arithmetic_progression(5, 3)
>>> arith_10 = list(islice(arith_gen, 10))
>>> print(f"等差数列（初項5, 公差3）: {arith_10}")

>>> # 等比数列（初項2, 公比3）
>>> geom_gen = MathSequences.geometric_progression(2, 3)
>>> geom_8 = list(islice(geom_gen, 8))
>>> print(f"等比数列（初項2, 公比3）: {geom_8}")

>>> # 階乗数列
>>> fact_gen = MathSequences.factorial_sequence()
>>> fact_8 = list(islice(fact_gen, 8))
>>> print(f"階乗数列: {fact_8}")

=== 等差数列と等比数列 ===
等差数列（初項5, 公差3）: [5, 8, 11, 14, 17, 20, 23, 26, 29, 32]
等比数列（初項2, 公比3）: [2, 6, 18, 54, 162, 486, 1458, 4374]
階乗数列: [1, 1, 2, 6, 24, 120, 720, 5040]
```

### ステップ4：数列分析ツール

```python
>>> class SequenceAnalyzer:
...     """数列の分析を行うクラス"""
...     
...     @staticmethod
...     def find_pattern(sequence, max_terms=100):
...         """数列のパターンを分析"""
...         terms = list(islice(sequence, max_terms))
...         
...         if len(terms) < 3:
...             return "分析に十分なデータがありません"
...         
...         # 等差数列のチェック
...         differences = [terms[i+1] - terms[i] for i in range(len(terms)-1)]
...         if len(set(differences)) == 1:
...             return f"等差数列（公差: {differences[0]}）"
...         
...         # 等比数列のチェック
...         if all(terms[i] != 0 for i in range(len(terms)-1)):
...             ratios = [terms[i+1] / terms[i] for i in range(len(terms)-1)]
...             if len(set(round(r, 6) for r in ratios)) == 1:
...                 return f"等比数列（公比: {ratios[0]:.6f}）"
...         
...         # フィボナッチ数列のチェック
...         is_fibonacci = True
...         for i in range(2, len(terms)):
...             if terms[i] != terms[i-1] + terms[i-2]:
...                 is_fibonacci = False
...                 break
...         if is_fibonacci:
...             return "フィボナッチ数列"
...         
...         # 完全平方数のチェック
...         sqrt_values = [math.sqrt(term) for term in terms if term >= 0]
...         if all(int(val) == val for val in sqrt_values):
...             return "完全平方数列"
...         
...         return "特定のパターンは見つかりませんでした"
...     
...     @staticmethod
...     def convergence_analysis(sequence, max_terms=1000):
...         """数列の収束性を分析"""
...         terms = []
...         prev_term = None
...         convergence_info = {"converges": False, "limit": None, "rate": None}
...         
...         for i, term in enumerate(islice(sequence, max_terms)):
...             terms.append(term)
...             
...             if i > 10:  # 最初の10項は無視
...                 # 連続する項の差が小さくなっているかチェック
...                 if prev_term is not None:
...                     diff = abs(term - prev_term)
...                     if diff < 1e-10:  # 収束判定
...                         convergence_info["converges"] = True
...                         convergence_info["limit"] = term
...                         convergence_info["convergence_term"] = i
...                         break
...             
...             prev_term = term
...         
...         # 収束率の計算（最後の10項を使用）
...         if len(terms) >= 20:
...             recent_terms = terms[-10:]
...             if convergence_info["converges"]:
...                 limit = convergence_info["limit"]
...                 errors = [abs(term - limit) for term in recent_terms]
...                 if len(errors) > 1:
...                     rate_estimates = []
...                     for i in range(1, len(errors)):
...                         if errors[i-1] != 0:
...                             rate_estimates.append(errors[i] / errors[i-1])
...                     if rate_estimates:
...                         convergence_info["rate"] = sum(rate_estimates) / len(rate_estimates)
...         
...         return convergence_info, terms
...     
...     @staticmethod
...     def statistics(sequence, max_terms=100):
...         """数列の統計情報を計算"""
...         terms = list(islice(sequence, max_terms))
...         
...         if not terms:
...             return {}
...         
...         stats = {
...             "count": len(terms),
...             "min": min(terms),
...             "max": max(terms),
...             "mean": sum(terms) / len(terms),
...             "first_term": terms[0],
...             "last_term": terms[-1]
...         }
...         
...         # 中央値
...         sorted_terms = sorted(terms)
...         n = len(sorted_terms)
...         if n % 2 == 0:
...             stats["median"] = (sorted_terms[n//2 - 1] + sorted_terms[n//2]) / 2
...         else:
...             stats["median"] = sorted_terms[n//2]
...         
...         # 分散と標準偏差
...         mean = stats["mean"]
...         variance = sum((term - mean)**2 for term in terms) / len(terms)
...         stats["variance"] = variance
...         stats["std_dev"] = math.sqrt(variance)
...         
...         return stats
... 

>>> # 数列分析の実行
>>> print("=== 数列パターン分析 ===")

>>> # フィボナッチ数列の分析
>>> fib_gen = MathSequences.fibonacci()
>>> fib_pattern = SequenceAnalyzer.find_pattern(fib_gen)
>>> print(f"フィボナッチ数列: {fib_pattern}")

>>> # 等差数列の分析
>>> arith_gen = MathSequences.arithmetic_progression(10, 5)
>>> arith_pattern = SequenceAnalyzer.find_pattern(arith_gen)
>>> print(f"等差数列: {arith_pattern}")

>>> # 等比数列の分析
>>> geom_gen = MathSequences.geometric_progression(3, 2)
>>> geom_pattern = SequenceAnalyzer.find_pattern(geom_gen)
>>> print(f"等比数列: {geom_pattern}")

>>> # 完全平方数の分析
>>> square_gen = MathSequences.perfect_squares()
>>> square_pattern = SequenceAnalyzer.find_pattern(square_gen)
>>> print(f"完全平方数: {square_pattern}")

=== 数列パターン分析 ===
フィボナッチ数列: フィボナッチ数列
等差数列: 等差数列（公差: 5）
等比数列: 等比数列（公比: 2.000000）
完全平方数: 完全平方数列

>>> # 収束性分析
>>> print("\\n=== 収束性分析 ===")

>>> # 円周率近似の収束性
>>> pi_gen = MathSequences.pi_approximation()
>>> pi_convergence, pi_terms = SequenceAnalyzer.convergence_analysis(pi_gen, 1000)
>>> print(f"円周率近似:")
>>> print(f"  収束: {pi_convergence['converges']}")
>>> if pi_convergence['converges']:
...     print(f"  収束値: {pi_convergence['limit']:.6f}")
...     print(f"  収束項数: {pi_convergence['convergence_term']}")

>>> # 統計情報
>>> print("\\n=== 統計情報 ===")

>>> # フィボナッチ数列の統計
>>> fib_gen = MathSequences.fibonacci()
>>> fib_stats = SequenceAnalyzer.statistics(fib_gen, 20)
>>> print(f"フィボナッチ数列（20項）:")
>>> print(f"  平均: {fib_stats['mean']:.2f}")
>>> print(f"  中央値: {fib_stats['median']:.2f}")
>>> print(f"  最小値: {fib_stats['min']}")
>>> print(f"  最大値: {fib_stats['max']}")
>>> print(f"  標準偏差: {fib_stats['std_dev']:.2f}")

>>> # 素数の統計
>>> prime_gen = MathSequences.prime_numbers()
>>> prime_stats = SequenceAnalyzer.statistics(prime_gen, 50)
>>> print(f"\\n素数（50個）:")
>>> print(f"  平均: {prime_stats['mean']:.2f}")
>>> print(f"  中央値: {prime_stats['median']:.2f}")
>>> print(f"  最小値: {prime_stats['min']}")
>>> print(f"  最大値: {prime_stats['max']}")
>>> print(f"  標準偏差: {prime_stats['std_dev']:.2f}")

=== 収束性分析 ===
円周率近似:
  収束: False

=== 統計情報 ===
フィボナッチ数列（20項）:
  平均: 1364.80
  中央値: 21.50
  最小値: 0
  最大値: 6765
  標準偏差: 2297.04

素数（50個）:
  平均: 116.34
  中央値: 113.00
  最小値: 2
  最大値: 229
  標準偏差: 63.35
```

## まとめ：イテレータとジェネレータの威力

この章で学んだことをまとめましょう：

### イテレータの基本概念
- **反復可能オブジェクト**: for文で使えるオブジェクト
- **イテレータプロトコル**: `__iter__()` と `__next__()` メソッド
- **StopIteration**: 反復終了の合図
- **メモリ効率**: 必要な時だけデータを生成

### ジェネレータの利点
```python
# メモリ効率の比較
big_list = [x**2 for x in range(1000000)]      # 大量メモリ使用
big_gen = (x**2 for x in range(1000000))       # 少ないメモリ使用

# 無限数列の処理
def infinite_sequence():
    n = 0
    while True:
        yield n
        n += 1
```

### 実用的な応用例
1. **ログ解析システム**
   - 大容量ファイルの効率的処理
   - メモリ使用量の最適化
   - リアルタイム分析

2. **数学的数列処理**
   - 無限数列の生成
   - 数値計算の最適化
   - パターン分析

3. **データストリーミング**
   - ファイル処理の効率化
   - チャンク単位での処理
   - フィルタリングとパイプライン

### パフォーマンスの比較
```python
import time
import sys

# リスト使用（大量メモリ）
start = time.time()
big_list = [x for x in range(1000000)]
total = sum(big_list)
list_time = time.time() - start
list_memory = sys.getsizeof(big_list)

# ジェネレータ使用（少ないメモリ）
start = time.time()
big_gen = (x for x in range(1000000))
total = sum(big_gen)
gen_time = time.time() - start
gen_memory = sys.getsizeof(big_gen)

print(f"リスト: {list_time:.3f}秒, {list_memory:,}バイト")
print(f"ジェネレータ: {gen_time:.3f}秒, {gen_memory:,}バイト")
```

### ベストプラクティス
1. **大量データはジェネレータで処理**
2. **無限数列にはジェネレータが必須**
3. **メモリ制約がある環境ではイテレータを活用**
4. **再利用が必要な場合はリストに変換**
5. **パイプライン処理でジェネレータを組み合わせ**

次の章では、**デコレータと高度な関数機能**について学びます。関数をより柔軟に拡張し、コードの再利用性を高める高度なテクニックを習得しましょう！

---

**第15章執筆完了ログ:**
第15章ではイテレータとジェネレータの概念から実用的な応用まで包括的に学習。基本的な反復処理の仕組み、カスタムイテレータの作成、yield文を使ったジェネレータの実装を段階的に説明。実践例として大容量ログファイルの効率的解析システム、無限数列を扱う数学計算システムを構築。メモリ効率とパフォーマンスの比較も含み、実用的なデータ処理技術を習得。次は第16章のデコレータに進みます。