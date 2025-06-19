# 第12章：スコープとクロージャ

## この章で学ぶこと

- LEGB規則によるスコープ解決
- global文とnonlocal文のBNF
- クロージャの仕組みと作成
- デコレータの文法と実行順序
- 実用的なデコレータパターン

## 12.1 LEGB規則

### スコープの基本概念

```python
# scope_basics.py

# LEGB: Local, Enclosing, Global, Built-in

# Global スコープ
global_var = "グローバル変数"

def outer_function():
    # Enclosing スコープ
    enclosing_var = "外側の関数の変数"
    
    def inner_function():
        # Local スコープ
        local_var = "ローカル変数"
        
        # 各スコープの変数にアクセス
        print(f"Local: {local_var}")
        print(f"Enclosing: {enclosing_var}")
        print(f"Global: {global_var}")
        print(f"Built-in: {len}")  # 組み込み関数
    
    inner_function()

print("=== LEGB規則のデモ ===")
outer_function()

# スコープの優先順位
print("\n=== スコープの優先順位 ===")
name = "Global"

def scope_test():
    name = "Enclosing"
    
    def inner():
        name = "Local"
        print(f"inner()内: {name}")  # Local
    
    inner()
    print(f"scope_test()内: {name}")  # Enclosing

scope_test()
print(f"グローバル: {name}")  # Global

# 変数の解決
print("\n=== 変数の解決 ===")
x = "global x"

def test():
    # xを参照（グローバル変数）
    print(f"関数開始時のx: {x}")
    
    # 新しいローカル変数xを作成
    x = "local x"
    print(f"代入後のx: {x}")

test()
print(f"関数外のx: {x}")  # 変更されていない
```

### 【実行】スコープの可視化実験

```python
# scope_visualization.py

def visualize_scope():
    """スコープの可視化"""
    print("=== スコープの可視化 ===")
    
    # 各スコープで利用可能な名前を表示
    import builtins
    
    global_var = "グローバル"
    
    def outer():
        outer_var = "外側"
        
        def inner():
            inner_var = "内側"
            
            # ローカルスコープ
            print("ローカルスコープ:")
            local_names = [name for name in locals() if not name.startswith('_')]
            print(f"  {local_names}")
            
            # 外側のスコープの変数も見える
            print("\nアクセス可能な変数:")
            print(f"  inner_var: {inner_var}")
            print(f"  outer_var: {outer_var}")
            print(f"  global_var: {global_var}")
            
            # 組み込み関数の一部
            print("\n組み込み関数の例:")
            builtin_funcs = [name for name in dir(builtins) 
                           if not name.startswith('_')][:5]
            print(f"  {builtin_funcs}...")
        
        inner()
    
    outer()

visualize_scope()

# UnboundLocalError の例
print("\n=== UnboundLocalError ===")
counter = 0

def increment_wrong():
    # print(counter)  # この行があるとエラー
    counter = counter + 1  # UnboundLocalError
    return counter

try:
    increment_wrong()
except UnboundLocalError as e:
    print(f"エラー: {e}")
    print("理由: counterへの代入があるため、ローカル変数として扱われる")
```

## 12.2 global文とnonlocal文のBNF

### global文の構文

```bnf
<global文> ::= "global" <識別子> ("," <識別子>)*
```

### nonlocal文の構文

```bnf
<nonlocal文> ::= "nonlocal" <識別子> ("," <識別子>)*
```

### global文の使用

```python
# global_statement.py

# グローバル変数
counter = 0
message = "初期メッセージ"

def use_global():
    """global文の使用例"""
    global counter, message
    
    # グローバル変数を変更
    counter += 1
    message = f"カウンター: {counter}"
    print(f"関数内: {message}")

print("=== global文 ===")
print(f"実行前: counter={counter}, message='{message}'")

use_global()
print(f"1回目実行後: counter={counter}, message='{message}'")

use_global()
print(f"2回目実行後: counter={counter}, message='{message}'")

# globalなしで参照のみ
def read_global():
    """グローバル変数の参照（globalなし）"""
    print(f"counterの値: {counter}")  # 参照はOK
    # counter += 1  # これはUnboundLocalError

read_global()

# 関数内でのglobal宣言
def create_global():
    """関数内で新しいグローバル変数を作成"""
    global new_var
    new_var = "関数内で作成されたグローバル変数"

create_global()
print(f"\nnew_var: {new_var}")  # 関数外でもアクセス可能
```

### nonlocal文の使用

```python
# nonlocal_statement.py

def outer_function():
    """nonlocal文の使用例"""
    count = 0
    total = 0
    
    def increment():
        nonlocal count
        count += 1
        print(f"  increment: count = {count}")
    
    def add(value):
        nonlocal total
        total += value
        print(f"  add({value}): total = {total}")
    
    def get_stats():
        # nonlocalなしで参照
        return {'count': count, 'total': total}
    
    print("=== nonlocal文 ===")
    increment()
    increment()
    add(10)
    add(20)
    increment()
    
    return get_stats()

stats = outer_function()
print(f"\n最終結果: {stats}")

# ネストの深いnonlocal
def level1():
    x = 1
    
    def level2():
        nonlocal x
        x = 2
        
        def level3():
            nonlocal x
            x = 3
            print(f"    level3: x = {x}")
        
        level3()
        print(f"  level2: x = {x}")
    
    level2()
    print(f"level1: x = {x}")

print("\n=== ネストしたnonlocal ===")
level1()

# globalとnonlocalの違い
print("\n=== globalとnonlocalの違い ===")
global_x = "global"

def test_scopes():
    enclosing_x = "enclosing"
    
    def use_global():
        global global_x
        global_x = "modified by global"
        print(f"  use_global: global_x = '{global_x}'")
    
    def use_nonlocal():
        nonlocal enclosing_x
        enclosing_x = "modified by nonlocal"
        print(f"  use_nonlocal: enclosing_x = '{enclosing_x}'")
    
    print(f"実行前: enclosing_x = '{enclosing_x}'")
    use_global()
    use_nonlocal()
    print(f"実行後: enclosing_x = '{enclosing_x}'")

test_scopes()
print(f"グローバル: global_x = '{global_x}'")
```

## 12.3 【実行】クロージャの作成と変数キャプチャ

```python
# closure_demo.py

# 基本的なクロージャ
print("=== 基本的なクロージャ ===")
def make_multiplier(n):
    """n倍する関数を返す"""
    def multiplier(x):
        return x * n  # nを「キャプチャ」
    return multiplier

times3 = make_multiplier(3)
times5 = make_multiplier(5)

print(f"times3(10) = {times3(10)}")
print(f"times5(10) = {times5(10)}")

# クロージャの内部を確認
print(f"\ntimes3.__closure__ = {times3.__closure__}")
print(f"キャプチャされた値: {times3.__closure__[0].cell_contents}")

# カウンタークロージャ
print("\n=== カウンタークロージャ ===")
def make_counter(initial=0):
    """カウンターを作成"""
    count = initial
    
    def increment():
        nonlocal count
        count += 1
        return count
    
    def decrement():
        nonlocal count
        count -= 1
        return count
    
    def get_count():
        return count
    
    # 複数の関数を返す
    increment.get = get_count
    increment.dec = decrement
    return increment

counter1 = make_counter()
counter2 = make_counter(100)

print(f"counter1: {counter1()}, {counter1()}, {counter1()}")
print(f"counter2: {counter2()}, {counter2()}")
print(f"counter1の値: {counter1.get()}")
print(f"counter2の値: {counter2.get()}")

# 複数の変数をキャプチャ
print("\n=== 複数の変数をキャプチャ ===")
def make_bank_account(initial_balance):
    """銀行口座のシミュレーション"""
    balance = initial_balance
    transactions = []
    
    def deposit(amount):
        nonlocal balance
        if amount <= 0:
            raise ValueError("預金額は正の数である必要があります")
        balance += amount
        transactions.append(f"預金: +{amount}")
        return balance
    
    def withdraw(amount):
        nonlocal balance
        if amount <= 0:
            raise ValueError("引き出し額は正の数である必要があります")
        if amount > balance:
            raise ValueError("残高不足")
        balance -= amount
        transactions.append(f"引出: -{amount}")
        return balance
    
    def get_balance():
        return balance
    
    def get_statement():
        return {
            'balance': balance,
            'transactions': transactions.copy()
        }
    
    # 辞書として返す
    return {
        'deposit': deposit,
        'withdraw': withdraw,
        'balance': get_balance,
        'statement': get_statement
    }

# 使用例
account = make_bank_account(1000)
print(f"初期残高: {account['balance']()}")

account['deposit'](500)
account['withdraw'](200)
account['deposit'](300)

statement = account['statement']()
print(f"\n最終残高: {statement['balance']}")
print("取引履歴:")
for transaction in statement['transactions']:
    print(f"  {transaction}")

# クロージャの落とし穴
print("\n=== クロージャの落とし穴 ===")
functions = []
for i in range(5):
    def func():
        return i  # iは最後の値を参照
    functions.append(func)

print("期待と異なる結果:")
for f in functions:
    print(f(), end=' ')  # すべて4を返す

# 正しい実装
print("\n\n正しい実装:")
functions = []
for i in range(5):
    def make_func(n):
        def func():
            return n
        return func
    functions.append(make_func(i))

for f in functions:
    print(f(), end=' ')  # 0 1 2 3 4

# またはデフォルト引数を使用
print("\n\nデフォルト引数を使用:")
functions = []
for i in range(5):
    def func(n=i):  # デフォルト引数で値を固定
        return n
    functions.append(func)

for f in functions:
    print(f(), end=' ')  # 0 1 2 3 4
```

## 12.4 デコレータの文法

### 【実行】デコレータの実行順序と引数

```python
# decorator_syntax.py

# 基本的なデコレータ
print("=== 基本的なデコレータ ===")
def simple_decorator(func):
    """シンプルなデコレータ"""
    print(f"デコレータが{func.__name__}を装飾")
    
    def wrapper(*args, **kwargs):
        print(f"  {func.__name__}の実行前")
        result = func(*args, **kwargs)
        print(f"  {func.__name__}の実行後")
        return result
    
    return wrapper

@simple_decorator
def greet(name):
    print(f"    Hello, {name}!")
    return f"Greeted {name}"

# デコレータは関数定義時に実行される
print("\n関数を呼び出す:")
result = greet("Alice")
print(f"結果: {result}")

# 手動でのデコレータ適用
print("\n=== 手動でのデコレータ適用 ===")
def original_func():
    print("元の関数")

decorated_func = simple_decorator(original_func)
decorated_func()

# パラメータ付きデコレータ
print("\n=== パラメータ付きデコレータ ===")
def repeat(times):
    """指定回数繰り返すデコレータ"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            results = []
            for i in range(times):
                print(f"実行 {i+1}/{times}")
                result = func(*args, **kwargs)
                results.append(result)
            return results
        return wrapper
    return decorator

@repeat(times=3)
def say_hello():
    print("  Hello!")
    return "Done"

results = say_hello()
print(f"結果: {results}")

# 複数のデコレータ
print("\n=== 複数のデコレータ ===")
def bold(func):
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return f"**{result}**"
    return wrapper

def italic(func):
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return f"*{result}*"
    return wrapper

@bold
@italic
def text(s):
    return s

# 実行順序: bold(italic(text))
print(f"装飾されたテキスト: {text('Hello')}")

# 実行順序の確認
print("\n=== デコレータの実行順序 ===")
def decorator_a(func):
    print(f"デコレータA: {func.__name__}を装飾")
    def wrapper():
        print("  A: 実行前")
        result = func()
        print("  A: 実行後")
        return result
    wrapper.__name__ = f"a({func.__name__})"
    return wrapper

def decorator_b(func):
    print(f"デコレータB: {func.__name__}を装飾")
    def wrapper():
        print("    B: 実行前")
        result = func()
        print("    B: 実行後")
        return result
    wrapper.__name__ = f"b({func.__name__})"
    return wrapper

@decorator_a
@decorator_b
def target():
    print("      ターゲット関数")
    return "完了"

print(f"\n装飾後の関数名: {target.__name__}")
print("\n実行:")
result = target()
```

### 実用的なデコレータ

```python
# decorator_practical.py
import time
import functools
from typing import Any, Callable

# 実行時間計測デコレータ
print("=== 実行時間計測 ===")
def timeit(func: Callable) -> Callable:
    """関数の実行時間を計測"""
    @functools.wraps(func)  # 元の関数の情報を保持
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__}の実行時間: {end - start:.4f}秒")
        return result
    return wrapper

@timeit
def slow_function(n):
    """時間のかかる処理のシミュレーション"""
    time.sleep(0.1)
    return sum(range(n))

result = slow_function(1000000)
print(f"結果: {result}")

# メモ化デコレータ
print("\n=== メモ化デコレータ ===")
def memoize(func):
    """計算結果をキャッシュ"""
    cache = {}
    
    @functools.wraps(func)
    def wrapper(*args):
        if args in cache:
            print(f"  キャッシュから取得: {args}")
            return cache[args]
        
        print(f"  計算実行: {args}")
        result = func(*args)
        cache[args] = result
        return result
    
    wrapper.cache = cache  # キャッシュへのアクセスを提供
    return wrapper

@memoize
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(f"fib(10) = {fibonacci(10)}")
print(f"fib(15) = {fibonacci(15)}")  # 多くがキャッシュから
print(f"キャッシュサイズ: {len(fibonacci.cache)}")

# 型チェックデコレータ
print("\n=== 型チェックデコレータ ===")
def type_check(**expected_types):
    """引数の型をチェック"""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # 引数名を取得
            import inspect
            sig = inspect.signature(func)
            bound = sig.bind(*args, **kwargs)
            bound.apply_defaults()
            
            # 型チェック
            for name, expected_type in expected_types.items():
                if name in bound.arguments:
                    value = bound.arguments[name]
                    if not isinstance(value, expected_type):
                        raise TypeError(
                            f"{name}は{expected_type.__name__}型である必要があります。"
                            f"実際の型: {type(value).__name__}"
                        )
            
            return func(*args, **kwargs)
        return wrapper
    return decorator

@type_check(name=str, age=int)
def create_user(name, age):
    return {'name': name, 'age': age}

print(create_user("Alice", 25))
try:
    create_user("Bob", "25")  # 型エラー
except TypeError as e:
    print(f"エラー: {e}")

# リトライデコレータ
print("\n=== リトライデコレータ ===")
def retry(max_attempts=3, delay=1.0):
    """失敗時にリトライ"""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    print(f"  試行{attempt + 1}失敗: {e}")
                    time.sleep(delay)
            
        return wrapper
    return decorator

import random

@retry(max_attempts=3, delay=0.5)
def unreliable_operation():
    """50%の確率で失敗する操作"""
    if random.random() < 0.5:
        raise ValueError("ランダムエラー")
    return "成功！"

try:
    result = unreliable_operation()
    print(f"結果: {result}")
except ValueError as e:
    print(f"最終的に失敗: {e}")

# プロパティデコレータ
print("\n=== プロパティデコレータ ===")
class Temperature:
    def __init__(self):
        self._celsius = 0
    
    @property
    def celsius(self):
        """摂氏温度"""
        return self._celsius
    
    @celsius.setter
    def celsius(self, value):
        if value < -273.15:
            raise ValueError("絶対零度以下にはできません")
        self._celsius = value
    
    @property
    def fahrenheit(self):
        """華氏温度"""
        return self._celsius * 9/5 + 32
    
    @fahrenheit.setter
    def fahrenheit(self, value):
        self.celsius = (value - 32) * 5/9

temp = Temperature()
temp.celsius = 25
print(f"摂氏: {temp.celsius}°C")
print(f"華氏: {temp.fahrenheit}°F")

temp.fahrenheit = 86
print(f"摂氏: {temp.celsius}°C")
```

## 12.5 この章のまとめ

- PythonはLEGB規則に従って変数を解決する
- global文でグローバル変数を、nonlocal文で外側のスコープの変数を変更できる
- クロージャは外側のスコープの変数をキャプチャする
- デコレータは関数を装飾する強力な仕組み
- 複数のデコレータは内側から外側に向かって適用される

## 練習問題

1. **スコープパズル**
   以下のコードの出力を予想し、理由を説明してください：
   ```python
   x = 1
   def f():
       x = 2
       def g():
           global x
           x = 3
       g()
       return x
   print(f(), x)
   ```

2. **カウンタークロージャ**
   リセット機能付きのカウンターをクロージャで実装してください。

3. **キャッシュデコレータ**
   LRU（Least Recently Used）キャッシュを実装するデコレータを作成してください。

4. **権限チェックデコレータ**
   ユーザーの権限をチェックするデコレータを実装してください。

5. **デバッグデコレータ**
   関数の引数、戻り値、例外を記録するデバッグ用デコレータを作成してください。

---

次章では、モジュールとパッケージについて学びます。

[第13章 モジュールとパッケージ →](chapter13.md)