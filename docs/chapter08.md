# 第8章：コンピュータに判断させよう

これまでの章では、決まった処理を順番に実行するプログラムを作ってきました。しかし、実際のプログラムでは「もしも〜だったら〜する」という判断が必要になります。この章では、**条件分岐**を使ってコンピュータに判断させる方法を学びます。年齢による映画料金計算やパスワード強度チェックなど、実用的なプログラムを作りながら、プログラムに知能を持たせてみましょう。

## もしも〜だったら（if文）

### 条件分岐の基本概念

**条件分岐**とは、ある条件が満たされるかどうかによって、実行する処理を変えることです。これは私たちが日常的に行っている判断と同じです：

**日常の例：**
- もし雨が降っていたら、傘を持って行く
- もし時間が午前中だったら、「おはようございます」と挨拶する
- もし残高が足りなかったら、お金を下ろしに行く

**プログラムの例：**
- もしユーザーが成人だったら、大人料金を適用する
- もしパスワードが正しかったら、ログインを許可する
- もし在庫が不足していたら、警告メッセージを表示する

### if文の基本構文

Pythonのif文は以下の形で書きます：

```python
if 条件:
    条件が真のときに実行する処理
```

**重要なポイント：**
1. `if`の後に条件を書く
2. 条件の後に`:`（コロン）を付ける
3. 実行したい処理は**インデント**（字下げ）して書く

### 簡単な例から始めよう

```python
>>> age = 20

>>> if age >= 18:
...     print("成人です")
成人です

>>> # 条件が偽の場合は何も実行されない
>>> age = 16

>>> if age >= 18:
...     print("成人です")
>>> # 何も表示されない
```

### if-else文

条件が偽の場合の処理も書きたい場合は、`else`を使います：

```python
>>> age = 16

>>> if age >= 18:
...     print("成人です")
... else:
...     print("未成年です")
未成年です

>>> # 年齢に応じたメッセージ
>>> name = "田中太郎"
>>> age = 25

>>> if age >= 18:
...     print(f"{name}さんは成人です")
... else:
...     print(f"{name}さんは未成年です")
田中太郎さんは成人です
```

### if-elif-else文

複数の条件を判定したい場合は、`elif`（else if）を使います：

```python
>>> score = 85

>>> if score >= 90:
...     grade = "A"
... elif score >= 80:
...     grade = "B"
... elif score >= 70:
...     grade = "C"
... elif score >= 60:
...     grade = "D"
... else:
...     grade = "F"

>>> print(f"点数: {score}, 評価: {grade}")
点数: 85, 評価: B
```

**重要：**`elif`は上から順番に評価され、最初に真になった条件だけが実行されます。

## 【実行】年齢による映画料金計算プログラム

実際の映画館の料金システムを模したプログラムを作ってみましょう。

### ステップ1：基本的な年齢別料金

```python
>>> def calculate_movie_ticket_price(age):
...     """年齢に基づいて映画チケット料金を計算"""
...     
...     if age < 3:
...         price = 0  # 3歳未満無料
...         category = "幼児（無料）"
...     elif age < 12:
...         price = 1000  # 子供料金
...         category = "子供"
...     elif age < 18:
...         price = 1300  # 学生料金
...         category = "学生"
...     elif age < 60:
...         price = 1800  # 一般料金
...         category = "一般"
...     else:
...         price = 1200  # シニア料金
...         category = "シニア"
...     
...     return price, category
... 

>>> # テスト用の年齢データ
>>> test_ages = [2, 8, 15, 25, 45, 65, 80]

>>> print("=== 映画チケット料金 ===")
>>> for age in test_ages:
...     price, category = calculate_movie_ticket_price(age)
...     print(f"{age}歳: {category} - {price}円")

=== 映画チケット料金 ===
2歳: 幼児（無料） - 0円
8歳: 子供 - 1000円
15歳: 学生 - 1300円
25歳: 一般 - 1800円
45歳: 一般 - 1800円
65歳: シニア - 1200円
80歳: シニア - 1200円
```

### ステップ2：時間帯による割引

```python
>>> import datetime

>>> def get_time_discount(current_time):
...     """時間帯による割引を計算"""
...     hour = current_time.hour
...     
...     if hour < 10:
...         return 0.2, "早朝割引"  # 20%オフ
...     elif hour < 18:
...         return 0, "通常料金"      # 割引なし
...     elif hour < 20:
...         return 0.1, "夕方割引"   # 10%オフ
...     else:
...         return 0.3, "レイト割引" # 30%オフ
... 

>>> def calculate_final_price(age, show_time=None):
...     """最終的な料金を計算（時間割引込み）"""
...     if show_time is None:
...         show_time = datetime.datetime.now()
...     
...     # 基本料金を取得
...     base_price, age_category = calculate_movie_ticket_price(age)
...     
...     # 時間割引を取得
...     discount_rate, time_category = get_time_discount(show_time)
...     
...     # 最終料金を計算
...     discount_amount = base_price * discount_rate
...     final_price = base_price - discount_amount
...     
...     return {
...         "age": age,
...         "age_category": age_category,
...         "base_price": base_price,
...         "time_category": time_category,
...         "discount_rate": discount_rate,
...         "discount_amount": discount_amount,
...         "final_price": final_price,
...         "show_time": show_time.strftime("%H:%M")
...     }
... 

>>> # 異なる時間帯でのテスト
>>> test_times = [
...     datetime.datetime(2024, 1, 1, 9, 0),   # 9:00 早朝
...     datetime.datetime(2024, 1, 1, 14, 0),  # 14:00 昼間
...     datetime.datetime(2024, 1, 1, 19, 0),  # 19:00 夕方
...     datetime.datetime(2024, 1, 1, 22, 0),  # 22:00 深夜
... ]

>>> age = 25  # 一般料金
>>> print("=== 時間帯別料金（25歳・一般） ===")
>>> for test_time in test_times:
...     result = calculate_final_price(age, test_time)
...     print(f"{result['show_time']}: {result['time_category']}")
...     print(f"  基本料金: {result['base_price']}円")
...     print(f"  割引: {result['discount_rate']:.0%} ({result['discount_amount']:.0f}円)")
...     print(f"  最終料金: {result['final_price']:.0f}円")
...     print("---")
```

### ステップ3：会員割引とポイント還元

```python
>>> def calculate_member_benefits(is_member, member_level, final_price):
...     """会員特典を計算"""
...     if not is_member:
...         return 0, 0, "非会員"
...     
...     # 会員レベル別の割引率
...     if member_level == "ゴールド":
...         member_discount_rate = 0.15
...         point_rate = 0.05
...     elif member_level == "シルバー":
...         member_discount_rate = 0.10
...         point_rate = 0.03
...     else:  # ブロンズ
...         member_discount_rate = 0.05
...         point_rate = 0.02
...     
...     member_discount = final_price * member_discount_rate
...     points_earned = int(final_price * point_rate)
...     
...     return member_discount, points_earned, f"{member_level}会員"
... 

>>> def calculate_complete_price(age, is_member=False, member_level="ブロンズ", show_time=None):
...     """すべての割引を適用した最終料金計算"""
...     # 基本料金と時間割引
...     price_info = calculate_final_price(age, show_time)
...     
...     # 会員割引
...     member_discount, points, member_status = calculate_member_benefits(
...         is_member, member_level, price_info["final_price"]
...     )
...     
...     # 最終計算
...     final_price = price_info["final_price"] - member_discount
...     
...     return {
...         **price_info,
...         "is_member": is_member,
...         "member_status": member_status,
...         "member_discount": member_discount,
...         "points_earned": points,
...         "total_discount": price_info["discount_amount"] + member_discount,
...         "final_price_with_member": final_price
...     }
... 

>>> # 完全版テスト
>>> customers = [
...     {"name": "田中太郎", "age": 25, "is_member": False},
...     {"name": "佐藤花子", "age": 15, "is_member": True, "member_level": "シルバー"},
...     {"name": "鈴木一郎", "age": 70, "is_member": True, "member_level": "ゴールド"},
... ]

>>> show_time = datetime.datetime(2024, 1, 1, 19, 0)  # 19:00上映

>>> print("=== 完全版料金計算 ===")
>>> for customer in customers:
...     result = calculate_complete_price(
...         customer["age"],
...         customer.get("is_member", False),
...         customer.get("member_level", "ブロンズ"),
...         show_time
...     )
...     
...     print(f"お客様: {customer['name']} ({result['age']}歳)")
...     print(f"カテゴリ: {result['age_category']}")
...     print(f"上映時間: {result['show_time']} ({result['time_category']})")
...     print(f"会員ステータス: {result['member_status']}")
...     print(f"基本料金: {result['base_price']}円")
...     print(f"時間割引: -{result['discount_amount']:.0f}円")
...     print(f"会員割引: -{result['member_discount']:.0f}円")
...     print(f"最終料金: {result['final_price_with_member']:.0f}円")
...     if result['is_member']:
...         print(f"獲得ポイント: {result['points_earned']}pt")
...     print("=" * 30)
```

### ステップ4：映画チケット販売システム

```python
# 映画チケット販売システム
from datetime import datetime, time

class MovieTicketSystem:
    def __init__(self):
        # 基本料金設定
        self.age_prices = {
            "幼児": {"min_age": 0, "max_age": 2, "price": 0},
            "子供": {"min_age": 3, "max_age": 11, "price": 1000},
            "学生": {"min_age": 12, "max_age": 17, "price": 1300},
            "一般": {"min_age": 18, "max_age": 59, "price": 1800},
            "シニア": {"min_age": 60, "max_age": 120, "price": 1200}
        }
        
        # 時間帯割引設定
        self.time_discounts = [
            {"start": time(0, 0), "end": time(9, 59), "rate": 0.2, "name": "早朝割引"},
            {"start": time(10, 0), "end": time(17, 59), "rate": 0.0, "name": "通常料金"},
            {"start": time(18, 0), "end": time(19, 59), "rate": 0.1, "name": "夕方割引"},
            {"start": time(20, 0), "end": time(23, 59), "rate": 0.3, "name": "レイト割引"}
        ]
        
        # 会員レベル設定
        self.member_levels = {
            "ブロンズ": {"discount": 0.05, "point_rate": 0.02},
            "シルバー": {"discount": 0.10, "point_rate": 0.03},
            "ゴールド": {"discount": 0.15, "point_rate": 0.05}
        }
    
    def get_age_category_and_price(self, age):
        """年齢から料金カテゴリと基本料金を取得"""
        for category, info in self.age_prices.items():
            if info["min_age"] <= age <= info["max_age"]:
                return category, info["price"]
        return "一般", self.age_prices["一般"]["price"]  # デフォルト
    
    def get_time_discount(self, show_time):
        """時間帯割引を取得"""
        show_time_only = show_time.time()
        
        for discount_info in self.time_discounts:
            if discount_info["start"] <= show_time_only <= discount_info["end"]:
                return discount_info["rate"], discount_info["name"]
        
        return 0.0, "通常料金"  # デフォルト
    
    def calculate_ticket_price(self, age, show_time, is_member=False, member_level="ブロンズ"):
        """チケット料金を計算"""
        # 基本料金
        age_category, base_price = self.get_age_category_and_price(age)
        
        # 時間割引
        time_discount_rate, time_discount_name = self.get_time_discount(show_time)
        time_discount_amount = base_price * time_discount_rate
        price_after_time_discount = base_price - time_discount_amount
        
        # 会員割引
        if is_member and member_level in self.member_levels:
            member_info = self.member_levels[member_level]
            member_discount_rate = member_info["discount"]
            point_rate = member_info["point_rate"]
            member_status = f"{member_level}会員"
        else:
            member_discount_rate = 0
            point_rate = 0
            member_status = "非会員"
        
        member_discount_amount = price_after_time_discount * member_discount_rate
        final_price = price_after_time_discount - member_discount_amount
        points_earned = int(final_price * point_rate) if is_member else 0
        
        return {
            "age": age,
            "age_category": age_category,
            "base_price": base_price,
            "time_discount_name": time_discount_name,
            "time_discount_rate": time_discount_rate,
            "time_discount_amount": time_discount_amount,
            "member_status": member_status,
            "member_discount_rate": member_discount_rate,
            "member_discount_amount": member_discount_amount,
            "final_price": final_price,
            "points_earned": points_earned,
            "show_time": show_time.strftime("%Y-%m-%d %H:%M"),
            "total_savings": time_discount_amount + member_discount_amount
        }
    
    def print_ticket_receipt(self, ticket_info):
        """チケット料金の明細を表示"""
        print("=" * 40)
        print("     映画チケット料金明細")
        print("=" * 40)
        print(f"年齢: {ticket_info['age']}歳 ({ticket_info['age_category']})")
        print(f"上映時間: {ticket_info['show_time']}")
        print(f"会員ステータス: {ticket_info['member_status']}")
        print("-" * 40)
        print(f"基本料金: {ticket_info['base_price']:,}円")
        
        if ticket_info['time_discount_amount'] > 0:
            print(f"{ticket_info['time_discount_name']}: -{ticket_info['time_discount_amount']:,.0f}円")
        
        if ticket_info['member_discount_amount'] > 0:
            print(f"会員割引: -{ticket_info['member_discount_amount']:,.0f}円")
        
        print("-" * 40)
        print(f"お支払い金額: {ticket_info['final_price']:,.0f}円")
        
        if ticket_info['total_savings'] > 0:
            print(f"お得額: {ticket_info['total_savings']:,.0f}円")
        
        if ticket_info['points_earned'] > 0:
            print(f"獲得ポイント: {ticket_info['points_earned']}pt")
        
        print("=" * 40)

# 使用例
ticket_system = MovieTicketSystem()

# テストケース
test_cases = [
    {"age": 8, "show_time": datetime(2024, 1, 1, 10, 30), "is_member": False},
    {"age": 25, "show_time": datetime(2024, 1, 1, 21, 0), "is_member": True, "member_level": "ゴールド"},
    {"age": 70, "show_time": datetime(2024, 1, 1, 14, 0), "is_member": True, "member_level": "シルバー"}
]

for i, case in enumerate(test_cases, 1):
    print(f"\n--- テストケース {i} ---")
    ticket_info = ticket_system.calculate_ticket_price(**case)
    ticket_system.print_ticket_receipt(ticket_info)
```

## 真偽値（TrueとFalse）

条件分岐を理解するために、**真偽値**（ブール値）について詳しく学びましょう。

### ブール値の基本

Pythonには、真偽を表すための特別なデータ型があります：

```python
>>> # ブール値の基本
>>> is_adult = True
>>> is_student = False

>>> print(type(is_adult))
<class 'bool'>

>>> print(f"成人: {is_adult}")
>>> print(f"学生: {is_student}")

成人: True
学生: False
```

### 比較演算子

条件を作るために使用する比較演算子：

| 演算子 | 意味 | 例 | 結果 |
|--------|------|-----|------|
| `==` | 等しい | `5 == 5` | `True` |
| `!=` | 等しくない | `5 != 3` | `True` |
| `<` | より小さい | `3 < 5` | `True` |
| `<=` | 以下 | `5 <= 5` | `True` |
| `>` | より大きい | `7 > 3` | `True` |
| `>=` | 以上 | `5 >= 7` | `False` |

```python
>>> age = 25
>>> limit = 18

>>> print(f"{age} == {limit}: {age == limit}")
>>> print(f"{age} != {limit}: {age != limit}")
>>> print(f"{age} > {limit}: {age > limit}")
>>> print(f"{age} >= {limit}: {age >= limit}")

25 == 18: False
25 != 18: True
25 > 18: True
25 >= 18: True
```

### 文字列の比較

```python
>>> name1 = "田中"
>>> name2 = "佐藤"
>>> name3 = "田中"

>>> print(f"'{name1}' == '{name3}': {name1 == name3}")
>>> print(f"'{name1}' != '{name2}': {name1 != name2}")

'田中' == '田中': True
'田中' != '佐藤': True

>>> # 文字列の辞書順比較
>>> print(f"'apple' < 'banana': {'apple' < 'banana'}")
>>> print(f"'zebra' > 'apple': {'zebra' > 'apple'}")

'apple' < 'banana': True
'zebra' > 'apple': True
```

### Pythonにおける「偽」とみなされる値

Pythonでは、`False`以外にも「偽」とみなされる値があります：

```python
>>> # 偽とみなされる値
>>> false_values = [
...     False,
...     0,           # ゼロ
...     0.0,         # ゼロの浮動小数点
...     "",          # 空文字列
...     [],          # 空リスト
...     {},          # 空辞書
...     None         # None値
... ]

>>> for value in false_values:
...     print(f"{repr(value):>10}: {bool(value)}")

     False: False
         0: False
       0.0: False
        '': False
        []: False
        {}: False
      None: False

>>> # 真とみなされる値（上記以外のすべて）
>>> true_values = [
...     True,
...     1,           # ゼロ以外の数
...     -1,          # 負の数も真
...     "hello",     # 空でない文字列
...     [1, 2, 3],   # 空でないリスト
...     {"key": "value"}  # 空でない辞書
... ]

>>> for value in true_values:
...     print(f"{repr(value):>15}: {bool(value)}")

           True: True
              1: True
             -1: True
        'hello': True
      [1, 2, 3]: True
{'key': 'value'}: True
```

## 【実行】パスワード強度チェックプログラム

実用的なパスワード強度チェックプログラムを作って、複雑な条件分岐を学びましょう。

### ステップ1：基本的な強度チェック

```python
>>> def check_password_basic(password):
...     """基本的なパスワード強度チェック"""
...     
...     # 長さチェック
...     if len(password) < 8:
...         return False, "パスワードは8文字以上にしてください"
...     
...     # 英数字チェック
...     has_letter = False
...     has_digit = False
...     
...     for char in password:
...         if char.isalpha():  # アルファベット
...             has_letter = True
...         elif char.isdigit():  # 数字
...             has_digit = True
...     
...     if not has_letter:
...         return False, "アルファベットを含めてください"
...     
...     if not has_digit:
...         return False, "数字を含めてください"
...     
...     return True, "パスワードは有効です"
... 

>>> # テスト
>>> test_passwords = [
...     "abc",           # 短い
...     "abcdefgh",      # 数字なし
...     "12345678",      # アルファベットなし
...     "abc12345"       # 有効
... ]

>>> print("=== 基本パスワードチェック ===")
>>> for pwd in test_passwords:
...     is_valid, message = check_password_basic(pwd)
...     status = "✓" if is_valid else "✗"
...     print(f"{status} '{pwd}': {message}")

=== 基本パスワードチェック ===
✗ 'abc': パスワードは8文字以上にしてください
✗ 'abcdefgh': 数字を含めてください
✗ '12345678': アルファベットを含めてください
✓ 'abc12345': パスワードは有効です
```

### ステップ2：詳細な強度評価

```python
>>> def evaluate_password_strength(password):
...     """詳細なパスワード強度評価"""
...     
...     score = 0
...     feedback = []
...     
...     # 長さによる評価
...     if len(password) >= 12:
...         score += 2
...         feedback.append("✓ 十分な長さです")
...     elif len(password) >= 8:
...         score += 1
...         feedback.append("△ 8文字以上ですが、12文字以上をお勧めします")
...     else:
...         feedback.append("✗ 8文字以上にしてください")
...     
...     # 文字種類による評価
...     has_lower = any(c.islower() for c in password)
...     has_upper = any(c.isupper() for c in password)
...     has_digit = any(c.isdigit() for c in password)
...     has_symbol = any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password)
...     
...     char_types = sum([has_lower, has_upper, has_digit, has_symbol])
...     
...     if char_types >= 4:
...         score += 3
...         feedback.append("✓ 4種類の文字を使用")
...     elif char_types >= 3:
...         score += 2
...         feedback.append("△ 3種類の文字を使用（記号も追加をお勧め）")
...     elif char_types >= 2:
...         score += 1
...         feedback.append("△ 2種類の文字を使用（大文字・記号も追加してください）")
...     else:
...         feedback.append("✗ より多くの文字種類を使用してください")
...     
...     # パターンチェック
...     if password.lower() in ["password", "123456", "qwerty"]:
...         score -= 2
...         feedback.append("✗ よく使われるパスワードです")
...     
...     # 連続文字チェック
...     has_sequence = False
...     for i in range(len(password) - 2):
...         if (ord(password[i]) + 1 == ord(password[i+1]) and 
...             ord(password[i+1]) + 1 == ord(password[i+2])):
...             has_sequence = True
...             break
...     
...     if has_sequence:
...         score -= 1
...         feedback.append("△ 連続する文字があります")
...     
...     # 強度レベルの決定
...     if score >= 5:
...         strength = "非常に強い"
...         color = "🟢"
...     elif score >= 3:
...         strength = "強い"
...         color = "🔵"
...     elif score >= 1:
...         strength = "普通"
...         color = "🟡"
...     else:
...         strength = "弱い"
...         color = "🔴"
...     
...     return {
...         "score": score,
...         "strength": strength,
...         "color": color,
...         "feedback": feedback
...     }
... 

>>> # テスト用パスワード
>>> test_passwords = [
...     "123456",
...     "password",
...     "Password1",
...     "MySecret123",
...     "Str0ng!P@ssw0rd",
...     "VeryLongAndComplexPassword123!@#"
... ]

>>> print("=== 詳細パスワード強度評価 ===")
>>> for pwd in test_passwords:
...     result = evaluate_password_strength(pwd)
...     print(f"\nパスワード: '{pwd}'")
...     print(f"強度: {result['color']} {result['strength']} (スコア: {result['score']})")
...     print("フィードバック:")
...     for item in result['feedback']:
...         print(f"  {item}")
```

### ステップ3：インタラクティブなパスワードチェッカー

```python
>>> def interactive_password_checker():
...     """インタラクティブなパスワードチェッカー"""
...     
...     print("=== パスワード強度チェッカー ===")
...     print("終了するには 'quit' と入力してください\n")
...     
...     while True:
...         password = input("パスワードを入力してください: ")
...         
...         if password.lower() == 'quit':
...             print("終了します。")
...             break
...         
...         if not password:
...             print("パスワードを入力してください。\n")
...             continue
...         
...         # 基本チェック
...         is_valid, basic_message = check_password_basic(password)
...         
...         if not is_valid:
...             print(f"✗ {basic_message}\n")
...             continue
...         
...         # 詳細評価
...         result = evaluate_password_strength(password)
...         
...         print(f"\n強度評価: {result['color']} {result['strength']}")
...         print(f"セキュリティスコア: {result['score']}/6")
...         print("\n詳細フィードバック:")
...         for item in result['feedback']:
...             print(f"  {item}")
...         
...         # 改善提案
...         if result['score'] < 4:
...             print("\n💡 改善提案:")
...             if len(password) < 12:
...                 print("  • 12文字以上にしてみてください")
...             if not any(c.isupper() for c in password):
...                 print("  • 大文字を含めてみてください")
...             if not any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password):
...                 print("  • 記号を含めてみてください")
...         
...         print("\n" + "="*50 + "\n")
... 

>>> # 実行例（コメントアウトして手動実行）
>>> # interactive_password_checker()
```

### ステップ4：企業向けパスワードポリシーチェッカー

```python
# 企業向けパスワードポリシーチェッカー
import re
from datetime import datetime, timedelta

class PasswordPolicyChecker:
    def __init__(self, policy_level="standard"):
        """
        パスワードポリシーチェッカー
        policy_level: "basic", "standard", "strict"
        """
        self.policies = {
            "basic": {
                "min_length": 8,
                "require_upper": False,
                "require_lower": True,
                "require_digit": True,
                "require_symbol": False,
                "max_repeated": 3,
                "forbidden_patterns": ["password", "123456"],
                "expiry_days": 90
            },
            "standard": {
                "min_length": 10,
                "require_upper": True,
                "require_lower": True,
                "require_digit": True,
                "require_symbol": True,
                "max_repeated": 2,
                "forbidden_patterns": ["password", "123456", "qwerty", "admin"],
                "expiry_days": 60
            },
            "strict": {
                "min_length": 12,
                "require_upper": True,
                "require_lower": True,
                "require_digit": True,
                "require_symbol": True,
                "max_repeated": 1,
                "forbidden_patterns": ["password", "123456", "qwerty", "admin", "welcome"],
                "expiry_days": 30
            }
        }
        
        self.current_policy = self.policies.get(policy_level, self.policies["standard"])
        self.policy_level = policy_level
    
    def check_password(self, password, username="", previous_passwords=None):
        """パスワードをポリシーに従ってチェック"""
        if previous_passwords is None:
            previous_passwords = []
        
        violations = []
        score = 0
        
        # 長さチェック
        if len(password) < self.current_policy["min_length"]:
            violations.append(f"パスワードは{self.current_policy['min_length']}文字以上である必要があります")
        else:
            score += 1
        
        # 文字種別チェック
        if self.current_policy["require_upper"] and not any(c.isupper() for c in password):
            violations.append("大文字を含める必要があります")
        elif any(c.isupper() for c in password):
            score += 1
        
        if self.current_policy["require_lower"] and not any(c.islower() for c in password):
            violations.append("小文字を含める必要があります")
        elif any(c.islower() for c in password):
            score += 1
        
        if self.current_policy["require_digit"] and not any(c.isdigit() for c in password):
            violations.append("数字を含める必要があります")
        elif any(c.isdigit() for c in password):
            score += 1
        
        if self.current_policy["require_symbol"]:
            symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"
            if not any(c in symbols for c in password):
                violations.append("記号を含める必要があります")
            else:
                score += 1
        elif any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password):
            score += 1
        
        # 連続・重複文字チェック
        max_repeated = self.current_policy["max_repeated"]
        repeated_count = 1
        for i in range(1, len(password)):
            if password[i] == password[i-1]:
                repeated_count += 1
                if repeated_count > max_repeated:
                    violations.append(f"同じ文字の連続は{max_repeated}文字以下にしてください")
                    break
            else:
                repeated_count = 1
        
        # 禁止パターンチェック
        password_lower = password.lower()
        for pattern in self.current_policy["forbidden_patterns"]:
            if pattern in password_lower:
                violations.append(f"禁止されたパターン '{pattern}' が含まれています")
        
        # ユーザー名との類似性チェック
        if username and username.lower() in password_lower:
            violations.append("パスワードにユーザー名を含めることはできません")
        
        # 過去のパスワードとの重複チェック
        for prev_password in previous_passwords:
            if password == prev_password:
                violations.append("過去に使用したパスワードは使用できません")
                break
        
        # 結果の評価
        is_valid = len(violations) == 0
        
        return {
            "is_valid": is_valid,
            "violations": violations,
            "score": score,
            "max_score": 5,
            "policy_level": self.policy_level,
            "password_length": len(password)
        }
    
    def generate_password_suggestions(self):
        """ポリシーに適合するパスワードの例を生成"""
        import random
        import string
        
        min_len = self.current_policy["min_length"]
        
        # 基本文字セット
        lowercase = string.ascii_lowercase
        uppercase = string.ascii_uppercase
        digits = string.digits
        symbols = "!@#$%^&*"
        
        # 必要な文字種別を含む
        password_chars = []
        
        if self.current_policy["require_lower"]:
            password_chars.extend(random.choices(lowercase, k=2))
        if self.current_policy["require_upper"]:
            password_chars.extend(random.choices(uppercase, k=2))
        if self.current_policy["require_digit"]:
            password_chars.extend(random.choices(digits, k=2))
        if self.current_policy["require_symbol"]:
            password_chars.extend(random.choices(symbols, k=2))
        
        # 残りの文字数を埋める
        all_chars = lowercase + uppercase + digits + symbols
        remaining_length = min_len - len(password_chars)
        password_chars.extend(random.choices(all_chars, k=remaining_length))
        
        # シャッフル
        random.shuffle(password_chars)
        
        return ''.join(password_chars)

# 使用例
policy_checker = PasswordPolicyChecker("standard")

test_cases = [
    {"password": "password123", "username": "user1"},
    {"password": "MySecureP@ss2024", "username": "user2"},
    {"password": "VeryStr0ng!P@ssw0rd", "username": "user3"},
]

print("=== 企業ポリシーチェック ===")
for case in test_cases:
    result = policy_checker.check_password(case["password"], case["username"])
    
    print(f"\nパスワード: '{case['password']}'")
    print(f"ユーザー名: {case['username']}")
    print(f"ポリシーレベル: {result['policy_level']}")
    print(f"検査結果: {'✓ 合格' if result['is_valid'] else '✗ 不合格'}")
    print(f"スコア: {result['score']}/{result['max_score']}")
    
    if result['violations']:
        print("違反項目:")
        for violation in result['violations']:
            print(f"  • {violation}")
    else:
        print("✓ すべてのポリシーに適合しています")

print(f"\n💡 推奨パスワード例: {policy_checker.generate_password_suggestions()}")
```

## 複雑な条件（and, or, not）

実際のプログラムでは、複数の条件を組み合わせる必要があります。

### 論理演算子

| 演算子 | 意味 | 例 | 結果 |
|--------|------|-----|------|
| `and` | かつ | `True and False` | `False` |
| `or` | または | `True or False` | `True` |
| `not` | でない | `not True` | `False` |

### and演算子の使用例

```python
>>> # 両方の条件が真の場合のみ真
>>> age = 25
>>> has_license = True

>>> if age >= 18 and has_license:
...     print("運転できます")
... else:
...     print("運転できません")
運転できます

>>> # 複数の条件
>>> score = 85
>>> attendance = 90

>>> if score >= 80 and attendance >= 85:
...     print("優秀な成績です")
... else:
...     print("もう少し頑張りましょう")
優秀な成績です
```

### or演算子の使用例

```python
>>> # どちらかの条件が真なら真
>>> day = "土曜日"

>>> if day == "土曜日" or day == "日曜日":
...     print("週末です")
... else:
...     print("平日です")
週末です

>>> # 複数の支払い方法
>>> payment = "クレジットカード"

>>> if payment == "現金" or payment == "クレジットカード" or payment == "電子マネー":
...     print("お支払いを受け付けます")
... else:
...     print("対応していない支払い方法です")
お支払いを受け付けます
```

### not演算子の使用例

```python
>>> # 条件を反転
>>> is_logged_in = False

>>> if not is_logged_in:
...     print("ログインしてください")
... else:
...     print("ようこそ")
ログインしてください

>>> # 空でないことをチェック
>>> user_input = ""

>>> if not user_input:
...     print("入力が必要です")
... else:
...     print(f"入力内容: {user_input}")
入力が必要です
```

### 複雑な条件の組み合わせ

```python
>>> # 複雑な会員特典判定
>>> age = 25
>>> is_premium = True
>>> years_member = 3
>>> purchase_amount = 15000

>>> # プレミアム特典の条件
>>> if (is_premium and years_member >= 2) or purchase_amount >= 10000:
...     discount_rate = 0.15
...     print("15%割引が適用されます")
... elif age < 25 or age >= 65:
...     discount_rate = 0.10
...     print("年齢割引10%が適用されます")
... elif years_member >= 1:
...     discount_rate = 0.05
...     print("会員割引5%が適用されます")
... else:
...     discount_rate = 0
...     print("割引は適用されません")

15%割引が適用されます

>>> # 括弧を使って条件を明確にする
>>> temperature = 28
>>> humidity = 70
>>> is_rainy = False

>>> if (temperature >= 25 and humidity >= 60) and not is_rainy:
...     print("蒸し暑い晴れの日です")
... elif temperature >= 30 or (humidity >= 80 and is_rainy):
...     print("不快な天気です")
... else:
...     print("普通の天気です")
蒸し暑い晴れの日です
```

### 短絡評価

Pythonでは、論理演算子は**短絡評価**を行います：

```python
>>> # and の短絡評価
>>> def check_positive(x):
...     print(f"check_positive({x}) が呼ばれました")
...     return x > 0
... 

>>> # 最初の条件が偽なら、2番目は評価されない
>>> result = False and check_positive(5)
>>> print(f"結果: {result}")
結果: False

>>> # 最初の条件が真なら、2番目も評価される
>>> result = True and check_positive(5)
>>> print(f"結果: {result}")
check_positive(5) が呼ばれました
結果: True

>>> # or の短絡評価
>>> # 最初の条件が真なら、2番目は評価されない
>>> result = True or check_positive(5)
>>> print(f"結果: {result}")
結果: True

>>> # 最初の条件が偽なら、2番目も評価される
>>> result = False or check_positive(5)
>>> print(f"結果: {result}")
check_positive(5) が呼ばれました
結果: True
```

## まとめ：条件分岐の活用

この章で学んだことをまとめましょう：

### if文の基本構文
- `if 条件:` - 条件が真のときに実行
- `if-else` - 真の場合と偽の場合の処理
- `if-elif-else` - 複数の条件を順番に判定

### 実用的な応用例
- 年齢別料金システム
- 時間帯割引の計算
- パスワード強度チェック
- 企業ポリシーの適用

### 真偽値の理解
- `True`と`False`の基本
- 比較演算子（==, !=, <, >, <=, >=）
- 偽とみなされる値（0, "", [], {}, None）

### 論理演算子
- `and`: 両方の条件が真
- `or`: どちらかの条件が真
- `not`: 条件を反転
- 短絡評価による効率的な処理

### プログラム設計のポイント
- 条件は分かりやすく書く
- 複雑な条件は括弧で明確にする
- エラーケースを先にチェックする
- 可読性を重視した構造にする

次の章では、同じ処理を繰り返し実行する「ループ」について学びます。貯金目標達成までの計算や成績表の処理など、反復処理を使った実用的なプログラムを作成していきましょう！