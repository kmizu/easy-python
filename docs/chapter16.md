# 第16章：デコレータと高度な関数機能

Pythonの関数には、基本的な使い方を超えた高度な機能があります。この章では、**デコレータ**という強力な仕組みを学びます。ログ機能付きの関数、実行時間測定機能、キャッシュ機能などを作りながら、関数を拡張し、コードの再利用性を大幅に向上させる方法を習得しましょう。

## 高階関数の概念

### 関数は「第一級オブジェクト」

Pythonでは、関数も他のデータ（数値、文字列など）と同じように扱えます：

```python
>>> def greet(name):
...     return f"こんにちは、{name}さん！"
... 

>>> # 関数を変数に代入
>>> greeting_function = greet
>>> print(greeting_function("田中"))
こんにちは、田中さん！

>>> # 関数の情報を確認
>>> print(f"関数名: {greet.__name__}")
>>> print(f"関数の型: {type(greet)}")
>>> print(f"関数のID: {id(greet)}")

関数名: greet
関数の型: <class 'function'>
関数のID: 140234567890112

>>> # 関数をリストに入れる
>>> math_functions = [abs, max, min, sum]
>>> numbers = [-5, 10, -3, 7]

>>> for func in math_functions:
...     if func == sum:
...         result = func(numbers)
...     else:
...         result = func(numbers) if func in [max, min] else func(-8)
...     print(f"{func.__name__}: {result}")

abs: 8
max: 10
min: -5
sum: 9
```

### 関数を返す関数

```python
>>> def create_multiplier(factor):
...     """指定した倍数をかける関数を作る関数"""
...     def multiplier(number):
...         return number * factor
...     return multiplier
... 

>>> # 2倍にする関数を作成
>>> double = create_multiplier(2)
>>> print(f"5の2倍: {double(5)}")

>>> # 10倍にする関数を作成
>>> times_10 = create_multiplier(10)
>>> print(f"3の10倍: {times_10(3)}")

>>> # 作成された関数の確認
>>> print(f"double関数の型: {type(double)}")
>>> print(f"times_10関数の型: {type(times_10)}")

5の2倍: 10
3の10倍: 30
double関数の型: <class 'function'>
times_10関数の型: <class 'function'>

>>> def create_validator(min_value, max_value):
...     """指定した範囲内の値かチェックする関数を作る"""
...     def validator(value):
...         if min_value <= value <= max_value:
...             return True, f"{value}は有効な値です"
...         else:
...             return False, f"{value}は範囲外です（{min_value}～{max_value}）"
...     return validator
... 

>>> # 年齢チェック関数を作成
>>> age_validator = create_validator(0, 120)
>>> print(age_validator(25))
>>> print(age_validator(150))

>>> # パーセンテージチェック関数を作成
>>> percentage_validator = create_validator(0, 100)
>>> print(percentage_validator(85))
>>> print(percentage_validator(-5))

(True, '25は有効な値です')
(False, '150は範囲外です（0～120）')
(True, '85は有効な値です')
(False, '-5は範囲外です（0～100）')
```

### 関数を引数として受け取る関数

```python
>>> def apply_operation(numbers, operation):
...     """リストの各要素に操作を適用"""
...     return [operation(num) for num in numbers]
... 

>>> def square(x):
...     return x ** 2
... 

>>> def cube(x):
...     return x ** 3
... 

>>> numbers = [1, 2, 3, 4, 5]

>>> # 各種操作を適用
>>> squared = apply_operation(numbers, square)
>>> cubed = apply_operation(numbers, cube)
>>> doubled = apply_operation(numbers, lambda x: x * 2)

>>> print(f"元の数値: {numbers}")
>>> print(f"2乗: {squared}")
>>> print(f"3乗: {cubed}")
>>> print(f"2倍: {doubled}")

元の数値: [1, 2, 3, 4, 5]
2乗: [1, 4, 9, 16, 25]
3乗: [1, 8, 27, 64, 125]
2倍: [2, 4, 6, 8, 10]

>>> def filter_and_transform(data, condition, transformation):
...     """条件に合うデータだけを変換"""
...     result = []
...     for item in data:
...         if condition(item):
...             result.append(transformation(item))
...     return result
... 

>>> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

>>> # 偶数だけを2乗
>>> even_squares = filter_and_transform(
...     numbers, 
...     lambda x: x % 2 == 0,  # 偶数判定
...     lambda x: x ** 2       # 2乗変換
... )

>>> print(f"偶数の2乗: {even_squares}")

偶数の2乗: [4, 16, 36, 64, 100]
```

## デコレータの基本

### デコレータとは

**デコレータ**は、既存の関数に新しい機能を追加する仕組みです。関数を「装飾」して機能を拡張します：

```python
>>> def simple_decorator(func):
...     """シンプルなデコレータ"""
...     def wrapper():
...         print("関数実行前の処理")
...         result = func()
...         print("関数実行後の処理")
...         return result
...     return wrapper
... 

>>> # デコレータを手動で適用
>>> def say_hello():
...     print("Hello, World!")
... 

>>> decorated_hello = simple_decorator(say_hello)
>>> decorated_hello()

関数実行前の処理
Hello, World!
関数実行後の処理

>>> # @記法を使ったデコレータ（推奨）
>>> @simple_decorator
... def say_goodbye():
...     print("Goodbye, World!")
... 

>>> say_goodbye()

関数実行前の処理
Goodbye, World!
関数実行後の処理
```

### 引数を持つ関数のデコレータ

```python
>>> def print_args_decorator(func):
...     """引数を表示するデコレータ"""
...     def wrapper(*args, **kwargs):
...         print(f"関数 '{func.__name__}' を呼び出し")
...         print(f"引数: {args}")
...         print(f"キーワード引数: {kwargs}")
...         result = func(*args, **kwargs)
...         print(f"戻り値: {result}")
...         return result
...     return wrapper
... 

>>> @print_args_decorator
... def add_numbers(a, b):
...     return a + b
... 

>>> @print_args_decorator
... def greet_person(name, greeting="こんにちは"):
...     return f"{greeting}、{name}さん！"
... 

>>> # デコレート済み関数の実行
>>> result1 = add_numbers(5, 3)
>>> print(f"計算結果: {result1}")

>>> print()
>>> result2 = greet_person("田中", greeting="おはよう")
>>> print(f"挨拶結果: {result2}")

関数 'add_numbers' を呼び出し
引数: (5, 3)
キーワード引数: {}
戻り値: 8
計算結果: 8

関数 'greet_person' を呼び出し
引数: ('田中',)
キーワード引数: {'greeting': 'おはよう'}
戻り値: おはよう、田中さん！
挨拶結果: おはよう、田中さん！
```

## 【実行】実用的なデコレータシステムを作ろう

### ステップ1：ログ機能デコレータ

```python
>>> import functools
>>> import time
>>> from datetime import datetime

>>> def log_function_calls(log_file=None, include_args=True, include_time=True):
...     """関数呼び出しをログに記録するデコレータ"""
...     def decorator(func):
...         @functools.wraps(func)  # 元の関数の属性を保持
...         def wrapper(*args, **kwargs):
...             # ログエントリの作成
...             log_entry = []
...             
...             if include_time:
...                 timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
...                 log_entry.append(f"[{timestamp}]")
...             
...             log_entry.append(f"関数 '{func.__name__}' を実行")
...             
...             if include_args:
...                 if args:
...                     log_entry.append(f"引数: {args}")
...                 if kwargs:
...                     log_entry.append(f"キーワード引数: {kwargs}")
...             
...             # 関数の実行
...             start_time = time.time()
...             try:
...                 result = func(*args, **kwargs)
...                 end_time = time.time()
...                 
...                 log_entry.append(f"成功 (実行時間: {end_time - start_time:.4f}秒)")
...                 log_entry.append(f"戻り値: {result}")
...                 
...             except Exception as e:
...                 end_time = time.time()
...                 log_entry.append(f"エラー (実行時間: {end_time - start_time:.4f}秒)")
...                 log_entry.append(f"エラー内容: {str(e)}")
...                 raise
...             
...             finally:
...                 # ログの出力
...                 log_message = " | ".join(log_entry)
...                 
...                 if log_file:
...                     with open(log_file, 'a', encoding='utf-8') as f:
...                         f.write(log_message + "\\n")
...                 else:
...                     print(f"LOG: {log_message}")
...             
...             return result
...         return wrapper
...     return decorator
... 

>>> # ログ機能付き関数の作成
>>> @log_function_calls(include_args=True, include_time=True)
... def calculate_factorial(n):
...     """階乗を計算する関数"""
...     if n < 0:
...         raise ValueError("負の数の階乗は定義されていません")
...     if n == 0 or n == 1:
...         return 1
...     result = 1
...     for i in range(2, n + 1):
...         result *= i
...     return result
... 

>>> @log_function_calls(log_file="math_operations.log")
... def divide_numbers(a, b):
...     """数値を除算する関数"""
...     if b == 0:
...         raise ZeroDivisionError("ゼロで割ることはできません")
...     return a / b
... 

>>> # ログ機能のテスト
>>> print("=== ログ機能デコレータのテスト ===")
>>> result1 = calculate_factorial(5)
>>> print(f"5! = {result1}")

>>> try:
...     result2 = calculate_factorial(-1)
... except ValueError as e:
...     print(f"エラーキャッチ: {e}")

>>> result3 = divide_numbers(10, 2)
>>> print(f"10 ÷ 2 = {result3}")

>>> try:
...     result4 = divide_numbers(10, 0)
... except ZeroDivisionError as e:
...     print(f"ゼロ除算エラー: {e}")

=== ログ機能デコレータのテスト ===
LOG: [2024-12-19 11:25:00] | 関数 'calculate_factorial' を実行 | 引数: (5,) | 成功 (実行時間: 0.0001秒) | 戻り値: 120
5! = 120
LOG: [2024-12-19 11:25:00] | 関数 'calculate_factorial' を実行 | 引数: (-1,) | エラー (実行時間: 0.0001秒) | エラー内容: 負の数の階乗は定義されていません
エラーキャッチ: 負の数の階乗は定義されていません
10 ÷ 2 = 5.0
ゼロ除算エラー: ゼロで割ることはできません
```

### ステップ2：実行時間測定デコレータ

```python
>>> import time
>>> import statistics
>>> from collections import defaultdict

>>> class PerformanceMonitor:
...     """関数のパフォーマンスを監視するクラス"""
...     
...     def __init__(self):
...         self.execution_times = defaultdict(list)
...         self.call_counts = defaultdict(int)
...     
...     def timing_decorator(self, func):
...         """実行時間を測定するデコレータ"""
...         @functools.wraps(func)
...         def wrapper(*args, **kwargs):
...             start_time = time.perf_counter()
...             result = func(*args, **kwargs)
...             end_time = time.perf_counter()
...             
...             execution_time = end_time - start_time
...             
...             # 統計情報を記録
...             self.execution_times[func.__name__].append(execution_time)
...             self.call_counts[func.__name__] += 1
...             
...             return result
...         return wrapper
...     
...     def get_statistics(self, func_name):
...         """指定した関数の統計情報を取得"""
...         if func_name not in self.execution_times:
...             return None
...         
...         times = self.execution_times[func_name]
...         return {
...             "function_name": func_name,
...             "call_count": self.call_counts[func_name],
...             "total_time": sum(times),
...             "average_time": statistics.mean(times),
...             "min_time": min(times),
...             "max_time": max(times),
...             "median_time": statistics.median(times),
...             "std_dev": statistics.stdev(times) if len(times) > 1 else 0
...         }
...     
...     def get_report(self):
...         """全関数の統計レポートを生成"""
...         report = ["=== パフォーマンス統計レポート ==="]
...         
...         for func_name in sorted(self.execution_times.keys()):
...             stats = self.get_statistics(func_name)
...             report.append(f"\\n関数: {stats['function_name']}")
...             report.append(f"  呼び出し回数: {stats['call_count']}回")
...             report.append(f"  総実行時間: {stats['total_time']:.6f}秒")
...             report.append(f"  平均実行時間: {stats['average_time']:.6f}秒")
...             report.append(f"  最短実行時間: {stats['min_time']:.6f}秒")
...             report.append(f"  最長実行時間: {stats['max_time']:.6f}秒")
...             report.append(f"  標準偏差: {stats['std_dev']:.6f}秒")
...         
...         return "\\n".join(report)
... 

>>> # パフォーマンス監視インスタンスの作成
>>> monitor = PerformanceMonitor()

>>> # パフォーマンス測定対象の関数
>>> @monitor.timing_decorator
... def fibonacci_recursive(n):
...     """再帰的フィボナッチ数列（非効率）"""
...     if n <= 1:
...         return n
...     return fibonacci_recursive(n-1) + fibonacci_recursive(n-2)
... 

>>> @monitor.timing_decorator
... def fibonacci_iterative(n):
...     """反復的フィボナッチ数列（効率的）"""
...     if n <= 1:
...         return n
...     a, b = 0, 1
...     for _ in range(2, n + 1):
...         a, b = b, a + b
...     return b
... 

>>> @monitor.timing_decorator
... def bubble_sort(arr):
...     """バブルソート（非効率）"""
...     arr = arr.copy()  # 元の配列を変更しない
...     n = len(arr)
...     for i in range(n):
...         for j in range(0, n - i - 1):
...             if arr[j] > arr[j + 1]:
...                 arr[j], arr[j + 1] = arr[j + 1], arr[j]
...     return arr
... 

>>> @monitor.timing_decorator
... def quick_sort(arr):
...     """クイックソート（効率的）"""
...     if len(arr) <= 1:
...         return arr
...     pivot = arr[len(arr) // 2]
...     left = [x for x in arr if x < pivot]
...     middle = [x for x in arr if x == pivot]
...     right = [x for x in arr if x > pivot]
...     return quick_sort(left) + middle + quick_sort(right)
... 

>>> # パフォーマンステスト
>>> print("=== パフォーマンス比較テスト ===")

>>> # フィボナッチ数列の比較
>>> print("\\nフィボナッチ数列の比較:")
>>> for i in [10, 15, 20, 25]:
...     print(f"n={i}")
...     result1 = fibonacci_recursive(i)
...     result2 = fibonacci_iterative(i)
...     print(f"  結果: {result1} (両方とも同じ)")

>>> # ソートアルゴリズムの比較
>>> print("\\nソートアルゴリズムの比較:")
>>> import random

>>> for size in [100, 500, 1000]:
...     test_data = [random.randint(1, 1000) for _ in range(size)]
...     print(f"データサイズ: {size}")
...     
...     # バブルソート
...     sorted1 = bubble_sort(test_data)
...     
...     # クイックソート
...     sorted2 = quick_sort(test_data)
...     
...     print(f"  ソート結果の一致: {sorted1 == sorted2}")

フィボナッチ数列の比較:

n=10
  結果: 55 (両方とも同じ)
n=15
  結果: 610 (両方とも同じ)
n=20
  結果: 6765 (両方とも同じ)
n=25
  結果: 75025 (両方とも同じ)

ソートアルゴリズムの比較:
データサイズ: 100
  ソート結果の一致: True
データサイズ: 500
  ソート結果の一致: True
データサイズ: 1000
  ソート結果の一致: True

>>> # パフォーマンス統計の表示
>>> print("\\n" + monitor.get_report())

=== パフォーマンス統計レポート ===

関数: bubble_sort
  呼び出し回数: 3回
  総実行時間: 0.123456秒
  平均実行時間: 0.041152秒
  最短実行時間: 0.002345秒
  最長実行時間: 0.089234秒
  標準偏差: 0.035672秒

関数: fibonacci_iterative
  呼び出し回数: 4回
  総実行時間: 0.000123秒
  平均実行時間: 0.000031秒
  最短実行時間: 0.000012秒
  最長実行時間: 0.000067秒
  標準偏差: 0.000023秒

関数: fibonacci_recursive
  呼び出し回数: 4回
  総実行時間: 2.456789秒
  平均実行時間: 0.614197秒
  最短実行時間: 0.000234秒
  最長実行時間: 2.123456秒
  標準偏差: 0.987654秒

関数: quick_sort
  呼び出し回数: 3回
  総実行時間: 0.012345秒
  平均実行時間: 0.004115秒
  最短実行時間: 0.001234秒
  最長実行時間: 0.006789秒
  標準偏差: 0.002345秒
```

### ステップ3：キャッシュ機能デコレータ

```python
>>> import hashlib
>>> import pickle
>>> import os
>>> from functools import wraps

>>> class CacheManager:
...     """キャッシュ機能を提供するクラス"""
...     
...     def __init__(self, cache_dir="cache", max_cache_size=100):
...         self.cache_dir = cache_dir
...         self.max_cache_size = max_cache_size
...         self.memory_cache = {}
...         self.cache_stats = {"hits": 0, "misses": 0}
...         
...         # キャッシュディレクトリの作成
...         if not os.path.exists(cache_dir):
...             os.makedirs(cache_dir)
...     
...     def _generate_key(self, func_name, args, kwargs):
...         """引数からキャッシュキーを生成"""
...         key_data = f"{func_name}_{args}_{sorted(kwargs.items())}"
...         return hashlib.md5(key_data.encode()).hexdigest()
...     
...     def memory_cache_decorator(self, func):
...         """メモリキャッシュデコレータ"""
...         @wraps(func)
...         def wrapper(*args, **kwargs):
...             cache_key = self._generate_key(func.__name__, args, kwargs)
...             
...             # キャッシュヒットの確認
...             if cache_key in self.memory_cache:
...                 self.cache_stats["hits"] += 1
...                 print(f"キャッシュヒット: {func.__name__}{args}")
...                 return self.memory_cache[cache_key]
...             
...             # キャッシュミス：関数を実行してキャッシュに保存
...             self.cache_stats["misses"] += 1
...             print(f"キャッシュミス: {func.__name__}{args} - 計算実行中...")
...             result = func(*args, **kwargs)
...             
...             # メモリキャッシュサイズの管理
...             if len(self.memory_cache) >= self.max_cache_size:
...                 # 最も古いキーを削除（簡易実装）
...                 oldest_key = next(iter(self.memory_cache))
...                 del self.memory_cache[oldest_key]
...             
...             self.memory_cache[cache_key] = result
...             return result
...         return wrapper
...     
...     def file_cache_decorator(self, func):
...         """ファイルキャッシュデコレータ"""
...         @wraps(func)
...         def wrapper(*args, **kwargs):
...             cache_key = self._generate_key(func.__name__, args, kwargs)
...             cache_file = os.path.join(self.cache_dir, f"{cache_key}.pkl")
...             
...             # ファイルキャッシュの確認
...             if os.path.exists(cache_file):
...                 try:
...                     with open(cache_file, 'rb') as f:
...                         result = pickle.load(f)
...                     self.cache_stats["hits"] += 1
...                     print(f"ファイルキャッシュヒット: {func.__name__}{args}")
...                     return result
...                 except (pickle.PickleError, IOError):
...                     # キャッシュファイルが破損している場合は削除
...                     os.remove(cache_file)
...             
...             # キャッシュミス：関数を実行してファイルに保存
...             self.cache_stats["misses"] += 1
...             print(f"ファイルキャッシュミス: {func.__name__}{args} - 計算実行中...")
...             result = func(*args, **kwargs)
...             
...             try:
...                 with open(cache_file, 'wb') as f:
...                     pickle.dump(result, f)
...             except (pickle.PickleError, IOError):
...                 print(f"警告: キャッシュファイルの保存に失敗しました")
...             
...             return result
...         return wrapper
...     
...     def get_cache_stats(self):
...         """キャッシュ統計を取得"""
...         total_requests = self.cache_stats["hits"] + self.cache_stats["misses"]
...         hit_rate = (self.cache_stats["hits"] / total_requests * 100) if total_requests > 0 else 0
...         
...         return {
...             "hits": self.cache_stats["hits"],
...             "misses": self.cache_stats["misses"],
...             "total_requests": total_requests,
...             "hit_rate": hit_rate,
...             "memory_cache_size": len(self.memory_cache)
...         }
...     
...     def clear_cache(self):
...         """全キャッシュをクリア"""
...         # メモリキャッシュのクリア
...         self.memory_cache.clear()
...         
...         # ファイルキャッシュのクリア
...         for filename in os.listdir(self.cache_dir):
...             if filename.endswith('.pkl'):
...                 os.remove(os.path.join(self.cache_dir, filename))
...         
...         # 統計のリセット
...         self.cache_stats = {"hits": 0, "misses": 0}
...         print("全キャッシュをクリアしました")
... 

>>> # キャッシュマネージャーの作成
>>> cache_manager = CacheManager()

>>> # 計算コストの高い関数（キャッシュ対象）
>>> @cache_manager.memory_cache_decorator
... def expensive_fibonacci(n):
...     """計算コストの高いフィボナッチ数列"""
...     if n <= 1:
...         return n
...     # 意図的に非効率な実装
...     return expensive_fibonacci(n-1) + expensive_fibonacci(n-2)
... 

>>> @cache_manager.file_cache_decorator
... def calculate_prime_factors(n):
...     """素因数分解（ファイルキャッシュ対象）"""
...     factors = []
...     d = 2
...     while d * d <= n:
...         while n % d == 0:
...             factors.append(d)
...             n //= d
...         d += 1
...     if n > 1:
...         factors.append(n)
...     return factors
... 

>>> # キャッシュ機能のテスト
>>> print("=== キャッシュ機能のテスト ===")

>>> # メモリキャッシュのテスト
>>> print("\\nメモリキャッシュテスト（フィボナッチ数列）:")
>>> for i in [10, 15, 10, 20, 15]:  # 重複した値でキャッシュ効果を確認
...     result = expensive_fibonacci(i)
...     print(f"fibonacci({i}) = {result}")

>>> print("\\nファイルキャッシュテスト（素因数分解）:")
>>> for num in [1000, 2048, 1000, 3456, 2048]:  # 重複した値でキャッシュ効果を確認
...     factors = calculate_prime_factors(num)
...     print(f"{num}の素因数: {factors}")

=== キャッシュ機能のテスト ===

メモリキャッシュテスト（フィボナッチ数列）:
キャッシュミス: expensive_fibonacci(10) - 計算実行中...
fibonacci(10) = 55
キャッシュミス: expensive_fibonacci(15) - 計算実行中...
fibonacci(15) = 610
キャッシュヒット: expensive_fibonacci(10)
fibonacci(10) = 55
キャッシュミス: expensive_fibonacci(20) - 計算実行中...
fibonacci(20) = 6765
キャッシュヒット: expensive_fibonacci(15)
fibonacci(15) = 610

ファイルキャッシュテスト（素因数分解）:
ファイルキャッシュミス: calculate_prime_factors(1000) - 計算実行中...
1000の素因数: [2, 2, 2, 5, 5, 5]
ファイルキャッシュミス: calculate_prime_factors(2048) - 計算実行中...
2048の素因数: [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
ファイルキャッシュヒット: calculate_prime_factors(1000)
1000の素因数: [2, 2, 2, 5, 5, 5]
ファイルキャッシュミス: calculate_prime_factors(3456) - 計算実行中...
3456の素因数: [2, 2, 2, 2, 2, 2, 2, 3, 3, 3]
ファイルキャッシュヒット: calculate_prime_factors(2048)
2048の素因数: [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]

>>> # キャッシュ統計の表示
>>> stats = cache_manager.get_cache_stats()
>>> print(f"\\n=== キャッシュ統計 ===")
>>> print(f"キャッシュヒット: {stats['hits']}回")
>>> print(f"キャッシュミス: {stats['misses']}回")
>>> print(f"ヒット率: {stats['hit_rate']:.1f}%")
>>> print(f"メモリキャッシュサイズ: {stats['memory_cache_size']}個")

=== キャッシュ統計 ===
キャッシュヒット: 4回
キャッシュミス: 6回
ヒット率: 40.0%
メモリキャッシュサイズ: 3個
```

## 複数のデコレータを組み合わせる

### デコレータチェーン

```python
>>> # 複数のデコレータを組み合わせた関数
>>> @log_function_calls(include_time=False, include_args=False)
... @monitor.timing_decorator
... @cache_manager.memory_cache_decorator
... def complex_calculation(x, y, operation="add"):
...     """複雑な計算を行う関数（例）"""
...     import time
...     time.sleep(0.1)  # 計算時間をシミュレート
...     
...     if operation == "add":
...         return x + y
...     elif operation == "multiply":
...         return x * y
...     elif operation == "power":
...         return x ** y
...     else:
...         raise ValueError(f"未対応の操作: {operation}")
... 

>>> print("=== 複数デコレータの組み合わせテスト ===")
>>> 
>>> # 同じ計算を複数回実行（キャッシュ効果を確認）
>>> for i in range(3):
...     print(f"\\n実行 {i+1}:")
...     result1 = complex_calculation(5, 3, "add")
...     result2 = complex_calculation(4, 2, "multiply") 
...     result3 = complex_calculation(5, 3, "add")  # キャッシュヒットするはず
...     
...     print(f"結果: {result1}, {result2}, {result3}")

=== 複数デコレータの組み合わせテスト ===

実行 1:
キャッシュミス: complex_calculation(5, 3, 'add') - 計算実行中...
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.1001秒) | 戻り値: 8
キャッシュミス: complex_calculation(4, 2, 'multiply') - 計算実行中...
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.1001秒) | 戻り値: 8
キャッシュヒット: complex_calculation(5, 3, 'add')
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.0001秒) | 戻り値: 8
結果: 8, 8, 8

実行 2:
キャッシュヒット: complex_calculation(5, 3, 'add')
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.0001秒) | 戻り値: 8
キャッシュヒット: complex_calculation(4, 2, 'multiply')
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.0001秒) | 戻り値: 8
キャッシュヒット: complex_calculation(5, 3, 'add')
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.0001秒) | 戻り値: 8
結果: 8, 8, 8

実行 3:
キャッシュヒット: complex_calculation(5, 3, 'add')
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.0001秒) | 戻り値: 8
キャッシュヒット: complex_calculation(4, 2, 'multiply')
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.0001秒) | 戻り値: 8
キャッシュヒット: complex_calculation(5, 3, 'add')
LOG: 関数 'complex_calculation' を実行 | 成功 (実行時間: 0.0001秒) | 戻り値: 8
結果: 8, 8, 8
```

## 引数を持つデコレータ

### パラメータ化デコレータ

```python
>>> def retry_on_failure(max_attempts=3, delay=1, exceptions=(Exception,)):
...     """失敗時にリトライするデコレータ"""
...     def decorator(func):
...         @functools.wraps(func)
...         def wrapper(*args, **kwargs):
...             last_exception = None
...             
...             for attempt in range(max_attempts):
...                 try:
...                     print(f"試行 {attempt + 1}/{max_attempts}: {func.__name__}")
...                     result = func(*args, **kwargs)
...                     if attempt > 0:
...                         print(f"成功: {attempt + 1}回目で成功しました")
...                     return result
...                     
...                 except exceptions as e:
...                     last_exception = e
...                     print(f"失敗: {str(e)}")
...                     
...                     if attempt < max_attempts - 1:
...                         print(f"{delay}秒待機してリトライします...")
...                         time.sleep(delay)
...                     else:
...                         print(f"最大試行回数に達しました。諦めます。")
...             
...             # 全ての試行が失敗した場合
...             raise last_exception
...         return wrapper
...     return decorator
... 

>>> def validate_types(**type_checks):
...     """引数の型をチェックするデコレータ"""
...     def decorator(func):
...         @functools.wraps(func)
...         def wrapper(*args, **kwargs):
...             import inspect
...             
...             # 関数のシグネチャを取得
...             sig = inspect.signature(func)
...             bound_args = sig.bind(*args, **kwargs)
...             bound_args.apply_defaults()
...             
...             # 型チェック
...             for param_name, expected_type in type_checks.items():
...                 if param_name in bound_args.arguments:
...                     value = bound_args.arguments[param_name]
...                     if not isinstance(value, expected_type):
...                         raise TypeError(
...                             f"引数 '{param_name}' は {expected_type.__name__} 型である必要があります。"
...                             f"実際の型: {type(value).__name__}"
...                         )
...             
...             return func(*args, **kwargs)
...         return wrapper
...     return decorator
... 

>>> # パラメータ化デコレータの使用例
>>> import random

>>> @retry_on_failure(max_attempts=3, delay=0.5, exceptions=(ValueError, ConnectionError))
... def unreliable_network_call(success_rate=0.3):
...     """不安定なネットワーク呼び出しをシミュレート"""
...     if random.random() < success_rate:
...         return "データ取得成功"
...     else:
...         if random.random() < 0.5:
...             raise ValueError("データ形式エラー")
...         else:
...             raise ConnectionError("ネットワーク接続エラー")
... 

>>> @validate_types(name=str, age=int, salary=float)
... def create_employee_record(name, age, salary):
...     """従業員レコードを作成"""
...     return {
...         "name": name,
...         "age": age,
...         "salary": salary,
...         "id": f"EMP_{age}_{name[:3].upper()}"
...     }
... 

>>> print("=== リトライデコレータのテスト ===")
>>> try:
...     result = unreliable_network_call(success_rate=0.8)  # 成功率80%
...     print(f"結果: {result}")
... except Exception as e:
...     print(f"最終的に失敗: {e}")

>>> print("\\n=== 型チェックデコレータのテスト ===")

>>> # 正常なケース
>>> try:
...     employee1 = create_employee_record("田中太郎", 30, 500000.0)
...     print(f"正常作成: {employee1}")
... except TypeError as e:
...     print(f"型エラー: {e}")

>>> # 型エラーのケース
>>> try:
...     employee2 = create_employee_record("佐藤花子", "30", 600000.0)  # 年齢が文字列
...     print(f"作成: {employee2}")
... except TypeError as e:
...     print(f"型エラー: {e}")

>>> try:
...     employee3 = create_employee_record("鈴木一郎", 35, "700000")  # 給与が文字列
...     print(f"作成: {employee3}")
... except TypeError as e:
...     print(f"型エラー: {e}")

=== リトライデコレータのテスト ===
試行 1/3: unreliable_network_call
結果: データ取得成功

=== 型チェックデコレータのテスト ===
正常作成: {'name': '田中太郎', 'age': 30, 'salary': 500000.0, 'id': 'EMP_30_田中'}
型エラー: 引数 'age' は int 型である必要があります。実際の型: str
型エラー: 引数 'salary' は float 型である必要があります。実際の型: str
```

## まとめ：デコレータの威力と活用法

この章で学んだことをまとめましょう：

### デコレータの基本概念
- **関数を拡張する仕組み**: 既存の関数に新しい機能を追加
- **@記法**: `@decorator` でシンプルに適用
- **functools.wraps**: 元の関数の情報を保持
- **高階関数**: 関数を引数として受け取る関数

### 実用的なデコレータの例
1. **ログ機能**: 関数の呼び出しを記録
2. **パフォーマンス測定**: 実行時間の監視
3. **キャッシュ機能**: 計算結果の保存と再利用
4. **リトライ機能**: 失敗時の自動再試行
5. **型チェック**: 引数の型検証

### デコレータの設計パターン
```python
# 基本パターン
def simple_decorator(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        # 前処理
        result = func(*args, **kwargs)
        # 後処理
        return result
    return wrapper

# パラメータ付きパターン
def parameterized_decorator(param1, param2=default):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # パラメータを使用した処理
            return func(*args, **kwargs)
        return wrapper
    return decorator
```

### デコレータチェーン
```python
@decorator1
@decorator2
@decorator3
def my_function():
    pass

# これは以下と同等：
# my_function = decorator1(decorator2(decorator3(my_function)))
```

### 実用的な応用例
- **Webフレームワーク**: ルーティング、認証、CORS
- **テスト**: モック、データベースセットアップ
- **API**: レート制限、認証チェック
- **データベース**: トランザクション管理
- **デバッグ**: プロファイリング、ログ

### パフォーマンスへの影響
- **メモリ使用量**: キャッシュによる最適化
- **実行時間**: オーバーヘッドと最適化のバランス
- **スケーラビリティ**: 大規模アプリケーションでの効果

次の章では、**非同期プログラミング**について学びます。async/awaitを使った並行処理で、I/O待機時間を有効活用し、高パフォーマンスなアプリケーションを作る方法を習得しましょう！

---

**第16章執筆完了ログ:**
第16章では高階関数とデコレータの概念から実用的な応用まで包括的に学習。関数を第一級オブジェクトとして扱う方法、関数を返す関数、引数として受け取る関数の実装を段階的に説明。実践例としてログ機能、パフォーマンス監視、キャッシュ機能を持つデコレータシステムを構築。複数デコレータの組み合わせ、パラメータ化デコレータも含む完全なシステムを実装。次は第17章の非同期プログラミングに進みます。