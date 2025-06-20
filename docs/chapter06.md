# 第6章：文字と文章を扱おう

これまで数値の計算について学んできましたが、プログラムでは文字や文章の処理も非常に重要です。メールの件名を作成したり、住所を整理したり、テキストデータを分析したりと、文字列処理は日常的に使われます。この章では、Pythonの文字列処理機能を実際のプログラムを作りながら学んでいきましょう。

## 文字列ってなに？

### 文字列の基本概念

**文字列（String）**は、文字の集まりです。プログラムでは、名前、住所、メッセージなど、あらゆるテキストデータを文字列として扱います。

```python
>>> # 文字列の作成
>>> name = "田中太郎"
>>> message = "こんにちは"
>>> email = "tanaka@example.com"

>>> print(type(name))
<class 'str'>
```

### 文字列の作成方法

Pythonでは、いくつかの方法で文字列を作成できます：

```python
>>> # シングルクォート
>>> message1 = 'こんにちは'

>>> # ダブルクォート
>>> message2 = "こんにちは"

>>> # トリプルクォート（複数行）
>>> long_message = """これは
複数行にわたる
長いメッセージです"""

>>> print(long_message)
これは
複数行にわたる
長いメッセージです

>>> # 文字列の中にクォートを含む場合
>>> quote1 = "彼は'こんにちは'と言った"
>>> quote2 = '彼は"こんにちは"と言った'
>>> quote3 = "彼は\"こんにちは\"と言った"  # エスケープ

>>> print(quote1)
>>> print(quote2)
>>> print(quote3)
彼は'こんにちは'と言った
彼は"こんにちは"と言った
彼は"こんにちは"と言った
```

### 文字列の長さ

```python
>>> message = "こんにちは"
>>> print(f"文字数: {len(message)}")
文字数: 5

>>> # 英語と日本語の比較
>>> english = "Hello"
>>> japanese = "こんにちは"
>>> print(f"英語: {len(english)}文字")
>>> print(f"日本語: {len(japanese)}文字")
英語: 5文字
日本語: 5文字
```

## 【実行】メールの件名を組み立てるプログラム

実際にメールの件名を自動生成するプログラムを作ってみましょう。

### ステップ1：基本的な件名作成

```python
>>> # 基本情報
>>> sender_name = "田中太郎"
>>> date = "2024年1月15日"
>>> subject_type = "会議資料"

>>> # 件名の組み立て
>>> subject = f"【{subject_type}】{date} - {sender_name}"
>>> print(f"件名: {subject}")
件名: 【会議資料】2024年1月15日 - 田中太郎

>>> # より複雑な件名
>>> department = "営業部"
>>> project = "新商品企画"
>>> version = "v1.2"

>>> subject = f"【{department}】{project} {subject_type}({version}) - {sender_name}"
>>> print(f"件名: {subject}")
件名: 【営業部】新商品企画 会議資料(v1.2) - 田中太郎
```

### ステップ2：件名テンプレート機能

```python
>>> def create_email_subject(template_type, **kwargs):
...     """メール件名を生成する関数"""
...     templates = {
...         "meeting": "【会議】{date} {meeting_type} - {organizer}",
...         "report": "【報告】{department} {report_type} ({date}) - {author}",
...         "request": "【依頼】{content} - {requester}",
...         "notification": "【お知らせ】{title} - {sender}"
...     }
...     
...     if template_type not in templates:
...         return "【その他】件名なし"
...     
...     template = templates[template_type]
...     try:
...         return template.format(**kwargs)
...     except KeyError as e:
...         return f"エラー: 必要な項目が不足しています ({e})"
... 

>>> # 使用例
>>> meeting_subject = create_email_subject(
...     "meeting",
...     date="2024年1月20日",
...     meeting_type="月次売上会議",
...     organizer="佐藤部長"
... )
>>> print(meeting_subject)
【会議】2024年1月20日 月次売上会議 - 佐藤部長

>>> report_subject = create_email_subject(
...     "report",
...     department="営業部",
...     report_type="月次売上報告書",
...     date="2024年1月",
...     author="田中太郎"
... )
>>> print(report_subject)
【報告】営業部 月次売上報告書 (2024年1月) - 田中太郎
```

### ステップ3：件名の長さ制限機能

```python
>>> def create_safe_subject(template_type, max_length=50, **kwargs):
...     """長さ制限付きの件名生成"""
...     subject = create_email_subject(template_type, **kwargs)
...     
...     if len(subject) > max_length:
...         # 長すぎる場合は省略
...         subject = subject[:max_length-3] + "..."
...     
...     return subject
... 

>>> # 長い件名のテスト
>>> long_subject = create_safe_subject(
...     "meeting",
...     max_length=30,
...     date="2024年1月20日",
...     meeting_type="新商品企画に関する重要な打ち合わせ会議",
...     organizer="佐藤部長"
... )
>>> print(f"短縮版件名: {long_subject}")
>>> print(f"文字数: {len(long_subject)}")
短縮版件名: 【会議】2024年1月20日 新商品企画に関す...
文字数: 30
```

### ステップ4：完全版メール件名ジェネレーター

```python
# メール件名生成プログラム
from datetime import datetime

class EmailSubjectGenerator:
    def __init__(self):
        self.templates = {
            "meeting": "【会議】{date} {meeting_type} - {organizer}",
            "report": "【報告】{department} {report_type} ({period}) - {author}",
            "request": "【依頼】{content} - {requester}から{recipient}へ",
            "notification": "【お知らせ】{title} - {sender}",
            "urgent": "【緊急】{content} - {sender}",
            "followup": "【フォローアップ】{original_subject} - {sender}"
        }
    
    def generate(self, template_type, max_length=None, **kwargs):
        """件名を生成"""
        if template_type not in self.templates:
            available_types = ", ".join(self.templates.keys())
            return f"エラー: 未対応のテンプレート。利用可能: {available_types}"
        
        # 現在日時を自動追加（dateが指定されていない場合）
        if 'date' not in kwargs and template_type in ['meeting', 'report']:
            kwargs['date'] = datetime.now().strftime("%Y年%m月%d日")
        
        template = self.templates[template_type]
        
        try:
            subject = template.format(**kwargs)
        except KeyError as e:
            missing_key = str(e).strip("'")
            return f"エラー: '{missing_key}'が必要です"
        
        # 長さ制限
        if max_length and len(subject) > max_length:
            subject = subject[:max_length-3] + "..."
        
        return subject
    
    def add_template(self, name, template):
        """新しいテンプレートを追加"""
        self.templates[name] = template
    
    def list_templates(self):
        """利用可能なテンプレート一覧"""
        for name, template in self.templates.items():
            print(f"{name}: {template}")

# 使用例
generator = EmailSubjectGenerator()

# 各種件名を生成
subjects = []

subjects.append(generator.generate(
    "meeting",
    meeting_type="プロジェクト進捗会議",
    organizer="田中部長"
))

subjects.append(generator.generate(
    "report",
    department="営業部",
    report_type="四半期売上報告",
    period="2024年Q1",
    author="佐藤太郎"
))

subjects.append(generator.generate(
    "urgent",
    content="システム障害対応について",
    sender="IT部"
))

for i, subject in enumerate(subjects, 1):
    print(f"{i}. {subject}")
```

## 特殊な文字（改行、タブなど）

### エスケープシーケンス

文字列の中で特別な意味を持つ文字を表現するために、**エスケープシーケンス**を使います：

| エスケープシーケンス | 意味 | 例 |
|---------------------|------|-----|
| `\n` | 改行 | `"1行目\n2行目"` |
| `\t` | タブ | `"名前\t年齢"` |
| `\"` | ダブルクォート | `"彼は\"はい\"と言った"` |
| `\'` | シングルクォート | `'彼は\'はい\'と言った'` |
| `\\` | バックスラッシュ | `"C:\\Users\\name"` |
| `\r` | キャリッジリターン | `"行1\r\n行2"` |

### 実際の使用例

```python
>>> # 改行を含むテキスト
>>> address = "〒100-0001\n東京都千代田区千代田1-1\nXXXビル3階"
>>> print(address)
〒100-0001
東京都千代田区千代田1-1
XXXビル3階

>>> # タブ区切りのデータ
>>> header = "名前\t年齢\t職業"
>>> data1 = "田中太郎\t30\tエンジニア"
>>> data2 = "佐藤花子\t25\tデザイナー"

>>> print(header)
>>> print(data1)
>>> print(data2)
名前	年齢	職業
田中太郎	30	エンジニア
佐藤花子	25	デザイナー

>>> # ファイルパス（Windows）
>>> file_path = "C:\\Users\\田中\\Documents\\report.txt"
>>> print(file_path)
C:\Users\田中\Documents\report.txt

>>> # Raw文字列（エスケープしない）
>>> raw_path = r"C:\Users\田中\Documents\report.txt"
>>> print(raw_path)
C:\Users\田中\Documents\report.txt
```

### Raw文字列とf-string

```python
>>> # Raw文字列（r"...") - エスケープを無視
>>> regex_pattern = r"\d{3}-\d{4}-\d{4}"  # 電話番号パターン
>>> print(regex_pattern)
\d{3}-\d{4}-\d{4}

>>> # f-string（f"...") - 変数埋め込み
>>> name = "田中"
>>> age = 30
>>> message = f"{name}さんは{age}歳です"
>>> print(message)
田中さんは30歳です

>>> # Raw f-string（rf"..." または fr"..."）
>>> name = "田中"
>>> path_pattern = rf"C:\Users\{name}\Documents\*.txt"
>>> print(path_pattern)
C:\Users\田中\Documents\*.txt
```

## 【実行】住所の整形プログラム

住所データの整理と整形プログラムを作ってみましょう。

### ステップ1：基本的な住所整形

```python
>>> # 住所データ（整形前）
>>> raw_addresses = [
...     "  東京都渋谷区神南1-2-3  ",
...     "大阪府大阪市北区梅田１−２−３　",
...     "愛知県名古屋市中区栄3-4-5 ４階",
...     "〒100-0001 東京都千代田区千代田1-1"
... ]

>>> # 基本的な整形
>>> cleaned_addresses = []
>>> for addr in raw_addresses:
...     # 前後の空白を削除
...     clean_addr = addr.strip()
...     # 全角数字を半角に変換（簡易版）
...     clean_addr = clean_addr.replace("１", "1").replace("２", "2").replace("３", "3")
...     clean_addr = clean_addr.replace("４", "4").replace("５", "5")
...     # 全角ハイフンを半角に
...     clean_addr = clean_addr.replace("−", "-").replace("－", "-")
...     cleaned_addresses.append(clean_addr)
... 

>>> print("=== 整形後の住所 ===")
>>> for i, addr in enumerate(cleaned_addresses, 1):
...     print(f"{i}. {addr}")
=== 整形後の住所 ===
1. 東京都渋谷区神南1-2-3
2. 大阪府大阪市北区梅田1-2-3
3. 愛知県名古屋市中区栄3-4-5 4階
4. 〒100-0001 東京都千代田区千代田1-1
```

### ステップ2：郵便番号の抽出と分離

```python
>>> import re

>>> def parse_address(address):
...     """住所を郵便番号と住所に分離"""
...     # 郵便番号のパターン（〒xxx-xxxx または xxx-xxxx）
...     postal_pattern = r'〒?(\d{3}-\d{4})'
...     
...     match = re.search(postal_pattern, address)
...     if match:
...         postal_code = match.group(1)
...         # 郵便番号部分を除去
...         address_only = re.sub(r'〒?\d{3}-\d{4}\s*', '', address)
...         return postal_code, address_only.strip()
...     else:
...         return None, address
... 

>>> # テスト
>>> test_addresses = [
...     "〒100-0001 東京都千代田区千代田1-1",
...     "150-0041 東京都渋谷区神南1-2-3",
...     "東京都新宿区新宿3-4-5"
... ]

>>> for addr in test_addresses:
...     postal, address_part = parse_address(addr)
...     if postal:
...         print(f"郵便番号: {postal}")
...         print(f"住所: {address_part}")
...     else:
...         print(f"郵便番号なし: {address_part}")
...     print("---")
郵便番号: 100-0001
住所: 東京都千代田区千代田1-1
---
郵便番号: 150-0041
住所: 東京都渋谷区神南1-2-3
---
郵便番号なし: 東京都新宿区新宿3-4-5
---
```

### ステップ3：住所の階層分解

```python
>>> def split_address(address):
...     """住所を都道府県、市区町村、町名・番地に分解"""
...     import re
...     
...     # 都道府県のパターン
...     prefecture_pattern = r'^(.*?[都道府県])'
...     # 市区町村のパターン
...     city_pattern = r'([^都道府県]*?[市区町村])'
...     
...     prefecture_match = re.search(prefecture_pattern, address)
...     prefecture = prefecture_match.group(1) if prefecture_match else ""
...     
...     remaining = address[len(prefecture):] if prefecture else address
...     
...     city_match = re.search(city_pattern, remaining)
...     city = city_match.group(1) if city_match else ""
...     
...     town = remaining[len(city):] if city else remaining
...     
...     return {
...         "prefecture": prefecture,
...         "city": city,
...         "town": town.strip()
...     }
... 

>>> # テスト
>>> addresses = [
...     "東京都渋谷区神南1-2-3",
...     "大阪府大阪市北区梅田1-2-3",
...     "愛知県名古屋市中区栄3-4-5"
... ]

>>> for addr in addresses:
...     parts = split_address(addr)
...     print(f"元の住所: {addr}")
...     print(f"  都道府県: {parts['prefecture']}")
...     print(f"  市区町村: {parts['city']}")
...     print(f"  町名・番地: {parts['town']}")
...     print("---")
元の住所: 東京都渋谷区神南1-2-3
  都道府県: 東京都
  市区町村: 渋谷区
  町名・番地: 神南1-2-3
---
元の住所: 大阪府大阪市北区梅田1-2-3
  都道府県: 大阪府
  市区町村: 大阪市北区
  町名・番地: 梅田1-2-3
---
元の住所: 愛知県名古屋市中区栄3-4-5
  都道府県: 愛知県
  市区町村: 名古屋市中区
  町名・番地: 栄3-4-5
---
```

### ステップ4：完全版住所整形プログラム

```python
# 住所整形プログラム
import re

class AddressFormatter:
    def __init__(self):
        # 全角→半角変換テーブル
        self.zenkaku_to_hankaku = {
            '０': '0', '１': '1', '２': '2', '３': '3', '４': '4',
            '５': '5', '６': '6', '７': '7', '８': '8', '９': '9',
            '−': '-', '－': '-', '～': '~', '：': ':'
        }
    
    def normalize_text(self, text):
        """テキストの正規化"""
        # 前後の空白削除
        text = text.strip()
        
        # 全角文字を半角に変換
        for zenkaku, hankaku in self.zenkaku_to_hankaku.items():
            text = text.replace(zenkaku, hankaku)
        
        # 複数の空白を単一に
        text = re.sub(r'\s+', ' ', text)
        
        return text
    
    def extract_postal_code(self, address):
        """郵便番号の抽出"""
        pattern = r'〒?(\d{3}-\d{4})'
        match = re.search(pattern, address)
        
        if match:
            postal_code = match.group(1)
            # 郵便番号部分を削除
            cleaned_address = re.sub(r'〒?\d{3}-\d{4}\s*', '', address)
            return postal_code, cleaned_address.strip()
        
        return None, address
    
    def split_address_parts(self, address):
        """住所の階層分解"""
        # 都道府県
        prefecture_pattern = r'^(.*?[都道府県])'
        prefecture_match = re.search(prefecture_pattern, address)
        prefecture = prefecture_match.group(1) if prefecture_match else ""
        
        remaining = address[len(prefecture):]
        
        # 市区町村
        city_pattern = r'^(.*?[市区町村])'
        city_match = re.search(city_pattern, remaining)
        city = city_match.group(1) if city_match else ""
        
        # 残り（町名・番地）
        town = remaining[len(city):].strip()
        
        return prefecture, city, town
    
    def format_address(self, raw_address):
        """住所の完全整形"""
        # Step 1: テキスト正規化
        normalized = self.normalize_text(raw_address)
        
        # Step 2: 郵便番号抽出
        postal_code, address_without_postal = self.extract_postal_code(normalized)
        
        # Step 3: 住所階層分解
        prefecture, city, town = self.split_address_parts(address_without_postal)
        
        return {
            'original': raw_address,
            'postal_code': postal_code,
            'prefecture': prefecture,
            'city': city,
            'town': town,
            'formatted': f"{prefecture}{city}{town}"
        }
    
    def format_multiple(self, addresses):
        """複数住所の一括整形"""
        results = []
        for addr in addresses:
            result = self.format_address(addr)
            results.append(result)
        return results

# 使用例
formatter = AddressFormatter()

test_addresses = [
    "  〒100-0001  東京都千代田区千代田１−１  ",
    "150-0041 東京都渋谷区神南1-2-3 ４階",
    "大阪府大阪市北区梅田１−２−３　",
    "愛知県名古屋市中区栄3-4-5 XXXビル",
    "〒810-0001 福岡県福岡市中央区天神2-3-4"
]

results = formatter.format_multiple(test_addresses)

print("=== 住所整形結果 ===")
for i, result in enumerate(results, 1):
    print(f"\n{i}. 元の住所: {result['original']}")
    if result['postal_code']:
        print(f"   郵便番号: 〒{result['postal_code']}")
    print(f"   都道府県: {result['prefecture']}")
    print(f"   市区町村: {result['city']}")
    print(f"   町名番地: {result['town']}")
    print(f"   整形後: {result['formatted']}")
```

## 文字列の中身を調べよう

### 文字列の基本操作

文字列には、その内容を調べたり操作したりするための多くのメソッドがあります：

```python
>>> text = "Hello Python Programming"

>>> # 基本的な情報
>>> print(f"長さ: {len(text)}")
>>> print(f"大文字: {text.upper()}")
>>> print(f"小文字: {text.lower()}")
>>> print(f"タイトルケース: {text.title()}")

長さ: 24
大文字: HELLO PYTHON PROGRAMMING
小文字: hello python programming
タイトルケース: Hello Python Programming

>>> # 検索
>>> print(f"'Python'の位置: {text.find('Python')}")
>>> print(f"'Python'が含まれる: {'Python' in text}")
>>> print(f"'Java'が含まれる: {'Java' in text}")

'Python'の位置: 6
'Python'が含まれる: True
'Java'が含まれる: False

>>> # 文字列の判定
>>> print(f"数字のみ: {'123'.isdigit()}")
>>> print(f"アルファベットのみ: {'abc'.isalpha()}")
>>> print(f"英数字のみ: {'abc123'.isalnum()}")
>>> print(f"空白のみ: {'   '.isspace()}")

数字のみ: True
アルファベットのみ: True
英数字のみ: True
空白のみ: True
```

### 文字列の分割と結合

```python
>>> # 分割
>>> sentence = "Python,Java,JavaScript,Ruby"
>>> languages = sentence.split(',')
>>> print(languages)
['Python', 'Java', 'JavaScript', 'Ruby']

>>> # 行分割
>>> multiline = """第1行
第2行
第3行"""
>>> lines = multiline.split('\n')
>>> print(lines)
['第1行', '第2行', '第3行']

>>> # 結合
>>> words = ['Hello', 'Python', 'World']
>>> sentence = ' '.join(words)
>>> print(sentence)
Hello Python World

>>> # CSV形式で結合
>>> data = ['田中', '30', 'エンジニア']
>>> csv_line = ','.join(data)
>>> print(csv_line)
田中,30,エンジニア
```

### 文字列の置換と削除

```python
>>> text = "  Hello Python World  "

>>> # 置換
>>> new_text = text.replace('Python', 'Java')
>>> print(f"置換後: {new_text}")
置換後:   Hello Java World  

>>> # 空白削除
>>> print(f"前後空白削除: '{text.strip()}'")
>>> print(f"左空白削除: '{text.lstrip()}'")
>>> print(f"右空白削除: '{text.rstrip()}'")

前後空白削除: 'Hello Python World'
左空白削除: 'Hello Python World  '
右空白削除:   Hello Python World'

>>> # 特定文字の削除
>>> phone = "090-1234-5678"
>>> digits_only = phone.replace('-', '')
>>> print(f"ハイフン削除: {digits_only}")
ハイフン削除: 09012345678
```

### 文字列のインデックスとスライス

```python
>>> text = "Python"

>>> # インデックス（0から始まる）
>>> print(f"最初の文字: {text[0]}")
>>> print(f"最後の文字: {text[-1]}")
>>> print(f"後ろから2番目: {text[-2]}")

最初の文字: P
最後の文字: n
後ろから2番目: o

>>> # スライス
>>> print(f"最初の3文字: {text[:3]}")
>>> print(f"3文字目以降: {text[3:]}")
>>> print(f"2-4文字目: {text[2:5]}")
>>> print(f"逆順: {text[::-1]}")

最初の3文字: Pyt
3文字目以降: hon
2-4文字目: tho
逆順: nohtyP

>>> # 日本語でも同様
>>> japanese = "こんにちは"
>>> print(f"最初の2文字: {japanese[:2]}")
>>> print(f"最後の2文字: {japanese[-2:]}")

最初の2文字: こん
最後の2文字: ちは
```

### 実用的な文字列処理の例

```python
>>> # メールアドレスの検証（簡易版）
>>> def is_valid_email(email):
...     """簡易メールアドレス検証"""
...     if '@' not in email:
...         return False
...     
...     parts = email.split('@')
...     if len(parts) != 2:
...         return False
...     
...     local, domain = parts
...     
...     # 空文字チェック
...     if not local or not domain:
...         return False
...     
...     # ドメインにピリオドが必要
...     if '.' not in domain:
...         return False
...     
...     return True
... 

>>> # テスト
>>> emails = [
...     "user@example.com",
...     "test@domain.co.jp",
...     "invalid-email",
...     "@example.com",
...     "user@"
... ]

>>> for email in emails:
...     result = "有効" if is_valid_email(email) else "無効"
...     print(f"{email}: {result}")

user@example.com: 有効
test@domain.co.jp: 有効
invalid-email: 無効
@example.com: 無効
user@: 無効

>>> # パスワード強度チェック
>>> def check_password_strength(password):
...     """パスワード強度チェック"""
...     score = 0
...     feedback = []
...     
...     # 長さチェック
...     if len(password) >= 8:
...         score += 1
...     else:
...         feedback.append("8文字以上にしてください")
...     
...     # 大文字チェック
...     if any(c.isupper() for c in password):
...         score += 1
...     else:
...         feedback.append("大文字を含めてください")
...     
...     # 小文字チェック
...     if any(c.islower() for c in password):
...         score += 1
...     else:
...         feedback.append("小文字を含めてください")
...     
...     # 数字チェック
...     if any(c.isdigit() for c in password):
...         score += 1
...     else:
...         feedback.append("数字を含めてください")
...     
...     # 記号チェック
...     symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"
...     if any(c in symbols for c in password):
...         score += 1
...     else:
...         feedback.append("記号を含めてください")
...     
...     strength_levels = ["非常に弱い", "弱い", "普通", "強い", "非常に強い"]
...     strength = strength_levels[min(score, 4)]
...     
...     return {
...         "score": score,
...         "strength": strength,
...         "feedback": feedback
...     }
... 

>>> # パスワード強度テスト
>>> passwords = [
...     "password",
...     "Password1",
...     "Password123!",
...     "MyStr0ng!Pass"
... ]

>>> for pwd in passwords:
...     result = check_password_strength(pwd)
...     print(f"\nパスワード: {pwd}")
...     print(f"強度: {result['strength']} (スコア: {result['score']}/5)")
...     if result['feedback']:
...         print("改善点:")
...         for tip in result['feedback']:
...             print(f"  - {tip}")
```

## まとめ：文字列処理の基本

この章で学んだことをまとめましょう：

### 文字列の基本
- シングル・ダブル・トリプルクォートでの作成
- 文字列の長さ（len()）
- エスケープシーケンス（\n, \t, \"など）
- Raw文字列とf-string

### 実用的な処理
- メール件名の自動生成
- 住所データの整理と正規化
- 全角・半角文字の変換
- 郵便番号の抽出

### 文字列操作メソッド
- 大文字・小文字変換（upper(), lower(), title()）
- 検索と判定（find(), in演算子, isdigit()など）
- 分割と結合（split(), join()）
- 置換と削除（replace(), strip()）

### インデックスとスライス
- 文字の位置指定（[0], [-1]）
- 部分文字列の抽出（[start:end]）
- 逆順表示（[::-1]）

### 実用的な応用
- メールアドレス検証
- パスワード強度チェック
- データクリーニング
- テキスト解析

次の章では、これまで学んだ数値と文字列の知識を使って、変数というプログラミングの重要な概念を深く学んでいきます。変数を使って情報を管理し、より複雑で実用的なプログラムを作成していきましょう！