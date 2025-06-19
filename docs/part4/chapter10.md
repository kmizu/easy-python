# 第10章：文字列の高度な文法と処理

## この章で学ぶこと

- フォーマット済み文字列（f-string）のBNF
- f-stringの式評価とformat()との比較
- 文字列メソッドチェーン
- 正規表現の基礎とreモジュール
- 文字エンコーディングとバイト列

## 10.1 フォーマット済み文字列（f-string）のBNF

### f-stringの構文定義

```bnf
<f-string> ::= ("f" | "F") <文字列リテラル>
<置換フィールド> ::= "{" <式> ["!" <変換>] [":" <書式指定>] "}"
<変換> ::= "s" | "r" | "a"
<書式指定> ::= <書式指定文字>*
```

### 【実行】f-stringの式評価とformat()との比較

```python
# fstring_demo.py

# 基本的なf-string
print("=== 基本的なf-string ===")
name = "Python"
version = 3.11
print(f"Hello, {name} {version}!")

# 式の評価
print("\n=== 式の評価 ===")
a, b = 10, 20
print(f"{a} + {b} = {a + b}")
print(f"{a} * {b} = {a * b}")
print(f"2の10乗 = {2**10}")

# 関数呼び出し
print(f"文字列の長さ: {len('Hello World')}")
print(f"大文字: {'hello'.upper()}")

# 条件式
score = 85
print(f"成績: {score}点 - {'合格' if score >= 60 else '不合格'}")

# 変換フラグ
print("\n=== 変換フラグ ===")
text = "Hello\tWorld\n"
print(f"通常: {text}")
print(f"repr: {text!r}")
print(f"str: {text!s}")
print(f"ascii: {'こんにちは'!a}")

# 書式指定
print("\n=== 書式指定 ===")
pi = 3.14159265359
print(f"デフォルト: {pi}")
print(f"小数点2桁: {pi:.2f}")
print(f"小数点5桁: {pi:.5f}")
print(f"指数表記: {pi:e}")

# 幅と配置
print("\n=== 幅と配置 ===")
text = "Python"
print(f"|{text:20}|  # 左寄せ（デフォルト）")
print(f"|{text:>20}| # 右寄せ")
print(f"|{text:^20}| # 中央寄せ")
print(f"|{text:*^20}| # パディング文字指定")

# 数値の書式
print("\n=== 数値の書式 ===")
num = 1234567
print(f"通常: {num}")
print(f"カンマ区切り: {num:,}")
print(f"アンダースコア区切り: {num:_}")

# 進数変換
num = 42
print(f"\n10進数: {num:d}")
print(f"2進数: {num:b}")
print(f"8進数: {num:o}")
print(f"16進数: {num:x}")
print(f"16進数（大文字）: {num:X}")

# パーセント表示
ratio = 0.754
print(f"\n比率: {ratio:.1%}")

# format()メソッドとの比較
print("\n=== format()メソッドとの比較 ===")
# format()
name = "Alice"
age = 30
old_style = "Name: {}, Age: {}".format(name, age)
positional = "Name: {0}, Age: {1}, {0} is {1} years old".format(name, age)
keyword = "Name: {name}, Age: {age}".format(name=name, age=age)

print(f"format(): {old_style}")
print(f"位置指定: {positional}")
print(f"キーワード: {keyword}")

# f-string（より簡潔）
new_style = f"Name: {name}, Age: {age}, {name} is {age} years old"
print(f"f-string: {new_style}")

# パフォーマンス比較
import timeit

# f-string
f_time = timeit.timeit(
    lambda: f"Name: {name}, Age: {age}",
    number=1000000
)

# format()
format_time = timeit.timeit(
    lambda: "Name: {}, Age: {}".format(name, age),
    number=1000000
)

# % 演算子
percent_time = timeit.timeit(
    lambda: "Name: %s, Age: %d" % (name, age),
    number=1000000
)

print(f"\n実行時間（100万回）:")
print(f"  f-string: {f_time:.3f}秒")
print(f"  format(): {format_time:.3f}秒")
print(f"  %演算子: {percent_time:.3f}秒")
```

### 高度なf-stringの使い方

```python
# fstring_advanced.py
from datetime import datetime
import math

# 日時のフォーマット
print("=== 日時のフォーマット ===")
now = datetime.now()
print(f"現在時刻: {now}")
print(f"日付のみ: {now:%Y-%m-%d}")
print(f"時刻のみ: {now:%H:%M:%S}")
print(f"曜日: {now:%A}")
print(f"月名: {now:%B}")
print(f"カスタム: {now:%Y年%m月%d日 %H時%M分}")

# ネストした構造
print("\n=== ネストした構造 ===")
data = {
    'users': [
        {'name': 'Alice', 'score': 85},
        {'name': 'Bob', 'score': 92},
        {'name': 'Charlie', 'score': 78}
    ]
}

for user in data['users']:
    print(f"{user['name']:10s}: {user['score']:3d}点")

# 動的な書式指定
print("\n=== 動的な書式指定 ===")
width = 15
precision = 3
value = math.pi

print(f"固定: {value:15.3f}")
print(f"動的: {value:{width}.{precision}f}")

# 幅も動的に
for w in [10, 15, 20]:
    print(f"幅{w}: |{value:{w}.2f}|")

# デバッグ用のf-string（Python 3.8+）
print("\n=== デバッグ用f-string ===")
x = 10
y = 20
print(f"{x=}, {y=}")  # x=10, y=20
print(f"{x + y=}")    # x + y=30
print(f"{len('hello')=}")  # len('hello')=5

# 複数行のf-string
print("\n=== 複数行f-string ===")
name = "Python"
description = f"""
製品名: {name}
バージョン: {version}
リリース日: {now:%Y-%m-%d}
"""
print(description)

# エスケープ
print("\n=== エスケープ ===")
# 波括弧のエスケープ
print(f"{{これは波括弧}}")
print(f"変数 {{{name}}}")

# クォートの扱い
quote = "Hello"
print(f'シングルクォート: "{quote}"')
print(f"ダブルクォート: '{quote}'")
```

## 10.2 【実行】文字列メソッドチェーンの実行

```python
# string_methods.py

# 基本的な文字列メソッド
print("=== 文字列の変換メソッド ===")
text = "  Hello, World!  "

print(f"元の文字列: '{text}'")
print(f"upper(): '{text.upper()}'")
print(f"lower(): '{text.lower()}'")
print(f"title(): '{text.title()}'")
print(f"capitalize(): '{text.capitalize()}'")
print(f"swapcase(): '{text.swapcase()}'")

# 空白文字の処理
print("\n=== 空白文字の処理 ===")
print(f"strip(): '{text.strip()}'")
print(f"lstrip(): '{text.lstrip()}'")
print(f"rstrip(): '{text.rstrip()}'")
print(f"strip('o'): '{'oooHellooo'.strip('o')}'")

# メソッドチェーン
print("\n=== メソッドチェーン ===")
messy = "  pYtHoN pRoGrAmMiNg  "
cleaned = messy.strip().lower().replace(' ', '_')
print(f"元: '{messy}'")
print(f"整形後: '{cleaned}'")

# 複雑なチェーン
data = "name:John,age:30,city:Tokyo"
result = (data
    .replace(':', '=')
    .replace(',', ' ')
    .upper()
    .split()
)
print(f"\n複雑な変換:")
print(f"元: {data}")
print(f"結果: {result}")

# 検索と置換
print("\n=== 検索と置換 ===")
text = "Python is awesome. Python is powerful."
print(f"元: {text}")
print(f"find('Python'): {text.find('Python')}")
print(f"rfind('Python'): {text.rfind('Python')}")
print(f"count('Python'): {text.count('Python')}")
print(f"replace('Python', 'JavaScript'): {text.replace('Python', 'JavaScript')}")
print(f"replace('Python', 'JS', 1): {text.replace('Python', 'JS', 1)}")

# 分割と結合
print("\n=== 分割と結合 ===")
text = "apple,banana,orange,grape"
fruits = text.split(',')
print(f"split(','): {fruits}")

# 複数の区切り文字
import re
text = "apple;banana,orange|grape"
fruits = re.split('[;,|]', text)
print(f"正規表現split: {fruits}")

# join
words = ['Python', 'is', 'awesome']
print(f"' '.join(): '{' '.join(words)}'")
print(f"'-'.join(): '{'-'.join(words)}'")
print(f"''.join(): '{''.join(words)}'")

# 判定メソッド
print("\n=== 判定メソッド ===")
test_strings = ['Hello', 'hello123', '123', '123.45', '  ', '']

for s in test_strings:
    print(f"\n'{s}':")
    print(f"  isalpha(): {s.isalpha()}")
    print(f"  isdigit(): {s.isdigit()}")
    print(f"  isalnum(): {s.isalnum()}")
    print(f"  isspace(): {s.isspace()}")
    print(f"  isupper(): {s.isupper()}")
    print(f"  islower(): {s.islower()}")

# startswith/endswith
filename = "document.pdf"
print(f"\n'{filename}':")
print(f"  startswith('doc'): {filename.startswith('doc')}")
print(f"  endswith('.pdf'): {filename.endswith('.pdf')}")
print(f"  endswith(('.txt', '.pdf')): {filename.endswith(('.txt', '.pdf'))}")

# 文字列の整形
print("\n=== 文字列の整形 ===")
text = "Python"
print(f"center(20, '*'): '{text.center(20, '*')}'")
print(f"ljust(20, '-'): '{text.ljust(20, '-')}'")
print(f"rjust(20, '='): '{text.rjust(20, '=')}'")
print(f"zfill(10): '{'42'.zfill(10)}'")

# expandtabs
text_with_tabs = "Name:\tJohn\nAge:\t30\nCity:\tTokyo"
print(f"\n元のテキスト:")
print(text_with_tabs)
print(f"\nexpandtabs(10):")
print(text_with_tabs.expandtabs(10))
```

## 10.3 【実行】正規表現の基礎とreモジュール

```python
# regex_basics.py
import re

# 基本的なパターンマッチング
print("=== 基本的なマッチング ===")
text = "The phone number is 123-456-7890"

# search: 最初のマッチを探す
match = re.search(r'\d{3}-\d{3}-\d{4}', text)
if match:
    print(f"見つかった: {match.group()}")
    print(f"位置: {match.start()}-{match.end()}")

# 基本的なパターン
print("\n=== 基本的なパターン ===")
patterns = [
    (r'\d+', '123abc456', '数字の連続'),
    (r'[a-z]+', 'Hello123World', '小文字の連続'),
    (r'[A-Z][a-z]*', 'HelloWorld', '大文字で始まる単語'),
    (r'\w+@\w+\.\w+', 'email: test@example.com', 'メールアドレス'),
    (r'https?://\S+', 'Visit https://python.org', 'URL'),
]

for pattern, text, description in patterns:
    matches = re.findall(pattern, text)
    print(f"{description}: {matches}")

# グループの使用
print("\n=== グループ ===")
# 名前付きグループ
pattern = r'(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})'
text = "Today is 2023-12-25"
match = re.search(pattern, text)

if match:
    print(f"完全なマッチ: {match.group()}")
    print(f"年: {match.group('year')}")
    print(f"月: {match.group('month')}")
    print(f"日: {match.group('day')}")
    print(f"グループ辞書: {match.groupdict()}")

# 繰り返しパターン
print("\n=== 繰り返し ===")
text = "aaa bb cccc d"
patterns = [
    (r'a+', '1つ以上のa'),
    (r'b*', '0個以上のb'),
    (r'c?', '0個または1個のc'),
    (r'c{4}', 'ちょうど4個のc'),
    (r'd{2,4}', '2-4個のd'),
]

for pattern, description in patterns:
    matches = re.findall(pattern, text)
    print(f"{description}: {matches}")

# 文字クラス
print("\n=== 文字クラス ===")
text = "Python3.11 is released in 2023!"
patterns = [
    (r'\d', '数字'),
    (r'\D', '数字以外'),
    (r'\w', '単語文字'),
    (r'\W', '単語文字以外'),
    (r'\s', '空白文字'),
    (r'\S', '空白文字以外'),
]

for pattern, description in patterns:
    matches = re.findall(pattern, text)
    print(f"{description}: {matches[:10]}...")  # 最初の10個

# 置換
print("\n=== 置換 ===")
text = "The price is $100.50"

# 基本的な置換
result = re.sub(r'\$(\d+\.\d+)', r'¥\1', text)
print(f"ドルを円に: {result}")

# 関数を使った置換
def double_price(match):
    price = float(match.group(1))
    return f'${price * 2:.2f}'

result = re.sub(r'\$(\d+\.\d+)', double_price, text)
print(f"価格を2倍に: {result}")

# 複数行とフラグ
print("\n=== フラグ ===")
text = """First Line
second line
THIRD LINE"""

# 大文字小文字を無視
matches = re.findall(r'line', text, re.IGNORECASE)
print(f"IGNORECASE: {matches}")

# 複数行モード
matches = re.findall(r'^.*line$', text, re.MULTILINE | re.IGNORECASE)
print(f"MULTILINE: {matches}")

# コンパイル済み正規表現
print("\n=== コンパイル済み正規表現 ===")
# パフォーマンスが必要な場合
email_pattern = re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
texts = [
    "Contact: john@example.com",
    "Email: alice.smith@company.co.jp",
    "Invalid: not@email",
]

for text in texts:
    if email_pattern.search(text):
        email = email_pattern.search(text).group()
        print(f"有効: {email}")
    else:
        print(f"無効: {text}")
```

### 実用的な正規表現パターン

```python
# regex_practical.py
import re

# よく使うパターン集
patterns = {
    'email': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    'url': r'https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)',
    'ip_address': r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    'phone_jp': r'^0\d{1,4}-\d{1,4}-\d{4}$',
    'postal_code_jp': r'^\d{3}-\d{4}$',
    'hiragana': r'^[ぁ-ん]+$',
    'katakana': r'^[ァ-ヴー]+$',
    'kanji': r'^[一-龯]+$',
}

# テストデータ
test_data = {
    'email': ['test@example.com', 'invalid.email', 'user@domain.jp'],
    'url': ['https://www.python.org', 'http://example.com', 'not-a-url'],
    'ip_address': ['192.168.1.1', '255.255.255.255', '999.999.999.999'],
    'phone_jp': ['03-1234-5678', '090-1234-5678', '123-456'],
    'postal_code_jp': ['100-0001', '1234567', '12-3456'],
    'hiragana': ['ひらがな', 'カタカナ', 'hiragana'],
    'katakana': ['カタカナ', 'ひらがな', 'KATAKANA'],
}

# パターンのテスト
for pattern_name, pattern in patterns.items():
    if pattern_name in test_data:
        print(f"\n=== {pattern_name} ===")
        compiled = re.compile(pattern)
        for test in test_data[pattern_name]:
            match = compiled.match(test)
            print(f"'{test}': {'✓' if match else '✗'}")

# HTMLタグの除去
print("\n=== HTMLタグの除去 ===")
html = '<p>This is <b>bold</b> and <i>italic</i> text.</p>'
text_only = re.sub(r'<[^>]+>', '', html)
print(f"元: {html}")
print(f"テキストのみ: {text_only}")

# ログファイルの解析
print("\n=== ログ解析 ===")
log_entries = """
2023-12-25 10:30:45 [INFO] Application started
2023-12-25 10:31:02 [ERROR] Database connection failed
2023-12-25 10:31:15 [WARNING] Retry attempt 1
2023-12-25 10:31:30 [INFO] Connection restored
"""

pattern = r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \[(\w+)\] (.+)'
for line in log_entries.strip().split('\n'):
    match = re.match(pattern, line)
    if match:
        timestamp, level, message = match.groups()
        if level == 'ERROR':
            print(f"エラー発生: {timestamp} - {message}")
```

## 10.4 【実行】文字エンコーディングとバイト列

```python
# encoding_demo.py

# 文字列とバイト列の変換
print("=== エンコーディング基礎 ===")
text = "Hello, Python! こんにちは"
print(f"元の文字列: {text}")
print(f"型: {type(text)}")

# UTF-8エンコード
utf8_bytes = text.encode('utf-8')
print(f"\nUTF-8: {utf8_bytes}")
print(f"バイト数: {len(utf8_bytes)}")

# その他のエンコーディング
encodings = ['utf-8', 'utf-16', 'shift_jis', 'euc-jp', 'ascii']
for encoding in encodings:
    try:
        encoded = text.encode(encoding)
        print(f"{encoding:10s}: {len(encoded):3d} バイト")
    except UnicodeEncodeError:
        print(f"{encoding:10s}: エンコードエラー")

# デコード
print("\n=== デコード ===")
utf8_bytes = b'Python \xe3\x81\x93\xe3\x82\x93\xe3\x81\xab\xe3\x81\xa1\xe3\x81\xaf'
decoded = utf8_bytes.decode('utf-8')
print(f"バイト列: {utf8_bytes}")
print(f"デコード結果: {decoded}")

# エラーハンドリング
print("\n=== エラーハンドリング ===")
# 不正なバイト列
invalid_bytes = b'Hello \xff\xfe World'

# 異なるエラーハンドリング
handlers = ['strict', 'ignore', 'replace', 'backslashreplace']
for handler in handlers:
    try:
        result = invalid_bytes.decode('utf-8', errors=handler)
        print(f"{handler:15s}: {result}")
    except UnicodeDecodeError as e:
        print(f"{handler:15s}: エラー - {e}")

# バイト列の操作
print("\n=== バイト列の操作 ===")
b1 = b'Hello'
b2 = b' World'
print(f"結合: {b1 + b2}")
print(f"繰り返し: {b1 * 2}")
print(f"スライス: {b1[1:4]}")

# bytearrayは可変
ba = bytearray(b'Hello')
ba[0] = ord('h')
print(f"bytearray: {ba}")

# 16進数表現
print("\n=== 16進数表現 ===")
data = b'Hello'
hex_str = data.hex()
print(f"バイト列: {data}")
print(f"16進数: {hex_str}")
print(f"スペース区切り: {data.hex(' ')}")

# 16進数からバイト列
hex_data = '48656c6c6f'
bytes_data = bytes.fromhex(hex_data)
print(f"\n16進数→バイト: {bytes_data}")

# Base64エンコーディング
import base64
print("\n=== Base64 ===")
original = b'Hello, World!'
encoded = base64.b64encode(original)
decoded = base64.b64decode(encoded)

print(f"元: {original}")
print(f"Base64: {encoded}")
print(f"デコード: {decoded}")

# ファイルのエンコーディング検出
print("\n=== エンコーディング検出 ===")
# 異なるエンコーディングのテスト
test_texts = {
    'utf-8': 'UTF-8: 日本語テキスト',
    'shift_jis': 'Shift_JIS: 日本語テキスト',
    'euc-jp': 'EUC-JP: 日本語テキスト',
}

# BOM（Byte Order Mark）の検出
def detect_bom(data):
    """BOMを検出してエンコーディングを推定"""
    boms = {
        b'\xff\xfe\x00\x00': 'utf-32-le',
        b'\x00\x00\xfe\xff': 'utf-32-be',
        b'\xff\xfe': 'utf-16-le',
        b'\xfe\xff': 'utf-16-be',
        b'\xef\xbb\xbf': 'utf-8-sig',
    }
    
    for bom, encoding in boms.items():
        if data.startswith(bom):
            return encoding, len(bom)
    return None, 0

# BOM付きUTF-8
utf8_with_bom = b'\xef\xbb\xbf' + 'こんにちは'.encode('utf-8')
encoding, bom_len = detect_bom(utf8_with_bom)
print(f"検出されたBOM: {encoding}")
if encoding:
    text = utf8_with_bom[bom_len:].decode('utf-8')
    print(f"テキスト: {text}")
```

### 実用的な文字列処理

```python
# string_practical.py

# CSVデータの処理
print("=== CSV処理 ===")
csv_data = """name,age,city
Alice,30,Tokyo
Bob,25,Osaka
Charlie,35,Kyoto"""

# 手動パース
lines = csv_data.strip().split('\n')
headers = lines[0].split(',')
data = []
for line in lines[1:]:
    values = line.split(',')
    record = dict(zip(headers, values))
    data.append(record)

for record in data:
    print(f"{record['name']:10s} {record['age']:3s}歳 {record['city']}")

# テンプレート処理
print("\n=== テンプレート処理 ===")
from string import Template

template = Template("""
Dear $name,

Thank you for your order #$order_id.
Total amount: $$${amount:.2f}

Best regards,
$company
""")

result = template.safe_substitute(
    name="John Doe",
    order_id="12345",
    amount=150.50,
    company="Python Shop"
)
print(result)

# 文字列の正規化
print("\n=== 文字列の正規化 ===")
import unicodedata

# 全角・半角の統一
text = "Ｐｙｔｈｏｎ３．１１ プログラミング"
normalized = unicodedata.normalize('NFKC', text)
print(f"元: {text}")
print(f"正規化: {normalized}")

# アクセント記号の除去
text = "café résumé naïve"
# NFDで分解してアクセント記号を除去
nfd = unicodedata.normalize('NFD', text)
without_accents = ''.join(c for c in nfd if not unicodedata.combining(c))
print(f"\n元: {text}")
print(f"アクセント除去: {without_accents}")

# パスワードの検証
print("\n=== パスワード検証 ===")
import re

def validate_password(password):
    """パスワードの強度をチェック"""
    checks = {
        '8文字以上': len(password) >= 8,
        '大文字を含む': bool(re.search(r'[A-Z]', password)),
        '小文字を含む': bool(re.search(r'[a-z]', password)),
        '数字を含む': bool(re.search(r'\d', password)),
        '特殊文字を含む': bool(re.search(r'[!@#$%^&*(),.?":{}|<>]', password)),
    }
    
    score = sum(checks.values())
    strength = ['弱い', '普通', '普通', '強い', '強い', '非常に強い'][score]
    
    return checks, score, strength

passwords = ['password', 'Password1', 'P@ssw0rd!', '12345678', 'MyP@ssw0rd123!']
for pwd in passwords:
    checks, score, strength = validate_password(pwd)
    print(f"\n'{pwd}' - {strength} (スコア: {score}/5)")
    for check, passed in checks.items():
        print(f"  {check}: {'✓' if passed else '✗'}")
```

## 10.5 この章のまとめ

- f-stringは簡潔で高速な文字列フォーマット方法
- 文字列メソッドは連鎖（チェーン）して使用できる
- 正規表現は強力なパターンマッチングツール
- 文字エンコーディングの理解は国際化対応に必須
- 適切な文字列処理手法の選択が重要

## 練習問題

1. **f-stringの活用**
   データのリストを受け取り、整形された表を出力する関数を作成してください。
   列幅は動的に調整し、数値は右寄せ、文字列は左寄せにしてください。

2. **正規表現パズル**
   以下を抽出する正規表現を書いてください：
   - 日本の携帯電話番号（080, 090, 070で始まる）
   - クレジットカード番号（4桁-4桁-4桁-4桁）
   - メールアドレスのドメイン部分のみ

3. **文字エンコーディング**
   複数のエンコーディングが混在したファイルを読み込み、
   正しくデコードするプログラムを作成してください。

4. **ログパーサー**
   Webサーバーのアクセスログを解析し、以下を集計してください：
   - アクセス数の多いIPアドレス
   - ステータスコード別の件数
   - アクセスの多い時間帯

5. **テキスト正規化**
   日本語テキストを正規化する関数を作成してください：
   - 全角英数字を半角に変換
   - カタカナ語の表記ゆれを統一
   - 余分な空白の除去

---

次章では、関数定義の文法と実行について詳しく学びます。

[第11章 関数定義の文法と実行 →](../part5/chapter11.md)