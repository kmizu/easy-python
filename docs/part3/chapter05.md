# 第5章：式（Expression）の文法と評価

## この章で学ぶこと

- 式とは何か、文との違い
- 基本的な式のBNF定義
- 演算子の優先順位と結合性
- 短絡評価のメカニズム
- eval()を使った式の評価の理解

## 5.1 式と文の違い

### 式（Expression）とは

**式**は、評価されて値を生成するコードの断片です。

```python
# これらはすべて式
42                    # リテラル式
x + y                 # 算術式
len("Hello")          # 関数呼び出し式
x > 5 and y < 10      # 論理式
[1, 2, 3]            # リスト表示式
```

### 文（Statement）とは

**文**は、何らかの動作を実行するが、値を生成しないコードの単位です。

```python
# これらはすべて文
x = 10               # 代入文
if x > 5:            # if文
    print(x)
for i in range(3):   # for文
    pass
```

### 式と文の見分け方

```python
# expression_vs_statement.py

# 式は値を持つ（変数に代入できる）
result = 2 + 3        # 2 + 3 は式
result = len("test")  # len("test") は式

# 文は値を持たない（代入できない）
# result = (x = 10)  # エラー！代入文は式ではない
# result = if True:  # エラー！if文は式ではない

# Pythonでは式文（expression statement）も可能
2 + 3  # 結果は捨てられる
print("Hello")  # 関数呼び出し式を文として使用
```

## 5.2 基本的な式のBNF定義

### 算術式の簡略BNF

```bnf
<式> ::= <項> { ("+" | "-") <項> }
<項> ::= <因子> { ("*" | "/" | "//" | "%") <因子> }
<因子> ::= <べき乗> { "**" <因子> }
<べき乗> ::= <基本式> | "(" <式> ")"
<基本式> ::= <識別子> | <リテラル> | <関数呼び出し>
```

この定義により、演算子の優先順位が自然に表現されます。

## 5.3 【実行】算術演算子と優先順位の実験

### 演算子の優先順位

```python
# precedence_demo.py

# 優先順位の確認
print("優先順位の実験:")
print(f"2 + 3 * 4 = {2 + 3 * 4}")          # 14 (not 20)
print(f"(2 + 3) * 4 = {(2 + 3) * 4}")      # 20
print(f"2 ** 3 ** 2 = {2 ** 3 ** 2}")      # 512 (= 2^9)
print(f"(2 ** 3) ** 2 = {(2 ** 3) ** 2}")  # 64 (= 8^2)

# べき乗は右結合
print(f"\nべき乗の結合性:")
print(f"2 ** 3 ** 2 = 2 ** (3 ** 2) = {2 ** (3 ** 2)}")

# 単項演算子
print(f"\n単項演算子:")
print(f"-2 ** 2 = {-2 ** 2}")    # -4 (-(2**2))
print(f"(-2) ** 2 = {(-2) ** 2}")  # 4

# 除算の種類
print(f"\n除算の種類:")
print(f"7 / 2 = {7 / 2}")      # 3.5 (真の除算)
print(f"7 // 2 = {7 // 2}")    # 3 (整数除算)
print(f"7 % 2 = {7 % 2}")      # 1 (剰余)
print(f"-7 // 2 = {-7 // 2}")  # -4 (負の無限大方向へ)
```

実行結果：

```
$ python3 precedence_demo.py
優先順位の実験:
2 + 3 * 4 = 14
(2 + 3) * 4 = 20
2 ** 3 ** 2 = 512
(2 ** 3) ** 2 = 64

べき乗の結合性:
2 ** 3 ** 2 = 2 ** (3 ** 2) = 512

単項演算子:
-2 ** 2 = -4
(-2) ** 2 = 4

除算の種類:
7 / 2 = 3.5
7 // 2 = 3
7 % 2 = 1
-7 // 2 = -4
```

### 演算子優先順位表（高い順）

| 優先順位 | 演算子 | 説明 |
|---------|--------|------|
| 1 | `**` | べき乗（右結合） |
| 2 | `+x`, `-x`, `~x` | 単項演算子 |
| 3 | `*`, `/`, `//`, `%` | 乗除算 |
| 4 | `+`, `-` | 加減算 |
| 5 | `<<`, `>>` | ビットシフト |
| 6 | `&` | ビットAND |
| 7 | `^` | ビットXOR |
| 8 | `\|` | ビットOR |
| 9 | `<`, `<=`, `>`, `>=`, `!=`, `==` | 比較 |
| 10 | `not` | 論理NOT |
| 11 | `and` | 論理AND |
| 12 | `or` | 論理OR |

## 5.4 【実行】比較演算子の連鎖

Pythonの特徴的な機能として、比較演算子の連鎖があります：

```python
# comparison_chain.py

# 通常の比較
x = 5
print(f"3 < x < 10: {3 < x < 10}")  # True
print(f"これは (3 < x) and (x < 10) と同じ")

# 複数の連鎖
a, b, c = 1, 2, 3
print(f"\n1 < 2 < 3 < 4: {1 < 2 < 3 < 4}")  # True
print(f"a < b < c: {a < b < c}")  # True
print(f"a < b > 0: {a < b > 0}")  # True

# 等価性の連鎖
x = y = z = 5
print(f"\nx == y == z: {x == y == z}")  # True

# 連鎖の落とし穴
print(f"\n連鎖の注意点:")
print(f"False == False == True: {False == False == True}")  # False!
# これは (False == False) and (False == True) と解釈される

# 式は一度だけ評価される
def get_value():
    print("get_value()が呼ばれました")
    return 5

print(f"\n3 < get_value() < 10:")
result = 3 < get_value() < 10  # get_value()は1回だけ呼ばれる
print(f"結果: {result}")
```

## 5.5 論理演算子と短絡評価

### 【実行】短絡評価の動作確認

```python
# short_circuit.py

def true_func():
    print("true_func()が呼ばれました")
    return True

def false_func():
    print("false_func()が呼ばれました")
    return False

print("=== AND演算子の短絡評価 ===")
print("False and true_func():")
result = False and true_func()  # true_func()は呼ばれない
print(f"結果: {result}\n")

print("True and false_func():")
result = True and false_func()  # false_func()は呼ばれる
print(f"結果: {result}\n")

print("=== OR演算子の短絡評価 ===")
print("True or false_func():")
result = True or false_func()  # false_func()は呼ばれない
print(f"結果: {result}\n")

print("False or true_func():")
result = False or true_func()  # true_func()は呼ばれる
print(f"結果: {result}\n")

# 実用的な例
print("=== 実用的な使い方 ===")
# デフォルト値の設定
name = ""
display_name = name or "匿名ユーザー"
print(f"表示名: {display_name}")

# 安全なアクセス
data = {"key": "value"}
# キーが存在する場合のみアクセス
result = "key" in data and data["key"]
print(f"結果: {result}")

# Noneチェック
def get_data():
    return None

data = get_data()
# dataがNoneでない場合のみlen()を呼ぶ
length = data and len(data)
print(f"長さ: {length}")  # None
```

### 論理演算子の返り値

Pythonの論理演算子は、必ずしもTrue/Falseを返すわけではありません：

```python
# logical_return_values.py

# andは最初のFalsy値または最後の値を返す
print("=== AND演算子の返り値 ===")
print(f"'hello' and 'world': {'hello' and 'world'}")  # 'world'
print(f"'' and 'world': {'' and 'world'}")            # ''
print(f"0 and 42: {0 and 42}")                        # 0
print(f"[1, 2] and [3, 4]: {[1, 2] and [3, 4]}")     # [3, 4]

# orは最初のTruthy値または最後の値を返す
print("\n=== OR演算子の返り値 ===")
print(f"'' or 'default': {'' or 'default'}")          # 'default'
print(f"'value' or 'default': {'value' or 'default'}")# 'value'
print(f"0 or 42: {0 or 42}")                          # 42
print(f"[] or [1, 2]: {[] or [1, 2]}")                # [1, 2]

# Falsy値の一覧
print("\n=== Falsy値 ===")
falsy_values = [False, None, 0, 0.0, '', [], {}, set(), ()]
for value in falsy_values:
    print(f"bool({repr(value)}): {bool(value)}")
```

## 5.6 演算子の結合性

### 左結合と右結合

```python
# associativity.py

# 左結合の例（ほとんどの演算子）
print("=== 左結合 ===")
print(f"10 - 5 - 2 = {10 - 5 - 2}")        # 3 ((10-5)-2)
print(f"10 / 5 / 2 = {10 / 5 / 2}")        # 1.0 ((10/5)/2)

# 右結合の例（べき乗）
print("\n=== 右結合 ===")
print(f"2 ** 3 ** 2 = {2 ** 3 ** 2}")      # 512 (2**(3**2))

# 代入も右結合（連鎖代入）
a = b = c = 10
print(f"\na = b = c = 10")
print(f"a={a}, b={b}, c={c}")

# 複雑な式の評価順序
print("\n=== 評価順序の追跡 ===")
def trace(name, value):
    print(f"  {name} = {value}")
    return value

result = trace("A", 2) + trace("B", 3) * trace("C", 4)
print(f"結果: {result}")
```

## 5.7 【実行】eval()で式の評価過程を理解する

### eval()関数の基本

```python
# eval_demo.py

# eval()は文字列を式として評価
expression = "2 + 3 * 4"
result = eval(expression)
print(f"eval('{expression}') = {result}")

# 変数を含む式
x = 10
y = 20
expression = "x + y * 2"
result = eval(expression)
print(f"x={x}, y={y}")
print(f"eval('{expression}') = {result}")

# 名前空間の指定
namespace = {"a": 5, "b": 3}
result = eval("a ** b", namespace)
print(f"\neval('a ** b', {namespace}) = {result}")

# 複雑な式
expressions = [
    "sum([1, 2, 3, 4, 5])",
    "[x**2 for x in range(5)]",
    "'hello'.upper()",
    "len('Python') > 5",
    "1 if True else 0"
]

print("\n複雑な式の評価:")
for expr in expressions:
    result = eval(expr)
    print(f"eval('{expr}') = {result}")
```

### eval()を使った式の解析

```python
# expression_analyzer.py
import ast

def analyze_expression(expr_str):
    """式の構造を解析して表示"""
    print(f"\n式: {expr_str}")
    
    # 評価結果
    try:
        result = eval(expr_str)
        print(f"結果: {result}")
    except Exception as e:
        print(f"エラー: {e}")
        return
    
    # AST（抽象構文木）の表示
    tree = ast.parse(expr_str, mode='eval')
    print("構文木:")
    print(ast.dump(tree, indent=2))

# 様々な式を解析
expressions = [
    "2 + 3",
    "2 + 3 * 4",
    "x if x > 0 else -x",  # 条件式
    "[x**2 for x in range(3)]",  # リスト内包表記
    "lambda x: x * 2",  # ラムダ式
]

# 変数の準備
x = 5

for expr in expressions:
    analyze_expression(expr)
```

!!! warning "eval()の危険性"
    `eval()`は任意のPythonコードを実行できるため、信頼できない入力に対して使用すると危険です：
    ```python
    # 危険な例
    user_input = "__import__('os').system('rm -rf /')"  # 絶対に実行しないで！
    # eval(user_input)  # システムを破壊する可能性
    ```

## 5.8 式の種類と例

### Pythonの様々な式

```python
# expression_types.py

print("=== リテラル式 ===")
print(42)
print("Hello")
print([1, 2, 3])

print("\n=== 算術式 ===")
print(10 + 20)
print(3.14 * 2)
print(2 ** 10)

print("\n=== 比較式 ===")
print(5 > 3)
print("apple" < "banana")
print(10 <= 10)

print("\n=== 論理式 ===")
print(True and False)
print(not False)
print(1 < 2 or 3 > 4)

print("\n=== メンバーシップ式 ===")
print(3 in [1, 2, 3, 4])
print("a" not in "hello")

print("\n=== アイデンティティ式 ===")
a = [1, 2, 3]
b = a
c = [1, 2, 3]
print(f"a is b: {a is b}")  # True（同じオブジェクト）
print(f"a is c: {a is c}")  # False（異なるオブジェクト）
print(f"a == c: {a == c}")  # True（値は同じ）

print("\n=== 条件式（三項演算子）===")
x = 5
result = "positive" if x > 0 else "non-positive"
print(result)

print("\n=== ラムダ式 ===")
square = lambda x: x ** 2
print(f"square(5) = {square(5)}")

print("\n=== 呼び出し式 ===")
print(len("Python"))
print(max(1, 2, 3))

print("\n=== 属性参照式 ===")
text = "hello"
print(text.upper())
print(text.startswith("he"))

print("\n=== インデックス/スライス式 ===")
lst = [10, 20, 30, 40, 50]
print(f"lst[2] = {lst[2]}")
print(f"lst[1:4] = {lst[1:4]}")
print(f"lst[::2] = {lst[::2]}")
```

## 5.9 この章のまとめ

- 式は値を生成し、文は動作を実行する
- 演算子には明確な優先順位と結合性がある
- 論理演算子は短絡評価を行い、必ずしもブール値を返さない
- 比較演算子は連鎖でき、式は一度だけ評価される
- eval()で文字列を式として評価できる（ただし注意が必要）
- Pythonには多様な式の種類がある

## 練習問題

1. **優先順位の理解**
   以下の式の結果を予想し、実際に確認してください：
   ```python
   3 + 4 * 2 ** 2
   (3 + 4) * 2 ** 2
   3 + (4 * 2) ** 2
   -2 ** 4
   (-2) ** 4
   ```

2. **短絡評価の活用**
   以下のコードを短絡評価を使って書き換えてください：
   ```python
   if x != 0:
       result = 10 / x
   else:
       result = 0
   ```

3. **比較連鎖**
   年齢が「10代」（13-19歳）かどうかを判定する式を、比較連鎖を使って書いてください。

4. **式のBNF**
   条件式（三項演算子）`x if condition else y`のBNFを書いてください。

5. **eval()の実験**
   eval()を使って簡単な電卓プログラムを作ってください。
   ただし、危険な操作を防ぐため、使える演算子を制限してください。

---

次章では、変数と代入文の詳細な文法を学びます。

[第6章 変数と代入文 →](chapter06.md)