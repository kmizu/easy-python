# 第18章：Pythonの内部動作と最適化

## この章で学ぶこと

- バイトコードとPython仮想マシン
- オブジェクトの内部構造
- メモリ管理とガベージコレクション
- パフォーマンス測定と最適化
- JITコンパイルとPyPy
- C拡張との相互運用

## 18.1 【実行】バイトコードとPython仮想マシン

```python
# bytecode_analysis.py

import dis
import types

# 基本的なバイトコード
print("=== 基本的なバイトコード ===")

def simple_function(x, y):
    z = x + y
    return z * 2

print("simple_function のバイトコード:")
dis.dis(simple_function)

# 式のバイトコード
print("\n=== 式のバイトコード ===")

# 単純な式
code1 = compile("2 + 3", "<string>", "eval")
print("2 + 3 のバイトコード:")
dis.dis(code1)

# 複雑な式
code2 = compile("(x + y) * z", "<string>", "eval")
print("\n(x + y) * z のバイトコード:")
dis.dis(code2)

# 制御構造のバイトコード
print("\n=== 制御構造のバイトコード ===")

def if_function(x):
    if x > 10:
        return "big"
    else:
        return "small"

print("if文のバイトコード:")
dis.dis(if_function)

def loop_function():
    total = 0
    for i in range(5):
        total += i
    return total

print("\nfor文のバイトコード:")
dis.dis(loop_function)

# バイトコードの詳細分析
print("\n=== バイトコードの詳細分析 ===")

def analyze_bytecode(func):
    """関数のバイトコードを詳細に分析"""
    print(f"\n関数: {func.__name__}")
    print(f"引数の数: {func.__code__.co_argcount}")
    print(f"ローカル変数の数: {func.__code__.co_nlocals}")
    print(f"スタックサイズ: {func.__code__.co_stacksize}")
    print(f"定数: {func.__code__.co_consts}")
    print(f"変数名: {func.__code__.co_varnames}")
    print(f"名前: {func.__code__.co_names}")
    
    print("\nバイトコード:")
    for instruction in dis.get_instructions(func):
        print(f"  {instruction.offset:4d} {instruction.opname:20s} "
              f"{instruction.arg if instruction.arg is not None else '':3s} "
              f"{instruction.argval}")

analyze_bytecode(simple_function)

# リスト内包表記のバイトコード
print("\n=== リスト内包表記 vs ループ ===")

def list_comprehension():
    return [x * 2 for x in range(10)]

def explicit_loop():
    result = []
    for x in range(10):
        result.append(x * 2)
    return result

print("リスト内包表記:")
dis.dis(list_comprehension)

print("\n明示的なループ:")
dis.dis(explicit_loop)

# バイトコードの実行時間比較
import time

def measure_time(func, iterations=100000):
    start = time.time()
    for _ in range(iterations):
        func()
    end = time.time()
    return end - start

comp_time = measure_time(list_comprehension)
loop_time = measure_time(explicit_loop)

print(f"\nリスト内包表記: {comp_time:.4f}秒")
print(f"明示的なループ: {loop_time:.4f}秒")
print(f"速度比: {loop_time / comp_time:.2f}倍")
```

### 【実行】Python仮想マシンの動作

```python
# virtual_machine.py

# PVMの動作を模擬
print("=== Python仮想マシンの動作 ===")

class SimplePVM:
    """簡単なPython仮想マシンのシミュレーション"""
    
    def __init__(self):
        self.stack = []
        self.locals = {}
        self.globals = {}
    
    def execute_bytecode(self, instructions):
        """バイトコード命令を実行"""
        for opcode, arg in instructions:
            if opcode == 'LOAD_CONST':
                self.stack.append(arg)
                print(f"LOAD_CONST {arg} -> スタック: {self.stack}")
            
            elif opcode == 'LOAD_NAME':
                value = self.locals.get(arg) or self.globals.get(arg)
                self.stack.append(value)
                print(f"LOAD_NAME {arg} -> スタック: {self.stack}")
            
            elif opcode == 'STORE_NAME':
                value = self.stack.pop()
                self.locals[arg] = value
                print(f"STORE_NAME {arg} = {value}")
            
            elif opcode == 'BINARY_ADD':
                b = self.stack.pop()
                a = self.stack.pop()
                result = a + b
                self.stack.append(result)
                print(f"BINARY_ADD {a} + {b} = {result} -> スタック: {self.stack}")
            
            elif opcode == 'BINARY_MULTIPLY':
                b = self.stack.pop()
                a = self.stack.pop()
                result = a * b
                self.stack.append(result)
                print(f"BINARY_MULTIPLY {a} * {b} = {result} -> スタック: {self.stack}")
            
            elif opcode == 'RETURN_VALUE':
                value = self.stack.pop()
                print(f"RETURN_VALUE {value}")
                return value
        
        return None

# x = 5, y = 3, result = (x + y) * 2 をシミュレート
pvm = SimplePVM()
bytecode = [
    ('LOAD_CONST', 5),      # x = 5
    ('STORE_NAME', 'x'),
    ('LOAD_CONST', 3),      # y = 3
    ('STORE_NAME', 'y'),
    ('LOAD_NAME', 'x'),     # x + y
    ('LOAD_NAME', 'y'),
    ('BINARY_ADD', None),
    ('LOAD_CONST', 2),      # ... * 2
    ('BINARY_MULTIPLY', None),
    ('RETURN_VALUE', None)
]

result = pvm.execute_bytecode(bytecode)
print(f"\n最終結果: {result}")

# 実際のコードとの比較
print("\n=== 実際のコードとの比較 ===")
actual_code = compile("x = 5; y = 3; (x + y) * 2", "<string>", "exec")
print("実際のバイトコード:")
dis.dis(actual_code)

# コードオブジェクトの検査
print("\n=== コードオブジェクトの検査 ===")

def inspect_code_object(code_obj):
    """コードオブジェクトの詳細を表示"""
    print(f"ファイル名: {code_obj.co_filename}")
    print(f"関数名: {code_obj.co_name}")
    print(f"第一行: {code_obj.co_firstlineno}")
    print(f"引数数: {code_obj.co_argcount}")
    print(f"キーワード専用引数数: {code_obj.co_kwonlyargcount}")
    print(f"ローカル変数数: {code_obj.co_nlocals}")
    print(f"スタックサイズ: {code_obj.co_stacksize}")
    print(f"フラグ: {code_obj.co_flags:b}")
    print(f"バイトコード長: {len(code_obj.co_code)}")
    print(f"定数: {code_obj.co_consts}")
    print(f"名前: {code_obj.co_names}")
    print(f"変数名: {code_obj.co_varnames}")

def sample_function(a, b=10, *args, **kwargs):
    x = a + b
    y = sum(args)
    return x + y

inspect_code_object(sample_function.__code__)

# フレームオブジェクトの調査
print("\n=== フレームオブジェクト ===")
import sys

def examine_frame():
    """現在のフレームを調査"""
    frame = sys._getframe()
    print(f"関数名: {frame.f_code.co_name}")
    print(f"行番号: {frame.f_lineno}")
    print(f"ローカル変数: {frame.f_locals}")
    print(f"グローバル変数の一部: {list(frame.f_globals.keys())[:5]}...")
    
    # 呼び出し元のフレーム
    caller = frame.f_back
    if caller:
        print(f"呼び出し元: {caller.f_code.co_name}")

examine_frame()
```

## 18.2 【実行】オブジェクトの内部構造

```python
# object_internals.py

import sys
import gc

# オブジェクトのメモリレイアウト
print("=== オブジェクトのメモリレイアウト ===")

class InspectObject:
    def __init__(self, value):
        self.value = value

def object_info(obj):
    """オブジェクトの詳細情報を表示"""
    print(f"オブジェクト: {obj}")
    print(f"型: {type(obj)}")
    print(f"ID (メモリアドレス): {id(obj)}")
    print(f"サイズ: {sys.getsizeof(obj)} bytes")
    print(f"参照カウント: {sys.getrefcount(obj) - 1}")  # -1は一時的な参照
    
    # __dict__がある場合
    if hasattr(obj, '__dict__'):
        print(f"__dict__: {obj.__dict__}")
        print(f"__dict__のサイズ: {sys.getsizeof(obj.__dict__)} bytes")
    
    # __slots__がある場合
    if hasattr(obj, '__slots__'):
        print(f"__slots__: {obj.__slots__}")
    
    print("-" * 40)

# 様々なオブジェクトのサイズ比較
objects = [
    42,
    "Hello, World!",
    [1, 2, 3, 4, 5],
    {'a': 1, 'b': 2},
    InspectObject("test"),
    lambda x: x * 2
]

for obj in objects:
    object_info(obj)

# 整数のインターニング
print("\n=== 整数のインターニング ===")
a = 256
b = 256
c = 257
d = 257

print(f"a = 256, b = 256")
print(f"a is b: {a is b}")
print(f"id(a): {id(a)}, id(b): {id(b)}")

print(f"\nc = 257, d = 257")
print(f"c is d: {c is d}")
print(f"id(c): {id(c)}, id(d): {id(d)}")

# 文字列のインターニング
print("\n=== 文字列のインターニング ===")
s1 = "hello"
s2 = "hello"
s3 = "hello world"
s4 = "hello world"

print(f's1 = "hello", s2 = "hello"')
print(f"s1 is s2: {s1 is s2}")

print(f's3 = "hello world", s4 = "hello world"')
print(f"s3 is s4: {s3 is s4}")

# 動的に作成された文字列
s5 = "hello" + " world"
s6 = "hello" + " world"
print(f"\n動的作成: s5 is s6: {s5 is s6}")

# __slots__によるメモリ最適化
print("\n=== __slots__によるメモリ最適化 ===")

class RegularClass:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class SlottedClass:
    __slots__ = ['x', 'y']
    
    def __init__(self, x, y):
        self.x = x
        self.y = y

regular = RegularClass(1, 2)
slotted = SlottedClass(1, 2)

print(f"通常のクラス: {sys.getsizeof(regular)} bytes")
print(f"__slots__クラス: {sys.getsizeof(slotted)} bytes")

# 大量のインスタンスでの差
regular_instances = [RegularClass(i, i+1) for i in range(1000)]
slotted_instances = [SlottedClass(i, i+1) for i in range(1000)]

regular_total = sum(sys.getsizeof(obj) + sys.getsizeof(obj.__dict__) 
                   for obj in regular_instances)
slotted_total = sum(sys.getsizeof(obj) for obj in slotted_instances)

print(f"\n1000個のインスタンス:")
print(f"通常のクラス: {regular_total:,} bytes")
print(f"__slots__クラス: {slotted_total:,} bytes")
print(f"削減率: {(regular_total - slotted_total) / regular_total * 100:.1f}%")

# 弱参照
print("\n=== 弱参照 ===")
import weakref

class MyClass:
    def __init__(self, name):
        self.name = name
    
    def __del__(self):
        print(f"MyClass({self.name}) が削除されました")

# 通常の参照
obj = MyClass("test")
print(f"参照カウント: {sys.getrefcount(obj) - 1}")

# 弱参照を作成
weak_ref = weakref.ref(obj)
print(f"弱参照作成後の参照カウント: {sys.getrefcount(obj) - 1}")
print(f"弱参照経由でアクセス: {weak_ref().name}")

# オブジェクトを削除
del obj
print(f"弱参照が生きているか: {weak_ref() is not None}")

# 循環参照の検出
print("\n=== 循環参照 ===")

class Node:
    def __init__(self, value):
        self.value = value
        self.parent = None
        self.children = []
    
    def add_child(self, child):
        child.parent = self
        self.children.append(child)

# 循環参照を作成
root = Node("root")
child1 = Node("child1")
child2 = Node("child2")

root.add_child(child1)
root.add_child(child2)

print(f"作成前のオブジェクト数: {len(gc.get_objects())}")

# 参照を削除
root_id = id(root)
del root, child1, child2

print(f"削除後のオブジェクト数: {len(gc.get_objects())}")

# ガベージコレクションを実行
collected = gc.collect()
print(f"ガベージコレクション実行: {collected} 個回収")
print(f"回収後のオブジェクト数: {len(gc.get_objects())}")
```

## 18.3 【実行】メモリ管理とガベージコレクション

```python
# memory_management.py

import gc
import sys
import weakref
from collections import defaultdict

# ガベージコレクションの設定
print("=== ガベージコレクション設定 ===")
print(f"GC有効: {gc.isenabled()}")
print(f"GCしきい値: {gc.get_threshold()}")
print(f"GC統計: {gc.get_stats()}")

# メモリプロファイリング
print("\n=== メモリプロファイリング ===")

def memory_usage():
    """現在のメモリ使用量を表示"""
    import psutil
    import os
    
    process = psutil.Process(os.getpid())
    memory_info = process.memory_info()
    
    print(f"RSS (物理メモリ): {memory_info.rss / 1024 / 1024:.2f} MB")
    print(f"VMS (仮想メモリ): {memory_info.vms / 1024 / 1024:.2f} MB")

def track_object_creation():
    """オブジェクト作成を追跡"""
    before = len(gc.get_objects())
    
    # 大量のオブジェクトを作成
    data = []
    for i in range(10000):
        data.append([i, i*2, i*3])
    
    after = len(gc.get_objects())
    print(f"オブジェクト作成前: {before}")
    print(f"オブジェクト作成後: {after}")
    print(f"増加数: {after - before}")
    
    # メモリ使用量を確認
    memory_usage()
    
    # データを削除
    del data
    collected = gc.collect()
    
    final = len(gc.get_objects())
    print(f"\n削除・GC後: {final}")
    print(f"回収されたオブジェクト: {collected}")
    
    memory_usage()

track_object_creation()

# 循環参照の詳細分析
print("\n=== 循環参照の詳細分析 ===")

class CircularRef:
    def __init__(self, name):
        self.name = name
        self.refs = []
    
    def add_ref(self, other):
        self.refs.append(other)
    
    def __del__(self):
        print(f"CircularRef({self.name}) が削除されました")

def create_circular_references():
    """循環参照を作成して分析"""
    # ガベージコレクションを無効化
    gc.disable()
    
    objects_before = len(gc.get_objects())
    
    # 循環参照を作成
    obj_a = CircularRef("A")
    obj_b = CircularRef("B")
    obj_c = CircularRef("C")
    
    obj_a.add_ref(obj_b)
    obj_b.add_ref(obj_c)
    obj_c.add_ref(obj_a)  # 循環
    
    objects_after = len(gc.get_objects())
    print(f"循環参照作成: {objects_after - objects_before} 個増加")
    
    # 直接参照を削除
    del obj_a, obj_b, obj_c
    
    objects_deleted = len(gc.get_objects())
    print(f"直接参照削除後: {objects_deleted - objects_before} 個残存")
    
    # ガベージコレクションを有効化・実行
    gc.enable()
    collected = gc.collect()
    
    objects_final = len(gc.get_objects())
    print(f"GC実行後: {objects_final - objects_before} 個残存")
    print(f"回収されたオブジェクト: {collected}")

create_circular_references()

# ガベージコレクションのカスタマイズ
print("\n=== ガベージコレクションのカスタマイズ ===")

# GCコールバック
def gc_callback(phase, info):
    """GC実行時のコールバック"""
    print(f"GC {phase}: {info}")

gc.callbacks.append(gc_callback)

# しきい値を変更
original_threshold = gc.get_threshold()
gc.set_threshold(100, 5, 5)  # より頻繁にGCを実行

print(f"元のしきい値: {original_threshold}")
print(f"新しいしきい値: {gc.get_threshold()}")

# 大量のオブジェクトを作成してGCをトリガー
temp_objects = []
for i in range(200):
    temp_objects.append({'data': list(range(100))})

# しきい値を元に戻す
gc.set_threshold(*original_threshold)
gc.callbacks.clear()

# メモリリーク検出
print("\n=== メモリリーク検出 ===")

class LeakyClass:
    _instances = []  # すべてのインスタンスを保持（リーク）
    
    def __init__(self, data):
        self.data = data
        LeakyClass._instances.append(self)

def detect_memory_leak():
    """メモリリークを検出"""
    initial_count = len(LeakyClass._instances)
    initial_objects = len(gc.get_objects())
    
    # オブジェクトを作成
    for i in range(1000):
        LeakyClass(f"data_{i}")
    
    after_count = len(LeakyClass._instances)
    after_objects = len(gc.get_objects())
    
    print(f"LeakyClassインスタンス: {initial_count} -> {after_count}")
    print(f"総オブジェクト数: {initial_objects} -> {after_objects}")
    
    # ガベージコレクションしても減らない
    collected = gc.collect()
    final_objects = len(gc.get_objects())
    print(f"GC後のオブジェクト数: {final_objects}")
    print(f"リークの可能性: {after_count > initial_count}")

detect_memory_leak()

# 弱参照による解決
print("\n=== 弱参照による解決 ===")

class NonLeakyClass:
    _instances = weakref.WeakSet()  # 弱参照を使用
    
    def __init__(self, data):
        self.data = data
        NonLeakyClass._instances.add(self)
    
    @classmethod
    def get_instance_count(cls):
        return len(cls._instances)

# 弱参照版のテスト
print(f"初期インスタンス数: {NonLeakyClass.get_instance_count()}")

objects = []
for i in range(100):
    obj = NonLeakyClass(f"data_{i}")
    if i < 50:  # 半分だけ保持
        objects.append(obj)

print(f"作成後インスタンス数: {NonLeakyClass.get_instance_count()}")

# 変数を削除
del objects
gc.collect()

print(f"削除後インスタンス数: {NonLeakyClass.get_instance_count()}")

# コンテキストマネージャーでのリソース管理
print("\n=== リソース管理 ===")

class ManagedResource:
    """適切にリソースを管理するクラス"""
    
    def __init__(self, name):
        self.name = name
        print(f"リソース {name} を作成")
    
    def __enter__(self):
        print(f"リソース {self.name} を開始")
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        print(f"リソース {self.name} をクリーンアップ")
        return False
    
    def __del__(self):
        print(f"リソース {self.name} が削除されました")

# 適切なリソース管理
with ManagedResource("test_resource") as resource:
    print(f"リソース {resource.name} を使用中")
    # ここで例外が発生してもクリーンアップされる

print("withブロック終了")
```

## 18.4 【実行】パフォーマンス測定と最適化

```python
# performance_optimization.py

import time
import timeit
import cProfile
import profile
import pstats
import sys
from functools import wraps

# 基本的なタイミング測定
print("=== 基本的なパフォーマンス測定 ===")

def timer_decorator(func):
    """実行時間を測定するデコレータ"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        print(f"{func.__name__}: {end - start:.6f}秒")
        return result
    return wrapper

@timer_decorator
def list_comprehension_test():
    return [x**2 for x in range(10000)]

@timer_decorator
def generator_expression_test():
    return list(x**2 for x in range(10000))

@timer_decorator
def explicit_loop_test():
    result = []
    for x in range(10000):
        result.append(x**2)
    return result

# 各手法の比較
list_result = list_comprehension_test()
gen_result = generator_expression_test()
loop_result = explicit_loop_test()

# timeitによる精密な測定
print("\n=== timeitによる精密測定 ===")

list_comp_time = timeit.timeit(
    '[x**2 for x in range(1000)]',
    number=1000
)

gen_expr_time = timeit.timeit(
    'list(x**2 for x in range(1000))',
    number=1000
)

map_time = timeit.timeit(
    'list(map(lambda x: x**2, range(1000)))',
    number=1000
)

print(f"リスト内包表記: {list_comp_time:.6f}秒")
print(f"ジェネレータ式: {gen_expr_time:.6f}秒")
print(f"map関数: {map_time:.6f}秒")

# メモリ効率の比較
print("\n=== メモリ効率の比較 ===")

def memory_comparison():
    """メモリ使用量を比較"""
    n = 100000
    
    # リスト（すべてメモリに保持）
    start_mem = sys.getsizeof([])
    big_list = [x**2 for x in range(n)]
    list_mem = sys.getsizeof(big_list)
    
    # ジェネレータ（必要時に生成）
    big_gen = (x**2 for x in range(n))
    gen_mem = sys.getsizeof(big_gen)
    
    print(f"リスト ({n}要素): {list_mem:,} bytes")
    print(f"ジェネレータ: {gen_mem} bytes")
    print(f"メモリ効率: {list_mem / gen_mem:.0f}倍の差")

memory_comparison()

# プロファイリング
print("\n=== プロファイリング ===")

def fibonacci_recursive(n):
    """再帰版フィボナッチ（非効率）"""
    if n <= 1:
        return n
    return fibonacci_recursive(n-1) + fibonacci_recursive(n-2)

def fibonacci_iterative(n):
    """反復版フィボナッチ（効率的）"""
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def fibonacci_memoized(n, memo={}):
    """メモ化版フィボナッチ"""
    if n in memo:
        return memo[n]
    if n <= 1:
        return n
    memo[n] = fibonacci_memoized(n-1, memo) + fibonacci_memoized(n-2, memo)
    return memo[n]

# プロファイリング実行
def profile_fibonacci():
    """フィボナッチ関数をプロファイリング"""
    print("再帰版 (n=30):")
    start = time.time()
    result1 = fibonacci_recursive(30)
    end = time.time()
    print(f"結果: {result1}, 時間: {end - start:.4f}秒")
    
    print("\n反復版 (n=30):")
    start = time.time()
    result2 = fibonacci_iterative(30)
    end = time.time()
    print(f"結果: {result2}, 時間: {end - start:.6f}秒")
    
    print("\nメモ化版 (n=30):")
    start = time.time()
    result3 = fibonacci_memoized(30)
    end = time.time()
    print(f"結果: {result3}, 時間: {end - start:.6f}秒")

profile_fibonacci()

# 詳細プロファイリング
print("\n=== 詳細プロファイリング ===")

def detailed_profiling():
    """cProfileを使った詳細プロファイリング"""
    
    # プロファイラーを作成
    pr = cProfile.Profile()
    
    # プロファイリング開始
    pr.enable()
    
    # 測定対象の処理
    for i in range(5):
        fibonacci_recursive(20)
        fibonacci_iterative(1000)
    
    # プロファイリング終了
    pr.disable()
    
    # 統計を表示
    stats = pstats.Stats(pr)
    stats.sort_stats('cumulative')
    stats.print_stats(10)  # 上位10関数を表示

detailed_profiling()

# データ構造の選択による最適化
print("\n=== データ構造の最適化 ===")

def compare_data_structures():
    """異なるデータ構造のパフォーマンス比較"""
    
    n = 100000
    
    # リストでの検索
    data_list = list(range(n))
    start = time.time()
    result = n-1 in data_list  # 最悪ケース
    list_time = time.time() - start
    
    # セットでの検索
    data_set = set(range(n))
    start = time.time()
    result = n-1 in data_set
    set_time = time.time() - start
    
    # 辞書での検索
    data_dict = {i: i for i in range(n)}
    start = time.time()
    result = n-1 in data_dict
    dict_time = time.time() - start
    
    print(f"リスト検索: {list_time:.6f}秒")
    print(f"セット検索: {set_time:.6f}秒")
    print(f"辞書検索: {dict_time:.6f}秒")
    print(f"セットはリストより {list_time/set_time:.0f}倍高速")

compare_data_structures()

# 最適化のベストプラクティス
print("\n=== 最適化のベストプラクティス ===")

# 1. 事前計算とキャッシュ
def expensive_calculation(n):
    """重い計算のシミュレーション"""
    time.sleep(0.01)
    return n ** 2

# キャッシュなし
@timer_decorator
def no_cache():
    return [expensive_calculation(i) for i in range(10)]

# 手動キャッシュ
cache = {}
def cached_calculation(n):
    if n not in cache:
        cache[n] = expensive_calculation(n)
    return cache[n]

@timer_decorator
def with_cache():
    return [cached_calculation(i) for i in range(10)]

# functools.lru_cache
from functools import lru_cache

@lru_cache(maxsize=128)
def lru_cached_calculation(n):
    return expensive_calculation(n)

@timer_decorator
def with_lru_cache():
    return [lru_cached_calculation(i) for i in range(10)]

print("初回実行:")
no_cache()
with_cache()
with_lru_cache()

print("\n2回目実行:")
no_cache()
with_cache()
with_lru_cache()

# 2. ボトルネックの特定
class PerformanceMonitor:
    """パフォーマンス監視クラス"""
    
    def __init__(self):
        self.times = {}
    
    def __call__(self, name):
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                start = time.perf_counter()
                result = func(*args, **kwargs)
                end = time.perf_counter()
                
                if name not in self.times:
                    self.times[name] = []
                self.times[name].append(end - start)
                
                return result
            return wrapper
        return decorator
    
    def report(self):
        """パフォーマンスレポートを表示"""
        print("\nパフォーマンスレポート:")
        for name, times in self.times.items():
            avg_time = sum(times) / len(times)
            total_time = sum(times)
            calls = len(times)
            print(f"{name}: {calls}回呼び出し, "
                  f"平均 {avg_time:.6f}秒, "
                  f"合計 {total_time:.6f}秒")

monitor = PerformanceMonitor()

@monitor('database_query')
def mock_db_query():
    time.sleep(0.01)
    return "data"

@monitor('data_processing')
def mock_data_processing(data):
    time.sleep(0.005)
    return data.upper()

# 複数回実行
for i in range(10):
    data = mock_db_query()
    processed = mock_data_processing(data)

monitor.report()
```

## 18.5 【実行】JITコンパイルとPyPy

```python
# jit_compilation.py

# PyPyとの比較（CPythonで実行）
print("=== PyPy vs CPython ===")

def compute_intensive_task(n):
    """計算集約的なタスク"""
    total = 0
    for i in range(n):
        for j in range(100):
            total += i * j
    return total

# CPythonでの実行時間測定
import time

def measure_cpython():
    """CPythonでの実行時間を測定"""
    start = time.time()
    result = compute_intensive_task(10000)
    end = time.time()
    
    print(f"CPython実行時間: {end - start:.4f}秒")
    print(f"結果: {result}")
    return end - start

cpython_time = measure_cpython()

# Numbaを使った高速化（JIT風）
try:
    from numba import jit
    
    @jit
    def compute_intensive_task_numba(n):
        """Numba JITコンパイル版"""
        total = 0
        for i in range(n):
            for j in range(100):
                total += i * j
        return total
    
    def measure_numba():
        """Numba版の実行時間を測定"""
        # ウォームアップ（初回コンパイル）
        compute_intensive_task_numba(100)
        
        start = time.time()
        result = compute_intensive_task_numba(10000)
        end = time.time()
        
        print(f"Numba実行時間: {end - start:.4f}秒")
        print(f"結果: {result}")
        print(f"高速化倍率: {cpython_time / (end - start):.1f}倍")
        return end - start
    
    measure_numba()
    
except ImportError:
    print("Numbaがインストールされていません")

# 数値計算の最適化
print("\n=== 数値計算の最適化 ===")

def matrix_multiply_python(a, b):
    """純Pythonでの行列乗算"""
    rows_a, cols_a = len(a), len(a[0])
    rows_b, cols_b = len(b), len(b[0])
    
    result = [[0 for _ in range(cols_b)] for _ in range(rows_a)]
    
    for i in range(rows_a):
        for j in range(cols_b):
            for k in range(cols_a):
                result[i][j] += a[i][k] * b[k][j]
    
    return result

# テスト用の小さな行列
matrix_a = [[1, 2], [3, 4]]
matrix_b = [[5, 6], [7, 8]]

start = time.time()
for _ in range(1000):
    result = matrix_multiply_python(matrix_a, matrix_b)
end = time.time()

print(f"純Python行列乗算 (1000回): {end - start:.4f}秒")

# NumPyとの比較
try:
    import numpy as np
    
    np_a = np.array(matrix_a)
    np_b = np.array(matrix_b)
    
    start = time.time()
    for _ in range(1000):
        result = np.dot(np_a, np_b)
    end = time.time()
    
    print(f"NumPy行列乗算 (1000回): {end - start:.4f}秒")
    
except ImportError:
    print("NumPyがインストールされていません")

# メモリアクセスパターンの最適化
print("\n=== メモリアクセスパターンの最適化 ===")

def row_major_access(matrix):
    """行優先アクセス（キャッシュフレンドリー）"""
    total = 0
    for i in range(len(matrix)):
        for j in range(len(matrix[0])):
            total += matrix[i][j]
    return total

def column_major_access(matrix):
    """列優先アクセス（キャッシュ非効率）"""
    total = 0
    for j in range(len(matrix[0])):
        for i in range(len(matrix)):
            total += matrix[i][j]
    return total

# 大きな行列を作成
large_matrix = [[i*j for j in range(1000)] for i in range(1000)]

start = time.time()
result1 = row_major_access(large_matrix)
row_time = time.time() - start

start = time.time()
result2 = column_major_access(large_matrix)
col_time = time.time() - start

print(f"行優先アクセス: {row_time:.4f}秒")
print(f"列優先アクセス: {col_time:.4f}秒")
print(f"差: {col_time / row_time:.2f}倍")

# 文字列操作の最適化
print("\n=== 文字列操作の最適化 ===")

def string_concatenation_slow(n):
    """非効率な文字列結合"""
    result = ""
    for i in range(n):
        result += str(i)
    return result

def string_concatenation_fast(n):
    """効率的な文字列結合"""
    parts = []
    for i in range(n):
        parts.append(str(i))
    return "".join(parts)

def string_concatenation_comprehension(n):
    """リスト内包表記を使用"""
    return "".join(str(i) for i in range(n))

n = 10000

start = time.time()
result1 = string_concatenation_slow(n)
slow_time = time.time() - start

start = time.time()
result2 = string_concatenation_fast(n)
fast_time = time.time() - start

start = time.time()
result3 = string_concatenation_comprehension(n)
comp_time = time.time() - start

print(f"非効率な結合: {slow_time:.4f}秒")
print(f"リスト+join: {fast_time:.4f}秒")
print(f"内包表記+join: {comp_time:.4f}秒")
print(f"改善率: {slow_time / fast_time:.1f}倍")

# プロファイリングに基づく最適化
print("\n=== プロファイリングに基づく最適化 ===")

def optimization_example():
    """最適化の例"""
    
    # 最適化前
    def unoptimized_function(data):
        result = []
        for item in data:
            if item % 2 == 0:  # 偶数チェック
                squared = item ** 2
                if squared < 100:
                    result.append(squared)
        return result
    
    # 最適化後
    def optimized_function(data):
        # リスト内包表記 + 早期終了条件
        return [item ** 2 for item in data 
                if item % 2 == 0 and item ** 2 < 100]
    
    # さらに最適化（NumPyなど外部ライブラリ使用想定）
    def highly_optimized_function(data):
        # 実際の実装ではNumPy配列操作を使用
        evens = [x for x in data if x % 2 == 0]
        squares = [x ** 2 for x in evens if x ** 2 < 100]
        return squares
    
    test_data = list(range(1000))
    
    # パフォーマンス比較
    start = time.time()
    for _ in range(1000):
        result1 = unoptimized_function(test_data)
    unopt_time = time.time() - start
    
    start = time.time()
    for _ in range(1000):
        result2 = optimized_function(test_data)
    opt_time = time.time() - start
    
    print(f"最適化前: {unopt_time:.4f}秒")
    print(f"最適化後: {opt_time:.4f}秒")
    print(f"改善率: {unopt_time / opt_time:.1f}倍")

optimization_example()
```

## 18.6 この章のまとめ

- Pythonコードはバイトコードにコンパイルされ、PVMで実行される
- オブジェクトは内部構造を持ち、メモリ効率を考慮した設計が重要
- ガベージコレクションが循環参照を解決し、メモリリークを防ぐ
- プロファイリングでボトルネックを特定し、データ構造を適切に選択する
- JITコンパイルや外部ライブラリで大幅な高速化が可能
- メモリアクセスパターンや文字列操作の最適化が効果的

## 練習問題

1. **カスタムプロファイラー**
   関数の実行時間、メモリ使用量、呼び出し回数を追跡するプロファイラーを作成してください。

2. **メモリ効率的なデータ構造**
   大量のデータを扱う際にメモリ使用量を最小化するデータ構造を設計してください。

3. **パフォーマンス比較ツール**
   異なるアルゴリズムの実装を比較するベンチマークツールを作成してください。

4. **ガベージコレクション分析**
   アプリケーションのガベージコレクションパターンを分析するツールを実装してください。

5. **最適化レコメンダー**
   コードを解析して最適化の提案を行うシステムを作成してください。

---

次章では、並行処理とマルチスレッドについて学びます。

[第19章 並行処理とマルチスレッド →](chapter19.md)