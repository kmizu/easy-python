# 第8章：リスト（list）の文法と実行時動作

## この章で学ぶこと

- リスト表示式のBNF定義
- リストの作成とメモリ上の表現
- リスト内包表記の文法と利点
- インデックスとスライスの詳細
- リストの参照とコピーの仕組み

## 8.1 リスト表示式のBNF

### リストの構文定義

```bnf
<リスト表示> ::= "[" [<式リスト>] "]"
<式リスト> ::= <式> { "," <式> } [","]
```

### 【実行】リストの作成とメモリ上の表現

```python
# list_creation.py
import sys

# 様々なリストの作成方法
print("=== リストの作成方法 ===")

# 空のリスト
empty1 = []
empty2 = list()
print(f"[] : {empty1}")
print(f"list() : {empty2}")
print(f"[] is list() : {empty1 is empty2}")  # False（別オブジェクト）

# 要素を持つリスト
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True, None]
nested = [[1, 2], [3, 4], [5, 6]]

print(f"\n数値リスト: {numbers}")
print(f"混合型リスト: {mixed}")
print(f"ネストしたリスト: {nested}")

# リストのメモリ使用量
print("\n=== メモリ使用量 ===")
sizes = [0, 1, 10, 100, 1000]
for n in sizes:
    lst = list(range(n))
    size = sys.getsizeof(lst)
    print(f"要素数 {n:4d}: {size:5d} バイト")

# リストの内部構造
print("\n=== リストの内部構造 ===")
lst = [10, 20, 30]
print(f"リスト: {lst}")
print(f"id(lst): {id(lst)}")
print(f"要素のid:")
for i, item in enumerate(lst):
    print(f"  lst[{i}] = {item}, id = {id(item)}")

# リストは要素への参照を保持
a = [1, 2, 3]
b = a  # 同じリストオブジェクトを参照
c = [a, a]  # 同じリストを2回参照
print(f"\na: {a}, id: {id(a)}")
print(f"b: {b}, id: {id(b)}")
print(f"c: {c}")
print(f"c[0] is c[1]: {c[0] is c[1]}")
```

### リストの動的な性質

```python
# list_dynamic.py

# リストは動的にサイズが変わる
print("=== 動的なサイズ変更 ===")
lst = []
print(f"初期: {lst}, 長さ: {len(lst)}")

# 要素の追加
lst.append(10)
print(f"append(10): {lst}, 長さ: {len(lst)}")

lst.extend([20, 30])
print(f"extend([20, 30]): {lst}, 長さ: {len(lst)}")

lst.insert(1, 15)
print(f"insert(1, 15): {lst}, 長さ: {len(lst)}")

# 要素の削除
removed = lst.pop()
print(f"pop(): {lst}, 削除された値: {removed}")

lst.remove(15)
print(f"remove(15): {lst}")

# リストの容量（capacity）と長さ（length）
import sys
print("\n=== 容量の変化 ===")
lst = []
prev_size = 0
for i in range(20):
    lst.append(i)
    size = sys.getsizeof(lst)
    if size != prev_size:
        print(f"要素数 {len(lst):2d}: サイズ {size} バイト（+{size - prev_size}）")
        prev_size = size
```

## 8.2 リスト内包表記のBNF

### 内包表記の構文

```bnf
<リスト内包表記> ::= "[" <式> <内包節>+ "]"
<内包節> ::= "for" <ターゲットリスト> "in" <式> ["if" <式>]
```

### 【実行】内包表記と通常のループの速度比較

```python
# list_comprehension.py
import time

# 基本的なリスト内包表記
print("=== 基本的なリスト内包表記 ===")

# 通常のfor文
squares1 = []
for i in range(10):
    squares1.append(i ** 2)
print(f"for文: {squares1}")

# リスト内包表記
squares2 = [i ** 2 for i in range(10)]
print(f"内包表記: {squares2}")

# 条件付き内包表記
evens = [i for i in range(10) if i % 2 == 0]
print(f"\n偶数のみ: {evens}")

# ネストした内包表記
matrix = [[i + j for j in range(3)] for i in range(0, 9, 3)]
print(f"\n行列: {matrix}")

# 速度比較
print("\n=== 速度比較 ===")
n = 1000000

# 通常のfor文
start = time.time()
result1 = []
for i in range(n):
    result1.append(i ** 2)
time1 = time.time() - start

# リスト内包表記
start = time.time()
result2 = [i ** 2 for i in range(n)]
time2 = time.time() - start

print(f"for文: {time1:.3f} 秒")
print(f"内包表記: {time2:.3f} 秒")
print(f"速度比: {time1/time2:.2f}倍")

# 複雑な内包表記
print("\n=== 複雑な内包表記 ===")

# 多重ループ
coords = [(x, y) for x in range(3) for y in range(3)]
print(f"座標: {coords}")

# 条件の組み合わせ
filtered = [x for x in range(20) if x % 2 == 0 if x % 3 == 0]
print(f"2と3の倍数: {filtered}")

# 内包表記内での三項演算子
labeled = [f"even:{x}" if x % 2 == 0 else f"odd:{x}" for x in range(5)]
print(f"ラベル付き: {labeled}")
```

### 内包表記の読み方

```python
# comprehension_reading.py

# 内包表記を段階的に理解する
print("=== 内包表記の読み方 ===")

# ステップ1: 単純な変換
# [式 for 変数 in イテラブル]
simple = [x * 2 for x in [1, 2, 3]]
print(f"単純: {simple}")

# 等価なfor文
result = []
for x in [1, 2, 3]:
    result.append(x * 2)
print(f"for文版: {result}")

# ステップ2: 条件付き
# [式 for 変数 in イテラブル if 条件]
filtered = [x * 2 for x in [1, 2, 3, 4, 5] if x > 2]
print(f"\n条件付き: {filtered}")

# 等価なfor文
result = []
for x in [1, 2, 3, 4, 5]:
    if x > 2:
        result.append(x * 2)
print(f"for文版: {result}")

# ステップ3: ネストしたループ
# [式 for 外側変数 in 外側イテラブル for 内側変数 in 内側イテラブル]
nested = [f"{i}-{j}" for i in "AB" for j in "12"]
print(f"\nネスト: {nested}")

# 等価なfor文
result = []
for i in "AB":
    for j in "12":
        result.append(f"{i}-{j}")
print(f"for文版: {result}")

# 複雑な例の分解
print("\n=== 複雑な例の分解 ===")
# フラット化
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flattened = [num for row in matrix for num in row]
print(f"フラット化: {flattened}")

# 転置
transposed = [[row[i] for row in matrix] for i in range(len(matrix[0]))]
print(f"転置: {transposed}")
```

## 8.3 インデックスとスライスの文法

### インデックスアクセス

```python
# list_indexing.py

# 基本的なインデックスアクセス
lst = ['a', 'b', 'c', 'd', 'e']
print(f"リスト: {lst}")

print("\n=== 正のインデックス ===")
for i in range(len(lst)):
    print(f"lst[{i}] = '{lst[i]}'")

print("\n=== 負のインデックス ===")
for i in range(-1, -len(lst)-1, -1):
    print(f"lst[{i}] = '{lst[i]}'")

# インデックスエラー
print("\n=== インデックスエラー ===")
try:
    print(lst[10])
except IndexError as e:
    print(f"エラー: {e}")

try:
    print(lst[-10])
except IndexError as e:
    print(f"エラー: {e}")
```

### 【実行】スライスの様々なパターンと動作

```python
# list_slicing.py

lst = list(range(10))  # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
print(f"元のリスト: {lst}")

print("\n=== 基本的なスライス ===")
slices = [
    ("lst[2:5]", lst[2:5]),
    ("lst[:5]", lst[:5]),
    ("lst[5:]", lst[5:]),
    ("lst[:]", lst[:]),
    ("lst[-3:]", lst[-3:]),
    ("lst[:-3]", lst[:-3]),
]

for expr, result in slices:
    print(f"{expr:15s} = {result}")

print("\n=== ステップ付きスライス ===")
step_slices = [
    ("lst[::2]", lst[::2]),
    ("lst[1::2]", lst[1::2]),
    ("lst[::-1]", lst[::-1]),
    ("lst[2:8:2]", lst[2:8:2]),
    ("lst[8:2:-1]", lst[8:2:-1]),
    ("lst[::-2]", lst[::-2]),
]

for expr, result in step_slices:
    print(f"{expr:15s} = {result}")

# スライスオブジェクト
print("\n=== スライスオブジェクト ===")
s1 = slice(2, 7)
s2 = slice(None, None, -1)
s3 = slice(1, 8, 2)

print(f"slice(2, 7): {lst[s1]}")
print(f"slice(None, None, -1): {lst[s2]}")
print(f"slice(1, 8, 2): {lst[s3]}")

# スライスの属性
print(f"\ns1の属性: start={s1.start}, stop={s1.stop}, step={s1.step}")

# 空のスライス
print("\n=== 空のスライス ===")
empty_slices = [
    ("lst[5:5]", lst[5:5]),
    ("lst[10:20]", lst[10:20]),
    ("lst[5:2]", lst[5:2]),
]

for expr, result in empty_slices:
    print(f"{expr:15s} = {result}")
```

### スライスによる代入

```python
# slice_assignment.py

# スライスへの代入
print("=== スライスへの代入 ===")
lst = list(range(10))
print(f"元: {lst}")

# 同じ長さの置換
lst[2:5] = ['a', 'b', 'c']
print(f"lst[2:5] = ['a', 'b', 'c']: {lst}")

# 異なる長さの置換
lst = list(range(10))
lst[2:5] = ['X']
print(f"\nlst[2:5] = ['X']: {lst}")

lst = list(range(10))
lst[2:5] = ['A', 'B', 'C', 'D', 'E']
print(f"lst[2:5] = ['A', 'B', 'C', 'D', 'E']: {lst}")

# 挿入
lst = list(range(5))
lst[2:2] = ['inserted']
print(f"\n挿入 lst[2:2] = ['inserted']: {lst}")

# 削除
lst = list(range(10))
lst[2:7] = []
print(f"\n削除 lst[2:7] = []: {lst}")

# ステップ付きスライスへの代入
print("\n=== ステップ付きスライスへの代入 ===")
lst = list(range(10))
lst[::2] = ['A', 'B', 'C', 'D', 'E']
print(f"lst[::2] = ['A', 'B', 'C', 'D', 'E']: {lst}")

# エラーケース
try:
    lst = list(range(10))
    lst[::2] = ['X', 'Y']  # 長さが合わない
except ValueError as e:
    print(f"\nエラー: {e}")
```

## 8.4 【実行】リストメソッド（append, extend, insert等）の動作

```python
# list_methods.py

# 要素の追加メソッド
print("=== 要素の追加 ===")
lst = [1, 2, 3]
print(f"初期: {lst}")

# append: 末尾に1要素追加
lst.append(4)
print(f"append(4): {lst}")

lst.append([5, 6])  # リストも1要素として追加
print(f"append([5, 6]): {lst}")

# extend: イテラブルの要素を追加
lst = [1, 2, 3]
lst.extend([4, 5, 6])
print(f"\nextend([4, 5, 6]): {lst}")

lst.extend("abc")  # 文字列もイテラブル
print(f"extend('abc'): {lst}")

# insert: 指定位置に挿入
lst = [1, 2, 3, 4, 5]
lst.insert(2, 'X')
print(f"\ninsert(2, 'X'): {lst}")

lst.insert(0, 'start')
print(f"insert(0, 'start'): {lst}")

lst.insert(len(lst), 'end')
print(f"insert(len(lst), 'end'): {lst}")

# 要素の削除メソッド
print("\n=== 要素の削除 ===")
lst = [1, 2, 3, 4, 5, 3]
print(f"初期: {lst}")

# remove: 最初に見つかった値を削除
lst.remove(3)
print(f"remove(3): {lst}")

try:
    lst.remove(10)
except ValueError as e:
    print(f"remove(10): エラー - {e}")

# pop: インデックスの要素を削除して返す
lst = [1, 2, 3, 4, 5]
val = lst.pop()
print(f"\npop(): {lst}, 返り値: {val}")

val = lst.pop(1)
print(f"pop(1): {lst}, 返り値: {val}")

# clear: 全要素削除
lst_copy = lst.copy()
lst_copy.clear()
print(f"clear(): {lst_copy}")

# 検索とカウント
print("\n=== 検索とカウント ===")
lst = [1, 2, 3, 2, 4, 2, 5]
print(f"リスト: {lst}")

# index: 値の位置を検索
idx = lst.index(2)
print(f"index(2): {idx}")

idx = lst.index(2, 2)  # 開始位置指定
print(f"index(2, 2): {idx}")

try:
    idx = lst.index(10)
except ValueError as e:
    print(f"index(10): エラー - {e}")

# count: 値の出現回数
cnt = lst.count(2)
print(f"count(2): {cnt}")

# ソートと反転
print("\n=== ソートと反転 ===")
lst = [3, 1, 4, 1, 5, 9, 2, 6]
print(f"元: {lst}")

# sort: インプレースソート
lst.sort()
print(f"sort(): {lst}")

lst.sort(reverse=True)
print(f"sort(reverse=True): {lst}")

# キー関数を使ったソート
words = ['apple', 'pie', 'a', 'longer', 'word']
words.sort(key=len)
print(f"\n文字列長でソート: {words}")

# reverse: 反転
lst = [1, 2, 3, 4, 5]
lst.reverse()
print(f"\nreverse(): {lst}")
```

## 8.5 【実行】リストの参照とコピー（浅いコピーvs深いコピー）

```python
# list_copy.py
import copy

# 参照のコピー
print("=== 参照のコピー ===")
original = [1, 2, [3, 4]]
reference = original
print(f"original: {original}, id: {id(original)}")
print(f"reference: {reference}, id: {id(reference)}")
print(f"same object? {original is reference}")

reference[0] = 999
print(f"\nreference[0] = 999 後:")
print(f"original: {original}")
print(f"reference: {reference}")

# 浅いコピー
print("\n=== 浅いコピー ===")
original = [1, 2, [3, 4]]

# 様々な浅いコピーの方法
shallow1 = original.copy()
shallow2 = list(original)
shallow3 = original[:]
shallow4 = copy.copy(original)

print(f"original: {original}, id: {id(original)}")
print(f"shallow1: {shallow1}, id: {id(shallow1)}")
print(f"same object? {original is shallow1}")

# 外側のリストは別オブジェクト
shallow1[0] = 999
print(f"\nshallow1[0] = 999 後:")
print(f"original: {original}")
print(f"shallow1: {shallow1}")

# 内側のリストは同じオブジェクト
shallow1[2][0] = 888
print(f"\nshallow1[2][0] = 888 後:")
print(f"original: {original}")
print(f"shallow1: {shallow1}")

# 内部オブジェクトの同一性確認
print(f"\noriginal[2] is shallow1[2]: {original[2] is shallow1[2]}")

# 深いコピー
print("\n=== 深いコピー ===")
original = [1, 2, [3, 4, [5, 6]]]
deep = copy.deepcopy(original)

print(f"original: {original}")
print(f"deep: {deep}")
print(f"same object? {original is deep}")
print(f"same inner list? {original[2] is deep[2]}")
print(f"same innermost list? {original[2][2] is deep[2][2]}")

# 深いコピーは完全に独立
deep[2][2][0] = 999
print(f"\ndeep[2][2][0] = 999 後:")
print(f"original: {original}")
print(f"deep: {deep}")

# 循環参照の処理
print("\n=== 循環参照 ===")
circular = [1, 2, 3]
circular.append(circular)  # 自己参照
print(f"circular: {circular}")

# 深いコピーは循環参照も処理できる
deep_circular = copy.deepcopy(circular)
print(f"deep_circular: {deep_circular}")
print(f"circular[3] is circular: {circular[3] is circular}")
print(f"deep_circular[3] is deep_circular: {deep_circular[3] is deep_circular}")

# メモリ効率の比較
import sys
print("\n=== メモリ使用量 ===")
original = [[i] * 100 for i in range(100)]
shallow = original.copy()
deep = copy.deepcopy(original)

print(f"original size: {sys.getsizeof(original)} bytes")
print(f"shallow size: {sys.getsizeof(shallow)} bytes")
print(f"deep size: {sys.getsizeof(deep)} bytes")

# 内部リストのサイズ
inner_size_original = sum(sys.getsizeof(lst) for lst in original)
inner_size_deep = sum(sys.getsizeof(lst) for lst in deep)
print(f"inner lists (original): {inner_size_original} bytes")
print(f"inner lists (deep): {inner_size_deep} bytes")
```

## 8.6 リストのパフォーマンス特性

```python
# list_performance.py
import time
import random

# 操作の時間計算量
print("=== リスト操作の時間計算量 ===")

def measure_time(func, *args):
    """関数の実行時間を測定"""
    start = time.time()
    result = func(*args)
    end = time.time()
    return end - start, result

# append操作: O(1)
sizes = [10000, 100000, 1000000]
print("\nappend操作（償却O(1)）:")
for size in sizes:
    lst = []
    elapsed, _ = measure_time(lambda: [lst.append(i) for i in range(size)])
    print(f"  {size:7d}要素: {elapsed:.3f}秒 ({elapsed/size*1000000:.2f}μs/要素)")

# insert(0, x)操作: O(n)
print("\ninsert(0, x)操作（O(n)）:")
for size in [1000, 10000, 100000]:
    lst = list(range(size))
    elapsed, _ = measure_time(lambda: lst.insert(0, -1))
    print(f"  {size:7d}要素のリスト: {elapsed*1000:.3f}ms")

# in演算子: O(n)
print("\nin演算子（O(n)）:")
for size in sizes:
    lst = list(range(size))
    target = size - 1  # 最後の要素を探す
    elapsed, _ = measure_time(lambda: target in lst)
    print(f"  {size:7d}要素: {elapsed*1000:.3f}ms")

# インデックスアクセス: O(1)
print("\nインデックスアクセス（O(1)）:")
lst = list(range(1000000))
positions = [0, len(lst)//2, len(lst)-1]
for pos in positions:
    elapsed, _ = measure_time(lambda: lst[pos])
    print(f"  位置 {pos}: {elapsed*1000000:.2f}μs")

# リストvs集合の検索速度比較
print("\n=== リストvs集合の検索速度 ===")
data_size = 100000
search_count = 1000

lst = list(range(data_size))
st = set(range(data_size))
targets = random.sample(range(data_size), search_count)

# リストでの検索
start = time.time()
for target in targets:
    _ = target in lst
list_time = time.time() - start

# 集合での検索
start = time.time()
for target in targets:
    _ = target in st
set_time = time.time() - start

print(f"リスト検索: {list_time:.3f}秒")
print(f"集合検索: {set_time:.3f}秒")
print(f"速度比: {list_time/set_time:.1f}倍")
```

## 8.7 この章のまとめ

- リストは可変長の順序付きコンテナ
- リスト内包表記は簡潔で高速
- インデックスとスライスで柔軟なアクセスが可能
- 浅いコピーと深いコピーの違いを理解することが重要
- 操作によって計算量が異なる（append: O(1), insert(0): O(n)）

## 練習問題

1. **リスト内包表記の変換**
   以下のfor文をリスト内包表記に書き換えてください：
   ```python
   result = []
   for i in range(50):
       if i % 2 == 0 and i % 3 == 0:
           result.append(i ** 2)
   ```

2. **スライスパズル**
   リスト`[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]`から以下を取り出すスライスを書いてください：
   - 偶数インデックスの要素
   - 最後の3要素を逆順で
   - 中央の4要素

3. **コピーの理解**
   以下のコードの出力を予想し、理由を説明してください：
   ```python
   a = [[1, 2], [3, 4]]
   b = a[:]
   c = copy.deepcopy(a)
   a[0][0] = 999
   ```

4. **効率的なアルゴリズム**
   リストから重複を除去する3つの方法を実装し、速度を比較してください。

5. **カスタムリストクラス**
   負のインデックスを循環的に扱うリストクラスを実装してください。
   例：`lst[-1]`が最後の要素、`lst[-len(lst)-1]`が最後から2番目

---

次章では、タプル、辞書、セットの文法と特性について学びます。

[第9章 タプル、辞書、セットの文法と特性 →](chapter09.md)