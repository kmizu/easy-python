# 第13章：モジュールとパッケージ

## この章で学ぶこと

- import文のBNF定義
- モジュールのロードとキャッシュの仕組み
- from...import文の文法
- 名前空間の管理
- sys.pathとモジュール検索順序
- パッケージ構造と__init__.py

## 13.1 import文のBNF定義

### import文の構文

```bnf
<import文> ::= "import" <モジュール> ["as" <名前>] ("," <モジュール> ["as" <名前>])*
<from_import文> ::= "from" <モジュール> "import" <インポート対象>
<インポート対象> ::= "*" | <名前> ["as" <名前>] ("," <名前> ["as" <名前>])*
<モジュール> ::= <識別子> ("." <識別子>)*
```

### 基本的なimport

```python
# import_basics.py

# 標準ライブラリのインポート
import os
import sys
import time

print("=== 基本的なimport ===")
print(f"os.name: {os.name}")
print(f"sys.version: {sys.version.split()[0]}")
print(f"現在時刻: {time.strftime('%Y-%m-%d %H:%M:%S')}")

# 別名でのインポート
import datetime as dt
import numpy as np  # 慣習的な別名

now = dt.datetime.now()
print(f"\n現在時刻（datetime）: {now}")

# 複数モジュールの同時インポート
import json, csv, io  # 可能だが推奨されない

# PEP 8推奨スタイル
import json
import csv
import io

# インポートの順序（PEP 8）
# 1. 標準ライブラリ
import os
import sys
from datetime import datetime

# 2. サードパーティライブラリ
# import requests
# import pandas as pd

# 3. ローカルモジュール
# from mymodule import myfunction
```

## 13.2 【実行】モジュールのロードとキャッシュ

```python
# module_loading.py

import sys
import importlib

print("=== モジュールのロード ===")

# モジュールのキャッシュを確認
print("インポート前のモジュール数:", len(sys.modules))

# 新しいモジュールをインポート
import json
print("jsonインポート後:", len(sys.modules))

# すでにロードされているモジュール
if 'json' in sys.modules:
    print("jsonモジュールはキャッシュされています")
    print(f"jsonモジュールの場所: {json.__file__}")

# モジュールの再ロード
print("\n=== モジュールの再ロード ===")
# 通常、importは2回目以降キャッシュを使用
import json  # キャッシュから
import json  # キャッシュから

# 強制的に再ロード
importlib.reload(json)
print("jsonモジュールを再ロードしました")

# カスタムモジュールのテスト用
# test_module.py を作成
test_module_code = '''
print("test_moduleが読み込まれました")
counter = 0

def increment():
    global counter
    counter += 1
    return counter
'''

with open('test_module.py', 'w') as f:
    f.write(test_module_code)

# カスタムモジュールのインポート
print("\n=== カスタムモジュール ===")
import test_module  # "test_moduleが読み込まれました"が表示される

print(f"counter: {test_module.counter}")
print(f"increment(): {test_module.increment()}")
print(f"counter: {test_module.counter}")

# 再度インポート（キャッシュから）
print("\n再インポート:")
import test_module  # 何も表示されない（キャッシュから）

# モジュールの属性
print("\n=== モジュールの属性 ===")
print(f"__name__: {test_module.__name__}")
print(f"__file__: {test_module.__file__}")
print(f"__doc__: {test_module.__doc__}")
print(f"dir(): {[attr for attr in dir(test_module) if not attr.startswith('_')]}")

# クリーンアップ
import os
os.remove('test_module.py')
if 'test_module' in sys.modules:
    del sys.modules['test_module']
```

### モジュールの遅延読み込み

```python
# lazy_loading.py

import sys
import time

print("=== 遅延読み込み ===")

def use_heavy_module():
    """必要になったときだけモジュールをロード"""
    print("重いモジュールが必要になりました")
    import numpy as np  # ここで初めてロード
    return np.array([1, 2, 3])

# まだnumpyはロードされていない
print(f"numpy in sys.modules: {'numpy' in sys.modules}")

# 関数を呼ぶとロードされる
result = use_heavy_module()
print(f"結果: {result}")
print(f"numpy in sys.modules: {'numpy' in sys.modules}")

# 条件付きインポート
print("\n=== 条件付きインポート ===")
try:
    import pandas as pd
    HAS_PANDAS = True
except ImportError:
    HAS_PANDAS = False
    print("pandasがインストールされていません")

if HAS_PANDAS:
    print("pandasが利用可能です")
else:
    print("pandas機能は無効です")

# プラットフォーム依存のインポート
import platform

if platform.system() == 'Windows':
    import msvcrt
elif platform.system() == 'Linux':
    import termios
else:
    print(f"サポートされていないOS: {platform.system()}")
```

## 13.3 from...import文の文法

### 【実行】名前空間の汚染を確認

```python
# from_import_demo.py

# 基本的なfrom...import
print("=== from...import ===")
from math import pi, sqrt, sin, cos
print(f"π = {pi}")
print(f"√2 = {sqrt(2)}")

# import * の使用（推奨されない）
print("\n=== import * ===")
# 名前空間の状態を保存
before = set(globals().keys())

from math import *

# 追加された名前を確認
after = set(globals().keys())
imported = after - before
print(f"追加された名前の数: {len(imported)}")
print(f"一部: {list(imported)[:10]}...")

# 名前の衝突
print("\n=== 名前の衝突 ===")
def sqrt(x):
    """カスタムsqrt関数"""
    return f"カスタムsqrt({x})"

print(f"sqrt(4) = {sqrt(4)}")  # カスタム関数

from math import sqrt  # mathのsqrtで上書き
print(f"sqrt(4) = {sqrt(4)}")  # mathのsqrt

# 選択的インポート
print("\n=== 選択的インポート ===")
from datetime import datetime, timedelta, timezone
# from datetime import *  # これは避ける

now = datetime.now()
tomorrow = now + timedelta(days=1)
print(f"今日: {now.date()}")
print(f"明日: {tomorrow.date()}")

# asを使った別名
print("\n=== 別名でのインポート ===")
from collections import defaultdict as dd, Counter as cnt

# 名前の衝突を避ける
data = dd(list)
data['fruits'].extend(['apple', 'banana', 'apple'])
counter = cnt(data['fruits'])
print(f"カウント: {dict(counter)}")

# 深いモジュールからのインポート
print("\n=== 深いモジュールからのインポート ===")
from urllib.parse import urlparse, parse_qs
from os.path import join, dirname, basename

url = "https://example.com/path?key=value&foo=bar"
parsed = urlparse(url)
query = parse_qs(parsed.query)
print(f"パース結果: {parsed.scheme}://{parsed.netloc}")
print(f"クエリパラメータ: {query}")

# __all__の効果
# test_all.py を作成
test_all_code = '''
__all__ = ['public_func', 'PublicClass']

def public_func():
    return "公開関数"

def _private_func():
    return "プライベート関数"

class PublicClass:
    pass

class _PrivateClass:
    pass
'''

with open('test_all.py', 'w') as f:
    f.write(test_all_code)

print("\n=== __all__の効果 ===")
from test_all import *

print(f"public_func: {public_func()}")
try:
    _private_func()
except NameError:
    print("_private_funcはインポートされていません")

# クリーンアップ
import os
os.remove('test_all.py')
```

## 13.4 【実行】sys.pathとモジュール検索順序

```python
# module_search_path.py

import sys
import os

print("=== モジュール検索パス ===")
print("sys.path:")
for i, path in enumerate(sys.path):
    print(f"{i}: {path}")

# カレントディレクトリの確認
print(f"\nカレントディレクトリ: {os.getcwd()}")

# 検索順序のデモ
# 同名モジュールを異なる場所に作成
os.makedirs('dir1', exist_ok=True)
os.makedirs('dir2', exist_ok=True)

with open('dir1/mymodule.py', 'w') as f:
    f.write('location = "dir1"')

with open('dir2/mymodule.py', 'w') as f:
    f.write('location = "dir2"')

# sys.pathに追加
sys.path.insert(0, 'dir2')
sys.path.insert(0, 'dir1')

import mymodule
print(f"\nmymoduleの場所: {mymodule.location}")
print(f"ファイルパス: {mymodule.__file__}")

# PYTHONPATH環境変数
print("\n=== PYTHONPATH ===")
pythonpath = os.environ.get('PYTHONPATH', '未設定')
print(f"PYTHONPATH: {pythonpath}")

# サイトパッケージ
print("\n=== site-packages ===")
import site
print("サイトパッケージのディレクトリ:")
for path in site.getsitepackages():
    print(f"  {path}")

# ユーザーサイトパッケージ
print(f"\nユーザーサイトパッケージ: {site.getusersitepackages()}")

# モジュールの検索をカスタマイズ
print("\n=== カスタム検索パス ===")
custom_path = os.path.join(os.getcwd(), 'custom_modules')
os.makedirs(custom_path, exist_ok=True)

# カスタムモジュールを作成
with open(os.path.join(custom_path, 'custom.py'), 'w') as f:
    f.write('''
def greet():
    return "カスタムモジュールからこんにちは！"
''')

# パスに追加してインポート
sys.path.append(custom_path)
import custom
print(custom.greet())

# モジュールファインダー
print("\n=== モジュールファインダー ===")
import importlib.util

# モジュールの仕様を検索
spec = importlib.util.find_spec('json')
print(f"jsonモジュール:")
print(f"  名前: {spec.name}")
print(f"  場所: {spec.origin}")
print(f"  ローダー: {spec.loader}")

# 存在しないモジュール
spec = importlib.util.find_spec('nonexistent_module')
print(f"\n存在しないモジュール: {spec}")

# クリーンアップ
import shutil
shutil.rmtree('dir1')
shutil.rmtree('dir2')
shutil.rmtree('custom_modules')
if 'mymodule' in sys.modules:
    del sys.modules['mymodule']
if 'custom' in sys.modules:
    del sys.modules['custom']
```

## 13.5 【実行】__init__.pyの役割とパッケージ構造

```python
# package_structure.py

import os
import sys

print("=== パッケージ構造 ===")

# パッケージ構造を作成
package_structure = {
    'mypackage': {
        '__init__.py': 'print("mypackageが初期化されました")\n__version__ = "1.0.0"',
        'module1.py': '''
def func1():
    return "module1.func1()"
''',
        'module2.py': '''
def func2():
    return "module2.func2()"
''',
        'subpackage': {
            '__init__.py': 'print("subpackageが初期化されました")',
            'submodule.py': '''
def subfunc():
    return "subpackage.submodule.subfunc()"
'''
        }
    }
}

def create_package_structure(base_path, structure):
    """パッケージ構造を作成"""
    for name, content in structure.items():
        path = os.path.join(base_path, name)
        if isinstance(content, dict):
            os.makedirs(path, exist_ok=True)
            create_package_structure(path, content)
        else:
            with open(path, 'w') as f:
                f.write(content)

create_package_structure('.', package_structure)

# パッケージのインポート
print("\n=== パッケージのインポート ===")
import mypackage  # __init__.pyが実行される
print(f"バージョン: {mypackage.__version__}")

# サブモジュールのインポート
print("\n=== サブモジュールのインポート ===")
from mypackage import module1
print(module1.func1())

# サブパッケージのインポート
from mypackage.subpackage import submodule
print(submodule.subfunc())

# __init__.pyでの公開API定義
# より高度な__init__.pyを作成
advanced_init = '''
"""
MyPackage - 高度なパッケージの例
"""

__version__ = "2.0.0"
__author__ = "Python Learner"

# サブモジュールからインポート
from .module1 import func1
from .module2 import func2

# 公開APIを定義
__all__ = ['func1', 'func2', 'utils']

# 便利な名前空間を提供
class utils:
    """ユーティリティ関数をまとめたクラス"""
    @staticmethod
    def combine():
        return func1() + " & " + func2()

# パッケージレベルの初期化
def _initialize():
    print("パッケージの初期化処理")
    # ここで設定ファイルの読み込みなどを行う

_initialize()
'''

with open('mypackage/__init__.py', 'w') as f:
    f.write(advanced_init)

# 再インポート（リロード）
import importlib
importlib.reload(mypackage)

print("\n=== 高度な__init__.py ===")
print(f"直接アクセス: {mypackage.func1()}")
print(f"utilsクラス: {mypackage.utils.combine()}")

# 相対インポート
print("\n=== 相対インポート ===")
relative_module = '''
# 相対インポートの例
from . import module1  # 同じパッケージから
from ..subpackage import submodule  # 親パッケージのサブパッケージから

def combined_func():
    return f"{module1.func1()} + {submodule.subfunc()}"
'''

with open('mypackage/relative_example.py', 'w') as f:
    f.write(relative_module)

# 名前空間パッケージ（__init__.pyなし）
print("\n=== 名前空間パッケージ ===")
os.makedirs('namespace_pkg/sub1', exist_ok=True)
os.makedirs('namespace_pkg/sub2', exist_ok=True)
# __init__.pyを作成しない

with open('namespace_pkg/sub1/mod1.py', 'w') as f:
    f.write('name = "sub1.mod1"')

with open('namespace_pkg/sub2/mod2.py', 'w') as f:
    f.write('name = "sub2.mod2"')

sys.path.insert(0, '.')
from namespace_pkg.sub1 import mod1
from namespace_pkg.sub2 import mod2
print(f"名前空間パッケージ: {mod1.name}, {mod2.name}")

# パッケージのメタデータ
print("\n=== パッケージのメタデータ ===")
print(f"__name__: {mypackage.__name__}")
print(f"__file__: {mypackage.__file__}")
print(f"__path__: {mypackage.__path__}")
print(f"__package__: {mypackage.__package__}")

# クリーンアップ
import shutil
shutil.rmtree('mypackage')
shutil.rmtree('namespace_pkg')
```

### 実用的なパッケージ構成

```python
# package_best_practices.py

print("=== 実用的なパッケージ構成 ===")

# 典型的なプロジェクト構造
project_structure = """
myproject/
├── setup.py              # パッケージ設定
├── README.md            # プロジェクト説明
├── requirements.txt     # 依存関係
├── .gitignore          # Git無視ファイル
├── tests/              # テストディレクトリ
│   ├── __init__.py
│   ├── test_core.py
│   └── test_utils.py
├── docs/               # ドキュメント
│   └── conf.py
└── myproject/          # メインパッケージ
    ├── __init__.py     # パッケージ初期化
    ├── __main__.py     # python -m myproject で実行
    ├── core.py         # コア機能
    ├── utils.py        # ユーティリティ
    ├── config.py       # 設定
    └── data/           # データファイル
        └── default.json
"""

print(project_structure)

# __main__.pyの例
main_py_example = '''
"""
パッケージを直接実行可能にする
python -m myproject
"""

import sys
from .core import main

if __name__ == '__main__':
    sys.exit(main())
'''

# setup.pyの基本例
setup_py_example = '''
from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="myproject",
    version="0.1.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="A short description",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/myproject",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
    install_requires=[
        'requests>=2.25.0',
        'click>=7.0',
    ],
    entry_points={
        'console_scripts': [
            'myproject=myproject.__main__:main',
        ],
    },
)
'''

print("\n=== setup.pyの例 ===")
print(setup_py_example)

# プラグインシステムの例
print("\n=== プラグインシステム ===")

plugin_system = '''
# plugins/__init__.py
import importlib
import pkgutil

# プラグインを自動的に発見してロード
discovered_plugins = {
    name: importlib.import_module(name)
    for finder, name, ispkg
    in pkgutil.iter_modules(__path__, __name__ + ".")
}

# プラグインインターフェース
class PluginBase:
    """すべてのプラグインが継承すべき基底クラス"""
    def execute(self):
        raise NotImplementedError
'''

print("プラグインシステムの例:")
print(plugin_system)
```

## 13.6 この章のまとめ

- import文でモジュールを読み込み、名前空間に追加する
- モジュールは一度だけロードされ、sys.modulesにキャッシュされる
- from...import文で特定の名前だけをインポートできる
- sys.pathがモジュールの検索パスを決定する
- パッケージは__init__.pyを含むディレクトリ
- 相対インポートでパッケージ内の参照を行える

## 練習問題

1. **カスタムインポーター**
   特定の拡張子（.txt）のファイルをPythonモジュールとして
   インポートできるカスタムインポーターを作成してください。

2. **循環インポートの解決**
   循環インポートが発生する例を作成し、
   それを解決する方法を実装してください。

3. **プラグインシステム**
   指定されたディレクトリからプラグインを動的にロードする
   システムを実装してください。

4. **パッケージ作成**
   pip installできる簡単なパッケージを作成し、
   setup.pyを書いてください。

5. **モジュール検索の最適化**
   大量のモジュールをインポートする際の
   パフォーマンスを測定し、最適化してください。

---

次章では、再帰とPythonインタプリタの実行モデルについて学びます。

[第14章 再帰とPythonインタプリタの実行モデル →](chapter14.md)