# 付録C：PEP 8 スタイルガイド要約

この付録では、Python Enhancement Proposal 8（PEP 8）で定められているPythonコードのスタイルガイドラインを要約します。PEP 8は「読みやすいコード」を書くための公式ガイドラインです。

## PEP 8の基本理念

> "Code is read much more often than it is written."  
> （コードは書かれるよりもはるかに多く読まれる）

- **一貫性**: チームや프ロ젝트내での一貫したスタイル
- **可読性**: 誰が読んでも理解しやすいコード  
- **美しさ**: 美しいコードは読みやすい

## コードレイアウト

### インデント

```python
# 良い例：4つのスペースを使用
def long_function_name(
        var_one, var_two, var_three,
        var_four):
    print(var_one)

# 悪い例：タブとスペースの混在
def bad_function():
	    print("混在はダメ")  # タブとスペース混在

# 良い例：if文の継続行
if (this_is_one_thing and
        that_is_another_thing):
    do_something()

# 良い例：リストの継続行
my_list = [
    1, 2, 3,
    4, 5, 6,
]
```

**規則**:
- インデントには4つのスペースを使用
- タブとスペースを混在させない
- 継続行では追加のインデントを使用

### 行の長さ

```python
# 良い例：79文字以内
def short_function_name(parameter_one, parameter_two):
    return parameter_one + parameter_two

# 良い例：長い行の分割
result = some_function_that_takes_arguments(
    'a very long string argument',
    'another very long string argument'
)

# 良い例：演算子での分割（推奨）
income = (gross_wages
          + taxable_interest
          + (dividends - qualified_dividends)
          - ira_deduction
          - student_loan_interest)

# 古いスタイル：演算子後での分割
income = (gross_wages +
          taxable_interest +
          (dividends - qualified_dividends) -
          ira_deduction -
          student_loan_interest)
```

**規則**:
- 行の長さは最大79文字
- docstringやコメントは72文字以内
- 長い行は適切な位置で分割

### 空行

```python
# モジュールレベルの関数・クラス定義の前後は2行空ける
import os
import sys


def module_level_function():
    pass


class MyClass:
    """クラス定義の前後も2行空ける"""
    
    def method_one(self):
        """メソッド間は1行空ける"""
        pass
    
    def method_two(self):
        pass


def another_module_function():
    pass


# ファイル終端
```

**規則**:
- トップレベルの関数・クラス定義は2行空けて区切る
- クラス内のメソッド定義は1行空けて区切る
- 関数内では論理セクションを1行空けて区切る（控えめに）

### ソースファイルエンコーディング

```python
# -*- coding: utf-8 -*-
"""
Python 3では通常不要だが、非ASCII文字を含む場合は明示的に記載
"""

# Python 3では以下のように自動的にUTF-8として扱われる
name = "山田太郎"
message = "こんにちは、世界！"
```

## インポート文

### インポートの順序と書き方

```python
# 1. 標準ライブラリ
import os
import sys
from pathlib import Path

# 2. サードパーティライブラリ  
import numpy as np
import pandas as pd
from requests import get

# 3. ローカルアプリケーション/ライブラリ
from mypackage import mymodule
from mypackage.subpackage import another_module
from . import sibling_module
from ..parent_package import parent_module

# 各グループ間は1行空ける
```

### インポートの良い例・悪い例

```python
# 良い例：個別にインポート
import os
import sys

# 悪い例：複数モジュールを1行でインポート
import os, sys

# 良い例：同じモジュールからの複数インポート
from subprocess import Popen, PIPE

# 良い例：長い場合の分割
from mypackage import (
    module_one, module_two, module_three,
    module_four, module_five
)

# 悪い例：ワイルドカードインポート（特別な場合を除く）
from module import *

# 良い例：エイリアスの使用
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
```

## 文字列クォート

```python
# 一重クォートと二重クォートはどちらでも良い（一貫性を保つ）
single_quoted = 'Hello, World!'
double_quoted = "Hello, World!"

# 文字列内にクォートを含む場合
message_with_quote = "I don't like this"  # 推奨
message_with_quote = 'I don\'t like this'  # エスケープが必要

# 三重クォートはdocstringで使用
def my_function():
    """この関数の説明.
    
    複数行の説明文を書く場合は
    三重ダブルクォートを使用する。
    """
    pass

# 三重シングルクォートはコメントアウトに使用することもある
'''
この部分はコメントアウト
複数行のコードを一時的に無効にする場合
'''
```

## 式と文での空白

### 推奨される空白の使い方

```python
# 良い例：演算子周りの空白
x = 1
y = 2
result = x + y

# 良い例：関数呼び出し
spam(ham[1], {eggs: 2})

# 悪い例：不要な空白
spam( ham[ 1 ], { eggs: 2 } )

# 良い例：スライス
ham[1:9], ham[1:9:3], ham[:9:3], ham[1::3], ham[1:9:]
ham[lower:upper], ham[lower:upper:], ham[lower::step]

# 悪い例：スライスでの空白
ham[1: 9], ham[1 :9], ham[1:9 :3]

# 良い例：キーワード引数
def complex(real, imag=0.0):
    return magic(r=real, i=imag)

# 悪い例：キーワード引数周りの空白
def complex(real, imag = 0.0):
    return magic(r = real, i = imag)

# 良い例：アノテーション
def munge(input: int) -> int:
    return input * 2

def munge(sep: AnyStr = None): pass

# 悪い例：アノテーションでの空白
def munge(input:int)->int:
    return input * 2
```

### 演算子の優先順位と空白

```python
# 良い例：優先順位の高い演算子は空白なし
i = i + 1
submitted += 1
x = x*2 - 1
hypot2 = x*x + y*y
c = (a+b) * (a-b)

# 悪い例：すべての演算子に空白
i = i + 1
submitted + = 1
x = x * 2 - 1
hypot2 = x * x + y * y
c = (a + b) * (a - b)

# 良い例：複雑な式での優先順位の明示
return a*b + c*d
return (a*b) + (c*d)  # より明確
```

## コメント

### コメントの書き方

```python
# 良い例：有用なコメント
x = x + 1  # x座標の境界値調整

# 悪い例：自明なコメント
x = x + 1  # xに1を加算

# 良い例：ブロックコメント
# この関数は複雑なアルゴリズムを実装している
# 主な手順：
# 1. データの前処理
# 2. アルゴリズムの適用
# 3. 結果の後処理
def complex_algorithm(data):
    # データの前処理
    preprocessed_data = preprocess(data)
    
    # アルゴリズムの適用
    result = apply_algorithm(preprocessed_data)
    
    # 結果の後処理
    return postprocess(result)

# 良い例：インラインコメント（控えめに）
x = x + 1    # 境界ケースの補正

# 悪い例：過度なインラインコメント
x = x + 1    # 変数xに整数1を加算する処理
```

### docstring

```python
def function_with_types_in_docstring(param1, param2):
    """一行で関数の概要を説明.

    より詳細な説明をここに書く。複数段落に
    分けることもできる。

    Args:
        param1 (int): 最初のパラメータの説明.
        param2 (str): 二番目のパラメータの説明.

    Returns:
        bool: 戻り値の説明.

    Raises:
        ValueError: 無効な値が渡された場合.
        TypeError: 型が正しくない場合.

    Example:
        >>> function_with_types_in_docstring(1, "hello")
        True
    """
    return True

class MyClass:
    """クラスの概要説明.

    より詳細なクラスの説明。

    Attributes:
        attr1 (str): 属性の説明.
        attr2 (int): もう一つの属性の説明.
    """
    
    def __init__(self, attr1, attr2):
        """コンストラクタの説明."""
        self.attr1 = attr1
        self.attr2 = attr2
```

## 命名規則

### 規則の概要

| 型 | 命名規則 | 例 |
|---|---------|---|
| パッケージ・モジュール | すべて小文字、短く | `mypackage`, `urllib` |
| クラス | CapWords（PascalCase） | `MyClass`, `HTTPServer` |
| 関数・変数 | 小文字+アンダースコア | `my_function`, `local_var` |
| 定数 | 大文字+アンダースコア | `MAX_SIZE`, `DEFAULT_COLOR` |
| メソッド | 小文字+アンダースコア | `get_value`, `set_name` |
| 非公開（内部使用） | 先頭にアンダースコア | `_internal_var`, `_helper_func` |
| 特殊メソッド | 前後にダブルアンダースコア | `__init__`, `__str__` |

### 具体例

```python
# パッケージ・モジュール名
import mypackage
from mylib import mymodule

# クラス名（CapWords）
class MyClass:
    pass

class HTTPServerError(Exception):
    pass

# 関数名・変数名（snake_case）
def my_function():
    pass

def calculate_total_price():
    pass

local_variable = 10
user_name = "Alice"

# 定数名（SCREAMING_SNAKE_CASE）
MAX_CONNECTIONS = 100
DEFAULT_TIMEOUT = 30
PI = 3.14159

# メソッド名
class Calculator:
    def add_numbers(self, a, b):
        return a + b
    
    def get_result(self):
        return self._result
    
    def _internal_calculation(self):  # 非公開メソッド
        pass

# 特殊メソッド
class MyClass:
    def __init__(self, value):
        self.value = value
    
    def __str__(self):
        return str(self.value)
    
    def __add__(self, other):
        return MyClass(self.value + other.value)
```

### 避けるべき名前

```python
# 悪い例：紛らわしい文字
l = 1    # 小文字のL（数字の1と混同）
O = 0    # 大文字のO（数字の0と混同）
I = 1    # 大文字のI（小文字のlと混同）

# 良い例：明確な名前
length = 1
count = 0
index = 1

# 悪い例：Python予約語の使用
class = "MyClass"    # SyntaxError
def = "definition"   # SyntaxError

# 悪い例：ビルトイン関数のオーバーライド
list = [1, 2, 3]     # listビルトイン関数を隠してしまう
str = "hello"        # strビルトイン関数を隠してしまう

# 良い例：明確で意味のある名前
class_name = "MyClass"
definition = "something"
my_list = [1, 2, 3]
greeting = "hello"
```

## プログラミング推奨事項

### 比較

```python
# 良い例：Noneとの比較
if foo is None:
    pass

if foo is not None:
    pass

# 悪い例：Noneとの比較
if foo == None:
    pass

if foo != None:
    pass

# 良い例：ブール値の判定
if greeting:
    pass

# 悪い例：ブール値の判定
if greeting == True:
    pass

if greeting is True:
    pass

# 良い例：空のシーケンスの判定
if not seq:
    pass

if seq:
    pass

# 悪い例：空のシーケンスの判定
if len(seq) == 0:
    pass

if len(seq):
    pass
```

### 例外処理

```python
# 良い例：具体的な例外をキャッチ
try:
    import platform_specific_module
except ImportError:
    platform_specific_module = None

# 悪い例：すべての例外をキャッチ
try:
    import platform_specific_module
except:
    platform_specific_module = None

# 良い例：例外の再発生
try:
    process_data()
except Exception as e:
    log_error(f"データ処理中にエラー: {e}")
    raise  # 例外を再発生

# 良い例：具体的な例外処理
try:
    value = int(user_input)
except ValueError:
    print("有効な数値を入力してください")
except KeyboardInterrupt:
    print("処理が中断されました")
```

### return文

```python
# 良い例：一貫したreturn
def foo(x):
    if x >= 0:
        return math.sqrt(x)
    else:
        return None

def bar(x):
    if x < 0:
        return None
    return math.sqrt(x)

# 悪い例：一部にreturnがない
def foo(x):
    if x >= 0:
        return math.sqrt(x)
    # ここにreturn文がない

# 良い例：明示的なreturn
def get_greeting(name):
    if name:
        return f"Hello, {name}!"
    return "Hello!"

# 悪い例：暗黙的なNone
def get_greeting(name):
    if name:
        return f"Hello, {name}!"
    # return文がない場合、Noneが返される
```

### 文字列メソッドの使用

```python
# 良い例：文字列メソッドを使用
if name.startswith('prefix'):
    pass

if name.endswith('.txt'):
    pass

# 悪い例：スライスでの判定
if name[:6] == 'prefix':
    pass

if name[-4:] == '.txt':
    pass

# 良い例：大文字小文字を無視した比較
if name.lower() == 'alice':
    pass

# 悪い例：複雑な条件
if name == 'alice' or name == 'Alice' or name == 'ALICE':
    pass
```

## 型アノテーション（Python 3.5+）

```python
from typing import List, Dict, Optional, Union, Callable

# 基本的な型アノテーション
def greeting(name: str) -> str:
    return f"Hello, {name}!"

def add_numbers(a: int, b: int) -> int:
    return a + b

# コレクション型
def process_items(items: List[str]) -> Dict[str, int]:
    return {item: len(item) for item in items}

# Optional型（None許可）
def find_user(user_id: int) -> Optional[str]:
    if user_id > 0:
        return f"user_{user_id}"
    return None

# Union型（複数型許可）
def format_id(user_id: Union[int, str]) -> str:
    return str(user_id)

# Callable型（関数型）
def apply_function(func: Callable[[int], int], value: int) -> int:
    return func(value)

# 変数の型アノテーション
count: int = 0
name: str = "Alice"
scores: List[float] = [85.5, 92.0, 78.5]
user_data: Dict[str, Union[str, int]] = {
    "name": "Bob",
    "age": 30
}
```

## ツールとチェッカー

### コードスタイルチェッカー

```bash
# flake8：PEP 8準拠チェック
pip install flake8
flake8 mycode.py

# black：自動コードフォーマッター
pip install black
black mycode.py

# isort：インポート文の自動整理
pip install isort
isort mycode.py

# pylint：包括的なコード品質チェック
pip install pylint
pylint mycode.py

# mypy：型チェック
pip install mypy
mypy mycode.py
```

### エディタ設定例

```json
// VS Code settings.json
{
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "editor.formatOnSave": true,
    "python.sortImports.args": ["--profile", "black"]
}
```

## まとめ

PEP 8は「読みやすいコード」を書くための指針です。重要なポイント：

1. **一貫性を保つ**: プロジェクト内で統一されたスタイル
2. **可読性を優先**: コードは人間が読むもの
3. **ツールを活用**: 自動フォーマッターやリンターを使用
4. **チームで合意**: プロジェクト固有のルールがある場合はそれに従う

> "A style guide is about consistency. Consistency with this style guide is important. Consistency within a project is more important. Consistency within one module or function is the most important."

PEP 8に完全に従うことよりも、チームやプロジェクトでの一貫性を保つことが最も重要です。