# 第16章：例外処理の文法

## この章で学ぶこと

- try-except文のBNF定義
- 例外クラスの階層構造
- raiseとassert文
- finally節とクリーンアップ
- カスタム例外の作成
- 例外処理のベストプラクティス

## 16.1 try-except文のBNF定義

### 例外処理の構文

```bnf
<try文> ::= "try" ":" <スイート>
           (<except節>+ [<else節>] [<finally節>] | <finally節>)
<except節> ::= "except" [<式> ["as" <識別子>]] ":" <スイート>
<else節> ::= "else" ":" <スイート>
<finally節> ::= "finally" ":" <スイート>
```

### 基本的な例外処理

```python
# exception_basics.py

# 基本的なtry-except
print("=== 基本的な例外処理 ===")
def divide(a, b):
    try:
        result = a / b
        print(f"{a} / {b} = {result}")
        return result
    except ZeroDivisionError:
        print(f"エラー: {b}で除算することはできません")
        return None

divide(10, 2)
divide(10, 0)

# 複数の例外をキャッチ
print("\n=== 複数の例外処理 ===")
def convert_to_int(value):
    try:
        return int(value)
    except ValueError:
        print(f"ValueError: '{value}'は整数に変換できません")
        return None
    except TypeError:
        print(f"TypeError: {type(value).__name__}型は変換できません")
        return None

print(f"convert_to_int('123'): {convert_to_int('123')}")
print(f"convert_to_int('abc'): {convert_to_int('abc')}")
print(f"convert_to_int([1, 2, 3]): {convert_to_int([1, 2, 3])}")

# 例外オブジェクトの取得
print("\n=== 例外オブジェクトの取得 ===")
def process_file(filename):
    try:
        with open(filename, 'r') as f:
            return f.read()
    except FileNotFoundError as e:
        print(f"ファイルエラー: {e}")
        print(f"エラータイプ: {type(e).__name__}")
        print(f"エラー引数: {e.args}")
        return None
    except IOError as e:
        print(f"入出力エラー: {e}")
        return None

process_file("nonexistent.txt")

# すべての例外をキャッチ（推奨されない）
print("\n=== すべての例外をキャッチ ===")
def risky_function(x):
    try:
        if x == 0:
            return 1 / x
        elif x == 1:
            return int("not a number")
        elif x == 2:
            return undefined_variable
        else:
            return x
    except Exception as e:
        print(f"予期しないエラー: {type(e).__name__}: {e}")
        return None

for i in range(4):
    print(f"risky_function({i}): {risky_function(i)}")
```

## 16.2 【実行】例外クラスの階層構造

```python
# exception_hierarchy.py

# 組み込み例外の階層
print("=== 例外クラスの階層 ===")

# 主要な例外クラスの関係を表示
def show_exception_hierarchy(exc_class, indent=0):
    """例外クラスの階層を表示"""
    print("  " * indent + exc_class.__name__)
    for subclass in exc_class.__subclasses__():
        show_exception_hierarchy(subclass, indent + 1)

# BaseExceptionから開始（一部のみ表示）
print("BaseException")
print("  Exception")
print("    ArithmeticError")
print("      ZeroDivisionError")
print("      OverflowError")
print("    LookupError")
print("      IndexError")
print("      KeyError")
print("    ValueError")
print("    TypeError")
print("    IOError (OSError)")
print("      FileNotFoundError")
print("      PermissionError")
print("  KeyboardInterrupt")
print("  SystemExit")

# 例外の継承関係を確認
print("\n=== 例外の継承関係 ===")
print(f"issubclass(ValueError, Exception): {issubclass(ValueError, Exception)}")
print(f"issubclass(KeyError, LookupError): {issubclass(KeyError, LookupError)}")
print(f"issubclass(FileNotFoundError, IOError): {issubclass(FileNotFoundError, IOError)}")

# 複数の例外を同時にキャッチ
print("\n=== 複数の例外を同時にキャッチ ===")
def access_data(data, key):
    try:
        # リストまたは辞書へのアクセス
        return data[key]
    except (IndexError, KeyError) as e:
        print(f"アクセスエラー ({type(e).__name__}): {e}")
        return None
    except TypeError as e:
        print(f"型エラー: {e}")
        return None

# テスト
my_list = [1, 2, 3]
my_dict = {'a': 1, 'b': 2}

print(f"access_data(my_list, 1): {access_data(my_list, 1)}")
print(f"access_data(my_list, 10): {access_data(my_list, 10)}")
print(f"access_data(my_dict, 'a'): {access_data(my_dict, 'a')}")
print(f"access_data(my_dict, 'z'): {access_data(my_dict, 'z')}")
print(f"access_data('string', 0): {access_data('string', 0)}")

# 基底クラスでキャッチ
print("\n=== 基底クラスでキャッチ ===")
def arithmetic_operation(a, b, op):
    try:
        if op == '/':
            return a / b
        elif op == '//':
            return a // b
        elif op == '%':
            return a % b
        else:
            raise ValueError(f"不明な演算子: {op}")
    except ArithmeticError as e:
        # ZeroDivisionError, OverflowError などをキャッチ
        print(f"算術エラー ({type(e).__name__}): {e}")
        return None

print(f"10 / 0: {arithmetic_operation(10, 0, '/')}")
print(f"10 // 0: {arithmetic_operation(10, 0, '//')}")
print(f"10 % 0: {arithmetic_operation(10, 0, '%')}")
```

## 16.3 【実行】else節とfinally節の実行順序

```python
# try_else_finally.py

# else節の使用
print("=== else節 ===")
def read_number(text):
    try:
        num = int(text)
    except ValueError:
        print(f"エラー: '{text}'は数値ではありません")
        return None
    else:
        # 例外が発生しなかった場合のみ実行
        print(f"正常に変換されました: {num}")
        return num * 2

print(f"read_number('42'): {read_number('42')}")
print(f"read_number('abc'): {read_number('abc')}")

# finally節の使用
print("\n=== finally節 ===")
def process_with_cleanup(should_fail=False):
    resource = "リソース"
    try:
        print(f"1. リソースを取得: {resource}")
        if should_fail:
            raise RuntimeError("処理中にエラー発生")
        print("2. 正常に処理完了")
        return "成功"
    except RuntimeError as e:
        print(f"3. エラーをキャッチ: {e}")
        return "失敗"
    finally:
        print(f"4. クリーンアップ: {resource}を解放")

print("正常なケース:")
result1 = process_with_cleanup(False)
print(f"結果: {result1}\n")

print("エラーのケース:")
result2 = process_with_cleanup(True)
print(f"結果: {result2}")

# 実行順序の詳細
print("\n=== 実行順序の詳細 ===")
def execution_order_demo(scenario):
    print(f"\nシナリオ: {scenario}")
    try:
        print("  1. try節の開始")
        if scenario == "success":
            print("  2. 正常処理")
        elif scenario == "caught":
            print("  2. 例外を発生")
            raise ValueError("キャッチされる例外")
        elif scenario == "uncaught":
            print("  2. 例外を発生")
            raise RuntimeError("キャッチされない例外")
        elif scenario == "return":
            print("  2. tryからreturn")
            return "try return"
    except ValueError as e:
        print(f"  3. except節: {e}")
        if scenario == "except_return":
            print("  4. exceptからreturn")
            return "except return"
    else:
        print("  3. else節（例外なし）")
        if scenario == "else_return":
            print("  4. elseからreturn")
            return "else return"
    finally:
        print("  F. finally節（常に実行）")
        if scenario == "finally_return":
            print("  F. finallyからreturn（他を上書き）")
            return "finally return"
    
    print("  5. 関数の最後")
    return "normal end"

# 各シナリオを実行
scenarios = ["success", "caught", "else_return", "finally_return"]
for scenario in scenarios:
    result = execution_order_demo(scenario)
    print(f"戻り値: {result}")

# finallyでの例外
print("\n=== finally節での例外 ===")
def finally_exception():
    try:
        print("try: 例外を発生")
        raise ValueError("元の例外")
    finally:
        print("finally: 新しい例外を発生")
        raise RuntimeError("finally内の例外")

try:
    finally_exception()
except RuntimeError as e:
    print(f"キャッチされた例外: {e}")
    print("注意: 元のValueErrorは失われた！")
```

## 16.4 raise文とassert文

### 【実行】例外の発生と再発生

```python
# raise_assert.py

# raise文の基本
print("=== raise文の基本 ===")
def validate_age(age):
    if not isinstance(age, int):
        raise TypeError(f"年齢は整数である必要があります: {type(age).__name__}")
    if age < 0:
        raise ValueError(f"年齢は0以上である必要があります: {age}")
    if age > 150:
        raise ValueError(f"年齢が現実的ではありません: {age}")
    return age

# テスト
test_ages = [25, -5, 200, "30"]
for age in test_ages:
    try:
        result = validate_age(age)
        print(f"validate_age({age!r}): OK - {result}")
    except (TypeError, ValueError) as e:
        print(f"validate_age({age!r}): {type(e).__name__}: {e}")

# 例外の再発生
print("\n=== 例外の再発生 ===")
def process_with_logging(func, *args):
    try:
        return func(*args)
    except Exception as e:
        print(f"エラーログ: {type(e).__name__}: {e}")
        print("詳細情報を記録後、例外を再発生")
        raise  # 元の例外をそのまま再発生

def buggy_function(x):
    return 1 / x

try:
    process_with_logging(buggy_function, 0)
except ZeroDivisionError:
    print("呼び出し元で例外をキャッチ")

# 例外の連鎖
print("\n=== 例外の連鎖 ===")
def load_config(filename):
    try:
        with open(filename) as f:
            import json
            return json.load(f)
    except FileNotFoundError as e:
        raise ValueError(f"設定ファイルが見つかりません: {filename}") from e
    except json.JSONDecodeError as e:
        raise ValueError(f"設定ファイルの形式が不正です") from e

try:
    load_config("nonexistent.json")
except ValueError as e:
    print(f"エラー: {e}")
    print(f"原因: {e.__cause__}")

# assert文
print("\n=== assert文 ===")
def calculate_average(numbers):
    assert len(numbers) > 0, "リストが空です"
    assert all(isinstance(n, (int, float)) for n in numbers), "数値以外が含まれています"
    
    total = sum(numbers)
    average = total / len(numbers)
    
    assert 0 <= average <= 100, f"平均値が範囲外です: {average}"
    
    return average

# テスト
test_cases = [
    [80, 90, 85],
    [],  # AssertionError
    [80, 90, "100"],  # AssertionError
]

for numbers in test_cases:
    try:
        avg = calculate_average(numbers)
        print(f"平均値: {avg}")
    except AssertionError as e:
        print(f"アサーションエラー: {e}")

# assertの無効化
print("\n=== assertの無効化 ===")
print(f"__debug__ = {__debug__}")
print("注意: python -O script.py で実行するとassertは無効化されます")

# 条件付きraise
print("\n=== 条件付きraise ===")
def safe_divide(a, b):
    """安全な除算"""
    return a / b if b != 0 else None

def strict_divide(a, b):
    """厳密な除算"""
    if b == 0:
        raise ValueError("ゼロ除算は許可されていません")
    return a / b

print(f"safe_divide(10, 0): {safe_divide(10, 0)}")
try:
    strict_divide(10, 0)
except ValueError as e:
    print(f"strict_divide(10, 0): {e}")
```

## 16.5 【実行】カスタム例外の作成

```python
# custom_exceptions.py

# 基本的なカスタム例外
print("=== 基本的なカスタム例外 ===")
class ValidationError(Exception):
    """検証エラーの基底クラス"""
    pass

class EmailValidationError(ValidationError):
    """メールアドレスの検証エラー"""
    def __init__(self, email, reason):
        self.email = email
        self.reason = reason
        super().__init__(f"無効なメールアドレス '{email}': {reason}")

class PasswordValidationError(ValidationError):
    """パスワードの検証エラー"""
    def __init__(self, reason, min_length=8):
        self.reason = reason
        self.min_length = min_length
        super().__init__(f"パスワードエラー: {reason}")

# 使用例
def validate_email(email):
    if '@' not in email:
        raise EmailValidationError(email, "@が含まれていません")
    if email.count('@') > 1:
        raise EmailValidationError(email, "@が複数含まれています")
    
    local, domain = email.split('@')
    if not local:
        raise EmailValidationError(email, "ローカル部が空です")
    if not domain:
        raise EmailValidationError(email, "ドメイン部が空です")
    if '.' not in domain:
        raise EmailValidationError(email, "ドメインが不正です")

def validate_password(password):
    if len(password) < 8:
        raise PasswordValidationError("パスワードが短すぎます")
    if not any(c.isupper() for c in password):
        raise PasswordValidationError("大文字が含まれていません")
    if not any(c.isdigit() for c in password):
        raise PasswordValidationError("数字が含まれていません")

# テスト
test_emails = ["user@example.com", "invalid", "user@@example.com", "@example.com"]
for email in test_emails:
    try:
        validate_email(email)
        print(f"✓ {email}")
    except EmailValidationError as e:
        print(f"✗ {e}")

print()
test_passwords = ["Pass123!", "short", "password123", "PASSWORD123"]
for password in test_passwords:
    try:
        validate_password(password)
        print(f"✓ パスワード '{password}' は有効です")
    except PasswordValidationError as e:
        print(f"✗ {e}")

# 高度なカスタム例外
print("\n=== 高度なカスタム例外 ===")
class BusinessLogicError(Exception):
    """ビジネスロジックエラーの基底クラス"""
    error_code = None
    default_message = "ビジネスロジックエラーが発生しました"
    
    def __init__(self, message=None, **kwargs):
        if message is None:
            message = self.default_message
        
        self.message = message
        self.details = kwargs
        
        # エラーメッセージの構築
        if kwargs:
            details_str = ", ".join(f"{k}={v}" for k, v in kwargs.items())
            full_message = f"{message} ({details_str})"
        else:
            full_message = message
        
        super().__init__(full_message)

class InsufficientFundsError(BusinessLogicError):
    """残高不足エラー"""
    error_code = "INSUFFICIENT_FUNDS"
    default_message = "残高が不足しています"
    
    def __init__(self, balance, required, **kwargs):
        self.balance = balance
        self.required = required
        self.shortage = required - balance
        super().__init__(
            balance=balance,
            required=required,
            shortage=self.shortage,
            **kwargs
        )

class AccountLockedError(BusinessLogicError):
    """アカウントロックエラー"""
    error_code = "ACCOUNT_LOCKED"
    default_message = "アカウントがロックされています"

# 使用例
class BankAccount:
    def __init__(self, balance=0, locked=False):
        self.balance = balance
        self.locked = locked
    
    def withdraw(self, amount):
        if self.locked:
            raise AccountLockedError(account_id=id(self))
        
        if amount > self.balance:
            raise InsufficientFundsError(
                balance=self.balance,
                required=amount,
                account_id=id(self)
            )
        
        self.balance -= amount
        return self.balance

# テスト
account = BankAccount(balance=1000)

try:
    account.withdraw(500)
    print("✓ 500円の引き出し成功")
    account.withdraw(600)
except InsufficientFundsError as e:
    print(f"✗ {e}")
    print(f"  エラーコード: {e.error_code}")
    print(f"  不足額: {e.shortage}円")

account.locked = True
try:
    account.withdraw(100)
except AccountLockedError as e:
    print(f"✗ {e}")
    print(f"  エラーコード: {e.error_code}")
```

## 16.6 例外処理のベストプラクティス

```python
# exception_best_practices.py

# 1. 具体的な例外をキャッチする
print("=== 1. 具体的な例外をキャッチ ===")

# 悪い例
def bad_practice():
    try:
        # 何でもキャッチしてしまう
        risky_operation()
    except:  # bareなexceptは避ける
        print("エラーが発生しました")

# 良い例
def good_practice():
    try:
        risky_operation()
    except ValueError as e:
        print(f"値エラー: {e}")
    except KeyError as e:
        print(f"キーエラー: {e}")
    except Exception as e:
        # 予期しないエラーもログに記録
        import logging
        logging.error(f"予期しないエラー: {e}", exc_info=True)
        raise

# 2. EAFPとLBYL
print("\n=== 2. EAFP vs LBYL ===")

# LBYL (Look Before You Leap)
def lbyl_approach(dictionary, key):
    if key in dictionary:
        return dictionary[key]
    else:
        return None

# EAFP (Easier to Ask for Forgiveness than Permission)
def eafp_approach(dictionary, key):
    try:
        return dictionary[key]
    except KeyError:
        return None

# Pythonicな方法はEAFP
data = {'a': 1, 'b': 2}
print(f"EAFP: {eafp_approach(data, 'c')}")

# 3. コンテキストマネージャーを使用
print("\n=== 3. コンテキストマネージャー ===")

# 手動でのリソース管理（避けるべき）
def manual_resource_management():
    file = None
    try:
        file = open('data.txt', 'r')
        data = file.read()
        return data
    except IOError as e:
        print(f"ファイルエラー: {e}")
        return None
    finally:
        if file:
            file.close()

# withステートメント（推奨）
def with_statement():
    try:
        with open('data.txt', 'r') as file:
            return file.read()
    except IOError as e:
        print(f"ファイルエラー: {e}")
        return None

# 4. 例外の抑制
print("\n=== 4. 例外の抑制 ===")
from contextlib import suppress

# 特定の例外を無視
with suppress(FileNotFoundError):
    import os
    os.remove('nonexistent.txt')
    print("ファイルを削除しました")  # 実行されない

print("処理を継続")

# 5. 例外のラップ
print("\n=== 5. 例外のラップ ===")

class DataProcessingError(Exception):
    """データ処理エラー"""
    pass

def process_data(data):
    try:
        # 複雑な処理
        result = json.loads(data)
        return result['key']
    except json.JSONDecodeError as e:
        raise DataProcessingError("JSONの解析に失敗") from e
    except KeyError as e:
        raise DataProcessingError("必要なキーが見つかりません") from e

# 6. リトライパターン
print("\n=== 6. リトライパターン ===")
import time
import random

def retry(max_attempts=3, delay=1.0, exceptions=(Exception,)):
    """リトライデコレータ"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    if attempt == max_attempts - 1:
                        raise
                    print(f"試行 {attempt + 1} 失敗: {e}")
                    time.sleep(delay)
            return None
        return wrapper
    return decorator

@retry(max_attempts=3, delay=0.5, exceptions=(ValueError,))
def unreliable_operation():
    if random.random() < 0.7:  # 70%の確率で失敗
        raise ValueError("ランダムな失敗")
    return "成功！"

try:
    result = unreliable_operation()
    print(f"結果: {result}")
except ValueError:
    print("すべての試行が失敗しました")

# 7. エラーハンドリングの戦略
print("\n=== 7. エラーハンドリング戦略 ===")

class ErrorHandler:
    @staticmethod
    def log_and_continue(func):
        """エラーをログに記録して続行"""
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                print(f"エラーをログに記録: {e}")
                return None
        return wrapper
    
    @staticmethod
    def convert_to_default(default_value):
        """エラー時にデフォルト値を返す"""
        def decorator(func):
            def wrapper(*args, **kwargs):
                try:
                    return func(*args, **kwargs)
                except Exception:
                    return default_value
            return wrapper
        return decorator

@ErrorHandler.log_and_continue
def may_fail():
    raise ValueError("何か問題が発生")

@ErrorHandler.convert_to_default(default_value=0)
def parse_int(text):
    return int(text)

print(f"may_fail(): {may_fail()}")
print(f"parse_int('abc'): {parse_int('abc')}")
```

## 16.7 この章のまとめ

- try-except文で例外を処理し、プログラムのクラッシュを防ぐ
- 例外クラスは階層構造を持ち、適切なレベルでキャッチする
- else節は正常処理、finally節はクリーンアップに使用
- raise文で例外を発生させ、assert文で前提条件を確認
- カスタム例外でドメイン固有のエラーを表現
- EAFPスタイルとコンテキストマネージャーがPythonic

## 練習問題

1. **バリデーションフレームワーク**
   複数の検証ルールを組み合わせられるバリデーションフレームワークを作成してください。

2. **リトライメカニズム**
   指数バックオフを実装したリトライデコレータを作成してください。

3. **例外チェーン**
   複数の処理をチェーンし、各段階のエラーを適切に処理するパイプラインを実装してください。

4. **エラーレポート**
   例外情報を構造化してJSONフォーマットで出力するエラーレポーターを作成してください。

5. **コンテキストマネージャー**
   データベーストランザクションを模擬したコンテキストマネージャーを実装してください。

---

次章では、デコレータとメタプログラミングについて学びます。

[第17章 デコレータとメタプログラミング →](chapter17.md)