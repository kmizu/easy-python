# 第6章：変数と代入文

## この章で学ぶこと

- 識別子（identifier）のBNF規則
- 代入文のBNF定義と動作
- Pythonの名前空間とスコープの基礎
- 多重代入とアンパック
- オブジェクトの同一性とid()関数

## 6.1 識別子のBNF規則

### 識別子とは

**識別子**は、変数名、関数名、クラス名などに使われる名前です。

```bnf
<識別子> ::= <識別子開始> { <識別子継続> }
<識別子開始> ::= <文字> | "_"
<識別子継続> ::= <文字> | <数字> | "_"
<文字> ::= <小文字> | <大文字>
<小文字> ::= "a" | "b" | ... | "z"
<大文字> ::= "A" | "B" | ... | "Z"
<数字> ::= "0" | "1" | ... | "9"
```

### 【実行】有効/無効な変数名を試す

```python
# identifier_demo.py

# 有効な識別子
valid_names = [
    "x",
    "name",
    "user_name",
    "_private",
    "__dunder__",
    "camelCase",
    "PascalCase",
    "CONSTANT",
    "変数",  # Python 3ではUnicode文字も使える
    "π",
    "user123",
    "_",
]

print("=== 有効な識別子 ===")
for name in valid_names:
    try:
        exec(f"{name} = 'OK'")
        print(f"✓ {name}")
    except SyntaxError:
        print(f"✗ {name}")

# 無効な識別子
invalid_names = [
    "123user",      # 数字で始まる
    "user-name",    # ハイフンを含む
    "user name",    # スペースを含む
    "user.name",    # ドットを含む
    "class",        # 予約語
    "for",          # 予約語
]

print("\n=== 無効な識別子 ===")
for name in invalid_names:
    try:
        exec(f"{name} = 'NG'")
        print(f"✓ {name} （あれ？）")
    except SyntaxError as e:
        print(f"✗ {name}: {type(e).__name__}")

# 予約語の確認
import keyword
print(f"\n=== Python予約語（{len(keyword.kwlist)}個）===")
print(", ".join(sorted(keyword.kwlist)))
```

### 命名規則とスタイル

```python
# naming_conventions.py

# PEP 8 スタイルガイドに従った命名規則

# 変数名と関数名: snake_case
user_name = "Alice"
total_count = 42

def calculate_average(numbers):
    return sum(numbers) / len(numbers)

# クラス名: PascalCase
class UserAccount:
    pass

# 定数: UPPER_SNAKE_CASE
MAX_RETRY_COUNT = 3
PI = 3.14159

# プライベート（慣習）: 先頭にアンダースコア
_internal_value = "内部使用"

# 名前マングリング: 先頭に二重アンダースコア
class MyClass:
    def __init__(self):
        self.__private_attr = "プライベート"
        self._protected_attr = "保護"
        self.public_attr = "公開"

# 特殊メソッド（ダンダー）: 前後に二重アンダースコア
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __str__(self):
        return f"Point({self.x}, {self.y})"
```

## 6.2 代入文のBNF定義

### 基本的な代入文

```bnf
<代入文> ::= <ターゲットリスト> "=" <式リスト>
<ターゲットリスト> ::= <ターゲット> { "," <ターゲット> }
<ターゲット> ::= <識別子> | <属性参照> | <subscription> | <スライシング>
```

### 【実行】代入の右辺評価とメモリ上の動作

```python
# assignment_mechanism.py

# 基本的な代入
print("=== 基本的な代入 ===")
x = 42
print(f"x = {x}, id(x) = {id(x)}")

# 同じ値への代入
y = 42
print(f"y = {y}, id(y) = {id(y)}")
print(f"x is y: {x is y}")  # 小さい整数はキャッシュされる

# 異なるオブジェクト
a = [1, 2, 3]
b = [1, 2, 3]
print(f"\na = {a}, id(a) = {id(a)}")
print(f"b = {b}, id(b) = {id(b)}")
print(f"a is b: {a is b}")  # False
print(f"a == b: {a == b}")  # True

# 代入は参照のコピー
print("\n=== 代入は参照のコピー ===")
original = [1, 2, 3]
reference = original  # 参照をコピー
print(f"original: {original}, id: {id(original)}")
print(f"reference: {reference}, id: {id(reference)}")

reference.append(4)
print(f"reference.append(4)後:")
print(f"original: {original}")  # [1, 2, 3, 4]
print(f"reference: {reference}")  # [1, 2, 3, 4]

# 右辺の評価順序
print("\n=== 右辺の評価順序 ===")
def get_value(n):
    print(f"  get_value({n})が呼ばれました")
    return n * 10

x = get_value(1) + get_value(2) + get_value(3)
print(f"x = {x}")
```

### 複合代入演算子

```python
# compound_assignment.py

# 複合代入演算子
x = 10
print(f"初期値: x = {x}")

x += 5
print(f"x += 5: x = {x}")

x -= 3
print(f"x -= 3: x = {x}")

x *= 2
print(f"x *= 2: x = {x}")

x //= 4
print(f"x //= 4: x = {x}")

x **= 2
print(f"x **= 2: x = {x}")

# リストでの複合代入
lst = [1, 2, 3]
print(f"\n初期値: lst = {lst}")

lst += [4, 5]  # lst.extend([4, 5])と同じ
print(f"lst += [4, 5]: lst = {lst}")

lst *= 2  # リストを2回繰り返す
print(f"lst *= 2: lst = {lst}")

# 文字列での複合代入
text = "Hello"
text += " World"
print(f"\ntext = {text}")

# ビット演算の複合代入
n = 0b1010  # 10
print(f"\nn = 0b1010 ({n})")

n &= 0b1100  # AND
print(f"n &= 0b1100: n = 0b{n:04b} ({n})")

n |= 0b0011  # OR
print(f"n |= 0b0011: n = 0b{n:04b} ({n})")

n ^= 0b1111  # XOR
print(f"n ^= 0b1111: n = 0b{n:04b} ({n})")

n <<= 2  # 左シフト
print(f"n <<= 2: n = 0b{n:08b} ({n})")
```

## 6.3 【実行】多重代入とアンパックの実験

### 多重代入

```python
# multiple_assignment.py

# 基本的な多重代入
a = b = c = 100
print(f"a = {a}, b = {b}, c = {c}")
print(f"a is b is c: {a is b is c}")

# リストの多重代入（注意が必要）
x = y = [1, 2, 3]
print(f"\nx = {x}, y = {y}")
print(f"x is y: {x is y}")  # True（同じオブジェクト）

x.append(4)
print(f"x.append(4)後:")
print(f"x = {x}")  # [1, 2, 3, 4]
print(f"y = {y}")  # [1, 2, 3, 4] （yも変更される！）

# 独立したリストを作るには
x = [1, 2, 3]
y = [1, 2, 3]
# または
x = y = [1, 2, 3].copy()
```

### タプルアンパック

```python
# unpacking_demo.py

# 基本的なアンパック
print("=== 基本的なアンパック ===")
x, y = 10, 20
print(f"x = {x}, y = {y}")

# 値の交換（Pythonの特徴的な書き方）
x, y = y, x
print(f"交換後: x = {x}, y = {y}")

# リストのアンパック
coordinates = [3, 4]
x, y = coordinates
print(f"\n座標: x = {x}, y = {y}")

# ネストしたアンパック
data = ((1, 2), (3, 4))
(a, b), (c, d) = data
print(f"\na = {a}, b = {b}, c = {c}, d = {d}")

# 拡張アンパック（Python 3）
print("\n=== 拡張アンパック ===")
first, *rest = [1, 2, 3, 4, 5]
print(f"first = {first}, rest = {rest}")

*beginning, last = [1, 2, 3, 4, 5]
print(f"beginning = {beginning}, last = {last}")

first, *middle, last = [1, 2, 3, 4, 5]
print(f"first = {first}, middle = {middle}, last = {last}")

# アンダースコアで不要な値を無視
_, y, _ = [1, 2, 3]
print(f"\ny = {y} （他は無視）")

# 関数の戻り値のアンパック
def get_point():
    return 10, 20

x, y = get_point()
print(f"\n関数から: x = {x}, y = {y}")

# エラーケース
try:
    x, y = [1, 2, 3]  # 要素数が合わない
except ValueError as e:
    print(f"\nエラー: {e}")

try:
    x, y, z = [1, 2]  # 要素数が合わない
except ValueError as e:
    print(f"エラー: {e}")
```

### アンパックの高度な使い方

```python
# advanced_unpacking.py

# 辞書のアンパック
print("=== 辞書のアンパック ===")
person = {"name": "Alice", "age": 30}
# キーのアンパック
key1, key2 = person
print(f"キー: {key1}, {key2}")

# items()を使った値のアンパック
(k1, v1), (k2, v2) = person.items()
print(f"{k1}: {v1}, {k2}: {v2}")

# enumerate()とのアンパック
print("\n=== enumerate()との組み合わせ ===")
fruits = ["apple", "banana", "orange"]
for i, fruit in enumerate(fruits):
    print(f"{i}: {fruit}")

# zip()とのアンパック
print("\n=== zip()との組み合わせ ===")
names = ["Alice", "Bob", "Charlie"]
ages = [25, 30, 35]
for name, age in zip(names, ages):
    print(f"{name}: {age}歳")

# 関数の引数でのアンパック
print("\n=== 関数引数のアンパック ===")
def greet(first, last):
    return f"Hello, {first} {last}!"

# タプルのアンパック
name = ("John", "Doe")
print(greet(*name))

# 辞書のアンパック
kwargs = {"first": "Jane", "last": "Smith"}
print(greet(**kwargs))
```

## 6.4 【実行】id()関数でオブジェクトの同一性を確認

### オブジェクトの同一性

```python
# identity_demo.py
import sys

print("=== 整数の同一性 ===")
# 小さい整数はキャッシュされる（実装依存）
a = 256
b = 256
print(f"a = {a}, id(a) = {id(a)}")
print(f"b = {b}, id(b) = {id(b)}")
print(f"a is b: {a is b}")

# 大きい整数は通常別オブジェクト
a = 257
b = 257
print(f"\na = {a}, id(a) = {id(a)}")
print(f"b = {b}, id(b) = {id(b)}")
print(f"a is b: {a is b}")

print("\n=== 文字列の同一性 ===")
# 文字列のインターン
s1 = "hello"
s2 = "hello"
print(f"s1 is s2: {s1 is s2}")  # True（インターン）

# 動的に作成された文字列
s3 = "hel" + "lo"
print(f"s1 is s3: {s1 is s3}")  # True（最適化）

# 明示的なインターン
s4 = "".join(["h", "e", "l", "l", "o"])
print(f"s1 is s4: {s1 is s4}")  # False
s4_interned = sys.intern(s4)
print(f"s1 is s4_interned: {s1 is s4_interned}")  # True

print("\n=== 可変オブジェクトの同一性 ===")
list1 = [1, 2, 3]
list2 = [1, 2, 3]
list3 = list1

print(f"list1: id = {id(list1)}")
print(f"list2: id = {id(list2)}")
print(f"list3: id = {id(list3)}")
print(f"list1 is list2: {list1 is list2}")  # False
print(f"list1 is list3: {list1 is list3}")  # True

# コピーの種類
print("\n=== コピーの種類 ===")
import copy

original = [[1, 2], [3, 4]]
reference = original              # 参照
shallow = original.copy()        # 浅いコピー
deep = copy.deepcopy(original)  # 深いコピー

print(f"original: id = {id(original)}")
print(f"reference: id = {id(reference)}")
print(f"shallow: id = {id(shallow)}")
print(f"deep: id = {id(deep)}")

# 内部リストの同一性
print(f"\noriginal[0] is shallow[0]: {original[0] is shallow[0]}")  # True
print(f"original[0] is deep[0]: {original[0] is deep[0]}")        # False
```

## 6.5 代入文の特殊な形式

### 属性への代入

```python
# attribute_assignment.py

class Person:
    def __init__(self, name):
        self.name = name

# 属性への代入
person = Person("Alice")
print(f"初期値: {person.name}")

person.name = "Bob"  # 属性への代入
print(f"変更後: {person.name}")

# 新しい属性の追加（Pythonは動的）
person.age = 30
print(f"年齢: {person.age}")

# __dict__で属性を確認
print(f"\n属性辞書: {person.__dict__}")
```

### インデックスとスライスへの代入

```python
# index_slice_assignment.py

# インデックスへの代入
lst = [10, 20, 30, 40, 50]
print(f"元のリスト: {lst}")

lst[2] = 999
print(f"lst[2] = 999: {lst}")

# スライスへの代入
lst[1:4] = [200, 300, 400]
print(f"lst[1:4] = [200, 300, 400]: {lst}")

# スライスで要素数を変える
lst[2:4] = [111, 222, 333, 444]  # 2要素を4要素で置換
print(f"要素数変更: {lst}")

# スライスで削除
lst[1:3] = []  # 要素を削除
print(f"lst[1:3] = []: {lst}")

# ステップ付きスライスへの代入
lst = list(range(10))
lst[::2] = [99] * 5  # 偶数インデックスを99に
print(f"\nステップ付き: {lst}")

# 文字列は不変なのでエラー
try:
    text = "Hello"
    text[0] = "h"
except TypeError as e:
    print(f"\n文字列への代入エラー: {e}")
```

### セイウチ演算子（:=）

```python
# walrus_operator.py
# Python 3.8以降

# 通常の書き方
data = [1, 2, 3, 4, 5]
n = len(data)
if n > 3:
    print(f"データ数: {n}")

# セイウチ演算子を使った書き方
if (n := len(data)) > 3:
    print(f"データ数: {n}")

# whileループでの使用
print("\n入力を受け付けます（'quit'で終了）:")
# while (line := input("> ")) != "quit":
#     print(f"入力: {line}")

# リスト内包表記での使用
# 計算結果を再利用
results = [y for x in range(10) if (y := x**2) > 25]
print(f"\n25より大きい平方数: {results}")

# 正規表現でのパターンマッチ
import re
text = "Python 3.11 is great!"
if match := re.search(r'Python (\d+\.\d+)', text):
    print(f"バージョン: {match.group(1)}")
```

## 6.6 名前空間とスコープの基礎

### 名前空間の種類

```python
# namespace_basics.py

# グローバル名前空間
global_var = "グローバル変数"

def outer_function():
    # ローカル名前空間（outer_function）
    outer_var = "外側の変数"
    
    def inner_function():
        # ローカル名前空間（inner_function）
        inner_var = "内側の変数"
        
        # 各スコープの変数にアクセス
        print(f"inner_var: {inner_var}")
        print(f"outer_var: {outer_var}")
        print(f"global_var: {global_var}")
        
        # 組み込み名前空間
        print(f"len: {len}")
    
    inner_function()

outer_function()

# 名前空間の確認
print("\n=== 名前空間の確認 ===")
print(f"グローバル名前空間の一部: {list(globals().keys())[:5]}...")
print(f"組み込み名前空間の一部: {dir(__builtins__)[:5]}...")

def check_locals():
    x = 1
    y = 2
    print(f"ローカル名前空間: {locals()}")

check_locals()
```

## 6.7 この章のまとめ

- 識別子は文字またはアンダースコアで始まる
- 代入は右辺を評価してから左辺に束縛する
- 多重代入とアンパックで複数の値を扱える
- Pythonでは代入は参照のコピー
- id()関数でオブジェクトの同一性を確認できる
- 名前空間とスコープが変数の可視性を決定する

## 練習問題

1. **有効な識別子**
   以下のうち、有効なPython識別子はどれか：
   - `2nd_place`
   - `_private_var`
   - `class-name`
   - `__init__`
   - `import`

2. **値の交換**
   3つの変数a, b, cの値を、a→b、b→c、c→aのように循環的に入れ替えるコードを書いてください。

3. **アンパックの応用**
   リスト`[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]`から、最初の2つ、最後の2つ、残りの中央部分を別々の変数に代入してください。

4. **同一性の確認**
   以下のコードで`a is b`がTrueになるものとFalseになるものを予想し、確認してください：
   ```python
   a = 100; b = 100
   a = 1000; b = 1000
   a = "hello"; b = "hello"
   a = []; b = []
   a = (); b = ()
   ```

5. **代入文のBNF**
   拡張アンパックを含む代入文の簡略BNFを書いてください。

---

次章では、制御構造（if、for、while）の文法と実行フローを詳しく学びます。

[第7章 制御構造の文法と実行フロー →](chapter07.md)