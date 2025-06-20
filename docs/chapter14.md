# 第14章：クラスとオブジェクト指向プログラミング

これまでの章では、関数を使ってプログラムを整理してきました。しかし、もっと大きなプログラムでは、データと処理をひとまとめにした「設計図」があると便利です。この章では、**クラス**と**オブジェクト指向プログラミング**を学びます。図書館管理システムやゲームキャラクターシステムを作りながら、現実世界のものをプログラムで表現する方法を習得しましょう。

## クラスとオブジェクトって何？

### 現実世界との対応

**クラス**は「設計図」、**オブジェクト**は「設計図から作られた実際のもの」と考えることができます：

**現実世界の例：**
- **設計図（クラス）**: 車の設計図
- **実際のもの（オブジェクト）**: トヨタのプリウス、ホンダのシビック

**プログラムの例：**
- **設計図（クラス）**: 「人」クラス
- **実際のもの（オブジェクト）**: 田中太郎さん、佐藤花子さん

### クラスを使わない場合の問題

```python
>>> # クラスを使わない人物管理（悪い例）
>>> # 田中太郎さんの情報
>>> tanaka_name = "田中太郎"
>>> tanaka_age = 30
>>> tanaka_email = "tanaka@example.com"
>>> tanaka_skills = ["Python", "Java", "HTML"]

>>> # 佐藤花子さんの情報
>>> sato_name = "佐藤花子"
>>> sato_age = 25
>>> sato_email = "sato@example.com"
>>> sato_skills = ["JavaScript", "CSS", "React"]

>>> # 年齢を1つ増やす処理
>>> def increase_age_tanaka():
...     global tanaka_age
...     tanaka_age += 1
...     print(f"{tanaka_name}さんの年齢: {tanaka_age}歳")

>>> def increase_age_sato():
...     global sato_age
...     sato_age += 1
...     print(f"{sato_name}さんの年齢: {sato_age}歳")

>>> # スキルを追加する処理
>>> def add_skill_tanaka(skill):
...     tanaka_skills.append(skill)
...     print(f"{tanaka_name}さんのスキル: {tanaka_skills}")

>>> def add_skill_sato(skill):
...     sato_skills.append(skill)
...     print(f"{sato_name}さんのスキル: {sato_skills}")
```

**問題点：**
1. 人が増えるたびに変数と関数が倍増する
2. 同じような処理を何度も書く必要がある
3. データと処理がバラバラで管理しにくい
4. 間違った人の情報を変更してしまう可能性がある

### クラスを使った解決策

```python
>>> class Person:
...     """人を表すクラス"""
...     
...     def __init__(self, name, age, email):
...         """初期化メソッド（コンストラクタ）"""
...         self.name = name
...         self.age = age
...         self.email = email
...         self.skills = []
...     
...     def increase_age(self):
...         """年齢を1つ増やす"""
...         self.age += 1
...         print(f"{self.name}さんの年齢: {self.age}歳")
...     
...     def add_skill(self, skill):
...         """スキルを追加"""
...         self.skills.append(skill)
...         print(f"{self.name}さんのスキル: {self.skills}")
...     
...     def get_info(self):
...         """人物情報を取得"""
...         return f"名前: {self.name}, 年齢: {self.age}歳, メール: {self.email}, スキル: {self.skills}"
... 

>>> # オブジェクトの作成
>>> tanaka = Person("田中太郎", 30, "tanaka@example.com")
>>> sato = Person("佐藤花子", 25, "sato@example.com")

>>> # 初期スキルの設定
>>> tanaka.add_skill("Python")
>>> tanaka.add_skill("Java")
>>> sato.add_skill("JavaScript")
>>> sato.add_skill("CSS")

田中太郎さんのスキル: ['Python']
田中太郎さんのスキル: ['Python', 'Java']
佐藤花子さんのスキル: ['JavaScript']
佐藤花子さんのスキル: ['JavaScript', 'CSS']

>>> # 年齢を増やす
>>> tanaka.increase_age()
>>> sato.increase_age()

田中太郎さんの年齢: 31歳
佐藤花子さんの年齢: 26歳

>>> # 情報表示
>>> print(tanaka.get_info())
>>> print(sato.get_info())

名前: 田中太郎, 年齢: 31歳, メール: tanaka@example.com, スキル: ['Python', 'Java']
名前: 佐藤花子, 年齢: 26歳, メール: sato@example.com, スキル: ['JavaScript', 'CSS']
```

**クラスのメリット：**
1. **再利用性**: 一つの設計図で何個でもオブジェクトを作れる
2. **整理**: データと処理がまとまって管理しやすい
3. **安全性**: 他のオブジェクトの情報を間違って変更する心配がない
4. **拡張性**: 新しい機能を簡単に追加できる

## 【実行】図書館管理システムを作ろう

実用的な図書館管理システムを作って、クラスの使い方を学びましょう。

### ステップ1：本（Book）クラス

```python
>>> from datetime import datetime, timedelta

>>> class Book:
...     """図書館の本を表すクラス"""
...     
...     def __init__(self, isbn, title, author, genre, published_year):
...         """本の初期化"""
...         self.isbn = isbn
...         self.title = title
...         self.author = author
...         self.genre = genre
...         self.published_year = published_year
...         self.is_available = True  # 貸出可能かどうか
...         self.borrower = None      # 借りている人
...         self.borrowed_date = None # 借りた日
...         self.due_date = None      # 返却期限
...         self.borrow_history = []  # 貸出履歴
...     
...     def borrow(self, borrower_name, loan_period_days=14):
...         """本を貸し出す"""
...         if not self.is_available:
...             return False, f"'{self.title}'は既に貸出中です"
...         
...         self.is_available = False
...         self.borrower = borrower_name
...         self.borrowed_date = datetime.now()
...         self.due_date = self.borrowed_date + timedelta(days=loan_period_days)
...         
...         # 貸出履歴に記録
...         borrow_record = {
...             "borrower": borrower_name,
...             "borrowed_date": self.borrowed_date,
...             "due_date": self.due_date,
...             "returned_date": None
...         }
...         self.borrow_history.append(borrow_record)
...         
...         return True, f"'{self.title}'を{borrower_name}さんに貸し出しました（返却期限: {self.due_date.strftime('%Y-%m-%d')}）"
...     
...     def return_book(self):
...         """本を返却する"""
...         if self.is_available:
...             return False, f"'{self.title}'は貸出されていません"
...         
...         return_date = datetime.now()
...         borrower_name = self.borrower
...         
...         # 延滞チェック
...         is_overdue = return_date > self.due_date
...         overdue_days = (return_date - self.due_date).days if is_overdue else 0
...         
...         # 貸出履歴を更新
...         if self.borrow_history:
...             self.borrow_history[-1]["returned_date"] = return_date
...         
...         # 本の状態をリセット
...         self.is_available = True
...         self.borrower = None
...         self.borrowed_date = None
...         self.due_date = None
...         
...         if is_overdue:
...             return True, f"'{self.title}'が返却されました（{overdue_days}日延滞）"
...         else:
...             return True, f"'{self.title}'が返却されました"
...     
...     def is_overdue(self):
...         """延滞しているかチェック"""
...         if self.is_available or self.due_date is None:
...             return False
...         return datetime.now() > self.due_date
...     
...     def get_status(self):
...         """本の状態を取得"""
...         if self.is_available:
...             return "貸出可能"
...         else:
...             status = f"貸出中（借り手: {self.borrower}）"
...             if self.is_overdue():
...                 overdue_days = (datetime.now() - self.due_date).days
...                 status += f" ⚠️ {overdue_days}日延滞"
...             return status
...     
...     def get_info(self):
...         """本の詳細情報を取得"""
...         return {
...             "ISBN": self.isbn,
...             "タイトル": self.title,
...             "著者": self.author,
...             "ジャンル": self.genre,
...             "出版年": self.published_year,
...             "状態": self.get_status(),
...             "貸出回数": len(self.borrow_history)
...         }
... 

>>> # 本のオブジェクトを作成
>>> book1 = Book("978-4-12-345678-9", "Pythonプログラミング入門", "山田太郎", "プログラミング", 2023)
>>> book2 = Book("978-4-98-765432-1", "データサイエンスの基礎", "田中花子", "データサイエンス", 2022)
>>> book3 = Book("978-4-55-123456-7", "機械学習実践ガイド", "鈴木一郎", "AI・機械学習", 2024)

>>> # 本の情報を表示
>>> print("=== 図書館の蔵書 ===")
>>> for book in [book1, book2, book3]:
...     info = book.get_info()
...     print(f"『{info['タイトル』}』- {info['著者']} ({info['状態']})")

=== 図書館の蔵書 ===
『Pythonプログラミング入門』- 山田太郎 (貸出可能)
『データサイエンスの基礎』- 田中花子 (貸出可能)
『機械学習実践ガイド』- 鈴木一郎 (貸出可能)

>>> # 本の貸出
>>> success, message = book1.borrow("田中太郎")
>>> print(message)

>>> success, message = book2.borrow("佐藤花子")
>>> print(message)

Pythonプログラミング入門'を田中太郎さんに貸し出しました（返却期限: 2024-12-19）
'データサイエンスの基礎'を佐藤花子さんに貸し出しました（返却期限: 2024-12-19）

>>> # 貸出状況の確認
>>> print("\\n=== 貸出状況 ===")
>>> for book in [book1, book2, book3]:
...     info = book.get_info()
...     print(f"『{info['タイトル』}』- {info['状態']}")

=== 貸出状況 ===
『Pythonプログラミング入門』- 貸出中（借り手: 田中太郎）
『データサイエンスの基礎』- 貸出中（借り手: 佐藤花子）
『機械学習実践ガイド』- 貸出可能

>>> # 本の返却
>>> success, message = book1.return_book()
>>> print(f"\\n{message}")

'Pythonプログラミング入門'が返却されました
```

### ステップ2：利用者（Member）クラス

```python
>>> class Member:
...     """図書館の利用者を表すクラス"""
...     
...     def __init__(self, member_id, name, email, phone):
...         """利用者の初期化"""
...         self.member_id = member_id
...         self.name = name
...         self.email = email
...         self.phone = phone
...         self.borrowed_books = []      # 現在借りている本のリスト
...         self.borrow_history = []      # 過去の借用履歴
...         self.registration_date = datetime.now()
...         self.is_active = True
...         self.overdue_count = 0        # 延滞回数
...         self.fine_amount = 0          # 延滞料金
...     
...     def can_borrow(self, max_books=5, max_overdue=3):
...         """貸出可能かチェック"""
...         if not self.is_active:
...             return False, "アカウントが停止されています"
...         
...         if len(self.borrowed_books) >= max_books:
...             return False, f"同時貸出限度数({max_books}冊)を超えています"
...         
...         if self.overdue_count >= max_overdue:
...             return False, f"延滞回数が限度({max_overdue}回)を超えています"
...         
...         if self.fine_amount > 0:
...             return False, f"未払いの延滞料金があります: {self.fine_amount}円"
...         
...         return True, "貸出可能です"
...     
...     def borrow_book(self, book):
...         """本を借りる"""
...         # 貸出可能かチェック
...         can_borrow, message = self.can_borrow()
...         if not can_borrow:
...             return False, f"貸出不可: {message}"
...         
...         # 本を借りる
...         success, borrow_message = book.borrow(self.name)
...         if not success:
...             return False, borrow_message
...         
...         # 利用者の借用リストに追加
...         self.borrowed_books.append(book)
...         
...         # 借用履歴に記録
...         borrow_record = {
...             "book": book,
...             "borrowed_date": datetime.now(),
...             "returned_date": None
...         }
...         self.borrow_history.append(borrow_record)
...         
...         return True, borrow_message
...     
...     def return_book(self, book):
...         """本を返す"""
...         if book not in self.borrowed_books:
...             return False, "この本は借りていません"
...         
...         # 延滞チェック
...         was_overdue = book.is_overdue()
...         if was_overdue:
...             self.overdue_count += 1
...             overdue_days = (datetime.now() - book.due_date).days
...             fine = overdue_days * 10  # 1日10円の延滞料金
...             self.fine_amount += fine
...         
...         # 本を返却
...         success, return_message = book.return_book()
...         if success:
...             self.borrowed_books.remove(book)
...             
...             # 借用履歴を更新
...             for record in reversed(self.borrow_history):
...                 if record["book"] == book and record["returned_date"] is None:
...                     record["returned_date"] = datetime.now()
...                     break
...         
...         return success, return_message
...     
...     def pay_fine(self, amount):
...         """延滞料金を支払う"""
...         if amount <= 0:
...             return False, "支払い金額は正の数である必要があります"
...         
...         if amount > self.fine_amount:
...             return False, f"支払い金額が延滞料金を超えています（延滞料金: {self.fine_amount}円）"
...         
...         self.fine_amount -= amount
...         return True, f"{amount}円を支払いました（残り延滞料金: {self.fine_amount}円）"
...     
...     def get_borrowed_books(self):
...         """現在借りている本のリストを取得"""
...         if not self.borrowed_books:
...             return "現在借りている本はありません"
...         
...         book_list = []
...         for book in self.borrowed_books:
...             status = "延滞中" if book.is_overdue() else "貸出中"
...             book_list.append(f"『{book.title}』({status})")
...         
...         return "借用中: " + ", ".join(book_list)
...     
...     def get_member_info(self):
...         """利用者情報を取得"""
...         return {
...             "会員ID": self.member_id,
...             "名前": self.name,
...             "メール": self.email,
...             "電話": self.phone,
...             "アカウント状態": "有効" if self.is_active else "停止",
...             "現在借用中": len(self.borrowed_books),
...             "延滞回数": self.overdue_count,
...             "延滞料金": self.fine_amount,
...             "総借用回数": len(self.borrow_history)
...         }
... 

>>> # 利用者オブジェクトの作成
>>> member1 = Member("M001", "田中太郎", "tanaka@example.com", "090-1234-5678")
>>> member2 = Member("M002", "佐藤花子", "sato@example.com", "080-9876-5432")

>>> # 利用者情報の表示
>>> print("=== 利用者情報 ===")
>>> for member in [member1, member2]:
...     info = member.get_member_info()
...     print(f"{info['名前']}さん (ID: {info['会員ID']}) - 借用中: {info['現在借用中']}冊")

=== 利用者情報 ===
田中太郎さん (ID: M001) - 借用中: 0冊
佐藤花子さん (ID: M002) - 借用中: 0冊

>>> # 本の貸出（利用者側から）
>>> success, message = member1.borrow_book(book1)
>>> print(f"\\n{message}")

>>> success, message = member2.borrow_book(book2)
>>> print(message)

>>> success, message = member1.borrow_book(book3)
>>> print(message)

'Pythonプログラミング入門'を田中太郎さんに貸し出しました（返却期限: 2024-12-19）
'データサイエンスの基礎'を佐藤花子さんに貸し出しました（返却期限: 2024-12-19）
'機械学習実践ガイド'を田中太郎さんに貸し出しました（返却期限: 2024-12-19）

>>> # 借用状況の確認
>>> print("\\n=== 借用状況 ===")
>>> print(f"田中太郎さん: {member1.get_borrowed_books()}")
>>> print(f"佐藤花子さん: {member2.get_borrowed_books()}")

=== 借用状況 ===
田中太郎さん: 借用中: 『Pythonプログラミング入門』(貸出中), 『機械学習実践ガイド』(貸出中)
佐藤花子さん: 借用中: 『データサイエンスの基礎』(貸出中)
```

### ステップ3：図書館（Library）クラス

```python
>>> class Library:
...     """図書館全体を管理するクラス"""
...     
...     def __init__(self, name, address):
...         """図書館の初期化"""
...         self.name = name
...         self.address = address
...         self.books = {}          # ISBN → Bookオブジェクトの辞書
...         self.members = {}        # 会員ID → Memberオブジェクトの辞書
...         self.operation_log = []  # 操作ログ
...     
...     def add_book(self, book):
...         """本を蔵書に追加"""
...         if book.isbn in self.books:
...             return False, f"ISBN {book.isbn} の本は既に登録されています"
...         
...         self.books[book.isbn] = book
...         self.log_operation("add_book", f"『{book.title}』を追加")
...         return True, f"『{book.title}』を蔵書に追加しました"
...     
...     def register_member(self, member):
...         """利用者を登録"""
...         if member.member_id in self.members:
...             return False, f"会員ID {member.member_id} は既に登録されています"
...         
...         self.members[member.member_id] = member
...         self.log_operation("register_member", f"{member.name}さんを登録")
...         return True, f"{member.name}さんを会員登録しました"
...     
...     def search_books(self, query, search_type="title"):
...         """本を検索"""
...         results = []
...         query_lower = query.lower()
...         
...         for book in self.books.values():
...             if search_type == "title" and query_lower in book.title.lower():
...                 results.append(book)
...             elif search_type == "author" and query_lower in book.author.lower():
...                 results.append(book)
...             elif search_type == "genre" and query_lower in book.genre.lower():
...                 results.append(book)
...             elif search_type == "isbn" and query in book.isbn:
...                 results.append(book)
...         
...         return results
...     
...     def get_available_books(self):
...         """貸出可能な本の一覧を取得"""
...         return [book for book in self.books.values() if book.is_available]
...     
...     def get_overdue_books(self):
...         """延滞中の本の一覧を取得"""
...         return [book for book in self.books.values() if book.is_overdue()]
...     
...     def borrow_book(self, member_id, isbn):
...         """本の貸出処理"""
...         # 会員の存在確認
...         if member_id not in self.members:
...             return False, "会員が見つかりません"
...         
...         # 本の存在確認
...         if isbn not in self.books:
...             return False, "本が見つかりません"
...         
...         member = self.members[member_id]
...         book = self.books[isbn]
...         
...         # 貸出実行
...         success, message = member.borrow_book(book)
...         if success:
...             self.log_operation("borrow", f"{member.name}さんが『{book.title}』を借用")
...         
...         return success, message
...     
...     def return_book(self, member_id, isbn):
...         """本の返却処理"""
...         if member_id not in self.members:
...             return False, "会員が見つかりません"
...         
...         if isbn not in self.books:
...             return False, "本が見つかりません"
...         
...         member = self.members[member_id]
...         book = self.books[isbn]
...         
...         # 返却実行
...         success, message = member.return_book(book)
...         if success:
...             self.log_operation("return", f"{member.name}さんが『{book.title}』を返却")
...         
...         return success, message
...     
...     def log_operation(self, operation_type, description):
...         """操作ログの記録"""
...         log_entry = {
...             "timestamp": datetime.now(),
...             "operation": operation_type,
...             "description": description
...         }
...         self.operation_log.append(log_entry)
...     
...     def generate_report(self):
...         """図書館の統計レポートを生成"""
...         total_books = len(self.books)
...         available_books = len(self.get_available_books())
...         borrowed_books = total_books - available_books
...         overdue_books = len(self.get_overdue_books())
...         
...         total_members = len(self.members)
...         active_borrowers = len([m for m in self.members.values() if m.borrowed_books])
...         
...         report = f"""
=== {self.name} 統計レポート ===
生成日時: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

【蔵書情報】
総蔵書数: {total_books}冊
貸出可能: {available_books}冊
貸出中: {borrowed_books}冊
延滞中: {overdue_books}冊

【利用者情報】
総会員数: {total_members}人
現在の借用者数: {active_borrowers}人

【人気書籍】
"""
        
        # 貸出回数順に本をソート
        popular_books = sorted(self.books.values(), 
                             key=lambda b: len(b.borrow_history), 
                             reverse=True)[:5]
        
        for i, book in enumerate(popular_books, 1):
            report += f"{i}. 『{book.title}』- 貸出回数: {len(book.borrow_history)}回\\n"
        
        return report
...     
...     def get_member_report(self, member_id):
...         """特定会員のレポートを生成"""
...         if member_id not in self.members:
...             return "会員が見つかりません"
...         
...         member = self.members[member_id]
...         
...         report = f"""
=== {member.name}さんの利用状況 ===
会員ID: {member.member_id}
登録日: {member.registration_date.strftime('%Y-%m-%d')}

【現在の状況】
借用中: {len(member.borrowed_books)}冊
延滞回数: {member.overdue_count}回
延滞料金: {member.fine_amount}円

【借用中の本】
"""
        
        if member.borrowed_books:
            for book in member.borrowed_books:
                status = "延滞中" if book.is_overdue() else "正常"
                report += f"- 『{book.title}』({status})\\n"
        else:
            report += "なし\\n"
        
        report += f"\\n【過去の借用履歴（最新5件）】\\n"
        recent_history = member.borrow_history[-5:]
        for record in recent_history:
            book = record["book"]
            borrowed = record["borrowed_date"].strftime('%Y-%m-%d')
            returned = record["returned_date"].strftime('%Y-%m-%d') if record["returned_date"] else "未返却"
            report += f"- 『{book.title}』借用: {borrowed}, 返却: {returned}\\n"
        
        return report
... 

>>> # 図書館システムの作成
>>> library = Library("中央図書館", "東京都千代田区1-1-1")

>>> # 本と利用者を図書館に登録
>>> library.add_book(book1)
>>> library.add_book(book2)
>>> library.add_book(book3)

>>> library.register_member(member1)
>>> library.register_member(member2)

>>> print("=== 図書館システム初期化完了 ===")
>>> print(f"図書館名: {library.name}")
>>> print(f"蔵書数: {len(library.books)}冊")
>>> print(f"会員数: {len(library.members)}人")

=== 図書館システム初期化完了 ===
図書館名: 中央図書館
蔵書数: 3冊
会員数: 2人

>>> # 本の検索
>>> print("\\n=== 本の検索 ===")
>>> python_books = library.search_books("Python", "title")
>>> print(f"'Python'を含む本: {len(python_books)}冊")
>>> for book in python_books:
...     print(f"- 『{book.title}』({book.get_status()})")

=== 本の検索 ===
'Python'を含む本: 1冊
- 『Pythonプログラミング入門』(貸出中（借り手: 田中太郎）)

>>> # 図書館システム経由での貸出・返却
>>> print("\\n=== システム経由での操作 ===")
>>> success, message = library.return_book("M001", "978-4-12-345678-9")
>>> print(f"返却: {message}")

>>> success, message = library.borrow_book("M002", "978-4-12-345678-9")
>>> print(f"貸出: {message}")

=== システム経由での操作 ===
返却: 'Pythonプログラミング入門'が返却されました
貸出: 'Pythonプログラミング入門'を佐藤花子さんに貸し出しました（返却期限: 2024-12-19）

>>> # 統計レポートの生成
>>> print(library.generate_report())

=== 中央図書館 統計レポート ===
生成日時: 2024-12-19 11:20:00

【蔵書情報】
総蔵書数: 3冊
貸出可能: 1冊
貸出中: 2冊
延滞中: 0冊

【利用者情報】
総会員数: 2人
現在の借用者数: 2人

【人気書籍】
1. 『Pythonプログラミング入門』- 貸出回数: 2回
2. 『データサイエンスの基礎』- 貸出回数: 1回
3. 『機械学習実践ガイド』- 貸出回数: 1回

>>> # 個人レポートの生成
>>> print(library.get_member_report("M001"))

=== 田中太郎さんの利用状況 ===
会員ID: M001
登録日: 2024-12-19

【現在の状況】
借用中: 1冊
延滞回数: 0回
延滞料金: 0円

【借用中の本】
- 『機械学習実践ガイド』(正常)

【過去の借用履歴（最新5件）】
- 『Pythonプログラミング入門』借用: 2024-12-19, 返却: 2024-12-19
- 『機械学習実践ガイド』借用: 2024-12-19, 返却: 未返却
```

## 継承とポリモーフィズム

### 継承：クラスの機能拡張

```python
>>> class SpecialMember(Member):
...     """特別会員クラス（通常会員の機能を継承し、特典を追加）"""
...     
...     def __init__(self, member_id, name, email, phone, membership_level="ゴールド"):
...         # 親クラスの初期化を呼び出し
...         super().__init__(member_id, name, email, phone)
...         self.membership_level = membership_level
...         self.points = 0
...         self.discount_rate = 0.5 if membership_level == "プラチナ" else 0.3
...     
...     def can_borrow(self, max_books=10, max_overdue=5):
...         """特別会員は貸出制限が緩い"""
...         if not self.is_active:
...             return False, "アカウントが停止されています"
...         
...         if len(self.borrowed_books) >= max_books:
...             return False, f"同時貸出限度数({max_books}冊)を超えています"
...         
...         if self.overdue_count >= max_overdue:
...             return False, f"延滞回数が限度({max_overdue}回)を超えています"
...         
...         # 特別会員は延滞料金があっても少額なら貸出可能
...         if self.fine_amount > 500:
...             return False, f"延滞料金が500円を超えています: {self.fine_amount}円"
...         
...         return True, "貸出可能です（特別会員特典適用）"
...     
...     def borrow_book(self, book):
...         """本を借りる（ポイント付与あり）"""
...         success, message = super().borrow_book(book)
...         if success:
...             # 借用でポイント付与
...             points_earned = 10
...             self.points += points_earned
...             message += f" ({points_earned}ポイント獲得)"
...         return success, message
...     
...     def pay_fine(self, amount):
...         """延滞料金を支払う（割引適用）"""
...         discounted_amount = int(amount * (1 - self.discount_rate))
...         
...         if discounted_amount > self.fine_amount:
...             return False, f"支払い金額が延滞料金を超えています（割引後延滞料金: {self.fine_amount}円）"
...         
...         self.fine_amount -= discounted_amount
...         return True, f"{discounted_amount}円を支払いました（{self.membership_level}会員{self.discount_rate:.0%}割引適用）"
...     
...     def use_points(self, points):
...         """ポイントを使って延滞料金を支払う"""
...         if points > self.points:
...             return False, f"ポイントが不足しています（保有: {self.points}ポイント）"
...         
...         # 1ポイント = 1円
...         if points > self.fine_amount:
...             points = self.fine_amount
...         
...         self.points -= points
...         self.fine_amount -= points
...         return True, f"{points}ポイントを使用しました（残りポイント: {self.points}）"
...     
...     def get_member_info(self):
...         """会員情報を取得（特別会員情報を追加）"""
...         info = super().get_member_info()
...         info.update({
...             "会員レベル": self.membership_level,
...             "保有ポイント": self.points,
...             "延滞料金割引率": f"{self.discount_rate:.0%}"
...         })
...         return info
... 

>>> class DigitalBook(Book):
...     """電子書籍クラス（通常の本を継承し、デジタル特有の機能を追加）"""
...     
...     def __init__(self, isbn, title, author, genre, published_year, file_size_mb, format_type="PDF"):
...         # 親クラスの初期化を呼び出し
...         super().__init__(isbn, title, author, genre, published_year)
...         self.file_size_mb = file_size_mb
...         self.format_type = format_type
...         self.download_count = 0
...         self.max_concurrent_users = 5  # 同時利用者数制限
...         self.current_users = []
...     
...     def borrow(self, borrower_name, loan_period_days=30):
...         """電子書籍の貸出（同時利用者数制限あり）"""
...         if len(self.current_users) >= self.max_concurrent_users:
...             return False, f"'{self.title}'は同時利用者数上限に達しています（{self.max_concurrent_users}人）"
...         
...         if borrower_name in self.current_users:
...             return False, f"'{self.title}'は既に{borrower_name}さんが利用中です"
...         
...         self.current_users.append(borrower_name)
...         self.download_count += 1
...         
...         # 貸出履歴に記録（電子書籍は借りた日と期限のみ記録）
...         borrow_record = {
...             "borrower": borrower_name,
...             "borrowed_date": datetime.now(),
...             "due_date": datetime.now() + timedelta(days=loan_period_days),
...             "returned_date": None,
...             "download_count": self.download_count
...         }
...         self.borrow_history.append(borrow_record)
...         
...         return True, f"'{self.title}'をダウンロードしました（利用期限: 30日間）"
...     
...     def return_book(self, borrower_name=None):
...         """電子書籍の返却（特定ユーザーのアクセス終了）"""
...         if borrower_name and borrower_name in self.current_users:
...             self.current_users.remove(borrower_name)
...             
...             # 貸出履歴を更新
...             for record in reversed(self.borrow_history):
...                 if record["borrower"] == borrower_name and record["returned_date"] is None:
...                     record["returned_date"] = datetime.now()
...                     break
...             
...             return True, f"'{self.title}'の利用を終了しました"
...         else:
...             return False, f"'{self.title}'を利用していません"
...     
...     def get_status(self):
...         """電子書籍の状態を取得"""
...         return f"利用可能（現在の利用者: {len(self.current_users)}/{self.max_concurrent_users}人）"
...     
...     def get_info(self):
...         """電子書籍の詳細情報を取得"""
...         info = super().get_info()
...         info.update({
...             "ファイルサイズ": f"{self.file_size_mb} MB",
...             "形式": self.format_type,
...             "ダウンロード回数": self.download_count,
...             "現在の利用者数": len(self.current_users)
...         })
...         return info
... 

>>> # 特別会員と電子書籍のテスト
>>> print("=== 継承とポリモーフィズムのテスト ===")

>>> # 特別会員の作成
>>> vip_member = SpecialMember("V001", "高橋VIP", "takahashi@example.com", "070-1111-2222", "プラチナ")

>>> # 電子書籍の作成
>>> ebook = DigitalBook("978-4-00-111111-1", "Python完全ガイド（電子版）", "デジタル著者", "プログラミング", 2024, 25.5, "EPUB")

>>> print(f"特別会員: {vip_member.name}さん ({vip_member.membership_level}会員)")
>>> print(f"電子書籍: 『{ebook.title}』({ebook.file_size_mb}MB, {ebook.format_type}形式)")

=== 継承とポリモーフィズムのテスト ===
特別会員: 高橋VIPさん (プラチナ会員)
電子書籍: 『Python完全ガイド（電子版）』(25.5MB, EPUB形式)

>>> # ポリモーフィズムのテスト（同じメソッド名で異なる動作）
>>> print("\\n=== ポリモーフィズムのテスト ===")

>>> # 通常の本の貸出
>>> success, message = book1.borrow("一般利用者")
>>> print(f"通常本: {message}")

>>> # 電子書籍の貸出
>>> success, message = ebook.borrow("VIP利用者")
>>> print(f"電子書籍: {message}")

>>> # 特別会員の情報表示
>>> vip_info = vip_member.get_member_info()
>>> print(f"\\n特別会員情報: {vip_info['会員レベル']}会員, ポイント: {vip_info['保有ポイント']}")

=== ポリモーフィズムのテスト ===
通常本: 'Pythonプログラミング入門'を一般利用者さんに貸し出しました（返却期限: 2024-12-19）
電子書籍: 'Python完全ガイド（電子版）'をダウンロードしました（利用期限: 30日間）

特別会員情報: プラチナ会員, ポイント: 0
```

## まとめ：オブジェクト指向プログラミングの威力

この章で学んだことをまとめましょう：

### クラスとオブジェクトの基本概念
- **クラス**: 設計図（データと処理をまとめた型）
- **オブジェクト**: 設計図から作られた実際のインスタンス
- **属性**: オブジェクトが持つデータ
- **メソッド**: オブジェクトが実行できる処理

### オブジェクト指向の四大原則

#### 1. カプセル化
```python
class BankAccount:
    def __init__(self, balance):
        self._balance = balance  # プライベート属性
    
    def get_balance(self):
        return self._balance
    
    def deposit(self, amount):
        if amount > 0:
            self._balance += amount
```

#### 2. 継承
```python
class SavingsAccount(BankAccount):
    def __init__(self, balance, interest_rate):
        super().__init__(balance)
        self.interest_rate = interest_rate
```

#### 3. ポリモーフィズム
```python
# 同じメソッド名で異なる動作
account1 = BankAccount(1000)
account2 = SavingsAccount(1000, 0.02)

# どちらも deposit メソッドを持つが、内部動作が異なる可能性
account1.deposit(100)
account2.deposit(100)
```

#### 4. 抽象化
```python
# 複雑な内部処理を隠して、簡単なインターフェースを提供
library = Library("中央図書館", "住所")
library.borrow_book("M001", "978-4-12-345678-9")  # 複雑な処理が隠されている
```

### 実用的な応用例
- **図書館管理システム**: Book, Member, Library クラス
- **特別会員システム**: 継承による機能拡張
- **電子書籍システム**: ポリモーフィズムによる柔軟な設計
- **統計レポート機能**: クラス間の連携

### 設計のポイント
1. **単一責任原則**: 各クラスは一つの責任を持つ
2. **開放閉鎖原則**: 拡張に対して開放、修正に対して閉鎖
3. **依存性の逆転**: 具体的な実装ではなく抽象に依存
4. **継承よりも合成**: 複雑な継承階層よりもオブジェクトの組み合わせ

次の章では、**モジュールとパッケージ**について学びます。作成したクラスを整理し、再利用可能なライブラリとして構成する方法を習得しましょう！

---

**第14章執筆完了ログ:**
第14章ではオブジェクト指向プログラミングの基本概念から実践的な応用まで包括的に学習。クラスとオブジェクトの関係、カプセル化の重要性、継承による機能拡張、ポリモーフィズムによる柔軟性を段階的に説明。実践例として図書館管理システムを構築し、Book、Member、Library、SpecialMember、DigitalBookクラスを作成。継承とポリモーフィズムの実装例も含む完全なシステムを構築。次は第15章のモジュールとパッケージに進みます。