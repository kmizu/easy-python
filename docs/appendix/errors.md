# 付録D：よくあるエラーメッセージと対処法

この付録では、Python学習中によく遭遇するエラーメッセージを分類し、原因と対処法を具体例とともに解説します。

## 構文エラー（SyntaxError）

### 基本的な構文エラー

#### 1. SyntaxError: invalid syntax

```python
# エラー例：コロンの忘れ
if x > 5
    print("大きい")

# エラーメッセージ：
# File "example.py", line 1
#     if x > 5
#            ^
# SyntaxError: invalid syntax

# 対処法：条件文の後にコロン（:）を追加
if x > 5:
    print("大きい")
```

```python
# エラー例：括弧の閉じ忘れ
print("Hello"
print("World")

# エラーメッセージ：
# SyntaxError: '(' was never closed

# 対処法：括弧を正しく閉じる
print("Hello")
print("World")
```

#### 2. SyntaxError: EOL while scanning string literal

```python
# エラー例：文字列の閉じクォート忘れ
message = "Hello World
print(message)

# エラーメッセージ：
# SyntaxError: EOL while scanning string literal

# 対処法：クォートを正しく閉じる
message = "Hello World"
print(message)

# または複数行文字列の場合
message = """Hello
World"""
print(message)
```

#### 3. SyntaxError: EOF while scanning triple-quoted string literal

```python
# エラー例：三重クォートの閉じ忘れ
docstring = """
この関数は何かをする
# ファイルの終端

# エラーメッセージ：
# SyntaxError: EOF while scanning triple-quoted string literal

# 対処法：三重クォートを正しく閉じる
docstring = """
この関数は何かをする
"""
```

### インデントエラー

#### 4. IndentationError: expected an indented block

```python
# エラー例：インデントの忘れ
if x > 5:
print("大きい")

# エラーメッセージ：
# IndentationError: expected an indented block

# 対処法：適切にインデント（4つのスペース）
if x > 5:
    print("大きい")
```

#### 5. IndentationError: unindent does not match any outer indentation level

```python
# エラー例：インデントレベルの不一致
def my_function():
    if True:
        print("Hello")
      print("World")  # インデントが中途半端

# エラーメッセージ：
# IndentationError: unindent does not match any outer indentation level

# 対処法：一貫したインデントレベルを使用
def my_function():
    if True:
        print("Hello")
    print("World")
```

#### 6. TabError: inconsistent use of tabs and spaces in indentation

```python
# エラー例：タブとスペースの混在
def my_function():
    x = 1          # スペース4つ
	return x       # タブ文字

# エラーメッセージ：
# TabError: inconsistent use of tabs and spaces in indentation

# 対処法：スペースのみを使用（推奨）
def my_function():
    x = 1
    return x
```

## 名前エラー（NameError）

#### 7. NameError: name 'variable' is not defined

```python
# エラー例：変数の未定義
print(message)

# エラーメッセージ：
# NameError: name 'message' is not defined

# 対処法：変数を定義してから使用
message = "Hello, World!"
print(message)
```

```python
# エラー例：スコープ外の変数参照
def my_function():
    local_var = "ローカル変数"

print(local_var)  # 関数外からアクセス

# エラーメッセージ：
# NameError: name 'local_var' is not defined

# 対処法：変数のスコープを確認
def my_function():
    local_var = "ローカル変数"
    return local_var

result = my_function()
print(result)
```

#### 8. NameError: name 'function' is not defined

```python
# エラー例：関数の呼び出し前に定義がない
result = calculate(5, 3)

def calculate(a, b):
    return a + b

# エラーメッセージ：
# NameError: name 'calculate' is not defined

# 対処法：関数を定義してから呼び出し
def calculate(a, b):
    return a + b

result = calculate(5, 3)
```

## 型エラー（TypeError）

#### 9. TypeError: unsupported operand type(s)

```python
# エラー例：異なる型同士の演算
result = "5" + 3

# エラーメッセージ：
# TypeError: can only concatenate str (not "int") to str

# 対処法：型を統一
result = "5" + str(3)    # 文字列として結合
# または
result = int("5") + 3    # 数値として計算
```

#### 10. TypeError: 'str' object is not callable

```python
# エラー例：文字列を関数のように呼び出し
message = "Hello"
result = message()

# エラーメッセージ：
# TypeError: 'str' object is not callable

# 対処法：正しいメソッド呼び出し
message = "Hello"
result = message.upper()  # メソッドを呼び出し
```

#### 11. TypeError: missing positional argument

```python
# エラー例：必須引数の不足
def greet(name, age):
    return f"Hello, {name}! You are {age} years old."

message = greet("Alice")  # age引数が不足

# エラーメッセージ：
# TypeError: greet() missing 1 required positional argument: 'age'

# 対処法：すべての必須引数を提供
message = greet("Alice", 25)

# またはデフォルト値を設定
def greet(name, age=0):
    return f"Hello, {name}! You are {age} years old."

message = greet("Alice")  # age引数は省略可能
```

#### 12. TypeError: 'int' object is not iterable

```python
# エラー例：イテレート不可能なオブジェクトをループ
for i in 5:
    print(i)

# エラーメッセージ：
# TypeError: 'int' object is not iterable

# 対処法：イテレート可能なオブジェクトを使用
for i in range(5):
    print(i)

# または
for i in [1, 2, 3, 4, 5]:
    print(i)
```

## インデックスエラー（IndexError）

#### 13. IndexError: list index out of range

```python
# エラー例：リストの範囲外にアクセス
my_list = [1, 2, 3]
print(my_list[5])

# エラーメッセージ：
# IndexError: list index out of range

# 対処法：有効なインデックスを使用
my_list = [1, 2, 3]
if len(my_list) > 5:
    print(my_list[5])
else:
    print("インデックスが範囲外です")

# または例外処理を使用
try:
    print(my_list[5])
except IndexError:
    print("インデックスが範囲外です")
```

#### 14. IndexError: string index out of range

```python
# エラー例：文字列の範囲外にアクセス
text = "Hello"
print(text[10])

# エラーメッセージ：
# IndexError: string index out of range

# 対処法：有効なインデックスを確認
text = "Hello"
if len(text) > 10:
    print(text[10])
else:
    print("インデックスが範囲外です")
```

## キーエラー（KeyError）

#### 15. KeyError: 'key'

```python
# エラー例：辞書に存在しないキーにアクセス
person = {"name": "Alice", "age": 30}
print(person["height"])

# エラーメッセージ：
# KeyError: 'height'

# 対処法1：get()メソッドを使用
print(person.get("height", "不明"))

# 対処法2：キーの存在確認
if "height" in person:
    print(person["height"])
else:
    print("身長情報がありません")

# 対処法3：例外処理
try:
    print(person["height"])
except KeyError:
    print("指定されたキーが見つかりません")
```

## 値エラー（ValueError）

#### 16. ValueError: invalid literal for int()

```python
# エラー例：文字列を数値に変換できない
number = int("abc")

# エラーメッセージ：
# ValueError: invalid literal for int() with base 10: 'abc'

# 対処法：例外処理を使用
try:
    number = int("abc")
except ValueError:
    print("有効な数値を入力してください")
    number = 0
```

#### 17. ValueError: too many values to unpack

```python
# エラー例：アンパック時の値の数が不一致
a, b = [1, 2, 3]

# エラーメッセージ：
# ValueError: too many values to unpack (expected 2)

# 対処法：変数の数を合わせる
a, b, c = [1, 2, 3]

# または必要な分だけ取得
a, b = [1, 2, 3][:2]

# またはアスタリスクを使用
a, b, *rest = [1, 2, 3, 4, 5]
```

## 属性エラー（AttributeError）

#### 18. AttributeError: 'type' object has no attribute 'method'

```python
# エラー例：存在しないメソッドの呼び出し
my_list = [1, 2, 3]
my_list.add(4)  # listには add メソッドがない

# エラーメッセージ：
# AttributeError: 'list' object has no attribute 'add'

# 対処法：正しいメソッドを使用
my_list = [1, 2, 3]
my_list.append(4)  # append メソッドを使用
```

```python
# エラー例：None オブジェクトのメソッド呼び出し
def get_data():
    return None

result = get_data()
length = result.upper()  # None には upper メソッドがない

# エラーメッセージ：
# AttributeError: 'NoneType' object has no attribute 'upper'

# 対処法：None チェックを追加
result = get_data()
if result is not None:
    length = result.upper()
else:
    print("データがありません")
```

## インポートエラー（ImportError / ModuleNotFoundError）

#### 19. ModuleNotFoundError: No module named 'module'

```python
# エラー例：存在しないモジュールのインポート
import nonexistent_module

# エラーメッセージ：
# ModuleNotFoundError: No module named 'nonexistent_module'

# 対処法1：正しいモジュール名を確認
import os  # 標準ライブラリの正しいモジュール

# 対処法2：モジュールをインストール
# pip install requests
import requests

# 対処法3：相対インポートの修正
# from .mymodule import function  # 同じパッケージ内
```

#### 20. ImportError: cannot import name 'function' from 'module'

```python
# エラー例：存在しない関数のインポート
from math import nonexistent_function

# エラーメッセージ：
# ImportError: cannot import name 'nonexistent_function' from 'math'

# 対処法：存在する関数名を確認
from math import sqrt, sin, cos

# または利用可能な関数を確認
import math
print(dir(math))
```

## ファイル操作エラー

#### 21. FileNotFoundError: No such file or directory

```python
# エラー例：存在しないファイルを開く
with open("nonexistent.txt", "r") as f:
    content = f.read()

# エラーメッセージ：
# FileNotFoundError: [Errno 2] No such file or directory: 'nonexistent.txt'

# 対処法1：ファイルの存在確認
import os
if os.path.exists("nonexistent.txt"):
    with open("nonexistent.txt", "r") as f:
        content = f.read()
else:
    print("ファイルが見つかりません")

# 対処法2：例外処理
try:
    with open("nonexistent.txt", "r") as f:
        content = f.read()
except FileNotFoundError:
    print("ファイルが見つかりません")
    content = ""
```

#### 22. PermissionError: Permission denied

```python
# エラー例：権限のないファイルへのアクセス
with open("/root/private.txt", "w") as f:
    f.write("データ")

# エラーメッセージ：
# PermissionError: [Errno 13] Permission denied: '/root/private.txt'

# 対処法：適切な権限のある場所に保存
import os
home_dir = os.path.expanduser("~")
file_path = os.path.join(home_dir, "my_file.txt")

with open(file_path, "w") as f:
    f.write("データ")
```

## ゼロ除算エラー（ZeroDivisionError）

#### 23. ZeroDivisionError: division by zero

```python
# エラー例：ゼロで除算
result = 10 / 0

# エラーメッセージ：
# ZeroDivisionError: division by zero

# 対処法：除数のチェック
denominator = 0
if denominator != 0:
    result = 10 / denominator
else:
    print("ゼロで除算はできません")
    result = float('inf')  # または適切なデフォルト値

# または例外処理
try:
    result = 10 / denominator
except ZeroDivisionError:
    print("ゼロで除算はできません")
    result = float('inf')
```

## 論理エラー（実行時エラーではないが、期待と異なる結果）

#### 24. 無限ループ

```python
# 問題のあるコード：無限ループ
i = 0
while i < 10:
    print(i)
    # i += 1 が抜けている

# 対処法：ループ変数を適切に更新
i = 0
while i < 10:
    print(i)
    i += 1
```

#### 25. 意図しない変数の変更

```python
# 問題のあるコード：リストの参照による意図しない変更
original_list = [1, 2, 3]
modified_list = original_list
modified_list.append(4)
print(original_list)  # [1, 2, 3, 4] になってしまう

# 対処法：リストのコピーを作成
original_list = [1, 2, 3]
modified_list = original_list.copy()  # または list(original_list)
modified_list.append(4)
print(original_list)  # [1, 2, 3] のまま
```

## デバッグのための実践的なテクニック

### 1. print文によるデバッグ

```python
def calculate_average(numbers):
    print(f"入力: {numbers}")  # デバッグ用出力
    
    total = sum(numbers)
    print(f"合計: {total}")  # デバッグ用出力
    
    count = len(numbers)
    print(f"個数: {count}")  # デバッグ用出力
    
    if count == 0:
        return 0
    
    average = total / count
    print(f"平均: {average}")  # デバッグ用出力
    
    return average
```

### 2. type()関数による型確認

```python
def process_data(data):
    print(f"データの型: {type(data)}")
    print(f"データの値: {data}")
    
    if isinstance(data, str):
        return data.upper()
    elif isinstance(data, (int, float)):
        return data * 2
    else:
        raise TypeError(f"未対応の型: {type(data)}")
```

### 3. try-except文による安全な実行

```python
def safe_division(a, b):
    try:
        result = a / b
        return result
    except ZeroDivisionError:
        print("エラー: ゼロで除算しようとしました")
        return None
    except TypeError:
        print("エラー: 数値以外が渡されました")
        return None
    except Exception as e:
        print(f"予期しないエラー: {e}")
        return None
```

### 4. assert文による条件確認

```python
def calculate_square_root(x):
    assert x >= 0, "負の数の平方根は計算できません"
    assert isinstance(x, (int, float)), "数値を入力してください"
    
    import math
    return math.sqrt(x)

# 使用例
try:
    result = calculate_square_root(-4)
except AssertionError as e:
    print(f"アサーションエラー: {e}")
```

## エラー予防のベストプラクティス

### 1. 型ヒントの使用

```python
from typing import List, Optional

def process_names(names: List[str]) -> Optional[str]:
    """名前のリストから最長の名前を返す"""
    if not names:
        return None
    
    longest_name = ""
    for name in names:
        if len(name) > len(longest_name):
            longest_name = name
    
    return longest_name
```

### 2. 入力値の検証

```python
def validate_age(age):
    """年齢の妥当性をチェック"""
    if not isinstance(age, int):
        raise TypeError("年齢は整数である必要があります")
    
    if age < 0:
        raise ValueError("年齢は負の値にできません")
    
    if age > 150:
        raise ValueError("年齢が現実的ではありません")
    
    return True

def create_person(name, age):
    validate_age(age)
    return {"name": name, "age": age}
```

### 3. 適切な例外処理

```python
import json
import logging

def load_config(filename):
    """設定ファイルを読み込む"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            config = json.load(f)
        return config
    
    except FileNotFoundError:
        logging.error(f"設定ファイルが見つかりません: {filename}")
        return {}
    
    except json.JSONDecodeError as e:
        logging.error(f"JSONの解析エラー: {e}")
        return {}
    
    except Exception as e:
        logging.error(f"予期しないエラー: {e}")
        return {}
```

この付録を参考にして、エラーメッセージを正しく読み取り、適切な対処法を適用することで、より効率的にPythonプログラムを開発できるようになります。