# 第7章：変数という魔法の箱

これまでの章で、数値や文字列を直接扱ってきました。しかし、実際のプログラムでは、データを**変数**という「名前付きの箱」に保存して管理します。この章では、変数の本質的な仕組みを理解し、ユーザー情報管理システムや商品管理システムを作りながら、変数の効果的な使い方を学んでいきましょう。

## 変数ってなに？なぜ必要？

### 変数なしの世界を想像してみよう

まず、変数がない世界でプログラムを書くとどうなるか考えてみましょう：

```python
>>> # 変数を使わない場合（悪い例）
>>> print("田中太郎さんの消費税計算")
>>> print(f"商品価格: {1500}円")
>>> print(f"消費税: {1500 * 0.1}円")
>>> print(f"合計: {1500 + 1500 * 0.1}円")

>>> print("田中太郎さんの送料計算")
>>> print(f"商品価格: {1500}円")  # 同じ値を何度も書く
>>> if 1500 >= 3000:  # また同じ値を書く
...     print("送料無料")
... else:
...     print(f"送料: {500}円")
...     print(f"総合計: {1500 + 1500 * 0.1 + 500}円")  # 複雑な計算を繰り返し
```

この例の問題点：
1. 同じ値（1500）を何度も書いている
2. 価格を変更したい場合、すべての場所を修正する必要がある
3. 計算が複雑で間違いやすい
4. プログラムの意味が理解しにくい

### 変数を使った場合

```python
>>> # 変数を使う場合（良い例）
>>> customer_name = "田中太郎"
>>> product_price = 1500
>>> tax_rate = 0.1
>>> shipping_fee = 500
>>> free_shipping_threshold = 3000

>>> print(f"{customer_name}さんの消費税計算")
>>> tax_amount = product_price * tax_rate
>>> total_with_tax = product_price + tax_amount

>>> print(f"商品価格: {product_price}円")
>>> print(f"消費税: {tax_amount}円")
>>> print(f"合計: {total_with_tax}円")

>>> print(f"{customer_name}さんの送料計算")
>>> if product_price >= free_shipping_threshold:
...     shipping_cost = 0
...     print("送料無料")
... else:
...     shipping_cost = shipping_fee
...     print(f"送料: {shipping_cost}円")

>>> final_total = total_with_tax + shipping_cost
>>> print(f"総合計: {final_total}円")
```

変数を使うメリット：
1. **再利用性**：同じ値を何度でも使える
2. **保守性**：値を変更する場合、一箇所だけ修正すればよい
3. **可読性**：プログラムの意味が理解しやすい
4. **安全性**：計算ミスが減る

### 変数の本質：メモリ上の仕組み

変数は、コンピュータのメモリ上に作られる「名前付きの保存場所」です：

```python
>>> # 変数の作成とメモリ上の動作
>>> name = "田中太郎"  # メモリのどこかに"田中太郎"を保存し、nameという名前を付ける
>>> age = 30          # メモリのどこかに30を保存し、ageという名前を付ける

>>> # id()関数でメモリ上の位置（アドレス）を確認
>>> print(f"nameのメモリアドレス: {id(name)}")
>>> print(f"ageのメモリアドレス: {id(age)}")

nameのメモリアドレス: 140234567891200
ageのメモリアドレス: 140234567890112

>>> # 同じ値を持つ変数のアドレス
>>> age2 = 30
>>> print(f"ageのアドレス: {id(age)}")
>>> print(f"age2のアドレス: {id(age2)}")
>>> print(f"同じアドレス: {id(age) == id(age2)}")

ageのアドレス: 140234567890112
age2のアドレス: 140234567890112
同じアドレス: True  # Pythonは同じ値は同じ場所に保存することがある
```

## 【実行】ユーザー情報を管理するプログラム（名前、年齢、住所）

実際にユーザー情報を管理するプログラムを作って、変数の使い方を学びましょう。

### ステップ1：基本的なユーザー情報管理

```python
>>> # ユーザー情報の定義
>>> user_name = "田中太郎"
>>> user_age = 30
>>> user_email = "tanaka@example.com"
>>> user_phone = "090-1234-5678"
>>> user_address = "東京都渋谷区神南1-2-3"
>>> user_is_premium = True

>>> # 情報の表示
>>> print("=== ユーザー情報 ===")
>>> print(f"名前: {user_name}")
>>> print(f"年齢: {user_age}歳")
>>> print(f"メール: {user_email}")
>>> print(f"電話: {user_phone}")
>>> print(f"住所: {user_address}")
>>> print(f"プレミアム会員: {'はい' if user_is_premium else 'いいえ'}")

=== ユーザー情報 ===
名前: 田中太郎
年齢: 30歳
メール: tanaka@example.com
電話: 090-1234-5678
住所: 東京都渋谷区神南1-2-3
プレミアム会員: はい
```

### ステップ2：計算処理を含む情報管理

```python
>>> import datetime

>>> # 生年月日から年齢を計算
>>> birth_year = 1993
>>> current_year = datetime.datetime.now().year
>>> calculated_age = current_year - birth_year

>>> # 会員ランクの判定
>>> if user_age < 20:
...     age_category = "学生"
... elif user_age < 65:
...     age_category = "一般"
... else:
...     age_category = "シニア"

>>> # プレミアム特典の計算
>>> base_discount = 0.05  # 基本割引5%
>>> if user_is_premium:
...     if age_category == "学生":
...         total_discount = base_discount + 0.10  # 学生追加割引10%
...     elif age_category == "シニア":
...         total_discount = base_discount + 0.15  # シニア追加割引15%
...     else:
...         total_discount = base_discount + 0.05  # 一般追加割引5%
... else:
...     total_discount = 0

>>> print(f"生年月日から計算した年齢: {calculated_age}歳")
>>> print(f"年齢カテゴリ: {age_category}")
>>> print(f"適用割引率: {total_discount:.1%}")

生年月日から計算した年齢: 31歳
年齢カテゴリ: 一般
適用割引率: 10.0%
```

### ステップ3：複数ユーザーの管理

```python
>>> # 複数ユーザーの情報
>>> user1_name = "田中太郎"
>>> user1_age = 30
>>> user1_email = "tanaka@example.com"
>>> user1_is_premium = True

>>> user2_name = "佐藤花子"
>>> user2_age = 25
>>> user2_email = "sato@example.com"
>>> user2_is_premium = False

>>> user3_name = "鈴木一郎"
>>> user3_age = 70
>>> user3_email = "suzuki@example.com"
>>> user3_is_premium = True

>>> # ユーザーごとの処理（関数化）
>>> def calculate_user_discount(age, is_premium):
...     """ユーザーの割引率を計算"""
...     base_discount = 0.05
...     
...     if not is_premium:
...         return 0
...     
...     if age < 20:
...         return base_discount + 0.10  # 学生
...     elif age >= 65:
...         return base_discount + 0.15  # シニア
...     else:
...         return base_discount + 0.05  # 一般
... 

>>> def display_user_info(name, age, email, is_premium):
...     """ユーザー情報を表示"""
...     discount = calculate_user_discount(age, is_premium)
...     premium_status = "プレミアム" if is_premium else "一般"
...     
...     print(f"名前: {name}")
...     print(f"年齢: {age}歳")
...     print(f"メール: {email}")
...     print(f"会員タイプ: {premium_status}")
...     print(f"割引率: {discount:.1%}")
...     print("---")
... 

>>> # 全ユーザー情報の表示
>>> display_user_info(user1_name, user1_age, user1_email, user1_is_premium)
>>> display_user_info(user2_name, user2_age, user2_email, user2_is_premium)
>>> display_user_info(user3_name, user3_age, user3_email, user3_is_premium)

名前: 田中太郎
年齢: 30歳
メール: tanaka@example.com
会員タイプ: プレミアム
割引率: 10.0%
---
名前: 佐藤花子
年齢: 25歳
メール: sato@example.com
会員タイプ: 一般
割引率: 0.0%
---
名前: 鈴木一郎
年齢: 70歳
メール: suzuki@example.com
会員タイプ: プレミアム
割引率: 20.0%
---
```

### ステップ4：辞書を使った改良版

```python
>>> # 辞書を使ってユーザー情報をまとめる
>>> user1 = {
...     "name": "田中太郎",
...     "age": 30,
...     "email": "tanaka@example.com",
...     "phone": "090-1234-5678",
...     "address": "東京都渋谷区神南1-2-3",
...     "is_premium": True,
...     "registration_date": "2023-01-15"
... }

>>> user2 = {
...     "name": "佐藤花子",
...     "age": 25,
...     "email": "sato@example.com",
...     "phone": "080-9876-5432",
...     "address": "大阪府大阪市北区梅田1-1-1",
...     "is_premium": False,
...     "registration_date": "2023-03-20"
... }

>>> # ユーザー情報処理の改良版
>>> def process_user(user):
...     """ユーザー情報の処理"""
...     name = user["name"]
...     age = user["age"]
...     is_premium = user["is_premium"]
...     
...     # 年齢カテゴリの判定
...     if age < 20:
...         category = "学生"
...     elif age < 65:
...         category = "一般"
...     else:
...         category = "シニア"
...     
...     # 割引率の計算
...     discount = calculate_user_discount(age, is_premium)
...     
...     # 結果の返却
...     return {
...         "category": category,
...         "discount": discount,
...         "premium_status": "プレミアム" if is_premium else "一般"
...     }
... 

>>> # ユーザー情報の処理と表示
>>> for user in [user1, user2]:
...     result = process_user(user)
...     
...     print(f"名前: {user['name']}")
...     print(f"年齢: {user['age']}歳 ({result['category']})")
...     print(f"会員: {result['premium_status']}")
...     print(f"割引: {result['discount']:.1%}")
...     print(f"登録日: {user['registration_date']}")
...     print("---")
```

## いい変数名、だめな変数名

変数名は、プログラムの可読性に大きく影響します。良い変数名の付け方を学びましょう。

### 変数名のルール（必須）

```python
>>> # 正しい変数名
>>> user_name = "田中"      # OK: 英字とアンダースコア
>>> age_2024 = 30          # OK: 英字、数字、アンダースコア
>>> _private_data = "秘密"  # OK: アンダースコアで始まる

>>> # 間違った変数名（エラーになる）
>>> # 2user_name = "田中"   # NG: 数字で始まる
>>> # user-name = "田中"    # NG: ハイフンは使えない
>>> # user name = "田中"    # NG: スペースは使えない
>>> # def = "定義"          # NG: Pythonの予約語
```

### 良い変数名の例

```python
>>> # 意味が明確な変数名
>>> total_price = 1500           # 合計価格
>>> user_email_address = "..."   # ユーザーのメールアドレス
>>> is_premium_member = True     # プレミアム会員かどうか
>>> max_retry_count = 3          # 最大リトライ回数
>>> product_list = []            # 商品リスト

>>> # 単位を含む変数名
>>> distance_km = 100            # 距離（キロメートル）
>>> weight_kg = 5.5              # 重量（キログラム）
>>> time_seconds = 3600          # 時間（秒）
>>> price_yen = 1500             # 価格（円）

>>> # ブール値の変数名
>>> is_logged_in = True          # ログイン状態
>>> has_permission = False       # 権限の有無
>>> can_edit = True              # 編集可能かどうか
>>> should_update = False        # 更新すべきかどうか
```

### 悪い変数名の例

```python
>>> # 意味が不明な変数名
>>> x = "田中太郎"               # 何のx？
>>> data = 1500                 # 何のデータ？
>>> temp = True                 # 一時的？温度？
>>> list1 = []                  # 何のリスト？

>>> # 省略しすぎた変数名
>>> usr_nm = "田中"              # user_nameと書こう
>>> calc_prc = 1500             # calculated_priceと書こう
>>> chk_flg = True              # check_flagと書こう

>>> # 誤解を招く変数名
>>> user_data = 1500            # 数値なのにdata？
>>> count = "田中太郎"           # 文字列なのにcount？
>>> is_valid = "yes"            # 文字列なのにis_？
```

## 【実行】商品管理システムの変数名を考えよう

実際の商品管理システムを作りながら、適切な変数名の付け方を練習しましょう。

### ステップ1：商品の基本情報

```python
>>> # 商品情報の定義（良い変数名）
>>> product_id = "P001"
>>> product_name = "ワイヤレスイヤホン"
>>> product_category = "電子機器"
>>> unit_price = 8500
>>> stock_quantity = 25
>>> is_in_stock = stock_quantity > 0
>>> is_on_sale = True
>>> sale_discount_rate = 0.15
>>> supplier_name = "テック株式会社"
>>> arrival_date = "2024-01-10"

>>> # 計算された値
>>> sale_price = unit_price * (1 - sale_discount_rate) if is_on_sale else unit_price
>>> stock_status = "在庫あり" if is_in_stock else "在庫切れ"

>>> print("=== 商品情報 ===")
>>> print(f"商品ID: {product_id}")
>>> print(f"商品名: {product_name}")
>>> print(f"カテゴリ: {product_category}")
>>> print(f"定価: {unit_price:,}円")
>>> print(f"販売価格: {sale_price:,.0f}円")
>>> print(f"在庫数: {stock_quantity}個")
>>> print(f"在庫状況: {stock_status}")
>>> print(f"仕入先: {supplier_name}")
```

### ステップ2：在庫管理機能

```python
>>> def update_stock(current_stock, transaction_type, quantity):
...     """在庫を更新する関数"""
...     if transaction_type == "入荷":
...         new_stock = current_stock + quantity
...         print(f"入荷: {quantity}個 → 在庫: {new_stock}個")
...     elif transaction_type == "出荷":
...         if current_stock >= quantity:
...             new_stock = current_stock - quantity
...             print(f"出荷: {quantity}個 → 在庫: {new_stock}個")
...         else:
...             print(f"エラー: 在庫不足（要求: {quantity}個, 在庫: {current_stock}個）")
...             new_stock = current_stock
...     else:
...         print(f"エラー: 不明な取引タイプ: {transaction_type}")
...         new_stock = current_stock
...     
...     return new_stock
... 

>>> # 在庫の更新テスト
>>> current_stock_quantity = stock_quantity
>>> print(f"初期在庫: {current_stock_quantity}個")

>>> # 入荷
>>> current_stock_quantity = update_stock(current_stock_quantity, "入荷", 10)

>>> # 出荷
>>> current_stock_quantity = update_stock(current_stock_quantity, "出荷", 8)

>>> # 在庫不足の出荷
>>> current_stock_quantity = update_stock(current_stock_quantity, "出荷", 50)

初期在庫: 25個
入荷: 10個 → 在庫: 35個
出荷: 8個 → 在庫: 27個
エラー: 在庫不足（要求: 50個, 在庫: 27個）
```

### ステップ3：販売実績の管理

```python
>>> # 販売実績の管理
>>> daily_sales_count = 0
>>> daily_sales_amount = 0
>>> total_sales_count = 0
>>> total_sales_amount = 0

>>> def record_sale(product_price, sale_quantity):
...     """販売を記録する関数"""
...     global daily_sales_count, daily_sales_amount
...     global total_sales_count, total_sales_amount
...     
...     sale_amount = product_price * sale_quantity
...     
...     daily_sales_count += sale_quantity
...     daily_sales_amount += sale_amount
...     total_sales_count += sale_quantity
...     total_sales_amount += sale_amount
...     
...     print(f"販売記録: {sale_quantity}個 × {product_price:,}円 = {sale_amount:,}円")
...     return sale_amount
... 

>>> def display_sales_summary():
...     """販売サマリーを表示"""
...     print("\n=== 販売サマリー ===")
...     print(f"本日販売数: {daily_sales_count}個")
...     print(f"本日売上: {daily_sales_amount:,}円")
...     print(f"累計販売数: {total_sales_count}個")
...     print(f"累計売上: {total_sales_amount:,}円")
...     
...     if daily_sales_count > 0:
...         average_unit_price = daily_sales_amount / daily_sales_count
...         print(f"平均単価: {average_unit_price:,.0f}円")
... 

>>> # 販売記録のテスト
>>> record_sale(sale_price, 3)
>>> record_sale(sale_price, 2)
>>> record_sale(sale_price, 1)
>>> display_sales_summary()

販売記録: 3個 × 7,225円 = 21,675円
販売記録: 2個 × 7,225円 = 14,450円
販売記録: 1個 × 7,225円 = 7,225円

=== 販売サマリー ===
本日販売数: 6個
本日売上: 43,350円
累計販売数: 6個
累計売上: 43,350円
平均単価: 7,225円
```

### ステップ4：完全版商品管理クラス

```python
# 商品管理システム
from datetime import datetime

class ProductManager:
    def __init__(self, product_id, product_name, unit_price, initial_stock=0):
        # 商品基本情報
        self.product_id = product_id
        self.product_name = product_name
        self.product_category = ""
        self.unit_price = unit_price
        
        # 在庫情報
        self.current_stock = initial_stock
        self.minimum_stock_level = 5  # 最低在庫レベル
        self.maximum_stock_level = 100  # 最大在庫レベル
        
        # 販売情報
        self.is_on_sale = False
        self.sale_discount_rate = 0.0
        
        # 販売実績
        self.total_sales_quantity = 0
        self.total_sales_amount = 0
        
        # 仕入先情報
        self.supplier_name = ""
        self.last_restock_date = None
        
        # 取引履歴
        self.transaction_history = []
    
    def get_selling_price(self):
        """現在の販売価格を取得"""
        if self.is_on_sale:
            return self.unit_price * (1 - self.sale_discount_rate)
        return self.unit_price
    
    def is_stock_available(self, requested_quantity=1):
        """在庫があるかチェック"""
        return self.current_stock >= requested_quantity
    
    def is_low_stock(self):
        """在庫が少ないかチェック"""
        return self.current_stock <= self.minimum_stock_level
    
    def add_stock(self, quantity, note=""):
        """在庫を追加"""
        if quantity <= 0:
            return False, "数量は正の数である必要があります"
        
        old_stock = self.current_stock
        self.current_stock += quantity
        self.last_restock_date = datetime.now()
        
        # 取引履歴に記録
        transaction = {
            "date": datetime.now(),
            "type": "入荷",
            "quantity": quantity,
            "before_stock": old_stock,
            "after_stock": self.current_stock,
            "note": note
        }
        self.transaction_history.append(transaction)
        
        return True, f"入荷完了: {quantity}個追加（在庫: {old_stock} → {self.current_stock}）"
    
    def sell_product(self, quantity, note=""):
        """商品を販売"""
        if quantity <= 0:
            return False, "数量は正の数である必要があります"
        
        if not self.is_stock_available(quantity):
            return False, f"在庫不足（要求: {quantity}個, 在庫: {self.current_stock}個）"
        
        old_stock = self.current_stock
        self.current_stock -= quantity
        
        # 販売実績を更新
        selling_price = self.get_selling_price()
        sale_amount = selling_price * quantity
        self.total_sales_quantity += quantity
        self.total_sales_amount += sale_amount
        
        # 取引履歴に記録
        transaction = {
            "date": datetime.now(),
            "type": "販売",
            "quantity": quantity,
            "unit_price": selling_price,
            "total_amount": sale_amount,
            "before_stock": old_stock,
            "after_stock": self.current_stock,
            "note": note
        }
        self.transaction_history.append(transaction)
        
        return True, f"販売完了: {quantity}個 × {selling_price:,.0f}円 = {sale_amount:,.0f}円"
    
    def set_sale(self, discount_rate):
        """セールを設定"""
        if 0 <= discount_rate <= 1:
            self.is_on_sale = True
            self.sale_discount_rate = discount_rate
            return True, f"セール設定: {discount_rate:.1%}割引"
        return False, "割引率は0-1の範囲で指定してください"
    
    def end_sale(self):
        """セールを終了"""
        self.is_on_sale = False
        self.sale_discount_rate = 0.0
        return "セール終了"
    
    def get_product_summary(self):
        """商品サマリーを取得"""
        return {
            "product_id": self.product_id,
            "product_name": self.product_name,
            "unit_price": self.unit_price,
            "selling_price": self.get_selling_price(),
            "current_stock": self.current_stock,
            "is_low_stock": self.is_low_stock(),
            "total_sales": self.total_sales_quantity,
            "total_revenue": self.total_sales_amount,
            "is_on_sale": self.is_on_sale
        }

# 使用例
product = ProductManager("P001", "ワイヤレスイヤホン", 8500, 20)

# 商品情報設定
product.product_category = "電子機器"
product.supplier_name = "テック株式会社"
product.minimum_stock_level = 5

# セール設定
success, message = product.set_sale(0.15)
print(message)

# 販売テスト
success, message = product.sell_product(3, "オンライン注文")
print(message)

# 在庫補充
success, message = product.add_stock(15, "定期発注")
print(message)

# サマリー表示
summary = product.get_product_summary()
print("\n=== 商品サマリー ===")
for key, value in summary.items():
    print(f"{key}: {value}")
```

## 【実行】メモリの使用量を確認してみよう

変数がコンピュータのメモリにどう保存されているかを実際に確認してみましょう。

### メモリアドレスの確認

```python
>>> # 同じ値を持つ変数のメモリアドレス
>>> number1 = 100
>>> number2 = 100
>>> number3 = 200

>>> print(f"number1 (100)のアドレス: {id(number1)}")
>>> print(f"number2 (100)のアドレス: {id(number2)}")
>>> print(f"number3 (200)のアドレス: {id(number3)}")
>>> print(f"number1とnumber2は同じアドレス: {id(number1) == id(number2)}")

number1 (100)のアドレス: 140234567890112
number2 (100)のアドレス: 140234567890112
number3 (200)のアドレス: 140234567890144
number1とnumber2は同じアドレス: True

>>> # 文字列の場合
>>> text1 = "Hello"
>>> text2 = "Hello"
>>> text3 = "World"

>>> print(f"text1のアドレス: {id(text1)}")
>>> print(f"text2のアドレス: {id(text2)}")
>>> print(f"text3のアドレス: {id(text3)}")
>>> print(f"text1とtext2は同じアドレス: {id(text1) == id(text2)}")

text1のアドレス: 140234567891200
text2のアドレス: 140234567891200
text3のアドレス: 140234567891264
text1とtext2は同じアドレス: True
```

### 変数の代入とメモリの動作

```python
>>> # 変数の代入
>>> original_list = [1, 2, 3]
>>> copied_reference = original_list  # 参照をコピー
>>> copied_value = original_list.copy()  # 値をコピー

>>> print(f"original_listのアドレス: {id(original_list)}")
>>> print(f"copied_referenceのアドレス: {id(copied_reference)}")
>>> print(f"copied_valueのアドレス: {id(copied_value)}")

original_listのアドレス: 140234567892160
copied_referenceのアドレス: 140234567892160
copied_valueのアドレス: 140234567892224

>>> # 元のリストを変更
>>> original_list.append(4)

>>> print(f"original_list: {original_list}")
>>> print(f"copied_reference: {copied_reference}")  # 同じオブジェクトなので変更される
>>> print(f"copied_value: {copied_value}")          # 別のオブジェクトなので変更されない

original_list: [1, 2, 3, 4]
copied_reference: [1, 2, 3, 4]
copied_value: [1, 2, 3]
```

### メモリ使用量の測定

```python
>>> import sys

>>> # 基本的なデータ型のメモリ使用量
>>> integer_var = 42
>>> float_var = 3.14
>>> string_var = "Hello, Python!"
>>> list_var = [1, 2, 3, 4, 5]
>>> dict_var = {"name": "田中", "age": 30}

>>> print("=== メモリ使用量 ===")
>>> print(f"整数 ({integer_var}): {sys.getsizeof(integer_var)} bytes")
>>> print(f"浮動小数点 ({float_var}): {sys.getsizeof(float_var)} bytes")
>>> print(f"文字列 ('{string_var}'): {sys.getsizeof(string_var)} bytes")
>>> print(f"リスト {list_var}: {sys.getsizeof(list_var)} bytes")
>>> print(f"辞書 {dict_var}: {sys.getsizeof(dict_var)} bytes")

=== メモリ使用量 ===
整数 (42): 28 bytes
浮動小数点 (3.14): 24 bytes
文字列 ('Hello, Python!'): 64 bytes
リスト [1, 2, 3, 4, 5]: 104 bytes
辞書 {'name': '田中', 'age': 30}: 232 bytes

>>> # 文字列の長さとメモリ使用量の関係
>>> short_string = "Hi"
>>> medium_string = "Hello, World!"
>>> long_string = "This is a very long string that contains many characters to test memory usage."

>>> print(f"短い文字列 ('{short_string}'): {sys.getsizeof(short_string)} bytes")
>>> print(f"中程度の文字列: {sys.getsizeof(medium_string)} bytes")
>>> print(f"長い文字列: {sys.getsizeof(long_string)} bytes")

短い文字列 ('Hi'): 51 bytes
中程度の文字列: 62 bytes
長い文字列: 128 bytes
```

### 変数のスコープとライフサイクル

```python
>>> # グローバル変数
>>> global_counter = 0

>>> def increment_counter():
...     """カウンターを増加させる関数"""
...     global global_counter
...     local_temp = global_counter  # ローカル変数
...     global_counter += 1
...     print(f"ローカル変数 local_temp: {local_temp}")
...     print(f"グローバル変数 global_counter: {global_counter}")
...     # local_tempは関数終了時にメモリから削除される
... 

>>> print(f"関数呼び出し前: {global_counter}")
>>> increment_counter()
>>> print(f"関数呼び出し後: {global_counter}")

>>> # local_tempにはアクセスできない（スコープ外）
>>> # print(local_temp)  # NameError: name 'local_temp' is not defined

関数呼び出し前: 0
ローカル変数 local_temp: 0
グローバル変数 global_counter: 1
関数呼び出し後: 1
```

## まとめ：変数の効果的な使い方

この章で学んだことをまとめましょう：

### 変数の本質
- データを保存する「名前付きの箱」
- メモリ上の特定の場所に値を保存
- プログラムの可読性と保守性を向上
- 同じ値を繰り返し使える

### 変数名の付け方
- **意味が明確**：何を保存するかが分かる名前
- **一貫性**：同じような変数には似た命名規則
- **適切な長さ**：短すぎず長すぎず
- **規約に従う**：snake_caseを使用

### 良い変数名の例
```python
user_name = "田中太郎"
total_price = 1500
is_premium_member = True
max_retry_count = 3
distance_km = 100
```

### 悪い変数名の例
```python
x = "田中太郎"          # 意味不明
data = 1500            # 何のデータ？
temp = True            # 一時的？
usr_nm = "田中"         # 省略しすぎ
```

### メモリとの関係
- 変数はメモリ上のアドレスを指す
- 同じ値は同じメモリ位置を共有することがある
- 参照とコピーの違いを理解することが重要
- データ型によってメモリ使用量が異なる

### 実用的な応用
- ユーザー情報管理システム
- 商品管理システム
- 在庫管理と販売記録
- 設定値とビジネスロジックの分離

次の章では、コンピュータに判断をさせる「条件分岐」について学びます。年齢による料金計算やパスワード強度チェックなど、実際の判断処理を通じて、プログラムに知能を持たせる方法を習得しましょう！