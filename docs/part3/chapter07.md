# 第7章：制御構造の文法と実行フロー

## この章で学ぶこと

- if文のBNF定義と実行フロー
- while文とループ制御
- for文とイテラブルの仕組み
- break、continue、passの使い方
- match文（パターンマッチング）の文法

## 7.1 if文のBNF定義

### if文の構文

```bnf
<if文> ::= "if" <式> ":" <スイート> 
          { "elif" <式> ":" <スイート> }
          [ "else" ":" <スイート> ]
<スイート> ::= <単純文> | <改行> <インデント> <文>+ <デデント>
```

### 【実行】if-elif-elseの実行フローを追跡

```python
# if_flow_trace.py

def trace_if_flow(value):
    """if文の実行フローを可視化"""
    print(f"\n=== value = {value} の場合 ===")
    
    print("if value > 0: をチェック")
    if value > 0:
        print("  → True: 正の数ブロックを実行")
        result = "positive"
    elif value < 0:
        print("  → False: elif value < 0: をチェック")
        print("    → True: 負の数ブロックを実行")
        result = "negative"
    else:
        print("  → False: elif value < 0: をチェック")
        print("    → False: elseブロックを実行")
        result = "zero"
    
    print(f"結果: {result}")
    return result

# 様々な値でテスト
test_values = [5, -3, 0]
for val in test_values:
    trace_if_flow(val)

# ネストしたif文
print("\n=== ネストしたif文 ===")
def categorize_number(n):
    if n >= 0:
        if n == 0:
            return "ゼロ"
        elif n <= 10:
            return "小さい正の数"
        else:
            return "大きい正の数"
    else:
        if n >= -10:
            return "小さい負の数"
        else:
            return "大きい負の数"

for n in [-15, -5, 0, 5, 15]:
    print(f"{n}: {categorize_number(n)}")
```

### 条件式の真偽値

```python
# truthy_falsy.py

def check_truthiness(value):
    """値の真偽を確認"""
    if value:
        print(f"{repr(value)} は Truthy")
    else:
        print(f"{repr(value)} は Falsy")

print("=== Truthyな値 ===")
truthy_values = [
    True, 1, -1, 0.1, "Hello", [1], (1,), {1}, {"a": 1},
    object(), lambda x: x
]
for val in truthy_values:
    check_truthiness(val)

print("\n=== Falsyな値 ===")
falsy_values = [
    False, 0, 0.0, 0j, "", [], (), {}, set(), None
]
for val in falsy_values:
    check_truthiness(val)

# 実用的な例
print("\n=== 実用的な使い方 ===")
name = ""
greeting = f"Hello, {name}" if name else "Hello, stranger"
print(greeting)

items = []
if items:
    print(f"アイテム数: {len(items)}")
else:
    print("アイテムがありません")
```

## 7.2 while文のBNF定義

### while文の構文

```bnf
<while文> ::= "while" <式> ":" <スイート> [ "else" ":" <スイート> ]
```

### 【実行】無限ループとbreak

```python
# while_loop_demo.py
import time

# 基本的なwhileループ
print("=== カウントダウン ===")
count = 5
while count > 0:
    print(f"{count}...")
    count -= 1
print("発射！")

# 無限ループとbreak
print("\n=== 無限ループとbreak ===")
counter = 0
while True:  # 無限ループ
    counter += 1
    print(f"カウント: {counter}")
    
    if counter >= 3:
        print("breakで脱出")
        break
    
    time.sleep(0.5)

# else節付きwhile
print("\n=== else節付きwhile ===")
n = 5
while n > 0:
    print(f"n = {n}")
    n -= 1
else:
    print("正常終了（breakなし）")

# breakがある場合
n = 5
while n > 0:
    print(f"n = {n}")
    if n == 3:
        print("n == 3 でbreak")
        break
    n -= 1
else:
    print("この行は実行されない")

# センチネル値を使ったループ
print("\n=== センチネル値パターン ===")
data = [1, 2, 3, -1, 4, 5]  # -1がセンチネル値
index = 0
while index < len(data) and data[index] != -1:
    print(f"処理: {data[index]}")
    index += 1
```

### whileループの実用例

```python
# while_practical.py

# ユーザー入力の検証
def get_positive_number():
    """正の数を入力するまで繰り返す"""
    while True:
        try:
            value = float(input("正の数を入力してください: "))
            if value > 0:
                return value
            else:
                print("正の数を入力してください！")
        except ValueError:
            print("数値を入力してください！")

# リトライ処理
def retry_operation(max_attempts=3):
    """失敗した操作をリトライ"""
    attempts = 0
    while attempts < max_attempts:
        attempts += 1
        print(f"試行 {attempts}/{max_attempts}")
        
        # ここで実際の操作を行う（例として50%の確率で成功）
        import random
        if random.random() > 0.5:
            print("成功！")
            return True
        else:
            print("失敗...")
            
    print("最大試行回数に達しました")
    return False

# バイナリサーチの例
def binary_search(lst, target):
    """ソート済みリストからtargetを探す"""
    left = 0
    right = len(lst) - 1
    
    while left <= right:
        mid = (left + right) // 2
        if lst[mid] == target:
            return mid
        elif lst[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1  # 見つからない

# テスト
numbers = [1, 3, 5, 7, 9, 11, 13, 15]
target = 7
result = binary_search(numbers, target)
print(f"{target}のインデックス: {result}")
```

## 7.3 for文のBNF定義とイテラブル

### for文の構文

```bnf
<for文> ::= "for" <ターゲットリスト> "in" <式リスト> ":" <スイート>
           [ "else" ":" <スイート> ]
```

### 【実行】range()とenumerate()の動作

```python
# for_loop_demo.py

# range()の基本
print("=== range()の使い方 ===")
print("range(5):", list(range(5)))
print("range(2, 8):", list(range(2, 8)))
print("range(1, 10, 2):", list(range(1, 10, 2)))
print("range(10, 0, -1):", list(range(10, 0, -1)))

# forループでの使用
print("\n=== 基本的なforループ ===")
for i in range(5):
    print(f"i = {i}")

# enumerate()の使い方
print("\n=== enumerate() ===")
fruits = ["apple", "banana", "orange"]
for index, fruit in enumerate(fruits):
    print(f"{index}: {fruit}")

# 開始インデックスの指定
print("\nenumerate()で開始位置を指定:")
for index, fruit in enumerate(fruits, start=1):
    print(f"{index}. {fruit}")

# zip()の使い方
print("\n=== zip() ===")
names = ["Alice", "Bob", "Charlie"]
ages = [25, 30, 35]
cities = ["Tokyo", "Osaka", "Kyoto"]

for name, age, city in zip(names, ages, cities):
    print(f"{name} ({age}) - {city}")

# 長さが異なる場合
short_list = [1, 2]
long_list = ["a", "b", "c", "d"]
print("\n長さが異なるリストのzip:")
for x, y in zip(short_list, long_list):
    print(f"{x} - {y}")
```

### イテラブルプロトコル

```python
# iterable_protocol.py

# イテラブルとイテレータの違い
print("=== イテラブルとイテレータ ===")

# リストはイテラブル
lst = [1, 2, 3]
print(f"lst: {lst}")
print(f"iter(lst): {iter(lst)}")

# イテレータの取得と使用
iterator = iter(lst)
print(f"next(iterator): {next(iterator)}")  # 1
print(f"next(iterator): {next(iterator)}")  # 2
print(f"next(iterator): {next(iterator)}")  # 3
try:
    print(f"next(iterator): {next(iterator)}")  # StopIteration
except StopIteration:
    print("StopIteration例外が発生")

# forループの内部動作
print("\n=== forループの内部動作 ===")
lst = ["a", "b", "c"]
iterator = iter(lst)
while True:
    try:
        item = next(iterator)
        print(f"処理: {item}")
    except StopIteration:
        print("ループ終了")
        break

# カスタムイテラブルクラス
class CountDown:
    def __init__(self, start):
        self.start = start
    
    def __iter__(self):
        return CountDownIterator(self.start)

class CountDownIterator:
    def __init__(self, start):
        self.current = start
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.current <= 0:
            raise StopIteration
        self.current -= 1
        return self.current + 1

# 使用例
print("\n=== カスタムイテラブル ===")
for n in CountDown(5):
    print(f"カウント: {n}")
```

## 7.4 【実行】continue, passの違いを確認

```python
# loop_control.py

# continueの動作
print("=== continue文 ===")
for i in range(5):
    if i == 2:
        print(f"  i={i}でcontinue（以降をスキップ）")
        continue
    print(f"i = {i}")

# breakの動作
print("\n=== break文 ===")
for i in range(5):
    if i == 3:
        print(f"  i={i}でbreak（ループ終了）")
        break
    print(f"i = {i}")

# passの動作
print("\n=== pass文 ===")
for i in range(5):
    if i == 2:
        print(f"  i={i}でpass（何もしない）")
        pass
    print(f"i = {i}")

# ネストしたループでのbreak/continue
print("\n=== ネストしたループ ===")
for i in range(3):
    print(f"外側: i = {i}")
    for j in range(3):
        if i == 1 and j == 1:
            print(f"    内側でbreak (i={i}, j={j})")
            break  # 内側のループのみ終了
        print(f"  内側: j = {j}")

# else節との組み合わせ
print("\n=== else節との組み合わせ ===")
# breakなしの場合
for i in range(3):
    print(f"i = {i}")
else:
    print("正常終了（else節実行）")

# breakありの場合
for i in range(3):
    if i == 1:
        break
    print(f"i = {i}")
else:
    print("この行は実行されない")

# passの実用例
print("\n=== passの実用例 ===")
# 未実装の関数
def todo_function():
    pass  # 後で実装予定

# 空のクラス
class PlaceholderClass:
    pass

# 条件分岐での使用
x = 10
if x > 0:
    pass  # 正の場合は何もしない
else:
    x = -x  # 負の場合は符号を反転
```

## 7.5 match文（Python 3.10+）のBNF

### パターンマッチングの構文

```bnf
<match文> ::= "match" <式> ":" <改行> <インデント> <case>+ <デデント>
<case> ::= "case" <パターン> [ "if" <式> ] ":" <スイート>
<パターン> ::= <リテラルパターン> | <キャプチャパターン> | <ワイルドカード> | ...
```

### 【実行】パターンマッチングの実例

```python
# match_statement.py
# Python 3.10以降

def process_command(command):
    """コマンドをパターンマッチングで処理"""
    match command:
        case "quit" | "exit":
            print("プログラムを終了します")
            return False
        case "help":
            print("利用可能なコマンド: quit, help, move, set")
            return True
        case ["move", direction]:
            print(f"{direction}方向に移動")
            return True
        case ["move", x, y] if isinstance(x, int) and isinstance(y, int):
            print(f"座標({x}, {y})に移動")
            return True
        case ["set", key, value]:
            print(f"{key} = {value} を設定")
            return True
        case _:
            print(f"不明なコマンド: {command}")
            return True

# テスト
commands = [
    "help",
    "quit",
    ["move", "north"],
    ["move", 10, 20],
    ["set", "speed", 100],
    "unknown"
]

for cmd in commands:
    print(f"\nコマンド: {cmd}")
    process_command(cmd)

# より複雑なパターンマッチング
def analyze_data(data):
    """データ構造を解析"""
    match data:
        case int(n) if n < 0:
            return f"負の整数: {n}"
        case int(n):
            return f"正の整数: {n}"
        case float(f):
            return f"浮動小数点数: {f}"
        case str(s):
            return f"文字列: {s}"
        case []:
            return "空のリスト"
        case [x]:
            return f"単一要素のリスト: [{x}]"
        case [x, y]:
            return f"2要素のリスト: [{x}, {y}]"
        case [x, *rest]:
            return f"リスト: 最初={x}, 残り={rest}"
        case {"name": name, "age": age}:
            return f"人物: {name} ({age}歳)"
        case {"x": x, "y": y}:
            return f"座標: ({x}, {y})"
        case _:
            return f"その他: {type(data).__name__}"

# テストデータ
test_data = [
    -5, 42, 3.14, "Hello",
    [], [10], [1, 2], [1, 2, 3, 4],
    {"name": "Alice", "age": 30},
    {"x": 10, "y": 20},
    {"key": "value"}
]

print("\n=== データ構造の解析 ===")
for data in test_data:
    result = analyze_data(data)
    print(f"{data} → {result}")

# クラスパターン
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

def process_shape(shape):
    match shape:
        case Point(x=0, y=0):
            return "原点"
        case Point(x=0, y=y):
            return f"Y軸上の点 (0, {y})"
        case Point(x=x, y=0):
            return f"X軸上の点 ({x}, 0)"
        case Point(x=x, y=y):
            return f"点 ({x}, {y})"

# テスト
points = [
    Point(0, 0),
    Point(0, 5),
    Point(3, 0),
    Point(3, 4)
]

print("\n=== クラスパターン ===")
for p in points:
    result = process_shape(p)
    print(result)
```

## 7.6 制御構造のネストと組み合わせ

```python
# nested_control.py

# 複雑な制御構造の例
def find_prime_factors(n):
    """素因数分解"""
    factors = []
    d = 2
    
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    
    if n > 1:
        factors.append(n)
    
    return factors

print("=== 素因数分解 ===")
for num in [12, 17, 100, 2023]:
    factors = find_prime_factors(num)
    print(f"{num} = {' × '.join(map(str, factors))}")

# 多重ループの脱出
def find_in_matrix(matrix, target):
    """2次元配列から値を探す"""
    for i, row in enumerate(matrix):
        for j, value in enumerate(row):
            if value == target:
                return (i, j)
    return None

matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]

position = find_in_matrix(matrix, 5)
print(f"\n5の位置: {position}")

# フラグを使った複雑な制御
def complex_loop_control():
    """複雑なループ制御の例"""
    found = False
    
    for i in range(3):
        if found:
            break
        print(f"外側ループ: i = {i}")
        
        for j in range(3):
            if found:
                break
            print(f"  中間ループ: j = {j}")
            
            for k in range(3):
                print(f"    内側ループ: k = {k}")
                if i + j + k == 4:
                    print("      条件を満たしました！")
                    found = True
                    break

print("\n=== 多重ループの脱出 ===")
complex_loop_control()
```

## 7.7 この章のまとめ

- if文は条件に応じて処理を分岐する
- while文は条件が真の間ループを続ける
- for文はイテラブルオブジェクトを順に処理する
- break、continue、passでループを制御できる
- match文（Python 3.10+）で高度なパターンマッチングが可能
- 制御構造は自由にネストできる

## 練習問題

1. **FizzBuzz問題**
   1から100までの数字を出力し、3の倍数なら"Fizz"、5の倍数なら"Buzz"、
   両方の倍数なら"FizzBuzz"を出力してください。

2. **素数判定**
   与えられた数が素数かどうかを判定する関数を書いてください。
   while文とfor文の両方のバージョンを作成してください。

3. **リスト内包表記への変換**
   以下のコードをリスト内包表記で書き換えてください：
   ```python
   result = []
   for i in range(10):
       if i % 2 == 0:
           result.append(i ** 2)
   ```

4. **イテレータの実装**
   フィボナッチ数列を生成するイテレータクラスを実装してください。

5. **match文の活用**
   簡単な電卓プログラムをmatch文を使って実装してください。
   入力例: `["add", 3, 5]`, `["multiply", 4, 7]`

---

次章では、リスト（list）の文法と実行時動作について詳しく学びます。

[第8章 リスト（list）の文法と実行時動作 →](../part4/chapter08.md)