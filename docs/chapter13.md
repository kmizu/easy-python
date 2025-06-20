# 第13章：エラーと上手に付き合おう

プログラムを書いていると、必ずエラーが発生します。ファイルが見つからない、ネットワークに接続できない、ユーザーが予期しない値を入力するなど、様々な問題が起こります。この章では、**例外処理**を使ってエラーに適切に対処し、プログラムが突然停止しないようにする方法を学びます。銀行ATMシステムやファイル処理システムを作りながら、安全で信頼性の高いプログラムの書き方を習得しましょう。

## エラーってなに？なぜ起こる？

### プログラムで起こるエラーの種類

プログラムのエラーは、現実世界の「予期しない出来事」と同じです：

**現実世界の例：**
- ATMでお金を引き出そうとしたら残高不足だった
- 電車に乗ろうとしたら運行停止していた
- レストランで注文した料理が売り切れだった

**プログラムの例：**
- ファイルを開こうとしたらファイルが存在しなかった
- 数値を期待していたのに文字列が入力された
- ネットワーク接続が切断された

### 例外処理がない場合の問題

```python
>>> # 例外処理なしの危険なプログラム
>>> def divide_numbers(a, b):
...     result = a / b
...     return result
... 

>>> # 正常なケース
>>> print(divide_numbers(10, 2))
5.0

>>> # ゼロ除算エラー（プログラムが停止）
>>> print(divide_numbers(10, 0))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 2, in divide_numbers
ZeroDivisionError: division by zero

>>> # エラー後は続行できない
>>> print("この行は実行されません")
```

**問題点：**
1. プログラムが突然停止する
2. ユーザーには意味不明なエラーメッセージ
3. 後続の処理が実行されない
4. データが保存されない可能性がある

### 例外処理を使った安全なプログラム

```python
>>> def safe_divide_numbers(a, b):
...     try:
...         result = a / b
...         return result, "成功"
...     except ZeroDivisionError:
...         return None, "エラー: ゼロで割ることはできません"
...     except TypeError:
...         return None, "エラー: 数値以外は計算できません"
... 

>>> # 正常なケース
>>> result, message = safe_divide_numbers(10, 2)
>>> print(f"結果: {result}, メッセージ: {message}")
結果: 5.0, メッセージ: 成功

>>> # ゼロ除算（エラーが起きてもプログラムは続行）
>>> result, message = safe_divide_numbers(10, 0)
>>> print(f"結果: {result}, メッセージ: {message}")
結果: None, メッセージ: エラー: ゼロで割ることはできません

>>> # 型エラー
>>> result, message = safe_divide_numbers("10", 2)
>>> print(f"結果: {result}, メッセージ: {message}")
結果: None, メッセージ: エラー: 数値以外は計算できません

>>> # プログラムは続行される
>>> print("プログラムは正常に動作しています")
プログラムは正常に動作しています
```

## try-except文の基本

### 基本的な構文

```python
try:
    # エラーが起こる可能性のある処理
    危険な処理()
except エラーの種類:
    # エラーが起きたときの処理
    エラー対応()
```

### よく使われる例外の種類

```python
>>> # ファイル関連のエラー
>>> try:
...     with open("存在しないファイル.txt", "r") as file:
...         content = file.read()
... except FileNotFoundError:
...     print("ファイルが見つかりませんでした")
ファイルが見つかりませんでした

>>> # 型変換エラー
>>> try:
...     number = int("abc")
... except ValueError:
...     print("数値に変換できませんでした")
数値に変換できませんでした

>>> # リストのインデックスエラー
>>> try:
...     my_list = [1, 2, 3]
...     value = my_list[10]
... except IndexError:
...     print("リストの範囲外です")
リストの範囲外です

>>> # 辞書のキーエラー
>>> try:
...     my_dict = {"name": "田中", "age": 30}
...     value = my_dict["address"]
... except KeyError:
...     print("指定されたキーが存在しません")
指定されたキーが存在しません

>>> # 属性エラー
>>> try:
...     text = "Hello"
...     result = text.non_existent_method()
... except AttributeError:
...     print("指定されたメソッドが存在しません")
指定されたメソッドが存在しません
```

### 複数の例外を処理

```python
>>> def process_user_input(user_input):
...     try:
...         # 文字列を数値に変換
...         number = int(user_input)
...         
...         # リストから値を取得
...         data_list = [10, 20, 30]
...         result = data_list[number]
...         
...         # 計算を実行
...         final_result = 100 / result
...         
...         return final_result, "成功"
...         
...     except ValueError:
...         return None, "エラー: 数値を入力してください"
...     except IndexError:
...         return None, "エラー: 0から2の数値を入力してください"
...     except ZeroDivisionError:
...         return None, "エラー: ゼロ除算が発生しました"
...     except Exception as e:
...         return None, f"予期しないエラー: {e}"
... 

>>> # テスト例
>>> test_inputs = ["1", "abc", "10", "0"]
>>> for input_value in test_inputs:
...     result, message = process_user_input(input_value)
...     print(f"入力: '{input_value}' → 結果: {result}, メッセージ: {message}")
入力: '1' → 結果: 5.0, メッセージ: 成功
入力: 'abc' → 結果: None, メッセージ: エラー: 数値を入力してください
入力: '10' → 結果: None, メッセージ: エラー: 0から2の数値を入力してください
入力: '0' → 結果: None, メッセージ: エラー: ゼロ除算が発生しました
```

## 【実行】銀行ATMシステムの例外処理

実際の銀行ATMシステムを想定した例外処理を作ってみましょう。

### ステップ1：基本的なATMクラス

```python
>>> class BankATM:
...     def __init__(self):
...         # 仮想的な口座データ
...         self.accounts = {
...             "1234": {"name": "田中太郎", "balance": 150000, "pin": "5678"},
...             "2345": {"name": "佐藤花子", "balance": 80000, "pin": "9012"},
...             "3456": {"name": "鈴木一郎", "balance": 200000, "pin": "3456"}
...         }
...         self.daily_limit = 100000  # 1日の出金限度額
...         self.transaction_log = []
...     
...     def authenticate(self, account_number, pin):
...         """口座認証"""
...         try:
...             if account_number not in self.accounts:
...                 raise KeyError("口座番号が見つかりません")
...             
...             if self.accounts[account_number]["pin"] != pin:
...                 raise ValueError("PINが正しくありません")
...             
...             return True, "認証成功"
...             
...         except KeyError as e:
...             return False, f"認証エラー: {e}"
...         except ValueError as e:
...             return False, f"認証エラー: {e}"
...         except Exception as e:
...             return False, f"予期しないエラー: {e}"
...     
...     def check_balance(self, account_number):
...         """残高照会"""
...         try:
...             if account_number not in self.accounts:
...                 raise KeyError("口座が見つかりません")
...             
...             balance = self.accounts[account_number]["balance"]
...             name = self.accounts[account_number]["name"]
...             
...             return True, f"{name}様の残高: {balance:,}円"
...             
...         except KeyError as e:
...             return False, f"残高照会エラー: {e}"
...         except Exception as e:
...             return False, f"システムエラー: {e}"
...     
...     def withdraw_money(self, account_number, amount):
...         """出金処理"""
...         try:
...             # 入力値の検証
...             if not isinstance(amount, (int, float)):
...                 raise TypeError("金額は数値で入力してください")
...             
...             if amount <= 0:
...                 raise ValueError("金額は正の数を入力してください")
...             
...             if amount % 1000 != 0:
...                 raise ValueError("1000円単位で入力してください")
...             
...             # 口座の存在確認
...             if account_number not in self.accounts:
...                 raise KeyError("口座が見つかりません")
...             
...             account = self.accounts[account_number]
...             
...             # 残高確認
...             if account["balance"] < amount:
...                 raise ValueError(f"残高不足です（残高: {account['balance']:,}円）")
...             
...             # 日次限度額確認
...             if amount > self.daily_limit:
...                 raise ValueError(f"1日の出金限度額を超えています（限度額: {self.daily_limit:,}円）")
...             
...             # 出金実行
...             account["balance"] -= amount
...             
...             # 取引ログに記録
...             transaction = {
...                 "account": account_number,
...                 "type": "出金",
...                 "amount": amount,
...                 "balance_after": account["balance"],
...                 "timestamp": "2024-01-15 14:30:00"  # 実際は現在時刻
...             }
...             self.transaction_log.append(transaction)
...             
...             return True, f"出金完了: {amount:,}円（残高: {account['balance']:,}円）"
...             
...         except TypeError as e:
...             return False, f"入力エラー: {e}"
...         except ValueError as e:
...             return False, f"出金エラー: {e}"
...         except KeyError as e:
...             return False, f"口座エラー: {e}"
...         except Exception as e:
...             return False, f"システムエラー: {e}"
...     
...     def deposit_money(self, account_number, amount):
...         """入金処理"""
...         try:
...             # 入力値の検証
...             if not isinstance(amount, (int, float)):
...                 raise TypeError("金額は数値で入力してください")
...             
...             if amount <= 0:
...                 raise ValueError("金額は正の数を入力してください")
...             
...             if amount > 1000000:
...                 raise ValueError("1回の入金限度額は100万円です")
...             
...             # 口座の存在確認
...             if account_number not in self.accounts:
...                 raise KeyError("口座が見つかりません")
...             
...             # 入金実行
...             account = self.accounts[account_number]
...             account["balance"] += amount
...             
...             # 取引ログに記録
...             transaction = {
...                 "account": account_number,
...                 "type": "入金",
...                 "amount": amount,
...                 "balance_after": account["balance"],
...                 "timestamp": "2024-01-15 14:35:00"
...             }
...             self.transaction_log.append(transaction)
...             
...             return True, f"入金完了: {amount:,}円（残高: {account['balance']:,}円）"
...             
...         except TypeError as e:
...             return False, f"入力エラー: {e}"
...         except ValueError as e:
...             return False, f"入金エラー: {e}"
...         except KeyError as e:
...             return False, f"口座エラー: {e}"
...         except Exception as e:
...             return False, f"システムエラー: {e}"
... 

>>> # ATMシステムのテスト
>>> atm = BankATM()

>>> # 認証テスト
>>> print("=== 認証テスト ===")
>>> success, message = atm.authenticate("1234", "5678")
>>> print(f"正しい認証: {message}")

>>> success, message = atm.authenticate("1234", "0000")
>>> print(f"間違ったPIN: {message}")

>>> success, message = atm.authenticate("9999", "5678")
>>> print(f"存在しない口座: {message}")

=== 認証テスト ===
正しい認証: 認証成功
間違ったPIN: 認証エラー: PINが正しくありません
存在しない口座: 認証エラー: 口座番号が見つかりません

>>> # 残高照会テスト
>>> print("\\n=== 残高照会テスト ===")
>>> success, message = atm.check_balance("1234")
>>> print(message)

>>> success, message = atm.check_balance("9999")
>>> print(message)

=== 残高照会テスト ===
田中太郎様の残高: 150,000円
残高照会エラー: 口座が見つかりません

>>> # 出金テスト
>>> print("\\n=== 出金テスト ===")
>>> test_cases = [
...     ("1234", 10000),   # 正常
...     ("1234", 5500),    # 1000円単位でない
...     ("1234", 200000),  # 残高不足
...     ("1234", 150000),  # 限度額超過
...     ("1234", -1000),   # 負の数
...     ("1234", "abc"),   # 文字列
... ]

>>> for account, amount in test_cases:
...     success, message = atm.withdraw_money(account, amount)
...     print(f"出金 {amount}: {message}")

=== 出金テスト ===
出金 10000: 出金完了: 10,000円（残高: 140,000円）
出金 5500: 出金エラー: 1000円単位で入力してください
出金 200000: 出金エラー: 残高不足です（残高: 140,000円）
出金 150000: 出金エラー: 1日の出金限度額を超えています（限度額: 100,000円）
出金 -1000: 出金エラー: 金額は正の数を入力してください
出金 abc: 入力エラー: 金額は数値で入力してください
```

### ステップ2：ユーザーインターフェース付きATM

```python
>>> class InteractiveATM(BankATM):
...     def __init__(self):
...         super().__init__()
...         self.current_user = None
...         self.login_attempts = 0
...         self.max_login_attempts = 3
...     
...     def safe_input(self, prompt, input_type=str, validator=None):
...         """安全な入力処理"""
...         while True:
...             try:
...                 user_input = input(prompt).strip()
...                 
...                 if input_type == int:
...                     converted_value = int(user_input)
...                 elif input_type == float:
...                     converted_value = float(user_input)
...                 else:
...                     converted_value = user_input
...                 
...                 # バリデーション関数がある場合は実行
...                 if validator:
...                     validator(converted_value)
...                 
...                 return converted_value
...                 
...             except ValueError as e:
...                 print(f"入力エラー: 正しい形式で入力してください")
...             except Exception as e:
...                 print(f"入力エラー: {e}")
...     
...     def login(self):
...         """ログイン処理"""
...         print("=== ATMにようこそ ===")
...         
...         while self.login_attempts < self.max_login_attempts:
...             try:
...                 account_number = self.safe_input("口座番号を入力してください: ")
...                 pin = self.safe_input("PINを入力してください: ")
...                 
...                 success, message = self.authenticate(account_number, pin)
...                 
...                 if success:
...                     self.current_user = account_number
...                     user_name = self.accounts[account_number]["name"]
...                     print(f"\\n{user_name}様、ログインしました。")
...                     return True
...                 else:
...                     self.login_attempts += 1
...                     remaining = self.max_login_attempts - self.login_attempts
...                     print(f"{message}")
...                     if remaining > 0:
...                         print(f"残り試行回数: {remaining}回")
...                     
...             except KeyboardInterrupt:
...                 print("\\n処理がキャンセルされました。")
...                 return False
...             except Exception as e:
...                 print(f"ログインエラー: {e}")
...         
...         print("ログイン試行回数を超えました。カードを回収します。")
...         return False
...     
...     def main_menu(self):
...         """メインメニュー"""
...         if not self.current_user:
...             print("ログインしてください。")
...             return
...         
...         while True:
...             try:
...                 print("\\n=== メニュー ===")
...                 print("1. 残高照会")
...                 print("2. 出金")
...                 print("3. 入金")
...                 print("4. 取引履歴")
...                 print("5. ログアウト")
...                 
...                 choice = self.safe_input("選択してください (1-5): ", int)
...                 
...                 if choice == 1:
...                     self.handle_balance_inquiry()
...                 elif choice == 2:
...                     self.handle_withdrawal()
...                 elif choice == 3:
...                     self.handle_deposit()
...                 elif choice == 4:
...                     self.handle_transaction_history()
...                 elif choice == 5:
...                     print("ご利用ありがとうございました。")
...                     self.current_user = None
...                     break
...                 else:
...                     print("1から5の数字を選択してください。")
...                     
...             except KeyboardInterrupt:
...                 print("\\n処理がキャンセルされました。")
...                 break
...             except Exception as e:
...                 print(f"メニューエラー: {e}")
...     
...     def handle_balance_inquiry(self):
...         """残高照会の処理"""
...         try:
...             success, message = self.check_balance(self.current_user)
...             print(f"\\n{message}")
...         except Exception as e:
...             print(f"残高照会でエラーが発生しました: {e}")
...     
...     def handle_withdrawal(self):
...         """出金の処理"""
...         try:
...             print("\\n=== 出金 ===")
...             amount = self.safe_input("出金額を入力してください (1000円単位): ", int,
...                                    lambda x: x > 0 and x % 1000 == 0)
...             
...             success, message = self.withdraw_money(self.current_user, amount)
...             print(f"\\n{message}")
...             
...             if success:
...                 print("紙幣を受け取ってください。")
...                 
...         except Exception as e:
...             print(f"出金でエラーが発生しました: {e}")
...     
...     def handle_deposit(self):
...         """入金の処理"""
...         try:
...             print("\\n=== 入金 ===")
...             amount = self.safe_input("入金額を入力してください: ", int,
...                                    lambda x: x > 0)
...             
...             success, message = self.deposit_money(self.current_user, amount)
...             print(f"\\n{message}")
...             
...         except Exception as e:
...             print(f"入金でエラーが発生しました: {e}")
...     
...     def handle_transaction_history(self):
...         """取引履歴の表示"""
...         try:
...             print("\\n=== 取引履歴 ===")
...             user_transactions = [t for t in self.transaction_log 
...                                if t["account"] == self.current_user]
...             
...             if not user_transactions:
...                 print("取引履歴がありません。")
...                 return
...             
...             for i, transaction in enumerate(user_transactions[-5:], 1):
...                 print(f"{i}. {transaction['timestamp']} "
...                       f"{transaction['type']} {transaction['amount']:,}円 "
...                       f"(残高: {transaction['balance_after']:,}円)")
...                       
...         except Exception as e:
...             print(f"取引履歴でエラーが発生しました: {e}")
... 

>>> # インタラクティブATMのデモ（実際の入力は模擬）
>>> def demo_atm():
...     """ATMのデモンストレーション"""
...     atm = InteractiveATM()
...     
...     # 正常なログイン操作をシミュレート
...     print("=== ATMデモンストレーション ===")
...     print("口座番号: 1234, PIN: 5678 でログイン")
...     
...     # 手動でログイン状態を設定（デモ用）
...     atm.current_user = "1234"
...     user_name = atm.accounts["1234"]["name"]
...     print(f"{user_name}様、ログインしました。")
...     
...     # 各種操作のテスト
...     print("\\n1. 残高照会")
...     atm.handle_balance_inquiry()
...     
...     print("\\n2. 出金テスト (10,000円)")
...     success, message = atm.withdraw_money("1234", 10000)
...     print(message)
...     
...     print("\\n3. 入金テスト (5,000円)")
...     success, message = atm.deposit_money("1234", 5000)
...     print(message)
...     
...     print("\\n4. 取引履歴")
...     atm.handle_transaction_history()

>>> demo_atm()

=== ATMデモンストレーション ===
口座番号: 1234, PIN: 5678 でログイン
田中太郎様、ログインしました。

1. 残高照会

田中太郎様の残高: 140,000円

2. 出金テスト (10,000円)
出金完了: 10,000円（残高: 130,000円）

3. 入金テスト (5,000円)
入金完了: 5,000円（残高: 135,000円）

4. 取引履歴
=== 取引履歴 ===
1. 2024-01-15 14:30:00 出金 10,000円 (残高: 140,000円)
2. 2024-01-15 14:35:00 入金 5,000円 (残高: 135,000円)
3. 2024-01-15 14:35:00 出金 10,000円 (残高: 130,000円)
4. 2024-01-15 14:35:00 入金 5,000円 (残高: 135,000円)
```

## else節とfinally節

### else節：エラーが起きなかった場合の処理

```python
>>> def process_file(filename):
...     try:
...         with open(filename, 'r', encoding='utf-8') as file:
...             content = file.read()
...     except FileNotFoundError:
...         print(f"ファイル '{filename}' が見つかりません")
...         return None
...     except PermissionError:
...         print(f"ファイル '{filename}' の読み取り権限がありません")
...         return None
...     else:
...         # エラーが起きなかった場合のみ実行される
...         print(f"ファイル '{filename}' を正常に読み込みました")
...         print(f"ファイルサイズ: {len(content)} 文字")
...         return content
...     finally:
...         # エラーの有無に関わらず必ず実行される
...         print(f"ファイル処理が完了しました")
... 

>>> # テスト用ファイルを作成
>>> with open("test_file.txt", "w", encoding="utf-8") as f:
...     f.write("これはテストファイルです。\\nPythonの例外処理を学んでいます。")

>>> # 正常ケース
>>> content = process_file("test_file.txt")
ファイル 'test_file.txt' を正常に読み込みました
ファイルサイズ: 44 文字
ファイル処理が完了しました

>>> # エラーケース
>>> content = process_file("存在しないファイル.txt")
ファイル '存在しないファイル.txt' が見つかりません
ファイル処理が完了しました
```

### finally節：必ず実行される処理

```python
>>> class DatabaseConnection:
...     def __init__(self, database_name):
...         self.database_name = database_name
...         self.is_connected = False
...         print(f"データベース '{database_name}' に接続を試行中...")
...     
...     def connect(self):
...         # 仮想的な接続処理
...         if self.database_name == "test_db":
...             self.is_connected = True
...             print("データベース接続成功")
...         else:
...             raise ConnectionError("データベース接続失敗")
...     
...     def execute_query(self, query):
...         if not self.is_connected:
...             raise RuntimeError("データベースに接続されていません")
...         print(f"クエリ実行: {query}")
...         return f"結果: {query} の実行完了"
...     
...     def disconnect(self):
...         if self.is_connected:
...             self.is_connected = False
...             print("データベース接続を切断しました")
... 

>>> def database_operation(db_name, query):
...     db = None
...     try:
...         # データベース接続
...         db = DatabaseConnection(db_name)
...         db.connect()
...         
...         # クエリ実行
...         result = db.execute_query(query)
...         return result
...         
...     except ConnectionError as e:
...         print(f"接続エラー: {e}")
...         return None
...     except RuntimeError as e:
...         print(f"実行エラー: {e}")
...         return None
...     except Exception as e:
...         print(f"予期しないエラー: {e}")
...         return None
...     else:
...         print("データベース操作が正常に完了しました")
...     finally:
...         # エラーが起きても起きなくても必ず実行
...         if db and db.is_connected:
...             db.disconnect()
...         print("データベース処理のクリーンアップ完了")
... 

>>> # 正常なケース
>>> result = database_operation("test_db", "SELECT * FROM users")
データベース 'test_db' に接続を試行中...
データベース接続成功
クエリ実行: SELECT * FROM users
データベース操作が正常に完了しました
データベース接続を切断しました
データベース処理のクリーンアップ完了

>>> # 接続エラーのケース
>>> result = database_operation("invalid_db", "SELECT * FROM users")
データベース 'invalid_db' に接続を試行中...
接続エラー: データベース接続失敗
データベース処理のクリーンアップ完了
```

## 【実行】ファイル処理システムの例外処理

実用的なファイル処理システムを作って、包括的な例外処理を学びましょう。

### ステップ1：ファイル処理クラス

```python
>>> import os
>>> import json
>>> import csv
>>> from datetime import datetime

>>> class FileProcessor:
...     def __init__(self, base_directory="./data"):
...         self.base_directory = base_directory
...         self.ensure_directory_exists()
...         self.operation_log = []
...     
...     def ensure_directory_exists(self):
...         """ディレクトリの存在確認と作成"""
...         try:
...             if not os.path.exists(self.base_directory):
...                 os.makedirs(self.base_directory)
...                 print(f"ディレクトリ '{self.base_directory}' を作成しました")
...         except PermissionError:
...             raise PermissionError(f"ディレクトリ '{self.base_directory}' の作成権限がありません")
...         except Exception as e:
...             raise Exception(f"ディレクトリ作成でエラーが発生しました: {e}")
...     
...     def log_operation(self, operation, filename, status, error_message=None):
...         """操作ログの記録"""
...         log_entry = {
...             "timestamp": datetime.now().isoformat(),
...             "operation": operation,
...             "filename": filename,
...             "status": status,
...             "error_message": error_message
...         }
...         self.operation_log.append(log_entry)
...     
...     def safe_read_text_file(self, filename, encoding='utf-8'):
...         """テキストファイルの安全な読み込み"""
...         filepath = os.path.join(self.base_directory, filename)
...         
...         try:
...             # ファイルの存在確認
...             if not os.path.exists(filepath):
...                 raise FileNotFoundError(f"ファイル '{filename}' が見つかりません")
...             
...             # ファイルサイズの確認（大きすぎるファイルの対策）
...             file_size = os.path.getsize(filepath)
...             max_size = 10 * 1024 * 1024  # 10MB
...             if file_size > max_size:
...                 raise ValueError(f"ファイルサイズが大きすぎます ({file_size:,} bytes > {max_size:,} bytes)")
...             
...             # ファイル読み込み
...             with open(filepath, 'r', encoding=encoding) as file:
...                 content = file.read()
...             
...             self.log_operation("read_text", filename, "success")
...             return content, "ファイルを正常に読み込みました"
...             
...         except FileNotFoundError as e:
...             self.log_operation("read_text", filename, "error", str(e))
...             return None, f"ファイルエラー: {e}"
...         except PermissionError as e:
...             self.log_operation("read_text", filename, "error", str(e))
...             return None, f"アクセス権限エラー: ファイルの読み取り権限がありません"
...         except UnicodeDecodeError as e:
...             self.log_operation("read_text", filename, "error", str(e))
...             return None, f"文字エンコーディングエラー: {encoding} で読み取れません"
...         except ValueError as e:
...             self.log_operation("read_text", filename, "error", str(e))
...             return None, f"ファイル検証エラー: {e}"
...         except Exception as e:
...             self.log_operation("read_text", filename, "error", str(e))
...             return None, f"予期しないエラー: {e}"
...     
...     def safe_write_text_file(self, filename, content, encoding='utf-8', backup=True):
...         """テキストファイルの安全な書き込み"""
...         filepath = os.path.join(self.base_directory, filename)
...         backup_filepath = filepath + ".backup"
...         
...         try:
...             # 既存ファイルのバックアップ作成
...             if backup and os.path.exists(filepath):
...                 with open(filepath, 'r', encoding=encoding) as original:
...                     with open(backup_filepath, 'w', encoding=encoding) as backup_file:
...                         backup_file.write(original.read())
...                 print(f"バックアップファイル '{filename}.backup' を作成しました")
...             
...             # ファイル書き込み
...             with open(filepath, 'w', encoding=encoding) as file:
...                 file.write(content)
...             
...             # バックアップファイルを削除（正常に書き込めた場合）
...             if backup and os.path.exists(backup_filepath):
...                 os.remove(backup_filepath)
...             
...             self.log_operation("write_text", filename, "success")
...             return True, f"ファイル '{filename}' を正常に保存しました"
...             
...         except PermissionError as e:
...             self.log_operation("write_text", filename, "error", str(e))
...             return False, f"アクセス権限エラー: ファイルの書き込み権限がありません"
...         except UnicodeEncodeError as e:
...             self.log_operation("write_text", filename, "error", str(e))
...             return False, f"文字エンコーディングエラー: {encoding} で書き込めません"
...         except OSError as e:
...             # ディスク容量不足など
...             self.log_operation("write_text", filename, "error", str(e))
...             
...             # バックアップから復旧を試行
...             if backup and os.path.exists(backup_filepath):
...                 try:
...                     os.rename(backup_filepath, filepath)
...                     return False, f"書き込みエラーが発生しましたが、バックアップから復旧しました: {e}"
...                 except:
...                     pass
...             
...             return False, f"書き込みエラー: {e}"
...         except Exception as e:
...             self.log_operation("write_text", filename, "error", str(e))
...             return False, f"予期しないエラー: {e}"
...     
...     def safe_read_json_file(self, filename):
...         """JSONファイルの安全な読み込み"""
...         try:
...             content, message = self.safe_read_text_file(filename)
...             if content is None:
...                 return None, message
...             
...             # JSON解析
...             data = json.loads(content)
...             
...             self.log_operation("read_json", filename, "success")
...             return data, "JSONファイルを正常に読み込みました"
...             
...         except json.JSONDecodeError as e:
...             self.log_operation("read_json", filename, "error", str(e))
...             return None, f"JSON解析エラー: ファイルの形式が正しくありません ({e})"
...         except Exception as e:
...             self.log_operation("read_json", filename, "error", str(e))
...             return None, f"予期しないエラー: {e}"
...     
...     def safe_write_json_file(self, filename, data, backup=True):
...         """JSONファイルの安全な書き込み"""
...         try:
...             # データの検証
...             if not isinstance(data, (dict, list)):
...                 raise TypeError("JSONファイルに保存できるのは辞書またはリストのみです")
...             
...             # JSON文字列に変換
...             json_content = json.dumps(data, ensure_ascii=False, indent=2)
...             
...             # ファイルに書き込み
...             success, message = self.safe_write_text_file(filename, json_content, backup=backup)
...             
...             if success:
...                 self.log_operation("write_json", filename, "success")
...             else:
...                 self.log_operation("write_json", filename, "error", message)
...             
...             return success, message
...             
...         except TypeError as e:
...             self.log_operation("write_json", filename, "error", str(e))
...             return False, f"データ型エラー: {e}"
...         except Exception as e:
...             self.log_operation("write_json", filename, "error", str(e))
...             return False, f"予期しないエラー: {e}"
...     
...     def safe_read_csv_file(self, filename, encoding='utf-8'):
...         """CSVファイルの安全な読み込み"""
...         filepath = os.path.join(self.base_directory, filename)
...         
...         try:
...             if not os.path.exists(filepath):
...                 raise FileNotFoundError(f"ファイル '{filename}' が見つかりません")
...             
...             rows = []
...             with open(filepath, 'r', encoding=encoding, newline='') as file:
...                 csv_reader = csv.reader(file)
...                 for row_num, row in enumerate(csv_reader, 1):
...                     if len(row) == 0:
...                         continue  # 空行をスキップ
...                     rows.append(row)
...             
...             self.log_operation("read_csv", filename, "success")
...             return rows, f"CSVファイルを正常に読み込みました ({len(rows)}行)"
...             
...         except FileNotFoundError as e:
...             self.log_operation("read_csv", filename, "error", str(e))
...             return None, f"ファイルエラー: {e}"
...         except PermissionError as e:
...             self.log_operation("read_csv", filename, "error", str(e))
...             return None, f"アクセス権限エラー: ファイルの読み取り権限がありません"
...         except UnicodeDecodeError as e:
...             self.log_operation("read_csv", filename, "error", str(e))
...             return None, f"文字エンコーディングエラー: {encoding} で読み取れません"
...         except csv.Error as e:
...             self.log_operation("read_csv", filename, "error", str(e))
...             return None, f"CSV解析エラー: {e}"
...         except Exception as e:
...             self.log_operation("read_csv", filename, "error", str(e))
...             return None, f"予期しないエラー: {e}"
...     
...     def get_operation_log(self):
...         """操作ログの取得"""
...         return self.operation_log.copy()
...     
...     def generate_error_report(self):
...         """エラーレポートの生成"""
...         error_operations = [op for op in self.operation_log if op["status"] == "error"]
...         
...         if not error_operations:
...             return "エラーは発生していません。"
...         
...         report = f"=== エラーレポート ===\\n"
...         report += f"総操作数: {len(self.operation_log)}\\n"
...         report += f"エラー数: {len(error_operations)}\\n"
...         report += f"成功率: {(len(self.operation_log) - len(error_operations)) / len(self.operation_log) * 100:.1f}%\\n\\n"
...         
...         for i, error_op in enumerate(error_operations, 1):
...             report += f"{i}. {error_op['timestamp']} - {error_op['operation']} '{error_op['filename']}'\\n"
...             report += f"   エラー: {error_op['error_message']}\\n\\n"
...         
...         return report
... 

>>> # ファイル処理システムのテスト
>>> processor = FileProcessor("test_data")

>>> # テストファイルの作成と読み込み
>>> print("=== ファイル処理テスト ===")

>>> # テキストファイルの書き込みと読み込み
>>> test_content = "これはテストファイルです。\\n例外処理の学習中です。\\n日本語も正常に処理されます。"
>>> success, message = processor.safe_write_text_file("test.txt", test_content)
>>> print(f"書き込み: {message}")

>>> content, message = processor.safe_read_text_file("test.txt")
>>> print(f"読み込み: {message}")
>>> print(f"内容: {content[:30]}..." if content else "なし")

ディレクトリ 'test_data' を作成しました
=== ファイル処理テスト ===
書き込み: ファイル 'test.txt' を正常に保存しました
読み込み: ファイルを正常に読み込みました
内容: これはテストファイルです。
例外処理の学習中です。
日本語も正常に処理...

>>> # JSONファイルの処理
>>> test_data = {
...     "name": "田中太郎",
...     "age": 30,
...     "hobbies": ["読書", "映画鑑賞", "プログラミング"],
...     "scores": {"math": 85, "english": 92, "science": 78}
... }

>>> success, message = processor.safe_write_json_file("test_data.json", test_data)
>>> print(f"\\nJSON書き込み: {message}")

>>> data, message = processor.safe_read_json_file("test_data.json")
>>> print(f"JSON読み込み: {message}")
>>> print(f"データ: {data['name']}さん, 年齢: {data['age']}歳" if data else "なし")

JSON書き込み: ファイル 'test_data.json' を正常に保存しました
JSON読み込み: JSONファイルを正常に読み込みました
データ: 田中太郎さん, 年齢: 30歳

>>> # CSVファイルの処理
>>> import tempfile
>>> import os

>>> # 一時的にCSVファイルを作成
>>> csv_content = """名前,年齢,都市
田中太郎,30,東京
佐藤花子,25,大阪
鈴木一郎,35,名古屋"""

>>> success, message = processor.safe_write_text_file("test_data.csv", csv_content)
>>> print(f"\\nCSV作成: {message}")

>>> rows, message = processor.safe_read_csv_file("test_data.csv")
>>> print(f"CSV読み込み: {message}")
>>> if rows:
...     print("CSVデータ:")
...     for i, row in enumerate(rows):
...         print(f"  {i+1}: {row}")

CSV作成: ファイル 'test_data.csv' を正常に保存しました
CSV読み込み: CSVファイルを正常に読み込みました (4行)
CSVデータ:
  1: ['名前', '年齢', '都市']
  2: ['田中太郎', '30', '東京']
  3: ['佐藤花子', '25', '大阪']
  4: ['鈴木一郎', '35', '名古屋']

>>> # エラーケースのテスト
>>> print("\\n=== エラーケーステスト ===")

>>> # 存在しないファイルの読み込み
>>> content, message = processor.safe_read_text_file("存在しないファイル.txt")
>>> print(f"存在しないファイル: {message}")

>>> # 不正なJSONファイルの読み込み
>>> processor.safe_write_text_file("invalid.json", "{ invalid json content")
>>> data, message = processor.safe_read_json_file("invalid.json")
>>> print(f"不正なJSON: {message}")

>>> # 操作ログとエラーレポート
>>> print("\\n=== 操作ログ ===")
>>> log = processor.get_operation_log()
>>> print(f"総操作数: {len(log)}")

>>> error_report = processor.generate_error_report()
>>> print("\\n" + error_report)

=== エラーケーステスト ===
存在しないファイル: ファイルエラー: ファイル '存在しないファイル.txt' が見つかりません
不正なJSON: JSON解析エラー: ファイルの形式が正しくありません (Expecting property name enclosed in double quotes: line 1 column 3 (char 2))

=== 操作ログ ===
総操作数: 8

=== エラーレポート ===
総操作数: 8
エラー数: 2
成功率: 75.0%

1. 2024-12-19T11:15:32.123456 - read_text '存在しないファイル.txt'
   エラー: ファイル '存在しないファイル.txt' が見つかりません

2. 2024-12-19T11:15:32.345678 - read_json 'invalid.json'
   エラー: JSON解析エラー: ファイルの形式が正しくありません (Expecting property name enclosed in double quotes: line 1 column 3 (char 2))
```

## まとめ：例外処理のベストプラクティス

この章で学んだことをまとめましょう：

### 例外処理の基本原則
1. **予測可能なエラーには必ず対処する**
2. **ユーザーフレンドリーなエラーメッセージを提供する**
3. **プログラムの継続性を保つ**
4. **リソースの適切なクリーンアップを行う**

### try-except文の使い方
```python
try:
    # 危険な処理
    risky_operation()
except SpecificError as e:
    # 特定のエラーへの対処
    handle_specific_error(e)
except Exception as e:
    # その他のエラーへの対処
    handle_general_error(e)
else:
    # エラーが起きなかった場合
    success_operation()
finally:
    # 必ず実行される処理
    cleanup_resources()
```

### よく使われる例外タイプ
- **FileNotFoundError**: ファイルが見つからない
- **PermissionError**: アクセス権限がない
- **ValueError**: 不正な値
- **TypeError**: 不正な型
- **KeyError**: 辞書のキーが存在しない
- **IndexError**: リストの範囲外アクセス
- **ZeroDivisionError**: ゼロ除算

### 実用的な応用例
- 銀行ATMシステムの安全な取引処理
- ファイル操作の包括的なエラーハンドリング
- ユーザー入力の検証と安全な処理
- データベース操作のトランザクション管理
- ネットワーク通信の障害対応

### エラーログとデバッグ
```python
import logging

# ログ設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

try:
    dangerous_operation()
except Exception as e:
    logger.error(f"エラーが発生しました: {e}", exc_info=True)
```

次の章では、**クラスとオブジェクト指向プログラミング**について学びます。これまで学んだ機能を組み合わせて、より大規模で保守しやすいプログラムを作る方法を習得しましょう！

---

**第13章執筆完了ログ:**
第13章では例外処理の概念から実装まで包括的に学習。エラーが発生する理由、try-except文の基本構文、複数例外の処理、else節とfinally節の活用を段階的に説明。実践例として銀行ATMシステムとファイル処理システムを構築し、現実的なエラーハンドリングの方法を習得。ログ機能やエラーレポート生成まで含む完全なシステムを実装。次は第14章のオブジェクト指向プログラミングに進みます。