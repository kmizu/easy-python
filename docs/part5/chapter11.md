# 第11章：関数定義の文法と実行

## この章で学ぶこと

- def文のBNF定義
- 関数オブジェクトの作成と呼び出し
- パラメータリストの文法
- 位置引数、キーワード引数、デフォルト引数
- *argsと**kwargsの仕組み
- return文とyield文

## 11.1 def文のBNF定義

### 関数定義の構文

```bnf
<関数定義> ::= "def" <識別子> "(" [<パラメータリスト>] ")" ["->" <式>] ":" <スイート>
<パラメータリスト> ::= <パラメータ> ("," <パラメータ>)*
<パラメータ> ::= <識別子> [":" <式>] ["=" <式>]
              | "*" [<識別子>]
              | "**" <識別子>
```

### 【実行】関数オブジェクトの作成と呼び出し

```python
# function_basics.py

# 基本的な関数定義
def greet(name):
    """挨拶をする関数"""
    return f"Hello, {name}!"

# 関数オブジェクトの確認
print(f"関数名: {greet.__name__}")
print(f"ドキュメント: {greet.__doc__}")
print(f"型: {type(greet)}")
print(f"callable? {callable(greet)}")

# 関数の呼び出し
result = greet("Python")
print(f"\n呼び出し結果: {result}")

# 関数は第一級オブジェクト
print("\n=== 関数は第一級オブジェクト ===")
# 変数に代入
my_func = greet
print(f"my_func('World'): {my_func('World')}")

# リストに格納
functions = [greet, print, len]
for func in functions:
    print(f"{func.__name__}: {func}")

# 辞書に格納
operations = {
    'add': lambda x, y: x + y,
    'multiply': lambda x, y: x * y,
    'power': lambda x, y: x ** y
}

print(f"\n5 + 3 = {operations['add'](5, 3)}")
print(f"5 * 3 = {operations['multiply'](5, 3)}")
print(f"5 ** 3 = {operations['power'](5, 3)}")

# 関数を引数として渡す
def apply_twice(func, arg):
    """関数を2回適用する"""
    return func(func(arg))

def double(x):
    return x * 2

print(f"\napply_twice(double, 5): {apply_twice(double, 5)}")

# 関数を返す関数
def make_multiplier(n):
    """n倍する関数を作成"""
    def multiplier(x):
        return x * n
    return multiplier

times3 = make_multiplier(3)
times5 = make_multiplier(5)

print(f"\ntimes3(10): {times3(10)}")
print(f"times5(10): {times5(10)}")
```

## 11.2 パラメータリストの文法

### 【実行】位置引数、キーワード引数の実験

```python
# parameters_demo.py

# 様々なパラメータの組み合わせ
def full_example(
    pos_only1, pos_only2, /,  # 位置専用引数（Python 3.8+）
    normal1, normal2,          # 通常の引数
    *args,                     # 可変長位置引数
    kw_only1, kw_only2,       # キーワード専用引数
    **kwargs                   # 可変長キーワード引数
):
    """すべての種類のパラメータを持つ関数"""
    print(f"位置専用: pos_only1={pos_only1}, pos_only2={pos_only2}")
    print(f"通常: normal1={normal1}, normal2={normal2}")
    print(f"可変長位置: args={args}")
    print(f"キーワード専用: kw_only1={kw_only1}, kw_only2={kw_only2}")
    print(f"可変長キーワード: kwargs={kwargs}")

# 呼び出し例
print("=== 完全な例 ===")
full_example(
    1, 2,                    # 位置専用
    3, 4,                    # 通常
    5, 6, 7,                 # *args
    kw_only1=8, kw_only2=9,  # キーワード専用
    extra1=10, extra2=11     # **kwargs
)

# 位置引数とキーワード引数
print("\n=== 位置引数とキーワード引数 ===")
def greet(greeting, name, punctuation='!'):
    return f"{greeting}, {name}{punctuation}"

# 様々な呼び出し方
print(greet("Hello", "Alice"))
print(greet("Hello", "Bob", "?"))
print(greet("Hi", name="Charlie"))
print(greet(greeting="Hey", name="David", punctuation="."))

# 引数の順序
# print(greet(name="Eve", "Hello"))  # SyntaxError: 位置引数はキーワード引数の前

# 位置専用引数（Python 3.8+）
print("\n=== 位置専用引数 ===")
def divide(a, b, /):
    """位置引数のみで呼び出し可能"""
    return a / b

print(f"divide(10, 3): {divide(10, 3)}")
# print(divide(a=10, b=3))  # TypeError

# キーワード専用引数
print("\n=== キーワード専用引数 ===")
def create_user(*, username, email, active=True):
    """キーワード引数のみで呼び出し可能"""
    return {
        'username': username,
        'email': email,
        'active': active
    }

# print(create_user("john", "john@example.com"))  # TypeError
user = create_user(username="john", email="john@example.com")
print(f"ユーザー: {user}")

# 引数のアンパック
print("\n=== 引数のアンパック ===")
def add(a, b, c):
    return a + b + c

# タプルのアンパック
numbers = (1, 2, 3)
print(f"add(*numbers): {add(*numbers)}")

# 辞書のアンパック
params = {'a': 10, 'b': 20, 'c': 30}
print(f"add(**params): {add(**params)}")

# 組み合わせ
args = (1, 2)
kwargs = {'c': 3}
print(f"add(*args, **kwargs): {add(*args, **kwargs)}")
```

### 【実行】デフォルト引数の評価タイミング（ミュータブルの罠）

```python
# default_arguments.py
import time

# デフォルト引数の評価タイミング
print("=== デフォルト引数の評価タイミング ===")

def show_time(when=time.time()):
    """時刻を表示（バグあり）"""
    print(f"時刻: {when}")

# 関数定義時に評価される！
show_time()
time.sleep(1)
show_time()  # 同じ時刻が表示される

# 正しい実装
def show_time_correct(when=None):
    """時刻を表示（正しい実装）"""
    if when is None:
        when = time.time()
    print(f"時刻: {when}")

print("\n正しい実装:")
show_time_correct()
time.sleep(1)
show_time_correct()  # 異なる時刻

# ミュータブルなデフォルト引数の罠
print("\n=== ミュータブルなデフォルト引数 ===")

def append_to_list(item, target=[]):
    """リストに要素を追加（バグあり）"""
    target.append(item)
    return target

# 予期しない動作
list1 = append_to_list('a')
print(f"list1: {list1}")
list2 = append_to_list('b')
print(f"list2: {list2}")  # ['a', 'b']になってしまう！
print(f"list1 is list2: {list1 is list2}")

# デフォルト引数の確認
print(f"\nデフォルト引数の値: {append_to_list.__defaults__}")

# 正しい実装
def append_to_list_correct(item, target=None):
    """リストに要素を追加（正しい実装）"""
    if target is None:
        target = []
    target.append(item)
    return target

print("\n正しい実装:")
list3 = append_to_list_correct('x')
print(f"list3: {list3}")
list4 = append_to_list_correct('y')
print(f"list4: {list4}")

# 意図的にミュータブルなデフォルト引数を使う例
def memoize(func):
    """メモ化デコレータ"""
    cache = {}  # 関数定義時に作成
    
    def wrapper(n):
        if n not in cache:
            cache[n] = func(n)
            print(f"計算: {n}")
        return cache[n]
    
    wrapper.cache = cache  # キャッシュへのアクセスを提供
    return wrapper

@memoize
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print("\n=== メモ化の例 ===")
print(f"fib(5) = {fibonacci(5)}")
print(f"fib(10) = {fibonacci(10)}")
print(f"キャッシュ: {fibonacci.cache}")
```

## 11.3 *argsと**kwargsの文法

### 【実行】可変長引数の展開と辞書展開

```python
# args_kwargs.py

# *args: 可変長位置引数
print("=== *args ===")
def sum_all(*args):
    """すべての引数を合計"""
    print(f"args = {args}, type = {type(args)}")
    return sum(args)

print(sum_all(1, 2, 3))
print(sum_all(1, 2, 3, 4, 5))
print(sum_all())  # 引数なしもOK

# **kwargs: 可変長キーワード引数
print("\n=== **kwargs ===")
def print_info(**kwargs):
    """キーワード引数を表示"""
    print(f"kwargs = {kwargs}, type = {type(kwargs)}")
    for key, value in kwargs.items():
        print(f"  {key}: {value}")

print_info(name="Alice", age=30, city="Tokyo")
print_info()  # 引数なしもOK

# 組み合わせ
print("\n=== 組み合わせ ===")
def process_data(required, *args, default=None, **kwargs):
    """様々な引数の組み合わせ"""
    print(f"必須引数: {required}")
    print(f"追加の位置引数: {args}")
    print(f"デフォルト引数: {default}")
    print(f"追加のキーワード引数: {kwargs}")
    print()

process_data("必須")
process_data("必須", 1, 2, 3)
process_data("必須", 1, 2, default="値", x=10, y=20)

# 引数の転送
print("=== 引数の転送 ===")
def wrapper_function(*args, **kwargs):
    """すべての引数を別の関数に転送"""
    print("wrapper_functionが呼ばれました")
    print(f"  args: {args}")
    print(f"  kwargs: {kwargs}")
    # 元の関数を呼ぶ
    return original_function(*args, **kwargs)

def original_function(x, y, z=0):
    """元の関数"""
    return x + y + z

result = wrapper_function(10, 20, z=30)
print(f"結果: {result}")

# 実用例：ロギングデコレータ
print("\n=== 実用例：ロギングデコレータ ===")
def log_calls(func):
    """関数呼び出しをログに記録"""
    def wrapper(*args, **kwargs):
        args_repr = ', '.join(repr(arg) for arg in args)
        kwargs_repr = ', '.join(f'{k}={v!r}' for k, v in kwargs.items())
        signature = f"{func.__name__}({args_repr}"
        if kwargs_repr:
            signature += f", {kwargs_repr}"
        signature += ")"
        
        print(f"呼び出し: {signature}")
        result = func(*args, **kwargs)
        print(f"戻り値: {result!r}")
        return result
    
    return wrapper

@log_calls
def add(x, y):
    return x + y

@log_calls
def greet(name, greeting="Hello"):
    return f"{greeting}, {name}!"

add(3, 5)
greet("Alice")
greet("Bob", greeting="Hi")

# 引数の検証
print("\n=== 引数の検証 ===")
def validate_types(**expected_types):
    """型検証デコレータ"""
    def decorator(func):
        def wrapper(**kwargs):
            for name, expected_type in expected_types.items():
                if name in kwargs:
                    value = kwargs[name]
                    if not isinstance(value, expected_type):
                        raise TypeError(
                            f"{name}は{expected_type.__name__}型である必要があります"
                        )
            return func(**kwargs)
        return wrapper
    return decorator

@validate_types(name=str, age=int)
def create_person(*, name, age):
    return {'name': name, 'age': age}

print(create_person(name="Alice", age=30))
try:
    create_person(name="Bob", age="thirty")
except TypeError as e:
    print(f"エラー: {e}")
```

## 11.4 return文とyield文

### return文の動作

```python
# return_statement.py

# 基本的なreturn
print("=== 基本的なreturn ===")
def add(a, b):
    return a + b

result = add(3, 5)
print(f"add(3, 5) = {result}")

# 複数の値を返す
def divmod_custom(a, b):
    """商と余りを返す"""
    quotient = a // b
    remainder = a % b
    return quotient, remainder  # タプルとして返される

q, r = divmod_custom(17, 5)
print(f"\n17 ÷ 5 = {q} 余り {r}")

# 条件による早期return
def check_positive(n):
    """正の数かチェック"""
    if n <= 0:
        return False
    # ここ以降はn > 0が保証される
    print(f"{n}は正の数です")
    return True

print(f"\ncheck_positive(5): {check_positive(5)}")
print(f"check_positive(-3): {check_positive(-3)}")

# returnなしの関数
def no_return():
    x = 1 + 1

result = no_return()
print(f"\nno_return()の結果: {result}")  # None

# return文の式
def get_status(code):
    return "成功" if code == 200 else "エラー"

print(f"\nステータス200: {get_status(200)}")
print(f"ステータス404: {get_status(404)}")
```

### 【実行】ジェネレータ関数の動作追跡

```python
# yield_generator.py

# 基本的なジェネレータ
print("=== 基本的なジェネレータ ===")
def count_up_to(n):
    """0からnまでカウント"""
    print("ジェネレータ開始")
    i = 0
    while i <= n:
        print(f"  yield {i}")
        yield i
        print(f"  再開")
        i += 1
    print("ジェネレータ終了")

# ジェネレータオブジェクトの作成
gen = count_up_to(3)
print(f"gen = {gen}")
print(f"type(gen) = {type(gen)}")

# 値を一つずつ取得
print("\n手動でnext()を呼ぶ:")
print(f"next(gen) = {next(gen)}")
print(f"next(gen) = {next(gen)}")
print(f"next(gen) = {next(gen)}")
print(f"next(gen) = {next(gen)}")
try:
    next(gen)
except StopIteration:
    print("StopIteration例外")

# forループでの使用
print("\n\nforループで使用:")
for value in count_up_to(3):
    print(f"受け取った値: {value}")

# メモリ効率の比較
print("\n=== メモリ効率 ===")
import sys

# リスト（すべての値をメモリに保持）
def get_squares_list(n):
    return [i**2 for i in range(n)]

# ジェネレータ（必要に応じて値を生成）
def get_squares_gen(n):
    for i in range(n):
        yield i**2

n = 1000000
# リストのメモリ使用量
lst = get_squares_list(n)
print(f"リストのサイズ: {sys.getsizeof(lst):,} バイト")

# ジェネレータのメモリ使用量
gen = get_squares_gen(n)
print(f"ジェネレータのサイズ: {sys.getsizeof(gen)} バイト")

# 無限ジェネレータ
print("\n=== 無限ジェネレータ ===")
def fibonacci():
    """無限フィボナッチ数列"""
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

# 最初の10個を取得
fib = fibonacci()
fib_list = []
for _ in range(10):
    fib_list.append(next(fib))
print(f"フィボナッチ数列: {fib_list}")

# ジェネレータ式
print("\n=== ジェネレータ式 ===")
# リスト内包表記
squares_list = [x**2 for x in range(5)]
print(f"リスト内包表記: {squares_list}")

# ジェネレータ式
squares_gen = (x**2 for x in range(5))
print(f"ジェネレータ式: {squares_gen}")
print(f"値: {list(squares_gen)}")

# yield from（Python 3.3+）
print("\n=== yield from ===")
def nested_generator():
    yield from range(3)
    yield from "ABC"
    yield from [10, 20, 30]

for value in nested_generator():
    print(f"値: {value}")

# ジェネレータの状態
print("\n=== ジェネレータの状態 ===")
import inspect

def stateful_generator():
    print("状態1: 開始")
    yield 1
    print("状態2: 1を生成後")
    yield 2
    print("状態3: 2を生成後")

gen = stateful_generator()
print(f"作成直後: {inspect.getgeneratorstate(gen)}")

next(gen)
print(f"1回目のnext後: {inspect.getgeneratorstate(gen)}")

list(gen)  # 残りを消費
print(f"完了後: {inspect.getgeneratorstate(gen)}")
```

### ジェネレータの実用例

```python
# generator_practical.py

# ファイル処理
print("=== 大きなファイルの処理 ===")
def read_large_file(file_path, chunk_size=1024):
    """大きなファイルを少しずつ読む"""
    with open(file_path, 'r') as file:
        while True:
            chunk = file.read(chunk_size)
            if not chunk:
                break
            yield chunk

# 使用例（実際のファイルがある場合）
# for chunk in read_large_file('large_file.txt'):
#     process(chunk)

# パイプライン処理
print("=== データパイプライン ===")
def numbers():
    """数値を生成"""
    for i in range(1, 11):
        print(f"生成: {i}")
        yield i

def square(numbers):
    """数値を2乗"""
    for n in numbers:
        result = n ** 2
        print(f"  2乗: {n} -> {result}")
        yield result

def filter_even(numbers):
    """偶数のみフィルタ"""
    for n in numbers:
        if n % 2 == 0:
            print(f"    偶数: {n}")
            yield n

# パイプラインの構築
pipeline = filter_even(square(numbers()))
result = list(pipeline)
print(f"\n結果: {result}")

# コルーチン（双方向ジェネレータ）
print("\n=== コルーチン ===")
def averager():
    """平均値を計算するコルーチン"""
    total = 0
    count = 0
    average = None
    while True:
        value = yield average
        if value is None:
            break
        total += value
        count += 1
        average = total / count

# コルーチンの使用
avg = averager()
next(avg)  # コルーチンを開始（プライミング）

print(avg.send(10))
print(avg.send(20))
print(avg.send(30))
print(avg.send(40))

# 終了
try:
    avg.send(None)
except StopIteration:
    print("コルーチン終了")
```

## 11.5 関数アノテーション

```python
# function_annotations.py

# 関数アノテーション（Python 3.0+）
print("=== 関数アノテーション ===")
def greet(name: str, times: int = 1) -> str:
    """型ヒント付きの関数"""
    return (f"Hello, {name}! " * times).strip()

# アノテーションの確認
print(f"アノテーション: {greet.__annotations__}")

# 実行時には強制されない
result1 = greet("Alice", 2)
result2 = greet(123, "3")  # エラーにならない！
print(f"正しい型: {result1}")
print(f"間違った型: {result2}")

# より複雑なアノテーション
from typing import List, Dict, Tuple, Optional, Union, Callable

def process_data(
    data: List[int],
    transform: Callable[[int], int],
    filter_func: Optional[Callable[[int], bool]] = None
) -> Dict[str, Union[int, float]]:
    """データを処理して統計情報を返す"""
    if filter_func:
        data = [x for x in data if filter_func(x)]
    
    transformed = [transform(x) for x in data]
    
    return {
        'count': len(transformed),
        'sum': sum(transformed),
        'average': sum(transformed) / len(transformed) if transformed else 0
    }

# 使用例
numbers = [1, 2, 3, 4, 5]
result = process_data(
    data=numbers,
    transform=lambda x: x ** 2,
    filter_func=lambda x: x % 2 == 0
)
print(f"\n処理結果: {result}")

# カスタムアノテーション
def validate_range(min_val: int, max_val: int):
    """範囲検証用のカスタムアノテーション"""
    return {'min': min_val, 'max': max_val}

def set_temperature(
    temp: validate_range(0, 100)
) -> None:
    """温度を設定（0-100の範囲）"""
    print(f"温度を{temp}度に設定")

# アノテーションの活用
print(f"\nset_temperatureのアノテーション: {set_temperature.__annotations__}")
```

## 11.6 この章のまとめ

- 関数はdef文で定義され、第一級オブジェクトとして扱われる
- パラメータには位置引数、キーワード引数、デフォルト引数などがある
- *argsと**kwargsで可変長引数を扱える
- デフォルト引数は関数定義時に評価される（ミュータブルに注意）
- yield文でジェネレータ関数を作成できる
- 関数アノテーションで型情報を付与できる

## 練習問題

1. **デコレータの作成**
   関数の実行時間を測定するデコレータを作成してください。
   
2. **ジェネレータの実装**
   素数を無限に生成するジェネレータを実装してください。

3. **引数の検証**
   関数の引数が指定された条件を満たすかチェックするデコレータを作成してください。

4. **メモ化の実装**
   任意の関数をメモ化するデコレータを実装してください。
   LRUキャッシュのような機能も追加してください。

5. **コルーチンの活用**
   複数の統計値（平均、最大、最小、標準偏差）を同時に計算するコルーチンを実装してください。

---

次章では、スコープとクロージャについて詳しく学びます。

[第12章 スコープとクロージャ →](chapter12.md)