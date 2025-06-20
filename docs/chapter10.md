# 第10章：データをまとめて整理しよう

これまでの章では、数値や文字列といった単純なデータを扱ってきました。しかし、実際のプログラムでは、複数のデータをまとめて管理する必要があります。この章では、**リスト**、**辞書**、**セット**というPythonの重要なデータ構造を学び、買い物リスト管理プログラムや連絡先帳プログラムを作りながら、効率的なデータ管理方法を習得しましょう。

## リスト - データの集まり

### リストとは

**リスト**は、複数のデータを順番に並べて保存するデータ構造です。現実世界の「買い物リスト」や「やることリスト」と同じ概念です。

```python
>>> # リストの作成
>>> fruits = ["りんご", "バナナ", "オレンジ"]
>>> numbers = [1, 2, 3, 4, 5]
>>> mixed_list = ["文字列", 42, True, 3.14]

>>> print(f"果物リスト: {fruits}")
>>> print(f"数値リスト: {numbers}")
>>> print(f"混合リスト: {mixed_list}")

果物リスト: ['りんご', 'バナナ', 'オレンジ']
数値リスト: [1, 2, 3, 4, 5]
混合リスト: ['文字列', 42, True, 3.14]
```

### リストの基本操作

```python
>>> # 空のリストを作成
>>> shopping_list = []

>>> # 要素の追加
>>> shopping_list.append("牛乳")
>>> shopping_list.append("パン")
>>> shopping_list.append("卵")

>>> print(f"現在のリスト: {shopping_list}")
現在のリスト: ['牛乳', 'パン', '卵']

>>> # 要素の取得（インデックスは0から始まる）
>>> first_item = shopping_list[0]
>>> last_item = shopping_list[-1]  # 最後の要素

>>> print(f"最初の項目: {first_item}")
>>> print(f"最後の項目: {last_item}")

最初の項目: 牛乳
最後の項目: 卵

>>> # リストの長さ
>>> list_length = len(shopping_list)
>>> print(f"リストの長さ: {list_length}")
リストの長さ: 3
```

### リストの詳細操作

```python
>>> # 複数要素の追加
>>> additional_items = ["チーズ", "トマト", "レタス"]
>>> shopping_list.extend(additional_items)
>>> print(f"追加後: {shopping_list}")
追加後: ['牛乳', 'パン', '卵', 'チーズ', 'トマト', 'レタス']

>>> # 特定位置への挿入
>>> shopping_list.insert(1, "バター")  # 1番目に挿入
>>> print(f"挿入後: {shopping_list}")
挿入後: ['牛乳', 'バター', 'パン', '卵', 'チーズ', 'トマト', 'レタス']

>>> # 要素の削除
>>> removed_item = shopping_list.pop()  # 最後を削除
>>> print(f"削除された項目: {removed_item}")
>>> print(f"削除後: {shopping_list}")

削除された項目: レタス
削除後: ['牛乳', 'バター', 'パン', '卵', 'チーズ', 'トマト']

>>> # 値による削除
>>> shopping_list.remove("バター")
>>> print(f"バター削除後: {shopping_list}")
バター削除後: ['牛乳', 'パン', '卵', 'チーズ', 'トマト']

>>> # 要素の存在確認
>>> if "牛乳" in shopping_list:
...     print("牛乳はリストにあります")
... else:
...     print("牛乳はリストにありません")
牛乳はリストにあります
```

## 【実行】買い物リスト管理プログラム

実用的な買い物リスト管理プログラムを作って、リストの活用方法を学びましょう。

### ステップ1：基本的な買い物リスト

```python
>>> class ShoppingList:
...     def __init__(self):
...         self.items = []
...         self.completed_items = []
...     
...     def add_item(self, item, quantity=1):
...         """商品を追加"""
...         shopping_item = {
...             "name": item,
...             "quantity": quantity,
...             "completed": False
...         }
...         self.items.append(shopping_item)
...         print(f"✅ '{item}' を {quantity}個 追加しました")
...     
...     def mark_completed(self, item_name):
...         """商品を購入済みにマーク"""
...         for item in self.items:
...             if item["name"] == item_name and not item["completed"]:
...                 item["completed"] = True
...                 self.completed_items.append(item)
...                 print(f"✅ '{item_name}' を購入済みにしました")
...                 return True
...         print(f"❌ '{item_name}' が見つかりません")
...         return False
...     
...     def remove_item(self, item_name):
...         """商品をリストから削除"""
...         for i, item in enumerate(self.items):
...             if item["name"] == item_name:
...                 removed = self.items.pop(i)
...                 print(f"🗑️ '{item_name}' をリストから削除しました")
...                 return removed
...         print(f"❌ '{item_name}' が見つかりません")
...         return None
...     
...     def display_list(self):
...         """リストを表示"""
...         if not self.items:
...             print("📝 買い物リストは空です")
...             return
...         
...         print("\n📝 === 買い物リスト ===")
...         pending_items = [item for item in self.items if not item["completed"]]
...         completed_items = [item for item in self.items if item["completed"]]
...         
...         if pending_items:
...             print("【未購入】")
...             for i, item in enumerate(pending_items, 1):
...                 print(f"  {i}. {item['name']} × {item['quantity']}")
...         
...         if completed_items:
...             print("【購入済み】")
...             for i, item in enumerate(completed_items, 1):
...                 print(f"  ✓ {item['name']} × {item['quantity']}")
...         
...         print(f"\n📊 進捗: {len(completed_items)}/{len(self.items)} 完了")
...     
...     def get_summary(self):
...         """買い物の概要を取得"""
...         total_items = len(self.items)
...         completed_count = len([item for item in self.items if item["completed"]])
...         pending_count = total_items - completed_count
...         
...         return {
...             "total": total_items,
...             "completed": completed_count,
...             "pending": pending_count,
...             "completion_rate": (completed_count / total_items * 100) if total_items > 0 else 0
...         }
... 

>>> # 使用例
>>> my_shopping = ShoppingList()

>>> # 商品追加
>>> my_shopping.add_item("牛乳", 2)
>>> my_shopping.add_item("パン", 1)
>>> my_shopping.add_item("卵", 12)
>>> my_shopping.add_item("りんご", 5)

✅ '牛乳' を 2個 追加しました
✅ 'パン' を 1個 追加しました
✅ '卵' を 12個 追加しました
✅ 'りんご' を 5個 追加しました

>>> # リスト表示
>>> my_shopping.display_list()

📝 === 買い物リスト ===
【未購入】
  1. 牛乳 × 2
  2. パン × 1
  3. 卵 × 12
  4. りんご × 5

📊 進捗: 0/4 完了

>>> # 購入済みマーク
>>> my_shopping.mark_completed("牛乳")
>>> my_shopping.mark_completed("パン")

✅ '牛乳' を購入済みにしました
✅ 'パン' を購入済みにしました

>>> my_shopping.display_list()

📝 === 買い物リスト ===
【未購入】
  1. 卵 × 12
  2. りんご × 5
【購入済み】
  ✓ 牛乳 × 2
  ✓ パン × 1

📊 進捗: 2/4 完了
```

### ステップ2：カテゴリ別管理機能

```python
>>> class AdvancedShoppingList:
...     def __init__(self):
...         self.categories = {
...             "肉・魚": [],
...             "野菜・果物": [],
...             "乳製品": [],
...             "パン・米": [],
...             "調味料": [],
...             "その他": []
...         }
...         self.budget = 0
...         self.total_cost = 0
...     
...     def set_budget(self, amount):
...         """予算を設定"""
...         self.budget = amount
...         print(f"💰 予算を {amount}円 に設定しました")
...     
...     def add_item(self, name, quantity=1, category="その他", estimated_price=0):
...         """商品を追加（カテゴリ別）"""
...         if category not in self.categories:
...             category = "その他"
...         
...         item = {
...             "name": name,
...             "quantity": quantity,
...             "estimated_price": estimated_price,
...             "actual_price": 0,
...             "completed": False
...         }
...         
...         self.categories[category].append(item)
...         print(f"✅ '{name}' を {category} カテゴリに追加")
...         
...         if estimated_price > 0:
...             print(f"   予想価格: {estimated_price}円")
...     
...     def mark_purchased(self, name, actual_price=None, category=None):
...         """商品を購入済みにマーク"""
...         categories_to_search = [category] if category else self.categories.keys()
...         
...         for cat in categories_to_search:
...             for item in self.categories[cat]:
...                 if item["name"] == name and not item["completed"]:
...                     item["completed"] = True
...                     if actual_price is not None:
...                         item["actual_price"] = actual_price
...                         self.total_cost += actual_price
...                     print(f"✅ '{name}' を購入済みにしました")
...                     if actual_price:
...                         print(f"   実際の価格: {actual_price}円")
...                     return True
...         
...         print(f"❌ '{name}' が見つかりません")
...         return False
...     
...     def display_by_category(self):
...         """カテゴリ別にリストを表示"""
...         print("\n🛒 === カテゴリ別買い物リスト ===")
...         
...         total_items = 0
...         completed_items = 0
...         estimated_total = 0
...         
...         for category, items in self.categories.items():
...             if items:  # 空でないカテゴリのみ表示
...                 print(f"\n📂 {category}")
...                 for item in items:
...                     status = "✓" if item["completed"] else "○"
...                     price_info = ""
...                     if item["estimated_price"] > 0:
...                         price_info = f" (予想: {item['estimated_price']}円)"
...                     if item["actual_price"] > 0:
...                         price_info += f" [実際: {item['actual_price']}円]"
...                     
...                     print(f"  {status} {item['name']} × {item['quantity']}{price_info}")
...                     
...                     total_items += 1
...                     if item["completed"]:
...                         completed_items += 1
...                     estimated_total += item["estimated_price"] * item["quantity"]
...         
...         # サマリー表示
...         print(f"\n📊 === サマリー ===")
...         print(f"進捗: {completed_items}/{total_items} 完了")
...         print(f"予想総額: {estimated_total}円")
...         if self.budget > 0:
...             print(f"予算: {self.budget}円")
...             remaining = self.budget - estimated_total
...             if remaining >= 0:
...                 print(f"予算残り: {remaining}円")
...             else:
...                 print(f"予算オーバー: {-remaining}円")
...         print(f"実際の支払い: {self.total_cost}円")
...     
...     def get_shopping_route(self):
...         """効率的な買い物ルートを提案"""
...         # 一般的なスーパーマーケットのレイアウト順
...         route_order = ["野菜・果物", "肉・魚", "乳製品", "パン・米", "調味料", "その他"]
...         
...         print("\n🗺️ === 効率的な買い物ルート ===")
...         route_number = 1
...         
...         for category in route_order:
...             pending_items = [item for item in self.categories[category] if not item["completed"]]
...             if pending_items:
...                 print(f"{route_number}. {category} コーナー")
...                 for item in pending_items:
...                     print(f"   • {item['name']} × {item['quantity']}")
...                 route_number += 1
... 

>>> # 使用例
>>> advanced_list = AdvancedShoppingList()

>>> # 予算設定
>>> advanced_list.set_budget(3000)

💰 予算を 3000円 に設定しました

>>> # カテゴリ別に商品追加
>>> advanced_list.add_item("牛乳", 1, "乳製品", 200)
>>> advanced_list.add_item("食パン", 1, "パン・米", 150)
>>> advanced_list.add_item("りんご", 3, "野菜・果物", 300)
>>> advanced_list.add_item("鶏肉", 1, "肉・魚", 400)
>>> advanced_list.add_item("醤油", 1, "調味料", 250)

✅ '牛乳' を 乳製品 カテゴリに追加
   予想価格: 200円
✅ '食パン' を パン・米 カテゴリに追加
   予想価格: 150円
✅ 'りんご' を 野菜・果物 カテゴリに追加
   予想価格: 300円
✅ '鶏肉' を 肉・魚 カテゴリに追加
   予想価格: 400円
✅ '醤油' を 調味料 カテゴリに追加
   予想価格: 250円

>>> # リスト表示
>>> advanced_list.display_by_category()

🛒 === カテゴリ別買い物リスト ===

📂 肉・魚
  ○ 鶏肉 × 1 (予想: 400円)

📂 野菜・果物
  ○ りんご × 3 (予想: 300円)

📂 乳製品
  ○ 牛乳 × 1 (予想: 200円)

📂 パン・米
  ○ 食パン × 1 (予想: 150円)

📂 調味料
  ○ 醤油 × 1 (予想: 250円)

📊 === サマリー ===
進捗: 0/5 完了
予想総額: 1300円
予算: 3000円
予算残り: 1700円
実際の支払い: 0円

>>> # 買い物ルート表示
>>> advanced_list.get_shopping_route()

🗺️ === 効率的な買い物ルート ===
1. 野菜・果物 コーナー
   • りんご × 3
2. 肉・魚 コーナー
   • 鶏肉 × 1
3. 乳製品 コーナー
   • 牛乳 × 1
4. パン・米 コーナー
   • 食パン × 1
5. 調味料 コーナー
   • 醤油 × 1

>>> # いくつか購入
>>> advanced_list.mark_purchased("牛乳", 180)
>>> advanced_list.mark_purchased("りんご", 280)

✅ '牛乳' を購入済みにしました
   実際の価格: 180円
✅ 'りんご' を購入済みにしました
   実際の価格: 280円
```

### ステップ3：リストの高度な操作

```python
>>> # リストの並び替えとフィルタリング
>>> numbers = [64, 34, 25, 12, 22, 11, 90]

>>> # 元のリストを変更せずにソート
>>> sorted_numbers = sorted(numbers)
>>> print(f"元のリスト: {numbers}")
>>> print(f"ソート済み: {sorted_numbers}")

元のリスト: [64, 34, 25, 12, 22, 11, 90]
ソート済み: [11, 12, 22, 25, 34, 64, 90]

>>> # 元のリストを直接変更
>>> numbers.sort(reverse=True)  # 降順
>>> print(f"降順ソート: {numbers}")

降順ソート: [90, 64, 34, 25, 22, 12, 11]

>>> # リスト内包表記（基本）
>>> squares = [x ** 2 for x in range(1, 6)]
>>> print(f"平方数: {squares}")

平方数: [1, 4, 9, 16, 25]

>>> # 条件付きリスト内包表記
>>> even_squares = [x ** 2 for x in range(1, 11) if x % 2 == 0]
>>> print(f"偶数の平方: {even_squares}")

偶数の平方: [4, 16, 36, 64, 100]

>>> # 実用的な例：価格リストの処理
>>> products = [
...     {"name": "ノートPC", "price": 80000},
...     {"name": "マウス", "price": 2000},
...     {"name": "キーボード", "price": 5000},
...     {"name": "モニター", "price": 25000}
... ]

>>> # 10000円以下の商品名を取得
>>> affordable_products = [p["name"] for p in products if p["price"] <= 10000]
>>> print(f"10000円以下: {affordable_products}")

10000円以下: ['マウス', 'キーボード']

>>> # 価格に消費税を追加
>>> prices_with_tax = [p["price"] * 1.1 for p in products]
>>> print(f"税込価格: {prices_with_tax}")

税込価格: [88000.0, 2200.0, 5500.0, 27500.0]
```

## 辞書 - 名前をつけて整理

### 辞書とは

**辞書**は、キーと値のペアでデータを管理するデータ構造です。現実世界の辞書で「単語」から「意味」を調べるように、「キー」から「値」を効率的に取得できます。

```python
>>> # 辞書の作成
>>> student = {
...     "name": "田中太郎",
...     "age": 20,
...     "grade": "A",
...     "subjects": ["数学", "英語", "理科"]
... }

>>> print(f"学生情報: {student}")
学生情報: {'name': '田中太郎', 'age': 20, 'grade': 'A', 'subjects': ['数学', '英語', '理科']}

>>> # 値の取得
>>> name = student["name"]
>>> age = student["age"]
>>> print(f"名前: {name}, 年齢: {age}")

名前: 田中太郎, 年齢: 20

>>> # 安全な値の取得（キーが存在しない場合のデフォルト値）
>>> email = student.get("email", "未登録")
>>> print(f"メール: {email}")

メール: 未登録
```

### 辞書の基本操作

```python
>>> # 空の辞書から始める
>>> contact = {}

>>> # 値の追加・更新
>>> contact["name"] = "佐藤花子"
>>> contact["phone"] = "090-1234-5678"
>>> contact["email"] = "sato@example.com"

>>> print(f"連絡先: {contact}")
連絡先: {'name': '佐藤花子', 'phone': '090-1234-5678', 'email': 'sato@example.com'}

>>> # 複数の値を一度に更新
>>> contact.update({
...     "address": "東京都渋谷区",
...     "company": "ABC株式会社"
... })

>>> print(f"更新後: {contact}")
更新後: {'name': '佐藤花子', 'phone': '090-1234-5678', 'email': 'sato@example.com', 'address': '東京都渋谷区', 'company': 'ABC株式会社'}

>>> # キーの存在確認
>>> if "phone" in contact:
...     print(f"電話番号: {contact['phone']}")

電話番号: 090-1234-5678

>>> # キー、値、ペアの取得
>>> print("キー一覧:", list(contact.keys()))
>>> print("値一覧:", list(contact.values()))
>>> print("ペア一覧:", list(contact.items()))

キー一覧: ['name', 'phone', 'email', 'address', 'company']
値一覧: ['佐藤花子', '090-1234-5678', 'sato@example.com', '東京都渋谷区', 'ABC株式会社']
ペア一覧: [('name', '佐藤花子'), ('phone', '090-1234-5678'), ('email', 'sato@example.com'), ('address', '東京都渋谷区'), ('company', 'ABC株式会社')]
```

## 【実行】連絡先帳プログラム（名前→電話番号）

実用的な連絡先帳プログラムを作って、辞書の活用方法を学びましょう。

### ステップ1：基本的な連絡先帳

```python
>>> class ContactBook:
...     def __init__(self):
...         self.contacts = {}
...     
...     def add_contact(self, name, phone, email=None, address=None):
...         """連絡先を追加"""
...         contact_info = {
...             "phone": phone,
...             "email": email,
...             "address": address,
...             "created_date": "2024-01-01"  # 実際は現在日時
...         }
...         
...         self.contacts[name] = contact_info
...         print(f"✅ {name} の連絡先を追加しました")
...     
...     def search_contact(self, name):
...         """連絡先を検索"""
...         if name in self.contacts:
...             contact = self.contacts[name]
...             print(f"\n📞 === {name} の連絡先 ===")
...             print(f"電話番号: {contact['phone']}")
...             if contact['email']:
...                 print(f"メール: {contact['email']}")
...             if contact['address']:
...                 print(f"住所: {contact['address']}")
...             return contact
...         else:
...             print(f"❌ {name} の連絡先が見つかりません")
...             return None
...     
...     def update_contact(self, name, **kwargs):
...         """連絡先を更新"""
...         if name in self.contacts:
...             for key, value in kwargs.items():
...                 if key in ["phone", "email", "address"]:
...                     self.contacts[name][key] = value
...                     print(f"✅ {name} の {key} を更新しました")
...         else:
...             print(f"❌ {name} の連絡先が見つかりません")
...     
...     def delete_contact(self, name):
...         """連絡先を削除"""
...         if name in self.contacts:
...             del self.contacts[name]
...             print(f"🗑️ {name} の連絡先を削除しました")
...             return True
...         else:
...             print(f"❌ {name} の連絡先が見つかりません")
...             return False
...     
...     def list_all_contacts(self):
...         """全連絡先を一覧表示"""
...         if not self.contacts:
...             print("📕 連絡先帳は空です")
...             return
...         
...         print(f"\n📕 === 連絡先帳 ({len(self.contacts)}件) ===")
...         for name, info in sorted(self.contacts.items()):
...             print(f"👤 {name}: {info['phone']}")
...     
...     def search_by_phone(self, phone):
...         """電話番号で逆引き検索"""
...         for name, info in self.contacts.items():
...             if info['phone'] == phone:
...                 print(f"📞 {phone} は {name} の番号です")
...                 return name
...         print(f"❌ {phone} の登録者が見つかりません")
...         return None
... 

>>> # 使用例
>>> contacts = ContactBook()

>>> # 連絡先追加
>>> contacts.add_contact("田中太郎", "090-1234-5678", "tanaka@example.com", "東京都渋谷区1-1-1")
>>> contacts.add_contact("佐藤花子", "080-9876-5432", "sato@example.com")
>>> contacts.add_contact("鈴木一郎", "070-1111-2222")

✅ 田中太郎 の連絡先を追加しました
✅ 佐藤花子 の連絡先を追加しました
✅ 鈴木一郎 の連絡先を追加しました

>>> # 連絡先一覧
>>> contacts.list_all_contacts()

📕 === 連絡先帳 (3件) ===
👤 佐藤花子: 080-9876-5432
👤 田中太郎: 090-1234-5678
👤 鈴木一郎: 070-1111-2222

>>> # 検索
>>> contacts.search_contact("田中太郎")

📞 === 田中太郎 の連絡先 ===
電話番号: 090-1234-5678
メール: tanaka@example.com
住所: 東京都渋谷区1-1-1

>>> # 更新
>>> contacts.update_contact("佐藤花子", address="大阪府大阪市北区2-2-2")

✅ 佐藤花子 の address を更新しました

>>> # 逆引き検索
>>> contacts.search_by_phone("070-1111-2222")

📞 070-1111-2222 は 鈴木一郎 の番号です
```

### ステップ2：高度な検索機能

```python
>>> class AdvancedContactBook(ContactBook):
...     def __init__(self):
...         super().__init__()
...         self.groups = {}  # グループ管理
...     
...     def add_contact(self, name, phone, email=None, address=None, company=None, group="一般"):
...         """拡張された連絡先追加"""
...         contact_info = {
...             "phone": phone,
...             "email": email,
...             "address": address,
...             "company": company,
...             "group": group,
...             "created_date": "2024-01-01",
...             "notes": ""
...         }
...         
...         self.contacts[name] = contact_info
...         
...         # グループに追加
...         if group not in self.groups:
...             self.groups[group] = []
...         if name not in self.groups[group]:
...             self.groups[group].append(name)
...         
...         print(f"✅ {name} を {group} グループに追加しました")
...     
...     def search_by_keyword(self, keyword):
...         """キーワードで検索"""
...         results = []
...         keyword_lower = keyword.lower()
...         
...         for name, info in self.contacts.items():
...             # 名前、会社名、住所、メールで検索
...             search_fields = [
...                 name.lower(),
...                 (info.get('company') or '').lower(),
...                 (info.get('address') or '').lower(),
...                 (info.get('email') or '').lower()
...             ]
...             
...             if any(keyword_lower in field for field in search_fields):
...                 results.append(name)
...         
...         if results:
...             print(f"\n🔍 '{keyword}' の検索結果 ({len(results)}件):")
...             for name in results:
...                 info = self.contacts[name]
...                 print(f"👤 {name} ({info['group']}) - {info['phone']}")
...         else:
...             print(f"❌ '{keyword}' に一致する連絡先が見つかりません")
...         
...         return results
...     
...     def list_by_group(self, group=None):
...         """グループ別に表示"""
...         if group:
...             if group in self.groups:
...                 print(f"\n👥 === {group} グループ ===")
...                 for name in sorted(self.groups[group]):
...                     info = self.contacts[name]
...                     print(f"👤 {name}: {info['phone']}")
...             else:
...                 print(f"❌ '{group}' グループが見つかりません")
...         else:
...             print("\n👥 === 全グループ ===")
...             for group_name in sorted(self.groups.keys()):
...                 print(f"\n📂 {group_name} ({len(self.groups[group_name])}人)")
...                 for name in sorted(self.groups[group_name]):
...                     info = self.contacts[name]
...                     print(f"  👤 {name}: {info['phone']}")
...     
...     def export_to_csv_format(self):
...         """CSV形式でエクスポート"""
...         print("\n📄 === CSV形式エクスポート ===")
...         print("名前,電話番号,メール,住所,会社,グループ")
...         
...         for name in sorted(self.contacts.keys()):
...             info = self.contacts[name]
...             csv_line = f"{name},{info['phone']},{info.get('email', '')},{info.get('address', '')},{info.get('company', '')},{info['group']}"
...             print(csv_line)
... 

>>> # 使用例
>>> advanced_contacts = AdvancedContactBook()

>>> # 様々なグループで連絡先追加
>>> advanced_contacts.add_contact("田中太郎", "090-1234-5678", "tanaka@abc.com", "東京都渋谷区", "ABC株式会社", "仕事")
>>> advanced_contacts.add_contact("佐藤花子", "080-9876-5432", "sato@def.com", "大阪府大阪市", "DEF商事", "仕事")
>>> advanced_contacts.add_contact("鈴木一郎", "070-1111-2222", "suzuki@personal.com", "愛知県名古屋市", "", "友人")
>>> advanced_contacts.add_contact("山田健太", "060-3333-4444", "", "", "GHI建設", "仕事")

✅ 田中太郎 を 仕事 グループに追加しました
✅ 佐藤花子 を 仕事 グループに追加しました
✅ 鈴木一郎 を 友人 グループに追加しました
✅ 山田健太 を 仕事 グループに追加しました

>>> # グループ別表示
>>> advanced_contacts.list_by_group()

👥 === 全グループ ===

📂 仕事 (3人)
  👤 佐藤花子: 080-9876-5432
  👤 田中太郎: 090-1234-5678
  👤 山田健太: 060-3333-4444

📂 友人 (1人)
  👤 鈴木一郎: 070-1111-2222

>>> # キーワード検索
>>> advanced_contacts.search_by_keyword("ABC")

🔍 'ABC' の検索結果 (1件):
👤 田中太郎 (仕事) - 090-1234-5678

>>> advanced_contacts.search_by_keyword("東京")

🔍 '東京' の検索結果 (1件):
👤 田中太郎 (仕事) - 090-1234-5678

>>> # CSV形式エクスポート
>>> advanced_contacts.export_to_csv_format()

📄 === CSV形式エクスポート ===
名前,電話番号,メール,住所,会社,グループ
佐藤花子,080-9876-5432,sato@def.com,大阪府大阪市,DEF商事,仕事
田中太郎,090-1234-5678,tanaka@abc.com,東京都渋谷区,ABC株式会社,仕事
山田健太,060-3333-4444,,,GHI建設,仕事
鈴木一郎,070-1111-2222,suzuki@personal.com,愛知県名古屋市,,友人
```

## セット - 重複のない集合

### セットとは

**セット**は、重複を許さない要素の集合です。数学の「集合」と同じ概念で、同じ要素は一つしか存在できません。

```python
>>> # セットの作成
>>> fruits = {"りんご", "バナナ", "オレンジ", "りんご"}  # りんごが重複
>>> print(f"果物セット: {fruits}")

果物セット: {'オレンジ', 'りんご', 'バナナ'}  # 重複が自動で削除される

>>> # リストから重複を除去
>>> numbers_list = [1, 2, 2, 3, 3, 3, 4, 5]
>>> unique_numbers = set(numbers_list)
>>> print(f"元のリスト: {numbers_list}")
>>> print(f"重複除去後: {unique_numbers}")

元のリスト: [1, 2, 2, 3, 3, 3, 4, 5]
重複除去後: {1, 2, 3, 4, 5}

>>> # 空のセット
>>> empty_set = set()  # {}は辞書になってしまうため
>>> print(f"空のセット: {empty_set}")

空のセット: set()
```

### セットの操作

```python
>>> # セットの基本操作
>>> set1 = {1, 2, 3, 4, 5}
>>> set2 = {4, 5, 6, 7, 8}

>>> # 和集合（どちらかに含まれる要素）
>>> union_set = set1 | set2
>>> print(f"和集合: {union_set}")

和集合: {1, 2, 3, 4, 5, 6, 7, 8}

>>> # 積集合（両方に含まれる要素）
>>> intersection_set = set1 & set2
>>> print(f"積集合: {intersection_set}")

積集合: {4, 5}

>>> # 差集合（set1にあってset2にない要素）
>>> difference_set = set1 - set2
>>> print(f"差集合: {difference_set}")

差集合: {1, 2, 3}

>>> # 対称差集合（どちらか一方にのみ含まれる要素）
>>> symmetric_difference = set1 ^ set2
>>> print(f"対称差集合: {symmetric_difference}")

対称差集合: {1, 2, 3, 6, 7, 8}
```

### 実用的なセットの活用例

```python
>>> def analyze_survey_data():
...     """アンケートデータの分析"""
...     
...     # 複数の質問に対する回答者
...     question1_respondents = {"田中", "佐藤", "鈴木", "山田", "高橋"}
...     question2_respondents = {"佐藤", "鈴木", "伊藤", "渡辺", "高橋"}
...     question3_respondents = {"田中", "鈴木", "山田", "伊藤", "木村"}
...     
...     print("=== アンケート分析 ===")
...     print(f"質問1回答者: {question1_respondents}")
...     print(f"質問2回答者: {question2_respondents}")
...     print(f"質問3回答者: {question3_respondents}")
...     
...     # 全質問に回答した人
...     all_answered = question1_respondents & question2_respondents & question3_respondents
...     print(f"\n全質問回答者: {all_answered}")
...     
...     # 少なくとも1つの質問に回答した人
...     any_answered = question1_respondents | question2_respondents | question3_respondents
...     print(f"回答者総数: {len(any_answered)}人")
...     print(f"回答者一覧: {any_answered}")
...     
...     # 質問1のみに回答した人
...     only_q1 = question1_respondents - question2_respondents - question3_respondents
...     print(f"質問1のみ回答: {only_q1}")
...     
...     # 質問1と2には回答したが質問3には回答しなかった人
...     q1_and_q2_but_not_q3 = (question1_respondents & question2_respondents) - question3_respondents
...     print(f"質問1,2回答、質問3未回答: {q1_and_q2_but_not_q3}")
... 

>>> analyze_survey_data()

=== アンケート分析 ===
質問1回答者: {'山田', '高橋', '佐藤', '鈴木', '田中'}
質問2回答者: {'渡辺', '高橋', '佐藤', '鈴木', '伊藤'}
質問3回答者: {'山田', '木村', '伊藤', '鈴木', '田中'}

全質問回答者: {'鈴木'}
回答者総数: 8人
回答者一覧: {'山田', '渡辺', '高橋', '佐藤', '鈴木', '田中', '木村', '伊藤'}
質問1のみ回答: set()
質問1,2回答、質問3未回答: {'高橋', '佐藤'}

>>> # 重複データのクリーニング
>>> def clean_email_list(email_list):
...     """メールアドレスリストのクリーニング"""
...     
...     print("=== メールリストクリーニング ===")
...     print(f"元のリスト件数: {len(email_list)}")
...     
...     # セットで重複除去
...     unique_emails = set(email_list)
...     print(f"重複除去後: {len(unique_emails)}")
...     
...     # 有効なメールアドレスのみフィルタ
...     valid_emails = set()
...     for email in unique_emails:
...         if "@" in email and "." in email.split("@")[1]:
...             valid_emails.add(email.lower())  # 小文字に正規化
...     
...     print(f"有効なメール: {len(valid_emails)}")
...     return sorted(valid_emails)
... 

>>> # テストデータ
>>> test_emails = [
...     "user1@example.com",
...     "USER1@EXAMPLE.COM",  # 大文字小文字違い
...     "user2@test.co.jp",
...     "user1@example.com",  # 完全な重複
...     "invalid-email",      # 無効なメール
...     "user3@domain",       # ドメインが不完全
...     "user4@valid.org"
... ]

>>> cleaned_emails = clean_email_list(test_emails)
>>> print(f"クリーニング結果: {cleaned_emails}")

=== メールリストクリーニング ===
元のリスト件数: 7
重複除去後: 6
有効なメール: 3
クリーニング結果: ['user1@example.com', 'user2@test.co.jp', 'user4@valid.org']
```

## データ構造の使い分け

### それぞれの特徴と適用場面

```python
>>> def demonstrate_data_structures():
...     """データ構造の使い分けデモ"""
...     
...     print("=== データ構造の比較 ===\n")
...     
...     # リスト：順序が重要、重複あり、変更可能
...     print("📝 リスト（順序あり、重複あり、変更可能）")
...     shopping_list = ["牛乳", "パン", "卵", "牛乳"]  # 重複あり
...     print(f"買い物リスト: {shopping_list}")
...     print(f"最初の項目: {shopping_list[0]}")
...     shopping_list.append("チーズ")
...     print(f"追加後: {shopping_list}")
...     print()
...     
...     # 辞書：キー値ペア、高速検索
...     print("📖 辞書（キー値ペア、高速検索）")
...     student_grades = {
...         "田中": 85,
...         "佐藤": 92,
...         "鈴木": 78
...     }
...     print(f"成績表: {student_grades}")
...     print(f"田中の成績: {student_grades['田中']}")
...     student_grades["山田"] = 88
...     print(f"追加後: {student_grades}")
...     print()
...     
...     # セット：重複なし、集合演算
...     print("🔢 セット（重複なし、集合演算）")
...     class_a = {"田中", "佐藤", "鈴木", "山田"}
...     class_b = {"佐藤", "山田", "高橋", "伊藤"}
...     print(f"クラスA: {class_a}")
...     print(f"クラスB: {class_b}")
...     print(f"両クラス共通: {class_a & class_b}")
...     print(f"全参加者: {class_a | class_b}")
...     print()
...     
...     # 適切な選択の例
...     print("💡 使い分けの例:")
...     print("• 順番が重要な作業手順 → リスト")
...     print("• 名前から情報を検索 → 辞書") 
...     print("• 重複排除や集合演算 → セット")
... 

>>> demonstrate_data_structures()

=== データ構造の比較 ===

📝 リスト（順序あり、重複あり、変更可能）
買い物リスト: ['牛乳', 'パン', '卵', '牛乳']
最初の項目: 牛乳
追加後: ['牛乳', 'パン', '卵', '牛乳', 'チーズ']

📖 辞書（キー値ペア、高速検索）
成績表: {'田中': 85, '佐藤': 92, '鈴木': 78}
田中の成績: 85
追加後: {'田中': 85, '佐藤': 92, '鈴木': 78, '山田': 88}

🔢 セット（重複なし、集合演算）
クラスA: {'山田', '佐藤', '鈴木', '田中'}
クラスB: {'山田', '高橋', '佐藤', '伊藤'}
両クラス共通: {'山田', '佐藤'}
全参加者: {'山田', '高橋', '佐藤', '鈴木', '田中', '伊藤'}

💡 使い分けの例:
• 順番が重要な作業手順 → リスト
• 名前から情報を検索 → 辞書
• 重複排除や集合演算 → セット
```

## まとめ：データ構造の効果的な活用

この章で学んだことをまとめましょう：

### リスト（list）
- **特徴**: 順序あり、重複あり、変更可能
- **用途**: 順番が重要なデータ、同じ値の重複が必要
- **例**: 買い物リスト、作業手順、時系列データ
- **主要メソッド**: append(), extend(), insert(), remove(), pop()

### 辞書（dict）
- **特徴**: キー値ペア、高速検索、順序保持（Python 3.7+）
- **用途**: 名前から情報を検索、設定値の管理
- **例**: 連絡先帳、設定ファイル、データベース的な用途
- **主要メソッド**: get(), keys(), values(), items(), update()

### セット（set）
- **特徴**: 重複なし、順序なし、集合演算可能
- **用途**: 重複排除、集合演算、メンバーシップテスト
- **例**: ユニークな値の管理、共通要素の抽出
- **主要演算**: |（和集合）、&（積集合）、-（差集合）

### 実用的な応用例
- 買い物リスト管理システム（リスト）
- 連絡先帳システム（辞書）
- アンケート分析システム（セット）
- データクリーニング処理

### プログラム設計のポイント
- データの性質に応じた適切な構造の選択
- 効率的な検索・更新・削除操作
- エラーハンドリングの実装
- ユーザビリティの向上

次の章では、処理をまとめて再利用可能にする「関数」について学びます。BMI計算関数や割引価格計算関数を作りながら、プログラムをより構造化し、保守しやすくする方法を習得しましょう！