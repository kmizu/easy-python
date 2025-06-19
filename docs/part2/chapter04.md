# 第4章：リテラルと基本的なデータ型

## この章で学ぶこと

- 数値リテラル（整数・浮動小数点数）のBNF定義
- 様々な数値表記（2進数、16進数、指数表記）
- 文字列リテラルの完全な文法
- エスケープシーケンスとraw文字列
- ブール値とNone
- 型システムの基礎

## 4.1 リテラルとは

**リテラル**とは、プログラムに直接書かれた値のことです。

```python
age = 25          # 25 は整数リテラル
price = 19.99     # 19.99 は浮動小数点数リテラル
name = "Python"   # "Python" は文字列リテラル
```

変数は値を「入れる箱」で、リテラルは「箱に入れる値そのもの」です。

## 4.2 数値リテラルのBNF定義

### 整数リテラル

Pythonの整数リテラルの正式なBNF定義（簡略版）：

```bnf
<整数リテラル> ::= <10進整数> | <2進整数> | <8進整数> | <16進整数>
<10進整数> ::= <非ゼロ数字> {<数字>} | "0" {<ゼロ>}
<2進整数> ::= "0" ("b" | "B") <2進数字> {<2進数字>}
<8進整数> ::= "0" ("o" | "O") <8進数字> {<8進数字>}
<16進整数> ::= "0" ("x" | "X") <16進数字> {<16進数字>}

<数字> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
<非ゼロ数字> ::= "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
<2進数字> ::= "0" | "1"
<8進数字> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7"
<16進数字> ::= <数字> | "a" | "b" | "c" | "d" | "e" | "f" | "A" | "B" | "C" | "D" | "E" | "F"
```

### 【実行】様々な数値リテラルを試す

```python
# numbers_demo.py

# 10進数
decimal = 42
print(f"10進数: {decimal}")

# 2進数（0bまたは0B）
binary = 0b101010  # 42 in binary
print(f"2進数 0b101010 = {binary}")

# 8進数（0oまたは0O）
octal = 0o52  # 42 in octal
print(f"8進数 0o52 = {octal}")

# 16進数（0xまたは0X）
hexadecimal = 0x2A  # 42 in hexadecimal
print(f"16進数 0x2A = {hexadecimal}")

# 大文字小文字は区別されない
hex_upper = 0X2A
hex_lower = 0x2a
print(f"0X2A == 0x2a: {hex_upper == hex_lower}")

# 読みやすさのためのアンダースコア（Python 3.6+）
big_number = 1_000_000
binary_with_underscore = 0b1010_1010
print(f"1_000_000 = {big_number}")
print(f"0b1010_1010 = {binary_with_underscore}")
```

実行結果：

```
$ python3 numbers_demo.py
10進数: 42
2進数 0b101010 = 42
8進数 0o52 = 42
16進数 0x2A = 42
0X2A == 0x2a: True
1_000_000 = 1000000
0b1010_1010 = 170
```

### 浮動小数点数リテラル

```bnf
<浮動小数点数リテラル> ::= <小数部> [<指数部>]
<小数部> ::= <数字列> "." <数字列> | <数字列> "." | "." <数字列>
<指数部> ::= ("e" | "E") ["+" | "-"] <数字列>
<数字列> ::= <数字> {<数字>}
```

### 【実行】浮動小数点数と指数表記

```python
# float_demo.py

# 通常の小数
normal_float = 3.14159
print(f"通常の小数: {normal_float}")

# 小数点の前後の省略
no_fraction = 42.
no_integer = .5
print(f"42. = {no_fraction}")
print(f".5 = {no_integer}")

# 指数表記（科学的記数法）
scientific1 = 1.23e4    # 1.23 × 10^4 = 12300
scientific2 = 1.23E-4   # 1.23 × 10^-4 = 0.000123
print(f"1.23e4 = {scientific1}")
print(f"1.23E-4 = {scientific2}")

# 非常に大きな数/小さな数
avogadro = 6.022e23
planck = 6.626e-34
print(f"アボガドロ定数: {avogadro}")
print(f"プランク定数: {planck}")

# 特殊な浮動小数点数
infinity = float('inf')
neg_infinity = float('-inf')
not_a_number = float('nan')
print(f"無限大: {infinity}")
print(f"負の無限大: {neg_infinity}")
print(f"非数: {not_a_number}")
```

実行結果：

```
$ python3 float_demo.py
通常の小数: 3.14159
42. = 42.0
.5 = 0.5
1.23e4 = 12300.0
1.23E-4 = 0.000123
アボガドロ定数: 6.022e+23
プランク定数: 6.626e-34
無限大: inf
負の無限大: -inf
非数: nan
```

## 4.3 文字列リテラルのBNF

### 文字列リテラルの種類

Pythonの文字列リテラルは非常に柔軟です：

```bnf
<文字列リテラル> ::= <短い文字列> | <長い文字列>
<短い文字列> ::= "'" <短い文字列内容1> "'" | '"' <短い文字列内容2> '"'
<長い文字列> ::= "'''" <長い文字列内容1> "'''" | '"""' <長い文字列内容2> '"""'

<文字列プレフィックス> ::= "r" | "u" | "R" | "U" | "f" | "F" | "fr" | "Fr" | "fR" | "FR" | "rf" | "rF" | "Rf" | "RF"
```

### 【実行】文字列リテラルの種類

```python
# string_demo.py

# シングルクォート
single = 'Hello, World!'
print(f"シングルクォート: {single}")

# ダブルクォート
double = "Hello, World!"
print(f"ダブルクォート: {double}")

# 文字列内にクォートを含む
contains_single = "It's a beautiful day"
contains_double = 'She said "Hello"'
print(f"クォートを含む1: {contains_single}")
print(f"クォートを含む2: {contains_double}")

# トリプルクォート（複数行）
multiline = """これは
複数行にわたる
文字列です"""
print(f"複数行文字列:\n{multiline}")

# トリプルクォート（ドキュメント文字列として）
def my_function():
    """
    この関数は例示のためのものです。
    トリプルクォートはドキュメント文字列によく使われます。
    """
    pass

print(f"関数のドキュメント: {my_function.__doc__}")
```

### エスケープシーケンス

```bnf
<エスケープシーケンス> ::= "\" <エスケープ文字>
<エスケープ文字> ::= "n" | "t" | "r" | "\" | "'" | '"' | "a" | "b" | "f" | "v" | "0" | <8進数字>{1,3} | "x" <16進数字>{2} | "u" <16進数字>{4} | "U" <16進数字>{8}
```

### 【実行】エスケープシーケンスの実験、raw文字列

```python
# escape_demo.py

# 基本的なエスケープシーケンス
print("改行: Line1\nLine2")
print("タブ: Column1\tColumn2")
print("バックスラッシュ: C:\\Users\\Python")
print("クォート: He said \"Hello\"")

# 特殊な制御文字
print("\a")  # ベル音（環境による）
print("キャリッジリターン: ABC\rXYZ")  # ABCの上にXYZを上書き

# Unicode エスケープ
print("ハート: \u2665")
print("笑顔: \U0001F600")

# 8進数・16進数表記
print("8進数 \\101: \101")  # 'A'のASCIIコード
print("16進数 \\x41: \x41")  # 'A'のASCIIコード

# raw文字列（エスケープを無効化）
normal = "C:\new\text.txt"  # \n と \t がエスケープされる
raw = r"C:\new\text.txt"    # そのまま表示
print(f"通常文字列: {normal}")
print(f"raw文字列: {raw}")

# raw文字列の落とし穴
# raw = r"終端にバックスラッシュ\"  # エラー！
raw_ok = r"終端以外は大丈夫\ "
print(raw_ok)

# フォーマット済み文字列（f-string）とraw文字列の組み合わせ
path = "data"
formatted_raw = rf"C:\Users\{path}\file.txt"
print(f"f-string + raw: {formatted_raw}")
```

実行結果：

```
$ python3 escape_demo.py
改行: Line1
Line2
タブ: Column1    Column2
バックスラッシュ: C:\Users\Python
クォート: He said "Hello"

XYZ
ハート: ♥
笑顔: 😀
8進数 \101: A
16進数 \x41: A
通常文字列: C:
ew	ext.txt
raw文字列: C:\new\text.txt
終端以外は大丈夫\ 
f-string + raw: C:\Users\data\file.txt
```

## 4.4 ブール値とNone

### ブール値

```python
# bool_demo.py

# ブール値リテラル
true_value = True
false_value = False

print(f"True: {true_value}, type: {type(true_value)}")
print(f"False: {false_value}, type: {type(false_value)}")

# 大文字小文字は区別される
try:
    wrong = true  # NameError
except NameError as e:
    print(f"エラー: {e}")

# ブール値は実は整数のサブクラス
print(f"True == 1: {True == 1}")
print(f"False == 0: {False == 0}")
print(f"True + True: {True + True}")  # 2
print(f"isinstance(True, int): {isinstance(True, int)}")
```

### None

```python
# none_demo.py

# Noneは「値がない」ことを表す
nothing = None
print(f"None: {nothing}, type: {type(nothing)}")

# Noneは唯一の値（シングルトン）
none1 = None
none2 = None
print(f"none1 is none2: {none1 is none2}")  # True

# 関数が明示的に値を返さない場合もNone
def no_return():
    x = 1 + 1
    # returnがない

result = no_return()
print(f"返り値なしの関数: {result}")

# Noneのチェックは'is'を使う
if result is None:
    print("結果はNoneです")
```

## 4.5 【実行】type()関数で型を確認する

### 型システムの探索

```python
# types_demo.py

# 様々な値の型を確認
values = [
    42,                    # int
    3.14,                  # float
    "Hello",               # str
    True,                  # bool
    None,                  # NoneType
    [1, 2, 3],            # list
    (1, 2, 3),            # tuple
    {1, 2, 3},            # set
    {"a": 1, "b": 2},     # dict
    1 + 2j,               # complex
    b"bytes",             # bytes
    bytearray(b"data"),   # bytearray
]

for value in values:
    print(f"{str(value):20s} : {type(value).__name__}")

# 型の階層
print("\n型の階層:")
print(f"bool は int のサブクラス: {issubclass(bool, int)}")
print(f"int は object のサブクラス: {issubclass(int, object)}")

# 型変換
print("\n型変換:")
string_num = "123"
converted = int(string_num)
print(f'int("123") = {converted}, type: {type(converted).__name__}')

float_num = float("3.14")
print(f'float("3.14") = {float_num}, type: {type(float_num).__name__}')

# 型変換エラー
try:
    bad_conversion = int("12.3")
except ValueError as e:
    print(f"変換エラー: {e}")
```

実行結果：

```
$ python3 types_demo.py
42                   : int
3.14                 : float
Hello                : str
True                 : bool
None                 : NoneType
[1, 2, 3]            : list
(1, 2, 3)            : tuple
{1, 2, 3}            : set
{'a': 1, 'b': 2}     : dict
(1+2j)               : complex
b'bytes'             : bytes
bytearray(b'data')   : bytearray

型の階層:
bool は int のサブクラス: True
int は object のサブクラス: True

型変換:
int("123") = 123, type: int
float("3.14") = 3.14, type: float
変換エラー: invalid literal for int() with base 10: '12.3'
```

## 4.6 リテラルの内部表現

### 数値の精度と制限

```python
# precision_demo.py
import sys

# 整数の制限（Pythonでは事実上無制限）
big_int = 10**100
print(f"巨大な整数: {big_int}")
print(f"整数の最大値情報: {sys.maxsize}")

# 浮動小数点数の精度
print(f"\n浮動小数点数の情報:")
print(f"最大値: {sys.float_info.max}")
print(f"最小正規化数: {sys.float_info.min}")
print(f"イプシロン: {sys.float_info.epsilon}")

# 精度の限界
a = 0.1 + 0.1 + 0.1
b = 0.3
print(f"\n0.1 + 0.1 + 0.1 = {a}")
print(f"0.3 = {b}")
print(f"等しい？: {a == b}")
print(f"差: {abs(a - b)}")

# 正確な計算にはdecimalモジュール
from decimal import Decimal
d1 = Decimal('0.1') + Decimal('0.1') + Decimal('0.1')
d2 = Decimal('0.3')
print(f"\nDecimalで計算: {d1} == {d2}: {d1 == d2}")
```

## 4.7 この章のまとめ

- Pythonのリテラルには厳密なBNF定義がある
- 数値は10進、2進、8進、16進で表記できる
- 文字列は多様な記法とエスケープシーケンスを持つ
- raw文字列はエスケープを無効化する
- ブール値は整数のサブクラス
- Noneは「値がない」ことを表す特別な値
- 型システムは動的だが、明確な階層構造を持つ

## 練習問題

1. **数値リテラルの変換**
   42という値を2進数、8進数、16進数のリテラルで表現してください。

2. **エスケープシーケンスの練習**
   以下の出力を生成する文字列リテラルを書いてください：
   ```
   C:\Users\名前\Documents
   "Python"	'Programming'
   1行目
   2行目
   ```

3. **型の確認**
   以下の式の結果と型を予想し、実際に確認してください：
   ```python
   1 + 2.0
   True + 1
   "3" + "4"
   None or "default"
   ```

4. **BNFの理解**
   Pythonの識別子（変数名）の簡略BNFを書いてください。
   ヒント：英字またはアンダースコアで始まり、英数字とアンダースコアが続く

5. **文字列の実験**
   f-string、raw文字列、複数行文字列を組み合わせて、
   ファイルパスを含むSQLクエリを作成してください。

---

次章では、式（Expression）の文法と評価メカニズムについて詳しく学びます。

[第5章 式（Expression）の文法と評価 →](../part3/chapter05.md)