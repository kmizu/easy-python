# 第4章：Pythonと友達になろう

前の章でPythonをインストールして、初めてのプログラムを実行しました。この章では、Pythonとの対話をもっと深めて、実用的な計算プログラムを作ってみましょう。まずは身近な「消費税計算」から始めて、Pythonの基本的な使い方をマスターしていきます。

## Pythonとの対話（対話型シェル）

### 対話型シェルとは

前章で少し触れましたが、Pythonには**対話型シェル（インタラクティブシェル）**という便利な機能があります。これは、Pythonと「会話」するような感覚でプログラムを実行できる環境です。

**対話型シェルの特徴：**
- 一行入力するたびに、すぐに結果が返ってくる
- 計算機のように気軽に使える
- プログラムのテストや確認に最適
- 学習には最適な環境

### IDLEの対話型シェルを起動しよう

IDLEを起動すると、次のような画面が表示されます：

```
Python 3.11.0 (main, Oct 24 2022, 18:26:48)
[GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license()" for more information.
>>> 
```

この `>>>` が**プロンプト**と呼ばれる入力待ち状態の印です。ここにPythonのコードを入力できます。

### 電卓として使ってみよう

まずは、Pythonを電卓代わりに使ってみましょう：

```python
>>> 2 + 3
5
>>> 10 - 4
6
>>> 3 * 7
21
>>> 15 / 3
5.0
```

すぐに答えが返ってきますね！これが対話型シェルの便利さです。

### Pythonの計算演算子

Pythonで使える計算演算子を覚えましょう：

| 演算子 | 意味 | 例 | 結果 |
|--------|------|-----|------|
| `+` | 足し算 | `5 + 3` | `8` |
| `-` | 引き算 | `10 - 4` | `6` |
| `*` | 掛け算 | `6 * 7` | `42` |
| `/` | 割り算（小数） | `15 / 4` | `3.75` |
| `//` | 割り算（整数） | `15 // 4` | `3` |
| `%` | 余り | `15 % 4` | `3` |
| `**` | 累乗 | `2 ** 3` | `8` |

### 計算の優先順位

数学と同じように、Pythonでも計算の優先順位があります：

```python
>>> 2 + 3 * 4
14
>>> (2 + 3) * 4
20
```

**優先順位（高い順）：**
1. 括弧 `()`
2. 累乗 `**`
3. 単項演算子 `+`, `-`（符号）
4. 掛け算・割り算 `*`, `/`, `//`, `%`
5. 足し算・引き算 `+`, `-`

**覚え方のコツ：**数学の授業で習った順序と同じです！

## 【実行】消費税計算プログラムを作ろう

身近で実用的な例として、消費税計算プログラムを作ってみましょう。

### ステップ1：基本的な消費税計算

まずは、簡単な消費税計算から始めましょう：

```python
>>> price = 1000  # 商品価格
>>> tax_rate = 0.1  # 消費税率（10%）
>>> tax = price * tax_rate  # 税額
>>> total = price + tax  # 合計金額
>>> print(f"商品価格: {price}円")
商品価格: 1000円
>>> print(f"消費税: {tax}円")
消費税: 100.0円
>>> print(f"合計: {total}円")
合計: 1100.0円
```

### ステップ2：より実用的なバージョン

今度は、ユーザーが価格を入力できるバージョンを作ってみましょう：

```python
>>> price_input = input("商品価格を入力してください: ")
商品価格を入力してください: 1500
>>> price = int(price_input)  # 文字列を数値に変換
>>> tax_rate = 0.1
>>> tax = price * tax_rate
>>> total = price + tax
>>> print(f"商品価格: {price}円")
商品価格: 1500円
>>> print(f"消費税: {tax}円")
消費税: 150.0円
>>> print(f"合計: {total}円")
合計: 1650.0円
```

**ポイント：**
- `input()`関数：ユーザーからの入力を受け取る
- `int()`関数：文字列を整数に変換
- ユーザーが入力した値は最初は「文字列」として扱われる

### ステップ3：複数の商品に対応

複数の商品の合計消費税を計算するプログラムを作ってみましょう：

```python
>>> items = [1200, 800, 1500, 3000]  # 商品価格のリスト
>>> tax_rate = 0.1
>>> 
>>> total_price = 0
>>> total_tax = 0
>>> 
>>> for price in items:
...     tax = price * tax_rate
...     total_price += price
...     total_tax += tax
...     print(f"{price}円の商品: 税額{tax}円")
... 
1200円の商品: 税額120.0円
800円の商品: 税額80.0円
1500円の商品: 税額150.0円
3000円の商品: 税額300.0円
>>> 
>>> print(f"商品合計: {total_price}円")
商品合計: 6500円
>>> print(f"消費税合計: {total_tax}円")
消費税合計: 650.0円
>>> print(f"支払総額: {total_price + total_tax}円")
支払総額: 7150.0円
```

### ステップ4：関数として整理

同じ計算を何度も使えるように、関数として整理しましょう：

```python
>>> def calculate_tax(price, rate=0.1):
...     """消費税を計算する関数"""
...     tax = price * rate
...     total = price + tax
...     return tax, total
... 
>>> # 使用例
>>> tax, total = calculate_tax(1000)
>>> print(f"1000円の商品: 税額{tax}円、合計{total}円")
1000円の商品: 税額100.0円、合計1100.0円
>>> 
>>> tax, total = calculate_tax(2500)
>>> print(f"2500円の商品: 税額{tax}円、合計{total}円")
2500円の商品: 税額250.0円、合計2750.0円
```

**関数の基本構造：**
```python
def 関数名(引数):
    """関数の説明（省略可能）"""
    処理内容
    return 戻り値
```

### ステップ5：完全版プログラム

これまでの要素を組み合わせて、完全版の消費税計算プログラムを作りましょう。新しいファイルに保存して実行してみてください：

```python
# 消費税計算プログラム
def calculate_tax(price, rate=0.1):
    """
    消費税を計算する関数
    
    Args:
        price (float): 商品価格
        rate (float): 税率（デフォルト0.1）
    
    Returns:
        tuple: (税額, 合計金額)
    """
    tax = price * rate
    total = price + tax
    return tax, total

def main():
    """メイン処理"""
    print("=== 消費税計算プログラム ===")
    
    # 商品の入力
    items = []
    while True:
        price_str = input("商品価格を入力（終了は0）: ")
        price = float(price_str)
        
        if price == 0:
            break
        
        if price < 0:
            print("正の数を入力してください。")
            continue
            
        items.append(price)
    
    if not items:
        print("商品が入力されませんでした。")
        return
    
    # 計算と表示
    total_price = 0
    total_tax = 0
    
    print("\n=== 計算結果 ===")
    for i, price in enumerate(items, 1):
        tax, total = calculate_tax(price)
        total_price += price
        total_tax += tax
        print(f"商品{i}: {price:,.0f}円 (税額: {tax:,.0f}円, 合計: {total:,.0f}円)")
    
    print("-" * 40)
    print(f"商品合計: {total_price:,.0f}円")
    print(f"消費税合計: {total_tax:,.0f}円")
    print(f"支払総額: {total_price + total_tax:,.0f}円")

if __name__ == "__main__":
    main()
```

**新しい要素の説明：**
- `while True:`：条件が満たされるまで繰り返し
- `break`：ループから抜ける
- `continue`：ループの次の周期へ
- `enumerate()`：番号付きでループ
- `{:,.0f}`：数値を3桁区切りで表示
- `if __name__ == "__main__":`：ファイルが直接実行されたときだけmain()を実行

## エラーメッセージは怖くない

プログラミングを学ぶ上で、エラーは避けて通れません。でも、エラーメッセージは「敵」ではなく「問題を教えてくれる親切な先生」です。

### よくあるエラーとその対処法

**1. SyntaxError（構文エラー）**

```python
>>> print("Hello World"
  File "<stdin>", line 1
    print("Hello World"
                       ^
SyntaxError: unexpected EOF while parsing
```

**原因：**閉じ括弧が足りない
**対処法：**括弧を正しく閉じる

```python
>>> print("Hello World")  # 正しい
Hello World
```

**2. NameError（名前エラー）**

```python
>>> print(message)
NameError: name 'message' is not defined
```

**原因：**定義されていない変数を使おうとした
**対処法：**変数を先に定義する

```python
>>> message = "Hello"  # 変数を定義
>>> print(message)     # 正しい
Hello
```

**3. TypeError（型エラー）**

```python
>>> "5" + 3
TypeError: can only concatenate str (not "int") to str
```

**原因：**文字列と数値を足そうとした
**対処法：**型を揃える

```python
>>> int("5") + 3    # 文字列を数値に変換
8
>>> "5" + str(3)    # 数値を文字列に変換
'53'
```

**4. ValueError（値エラー）**

```python
>>> int("hello")
ValueError: invalid literal for int() with base 10: 'hello'
```

**原因：**数値でない文字列を数値に変換しようとした
**対処法：**入力値をチェックする

```python
>>> text = "hello"
>>> if text.isdigit():
...     number = int(text)
... else:
...     print("数値ではありません")
... 
数値ではありません
```

## 【実行】計算ミスでエラーを体験してみよう

意図的にエラーを起こして、エラーメッセージの読み方を練習しましょう。

### 練習1：構文エラー

次のコードを入力してみてください（わざと間違っています）：

```python
>>> print("消費税計算"
```

**結果：**
```
SyntaxError: unexpected EOF while parsing
```

**解説：**「予期しないファイル終端」というエラーです。閉じ括弧が足りないことを教えてくれています。

### 練習2：変数名の間違い

```python
>>> price = 1000
>>> print(prise)  # 'price'のスペルミス
```

**結果：**
```
NameError: name 'prise' is not defined
```

**解説：**「prise」という名前の変数は定義されていないという意味です。

### 練習3：型の間違い

```python
>>> price = "1000"  # 文字列として定義
>>> tax = price * 0.1  # 文字列に数値を掛けようとする
```

**結果：**
```
TypeError: can't multiply sequence by non-int of type 'float'
```

**解説：**文字列には整数以外の数値を掛けることができないという意味です。

### 練習4：ゼロ除算エラー

```python
>>> result = 10 / 0
```

**結果：**
```
ZeroDivisionError: division by zero
```

**解説：**ゼロで割ることはできないという意味です。

### エラーメッセージの読み方

エラーメッセージには重要な情報が含まれています：

```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'prise' is not defined
```

**構成要素：**
1. **Traceback**：エラーが発生した場所の履歴
2. **File, line**：どのファイルの何行目でエラーが発生したか
3. **エラーの種類**：NameError, TypeError など
4. **エラーの詳細**：具体的に何が問題なのか

## データ型の基本

これまでの例で、数値や文字列など、異なる種類のデータを扱ってきました。Pythonでは、データの種類を**データ型**として管理しています。

### 主要なデータ型

**1. 整数型（int）**
```python
>>> age = 25
>>> type(age)
<class 'int'>
```

**2. 浮動小数点型（float）**
```python
>>> price = 1500.50
>>> type(price)
<class 'float'>
```

**3. 文字列型（str）**
```python
>>> name = "田中太郎"
>>> type(name)
<class 'str'>
```

**4. 論理型（bool）**
```python
>>> is_student = True
>>> type(is_student)
<class 'bool'>
```

### 型の変換

異なる型の間で値を変換することができます：

```python
>>> # 文字列から数値への変換
>>> price_str = "1500"
>>> price_int = int(price_str)
>>> price_float = float(price_str)
>>> print(price_int, price_float)
1500 1500.0

>>> # 数値から文字列への変換
>>> age = 25
>>> age_str = str(age)
>>> print(f"私は{age_str}歳です")
私は25歳です

>>> # 論理型への変換
>>> bool(1)    # 0以外は True
True
>>> bool(0)    # 0は False
False
>>> bool("")   # 空文字列は False
False
>>> bool("Hello")  # 空でない文字列は True
True
```

### 型の確認方法

```python
>>> value = 3.14
>>> print(type(value))
<class 'float'>
>>> print(isinstance(value, float))
True
>>> print(isinstance(value, int))
False
```

## 変数の基本

これまで何度も使ってきた**変数**について、もう少し詳しく学びましょう。

### 変数とは

変数は、データを保存するための「名前付きの箱」です。

```python
>>> # 変数の定義
>>> name = "田中太郎"
>>> age = 25
>>> height = 170.5
```

### 変数名のルール

**使える文字：**
- 英字（a-z, A-Z）
- 数字（0-9）※先頭には使えない
- アンダースコア（_）

**良い変数名の例：**
```python
user_name = "田中太郎"
total_price = 1500
is_student = True
student_count = 30
```

**悪い変数名の例：**
```python
# ダメな例とその理由
2name = "田中"      # 数字から始まっている
user-name = "田中"  # ハイフンは使えない
user name = "田中"  # スペースは使えない
def = "定義"        # Pythonの予約語は使えない
```

### 変数の命名規則（慣習）

Pythonでは以下の命名規則が推奨されています：

**1. スネークケース（推奨）**
```python
user_name = "田中太郎"
total_price = 1500
max_retry_count = 3
```

**2. 意味のある名前を付ける**
```python
# 良い例
student_count = 30
average_score = 85.5

# 悪い例
x = 30
y = 85.5
```

**3. 定数は大文字**
```python
TAX_RATE = 0.1
MAX_STUDENTS = 100
PI = 3.14159
```

## まとめ：Pythonの基本操作

この章で学んだことをまとめましょう：

### 対話型シェルの活用
- 一行ずつ実行して即座に結果を確認
- 計算機代わりに気軽に使える
- 学習やテストに最適

### 基本的な計算
- 四則演算（+, -, *, /）
- 整数除算（//）、余り（%）、累乗（**）
- 優先順位は数学と同じ

### 実用的なプログラム作成
- ユーザー入力の受け取り（input）
- 型変換（int, float, str）
- 関数の定義と使用
- エラー処理の基本

### エラーとの付き合い方
- エラーメッセージは問題解決のヒント
- よくあるエラーの種類と対処法
- エラーを恐れずに実験することが大切

### データ型と変数
- 整数、浮動小数点、文字列、論理型
- 型変換の方法
- 変数の命名規則

次の章では、もっと複雑な計算や数値処理について学んでいきます。2進数や16進数といった異なる数値表現や、計算の優先順位についてより詳しく見ていきましょう！