# 第9章：タプル、辞書、セットの文法と特性

## この章で学ぶこと

- タプル表示式のBNFとイミュータブル性
- 辞書表示式のBNFとハッシュテーブル
- 辞書内包表記とget()メソッド
- セット（集合）の文法と集合演算
- 各データ構造の使い分け

## 9.1 タプル表示式のBNF

### タプルの構文定義

```bnf
<タプル表示> ::= "(" [<式リスト>] ")"
<式リスト> ::= <式> ("," <式>)* [","]
```

### 【実行】タプルのイミュータブル性を確認

```python
# tuple_immutable.py

# タプルの作成
print("=== タプルの作成 ===")
empty = ()
single = (1,)  # カンマが必要！
single_no_comma = (1)  # これは整数
multiple = (1, 2, 3)
no_parens = 1, 2, 3  # 括弧は省略可能

print(f"empty: {empty}, type: {type(empty)}")
print(f"single: {single}, type: {type(single)}")
print(f"single_no_comma: {single_no_comma}, type: {type(single_no_comma)}")
print(f"multiple: {multiple}")
print(f"no_parens: {no_parens}")

# イミュータブル性のテスト
print("\n=== イミュータブル性 ===")
tup = (1, 2, 3)
print(f"元のタプル: {tup}")

try:
    tup[0] = 999
except TypeError as e:
    print(f"tup[0] = 999: エラー - {e}")

try:
    del tup[1]
except TypeError as e:
    print(f"del tup[1]: エラー - {e}")

# タプルのメソッド（少ない）
print("\n=== タプルのメソッド ===")
tup = (1, 2, 3, 2, 4, 2)
print(f"タプル: {tup}")
print(f"count(2): {tup.count(2)}")
print(f"index(3): {tup.index(3)}")

# タプルに含まれるミュータブルオブジェクト
print("\n=== ミュータブルな要素を含むタプル ===")
tup_with_list = ([1, 2], [3, 4])
print(f"元: {tup_with_list}")

# タプル自体は変更できない
try:
    tup_with_list[0] = [5, 6]
except TypeError as e:
    print(f"要素の置換: エラー - {e}")

# しかし、含まれるリストは変更可能
tup_with_list[0].append(3)
print(f"リストの変更後: {tup_with_list}")

# ハッシュ可能性
print("\n=== ハッシュ可能性 ===")
hashable_tup = (1, 2, "hello")
print(f"hash((1, 2, 'hello')): {hash(hashable_tup)}")

unhashable_tup = ([1, 2], 3)
try:
    hash(unhashable_tup)
except TypeError as e:
    print(f"hash(([1, 2], 3)): エラー - {e}")
```

### タプルの用途

```python
# tuple_usage.py

# 複数の値を返す関数
def divmod_custom(a, b):
    """商と余りを返す"""
    return a // b, a % b

quotient, remainder = divmod_custom(17, 5)
print(f"17 ÷ 5 = {quotient} 余り {remainder}")

# 名前付きタプル
from collections import namedtuple

Point = namedtuple('Point', ['x', 'y'])
p1 = Point(3, 4)
p2 = Point(0, 0)

print(f"\np1: {p1}")
print(f"p1.x: {p1.x}, p1.y: {p1.y}")
print(f"距離: {((p1.x - p2.x)**2 + (p1.y - p2.y)**2)**0.5}")

# 辞書のキーとして
print("\n=== 辞書のキーとして ===")
locations = {
    (35.6762, 139.6503): "東京",
    (34.6937, 135.5023): "大阪",
    (35.0116, 135.7681): "京都",
}

for coords, city in locations.items():
    print(f"{coords} -> {city}")

# アンパックとの組み合わせ
print("\n=== アンパック ===")
data = [
    ("Alice", 25, "Engineer"),
    ("Bob", 30, "Designer"),
    ("Charlie", 35, "Manager"),
]

for name, age, job in data:
    print(f"{name} ({age}) - {job}")

# タプルの比較
print("\n=== タプルの比較 ===")
t1 = (1, 2, 3)
t2 = (1, 2, 4)
t3 = (1, 3)

print(f"{t1} < {t2}: {t1 < t2}")
print(f"{t1} < {t3}: {t1 < t3}")
print(f"sorted: {sorted([t2, t1, t3])}")
```

## 9.2 辞書表示式のBNF

### 辞書の構文定義

```bnf
<辞書表示> ::= "{" [<キー値リスト>] "}"
<キー値リスト> ::= <キー値> ("," <キー値>)* [","]
<キー値> ::= <式> ":" <式>
```

### 【実行】辞書のハッシュテーブル実装を理解する

```python
# dict_hashtable.py

# 辞書の基本操作
print("=== 辞書の作成と基本操作 ===")
# 様々な作成方法
d1 = {'a': 1, 'b': 2, 'c': 3}
d2 = dict(a=1, b=2, c=3)
d3 = dict([('a', 1), ('b', 2), ('c', 3)])
d4 = dict(zip(['a', 'b', 'c'], [1, 2, 3]))

print(f"リテラル: {d1}")
print(f"キーワード: {d2}")
print(f"タプルのリスト: {d3}")
print(f"zip: {d4}")
print(f"すべて同じ？ {d1 == d2 == d3 == d4}")

# ハッシュ値の確認
print("\n=== ハッシュ値と衝突 ===")
keys = ['a', 'b', 'c', 'abc', 'bca', 'cab']
for key in keys:
    h = hash(key)
    print(f"hash('{key}'): {h:20d} (mod 8 = {h % 8})")

# 辞書の内部動作をシミュレート
class SimpleDict:
    """簡単な辞書の実装（教育用）"""
    def __init__(self, size=8):
        self.size = size
        self.keys = [None] * size
        self.values = [None] * size
        self.count = 0
    
    def _hash_index(self, key):
        """ハッシュ値からインデックスを計算"""
        return hash(key) % self.size
    
    def __setitem__(self, key, value):
        index = self._hash_index(key)
        print(f"  '{key}' -> index {index}", end="")
        
        # 線形探査で空きスロットを探す
        original_index = index
        while self.keys[index] is not None:
            if self.keys[index] == key:
                print(f" (更新)")
                self.values[index] = value
                return
            index = (index + 1) % self.size
            
        print(f" (新規)")
        self.keys[index] = key
        self.values[index] = value
        self.count += 1
        
        # 負荷率が高くなったらリサイズ（実際の辞書の動作）
        if self.count > self.size * 0.66:
            print(f"  リサイズ: {self.size} -> {self.size * 2}")
            self._resize()
    
    def _resize(self):
        old_keys = self.keys
        old_values = self.values
        self.size *= 2
        self.keys = [None] * self.size
        self.values = [None] * self.size
        self.count = 0
        
        for key, value in zip(old_keys, old_values):
            if key is not None:
                self[key] = value
    
    def __repr__(self):
        items = []
        for key, value in zip(self.keys, self.values):
            if key is not None:
                items.append(f"'{key}': {value}")
        return "{" + ", ".join(items) + "}"

# 簡単な辞書の動作確認
print("\n=== 簡易辞書の動作 ===")
sd = SimpleDict(size=4)
for key, value in [('a', 1), ('b', 2), ('c', 3), ('d', 4), ('e', 5)]:
    sd[key] = value
    print(f"  現在の状態: {sd}")

# 実際の辞書の順序保持（Python 3.7+）
print("\n=== 辞書の順序保持 ===")
d = {}
for letter in 'python':
    d[letter] = ord(letter)

print("挿入順序を保持:")
for key, value in d.items():
    print(f"  '{key}': {value}")
```

### 【実行】辞書内包表記とget()メソッド

```python
# dict_comprehension.py

# 辞書内包表記
print("=== 辞書内包表記 ===")

# 基本的な辞書内包表記
squares = {x: x**2 for x in range(6)}
print(f"平方数: {squares}")

# 条件付き
even_squares = {x: x**2 for x in range(10) if x % 2 == 0}
print(f"偶数の平方数: {even_squares}")

# 2つのリストから辞書を作成
keys = ['a', 'b', 'c']
values = [1, 2, 3]
d = {k: v for k, v in zip(keys, values)}
print(f"zip から: {d}")

# 既存の辞書を変換
original = {'a': 1, 'b': 2, 'c': 3}
doubled = {k: v * 2 for k, v in original.items()}
print(f"値を2倍: {doubled}")

# キーと値を入れ替え
inverted = {v: k for k, v in original.items()}
print(f"反転: {inverted}")

# get()メソッドとデフォルト値
print("\n=== get()メソッド ===")
d = {'apple': 3, 'banana': 5, 'orange': 2}

# 通常のアクセス vs get()
print(f"d['apple']: {d['apple']}")
print(f"d.get('apple'): {d.get('apple')}")

# 存在しないキー
try:
    print(d['grape'])
except KeyError as e:
    print(f"d['grape']: KeyError - {e}")

print(f"d.get('grape'): {d.get('grape')}")
print(f"d.get('grape', 0): {d.get('grape', 0)}")

# setdefault()メソッド
print("\n=== setdefault() ===")
# 値がない場合は設定して返す
count = d.setdefault('grape', 0)
print(f"setdefault('grape', 0): {count}")
print(f"辞書: {d}")

# すでに値がある場合は既存の値を返す
count = d.setdefault('apple', 10)
print(f"setdefault('apple', 10): {count}")
print(f"辞書: {d}")

# defaultdictの使用
from collections import defaultdict

print("\n=== defaultdict ===")
# リストをデフォルト値とする
dd = defaultdict(list)
data = [('fruits', 'apple'), ('fruits', 'banana'), 
        ('vegetables', 'carrot'), ('fruits', 'orange')]

for category, item in data:
    dd[category].append(item)

print("カテゴリ別:")
for category, items in dd.items():
    print(f"  {category}: {items}")

# カウンター
counter = defaultdict(int)
text = "hello world"
for char in text:
    counter[char] += 1

print(f"\n文字カウント: {dict(counter)}")
```

## 9.3 セット（集合）の文法

### セットの構文定義

```bnf
<セット表示> ::= "{" <式リスト> "}"
<セット内包表記> ::= "{" <式> <内包節>+ "}"
```

### 【実行】集合演算（和、積、差）の実行

```python
# set_operations.py

# セットの作成
print("=== セットの作成 ===")
# リテラル記法
s1 = {1, 2, 3, 4, 5}
print(f"リテラル: {s1}")

# set()関数
s2 = set([3, 4, 5, 6, 7])
s3 = set("hello")
s4 = set()  # 空集合（{}は空の辞書）

print(f"リストから: {s2}")
print(f"文字列から: {s3}")
print(f"空集合: {s4}")

# 重複の除去
print("\n=== 重複の除去 ===")
numbers = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
unique = set(numbers)
print(f"元のリスト: {numbers}")
print(f"重複除去: {unique}")
print(f"リストに戻す: {list(unique)}")

# 集合演算
print("\n=== 集合演算 ===")
a = {1, 2, 3, 4, 5}
b = {4, 5, 6, 7, 8}

print(f"A = {a}")
print(f"B = {b}")

# 和集合（Union）
union1 = a | b
union2 = a.union(b)
print(f"\nA | B = {union1}")
print(f"A.union(B) = {union2}")

# 積集合（Intersection）
intersection1 = a & b
intersection2 = a.intersection(b)
print(f"\nA & B = {intersection1}")
print(f"A.intersection(B) = {intersection2}")

# 差集合（Difference）
diff1 = a - b
diff2 = a.difference(b)
print(f"\nA - B = {diff1}")
print(f"A.difference(B) = {diff2}")

diff3 = b - a
print(f"B - A = {diff3}")

# 対称差（Symmetric Difference）
sym_diff1 = a ^ b
sym_diff2 = a.symmetric_difference(b)
print(f"\nA ^ B = {sym_diff1}")
print(f"A.symmetric_difference(B) = {sym_diff2}")

# 部分集合と上位集合
print("\n=== 部分集合の判定 ===")
x = {1, 2, 3}
y = {1, 2, 3, 4, 5}
z = {2, 3, 4}

print(f"X = {x}, Y = {y}, Z = {z}")
print(f"X <= Y (XはYの部分集合): {x <= y}")
print(f"X < Y (XはYの真部分集合): {x < y}")
print(f"X <= Z: {x <= z}")
print(f"X.issubset(Y): {x.issubset(y)}")
print(f"Y.issuperset(X): {y.issuperset(x)}")

# 素集合（disjoint）
print(f"\nX.isdisjoint(Z): {x.isdisjoint(z)}")
print(f"{1, 2}.isdisjoint({3, 4}): {{1, 2}}.isdisjoint({{3, 4}})")

# セットの更新操作
print("\n=== セットの更新 ===")
s = {1, 2, 3}
print(f"初期: {s}")

s.add(4)
print(f"add(4): {s}")

s.add(3)  # 既存の要素
print(f"add(3): {s}")

s.update([5, 6, 7])
print(f"update([5, 6, 7]): {s}")

s.remove(3)
print(f"remove(3): {s}")

try:
    s.remove(10)
except KeyError as e:
    print(f"remove(10): KeyError")

s.discard(10)  # エラーにならない
print(f"discard(10): {s}")

elem = s.pop()
print(f"pop(): {elem}, 残り: {s}")

# セット内包表記
print("\n=== セット内包表記 ===")
squares = {x**2 for x in range(10)}
print(f"平方数: {squares}")

even_squares = {x**2 for x in range(10) if x % 2 == 0}
print(f"偶数の平方数: {even_squares}")

# 文字列処理での活用
text = "Hello World"
unique_chars = {char.lower() for char in text if char.isalpha()}
print(f"ユニークな文字: {unique_chars}")
```

### frozenset（不変集合）

```python
# frozenset_demo.py

# frozensetの作成
print("=== frozenset ===")
fs1 = frozenset([1, 2, 3, 4, 5])
fs2 = frozenset({3, 4, 5, 6, 7})

print(f"fs1: {fs1}")
print(f"fs2: {fs2}")

# イミュータブル性
try:
    fs1.add(6)
except AttributeError as e:
    print(f"add()メソッドなし: {e}")

# 集合演算は可能（新しいfrozensetを返す）
print(f"\nfs1 | fs2: {fs1 | fs2}")
print(f"fs1 & fs2: {fs1 & fs2}")

# ハッシュ可能
print(f"\nhash(fs1): {hash(fs1)}")

# 辞書のキーとして使用可能
d = {
    frozenset([1, 2]): "グループA",
    frozenset([3, 4]): "グループB",
    frozenset([1, 2, 3]): "グループC"
}

for key, value in d.items():
    print(f"{key} -> {value}")

# セットのセット
print("\n=== セットのセット ===")
# 通常のセットはハッシュ不可能
try:
    s = {{1, 2}, {3, 4}}
except TypeError as e:
    print(f"セットのセット: エラー - {e}")

# frozensetなら可能
s = {frozenset([1, 2]), frozenset([3, 4]), frozenset([1, 2])}
print(f"frozensetのセット: {s}")
```

## 9.4 各データ構造の比較と使い分け

```python
# data_structure_comparison.py
import time
import random

# パフォーマンス比較
print("=== パフォーマンス比較 ===")
n = 100000
data = list(range(n))
random.shuffle(data)

# リスト
lst = list(data)
start = time.time()
for _ in range(1000):
    _ = random.randint(0, n-1) in lst
list_time = time.time() - start

# セット
st = set(data)
start = time.time()
for _ in range(1000):
    _ = random.randint(0, n-1) in st
set_time = time.time() - start

# 辞書
dct = {x: True for x in data}
start = time.time()
for _ in range(1000):
    _ = random.randint(0, n-1) in dct
dict_time = time.time() - start

print(f"検索時間（1000回）:")
print(f"  リスト: {list_time:.3f}秒")
print(f"  セット: {set_time:.3f}秒")
print(f"  辞書: {dict_time:.3f}秒")

# メモリ使用量
import sys
print(f"\nメモリ使用量（要素数: {n}）:")
print(f"  リスト: {sys.getsizeof(lst):,} バイト")
print(f"  セット: {sys.getsizeof(st):,} バイト")
print(f"  辞書: {sys.getsizeof(dct):,} バイト")

# 使い分けガイド
print("\n=== データ構造の使い分け ===")

use_cases = {
    "リスト": [
        "順序が重要",
        "インデックスアクセスが必要",
        "重複を許可",
        "スライス操作が必要"
    ],
    "タプル": [
        "不変性が必要",
        "辞書のキーとして使用",
        "関数の複数戻り値",
        "名前付きタプルでレコード表現"
    ],
    "辞書": [
        "キーと値のマッピング",
        "高速な検索（O(1)）",
        "順序を保持（Python 3.7+）",
        "JSONとの相互変換"
    ],
    "セット": [
        "重複の除去",
        "集合演算（和、積、差）",
        "高速なメンバーシップテスト",
        "順序は不要"
    ]
}

for structure, cases in use_cases.items():
    print(f"\n{structure}を使う場合:")
    for case in cases:
        print(f"  • {case}")

# 実例：単語カウント
print("\n=== 実例：単語カウント ===")
text = """
Python provides several built-in data structures.
Lists are ordered and mutable.
Tuples are ordered but immutable.
Dictionaries store key-value pairs.
Sets are unordered collections of unique elements.
"""

# 方法1：辞書を使用
word_count = {}
for word in text.lower().split():
    word = word.strip('.,')
    word_count[word] = word_count.get(word, 0) + 1

print("辞書を使った単語カウント:")
for word, count in sorted(word_count.items(), key=lambda x: x[1], reverse=True)[:5]:
    print(f"  {word}: {count}")

# 方法2：Counterを使用
from collections import Counter
words = [word.strip('.,') for word in text.lower().split()]
counter = Counter(words)

print("\nCounterを使った単語カウント:")
for word, count in counter.most_common(5):
    print(f"  {word}: {count}")
```

## 9.5 この章のまとめ

- タプルは不変のシーケンスで、辞書のキーやレコード表現に適している
- 辞書はハッシュテーブルによる高速な検索を提供
- セットは重複のない要素の集合で、集合演算が可能
- 各データ構造には明確な用途と特性がある
- 適切なデータ構造の選択がプログラムの効率を大きく左右する

## 練習問題

1. **タプルの活用**
   座標のリストから、原点からの距離でソートするプログラムを書いてください。
   座標は`(x, y)`のタプルで表現します。

2. **辞書の操作**
   2つの辞書をマージする3つの方法を実装し、それぞれの特徴を説明してください。

3. **集合演算の応用**
   2つのテキストファイルに共通する単語、片方にしかない単語を見つけるプログラムを書いてください。

4. **データ構造の変換**
   以下のデータ構造を相互に変換する関数を実装してください：
   - リストのタプル → 辞書
   - 辞書 → タプルのリスト
   - リスト → セット → ソート済みリスト

5. **効率的な実装**
   大量のデータから重複を数える最も効率的な方法を実装してください。
   `Counter`を使う方法と使わない方法の両方を実装し、比較してください。

---

次章では、文字列の高度な文法と処理について学びます。

[第10章 文字列の高度な文法と処理 →](chapter10.md)