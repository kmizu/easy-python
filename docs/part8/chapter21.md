# 第21章：テストとデバッグ

## この章で学ぶこと

- ユニットテストの基礎とベストプラクティス
- pytestフレームワークの活用
- モックとスタブを使ったテスト
- デバッグ技法とツール
- プロファイリングと性能測定
- 継続的インテグレーション

## 21.1 【実行】ユニットテストの基礎

```python
# unit_testing_basics.py

import unittest
from unittest.mock import Mock, patch, MagicMock
import tempfile
import os
import json

# テスト対象のクラス
class Calculator:
    """計算機クラス（テスト対象）"""
    
    def add(self, a, b):
        """加算"""
        return a + b
    
    def divide(self, a, b):
        """除算"""
        if b == 0:
            raise ValueError("ゼロ除算はできません")
        return a / b
    
    def power(self, base, exponent):
        """累乗"""
        if exponent < 0:
            raise ValueError("負の指数はサポートされていません")
        return base ** exponent

class BankAccount:
    """銀行口座クラス（テスト対象）"""
    
    def __init__(self, initial_balance=0):
        if initial_balance < 0:
            raise ValueError("初期残高は負の値にできません")
        self.balance = initial_balance
    
    def deposit(self, amount):
        """入金"""
        if amount <= 0:
            raise ValueError("入金額は正の値である必要があります")
        self.balance += amount
        return self.balance
    
    def withdraw(self, amount):
        """出金"""
        if amount <= 0:
            raise ValueError("出金額は正の値である必要があります")
        if amount > self.balance:
            raise ValueError("残高不足です")
        self.balance -= amount
        return self.balance
    
    def get_balance(self):
        """残高取得"""
        return self.balance

# 基本的なユニットテスト
class TestCalculator(unittest.TestCase):
    """Calculatorクラスのテスト"""
    
    def setUp(self):
        """各テストメソッドの前に実行される"""
        self.calc = Calculator()
        print(f"テスト開始: {self._testMethodName}")
    
    def tearDown(self):
        """各テストメソッドの後に実行される"""
        print(f"テスト終了: {self._testMethodName}")
    
    def test_add_positive_numbers(self):
        """正の数の加算テスト"""
        result = self.calc.add(3, 5)
        self.assertEqual(result, 8)
    
    def test_add_negative_numbers(self):
        """負の数の加算テスト"""
        result = self.calc.add(-3, -5)
        self.assertEqual(result, -8)
    
    def test_add_mixed_numbers(self):
        """正負混合の加算テスト"""
        result = self.calc.add(-3, 5)
        self.assertEqual(result, 2)
    
    def test_divide_normal(self):
        """通常の除算テスト"""
        result = self.calc.divide(10, 2)
        self.assertEqual(result, 5.0)
    
    def test_divide_by_zero(self):
        """ゼロ除算のテスト"""
        with self.assertRaises(ValueError) as context:
            self.calc.divide(10, 0)
        
        self.assertEqual(str(context.exception), "ゼロ除算はできません")
    
    def test_power_positive(self):
        """正の累乗テスト"""
        result = self.calc.power(2, 3)
        self.assertEqual(result, 8)
    
    def test_power_zero(self):
        """ゼロ乗のテスト"""
        result = self.calc.power(5, 0)
        self.assertEqual(result, 1)
    
    def test_power_negative_exponent(self):
        """負の指数のテスト"""
        with self.assertRaises(ValueError) as context:
            self.calc.power(2, -1)
        
        self.assertIn("負の指数", str(context.exception))

class TestBankAccount(unittest.TestCase):
    """BankAccountクラスのテスト"""
    
    def test_initial_balance(self):
        """初期残高のテスト"""
        account = BankAccount(100)
        self.assertEqual(account.get_balance(), 100)
    
    def test_initial_balance_zero(self):
        """初期残高ゼロのテスト"""
        account = BankAccount()
        self.assertEqual(account.get_balance(), 0)
    
    def test_negative_initial_balance(self):
        """負の初期残高のテスト"""
        with self.assertRaises(ValueError):
            BankAccount(-100)
    
    def test_deposit(self):
        """入金のテスト"""
        account = BankAccount(100)
        new_balance = account.deposit(50)
        
        self.assertEqual(new_balance, 150)
        self.assertEqual(account.get_balance(), 150)
    
    def test_deposit_invalid_amount(self):
        """無効な入金額のテスト"""
        account = BankAccount(100)
        
        with self.assertRaises(ValueError):
            account.deposit(0)
        
        with self.assertRaises(ValueError):
            account.deposit(-50)
    
    def test_withdraw(self):
        """出金のテスト"""
        account = BankAccount(100)
        new_balance = account.withdraw(30)
        
        self.assertEqual(new_balance, 70)
        self.assertEqual(account.get_balance(), 70)
    
    def test_withdraw_insufficient_funds(self):
        """残高不足のテスト"""
        account = BankAccount(100)
        
        with self.assertRaises(ValueError) as context:
            account.withdraw(150)
        
        self.assertEqual(str(context.exception), "残高不足です")
    
    def test_multiple_operations(self):
        """複数操作のテスト"""
        account = BankAccount(100)
        
        account.deposit(50)   # 150
        account.withdraw(30)  # 120
        account.deposit(20)   # 140
        
        self.assertEqual(account.get_balance(), 140)

# テストの実行
def run_unittest_tests():
    """ユニットテストの実行"""
    print("=== ユニットテスト実行 ===")
    
    # テストスイートの作成
    suite = unittest.TestSuite()
    
    # 特定のテストメソッドを追加
    suite.addTest(TestCalculator('test_add_positive_numbers'))
    suite.addTest(TestCalculator('test_divide_by_zero'))
    suite.addTest(TestBankAccount('test_deposit'))
    suite.addTest(TestBankAccount('test_withdraw_insufficient_funds'))
    
    # テストランナーで実行
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    print(f"\n実行されたテスト: {result.testsRun}")
    print(f"失敗: {len(result.failures)}")
    print(f"エラー: {len(result.errors)}")

# 実行
run_unittest_tests()
```

## 21.2 【実行】pytestフレームワーク

```python
# pytest_examples.py

# pytestの基本的な使用法
import pytest
import tempfile
import os
from pathlib import Path

# フィクスチャの使用
@pytest.fixture
def calculator():
    """Calculatorインスタンスを提供するフィクスチャ"""
    return Calculator()

@pytest.fixture
def bank_account():
    """BankAccountインスタンスを提供するフィクスチャ"""
    return BankAccount(1000)  # 初期残高1000

@pytest.fixture
def temp_file():
    """一時ファイルを提供するフィクスチャ"""
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write('{"test": "data"}')
        temp_path = f.name
    
    yield temp_path  # テストに渡す
    
    # クリーンアップ
    os.unlink(temp_path)

# pytestスタイルのテスト
def test_calculator_add(calculator):
    """計算機の加算テスト"""
    assert calculator.add(2, 3) == 5
    assert calculator.add(-1, 1) == 0

def test_calculator_divide_by_zero(calculator):
    """ゼロ除算のテスト"""
    with pytest.raises(ValueError, match="ゼロ除算"):
        calculator.divide(10, 0)

def test_bank_account_operations(bank_account):
    """銀行口座の操作テスト"""
    # 入金テスト
    bank_account.deposit(500)
    assert bank_account.get_balance() == 1500
    
    # 出金テスト
    bank_account.withdraw(200)
    assert bank_account.get_balance() == 1300

def test_file_operations(temp_file):
    """ファイル操作のテスト"""
    # ファイルが存在することを確認
    assert os.path.exists(temp_file)
    
    # ファイル内容を確認
    with open(temp_file, 'r') as f:
        data = json.load(f)
    
    assert data["test"] == "data"

# パラメータ化テスト
@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (-1, 1, 0),
    (0, 0, 0),
    (10, -5, 5),
])
def test_calculator_add_parametrized(calculator, a, b, expected):
    """パラメータ化された加算テスト"""
    assert calculator.add(a, b) == expected

@pytest.mark.parametrize("base,exponent,expected", [
    (2, 3, 8),
    (5, 0, 1),
    (1, 100, 1),
])
def test_calculator_power_parametrized(calculator, base, exponent, expected):
    """パラメータ化された累乗テスト"""
    assert calculator.power(base, exponent) == expected

# マーカーを使用したテストの分類
@pytest.mark.slow
def test_slow_operation():
    """時間のかかるテスト"""
    import time
    time.sleep(0.1)
    assert True

@pytest.mark.integration
def test_integration_example():
    """統合テスト例"""
    # 複数のコンポーネントを組み合わせたテスト
    calc = Calculator()
    account = BankAccount(100)
    
    # 計算結果を使って入金
    result = calc.add(50, 30)
    account.deposit(result)
    
    assert account.get_balance() == 180

# カスタムマーカー
@pytest.mark.database
def test_database_connection():
    """データベース関連のテスト"""
    # データベース接続テストのシミュレーション
    assert True

# 条件付きスキップ
@pytest.mark.skipif(os.name == 'nt', reason="Windowsでは実行しない")
def test_unix_specific():
    """Unix固有の機能テスト"""
    assert True

@pytest.mark.xfail(reason="既知のバグ")
def test_known_failure():
    """既知の失敗テスト"""
    assert False  # このテストは失敗することが期待される

# カスタムアサーション
def test_custom_assertions():
    """カスタムアサーションの例"""
    data = [1, 2, 3, 4, 5]
    
    # 複数のアサーション
    assert len(data) == 5
    assert sum(data) == 15
    assert max(data) == 5
    assert min(data) == 1
    
    # リストの内容チェック
    assert 3 in data
    assert 6 not in data
    
    # 近似値のチェック
    assert 0.1 + 0.2 == pytest.approx(0.3)

# conftest.py相当の設定（実際はconftest.pyファイルに書く）
def pytest_configure():
    """pytest設定"""
    pytest.custom_marker = pytest.mark.custom

# pytestプラグインの例
class CustomPlugin:
    """カスタムpytestプラグイン"""
    
    def pytest_runtest_setup(self, item):
        """テスト実行前の処理"""
        print(f"\n[SETUP] {item.name}")
    
    def pytest_runtest_teardown(self, item):
        """テスト実行後の処理"""
        print(f"[TEARDOWN] {item.name}")

# テスト実行のシミュレーション
def simulate_pytest_run():
    """pytestの実行をシミュレート"""
    print("=== pytest実行シミュレーション ===")
    print("実際の実行コマンド例:")
    print("pytest test_file.py -v")
    print("pytest -m slow")  # slowマーカーのテストのみ
    print("pytest -k 'add'")  # 名前に'add'を含むテストのみ
    print("pytest --tb=short")  # 短いトレースバック
    print("pytest --collect-only")  # テスト収集のみ

simulate_pytest_run()
```

## 21.3 【実行】モックとスタブを使ったテスト

```python
# mocking_testing.py

from unittest.mock import Mock, MagicMock, patch, mock_open
import requests
import json
from datetime import datetime
import os

# テスト対象のクラス
class WeatherService:
    """天気予報サービス"""
    
    def __init__(self, api_key):
        self.api_key = api_key
        self.base_url = "https://api.weather.com"
    
    def get_weather(self, city):
        """天気情報を取得"""
        url = f"{self.base_url}/weather"
        params = {
            'city': city,
            'api_key': self.api_key
        }
        
        response = requests.get(url, params=params)
        response.raise_for_status()
        
        data = response.json()
        return {
            'city': data['city'],
            'temperature': data['temp'],
            'condition': data['condition']
        }

class FileManager:
    """ファイル管理クラス"""
    
    def save_data(self, filename, data):
        """データをファイルに保存"""
        with open(filename, 'w') as f:
            json.dump(data, f)
        return True
    
    def load_data(self, filename):
        """ファイルからデータを読み込み"""
        if not os.path.exists(filename):
            raise FileNotFoundError(f"ファイルが見つかりません: {filename}")
        
        with open(filename, 'r') as f:
            return json.load(f)

class EmailNotifier:
    """メール通知クラス"""
    
    def __init__(self, smtp_server):
        self.smtp_server = smtp_server
    
    def send_email(self, to, subject, body):
        """メール送信（外部依存）"""
        # 実際のSMTP接続はテストでモック化
        print(f"メール送信: {to} - {subject}")
        return True

class UserService:
    """ユーザーサービス（依存性注入）"""
    
    def __init__(self, weather_service, file_manager, email_notifier):
        self.weather_service = weather_service
        self.file_manager = file_manager
        self.email_notifier = email_notifier
    
    def get_weather_report(self, city, user_email):
        """天気レポートを取得してメール送信"""
        try:
            # 天気情報取得
            weather = self.weather_service.get_weather(city)
            
            # レポート作成
            report = {
                'timestamp': datetime.now().isoformat(),
                'weather': weather
            }
            
            # ファイルに保存
            filename = f"weather_{city}.json"
            self.file_manager.save_data(filename, report)
            
            # メール送信
            subject = f"{city}の天気予報"
            body = f"気温: {weather['temperature']}度\n状況: {weather['condition']}"
            self.email_notifier.send_email(user_email, subject, body)
            
            return report
        
        except Exception as e:
            return {'error': str(e)}

# モックを使ったテスト
print("=== モックを使ったテスト ===")

def test_weather_service_with_mock():
    """WeatherServiceのモックテスト"""
    
    # requestsモジュールをモック化
    with patch('requests.get') as mock_get:
        # モックレスポンスの設定
        mock_response = Mock()
        mock_response.json.return_value = {
            'city': 'Tokyo',
            'temp': 25,
            'condition': 'Sunny'
        }
        mock_response.raise_for_status.return_value = None
        mock_get.return_value = mock_response
        
        # テスト実行
        service = WeatherService('fake-api-key')
        result = service.get_weather('Tokyo')
        
        # アサーション
        assert result['city'] == 'Tokyo'
        assert result['temperature'] == 25
        assert result['condition'] == 'Sunny'
        
        # モックが正しく呼ばれたかチェック
        mock_get.assert_called_once()
        args, kwargs = mock_get.call_args
        assert kwargs['params']['city'] == 'Tokyo'
        
        print("WeatherServiceモックテスト: 成功")

def test_file_manager_with_mock():
    """FileManagerのモックテスト"""
    
    test_data = {'key': 'value', 'number': 42}
    
    # open関数をモック化
    with patch('builtins.open', mock_open()) as mock_file:
        file_manager = FileManager()
        
        # ファイル保存テスト
        result = file_manager.save_data('test.json', test_data)
        assert result is True
        
        # openが適切に呼ばれたかチェック
        mock_file.assert_called_once_with('test.json', 'w')
        
        # 書き込み内容をチェック
        handle = mock_file()
        written_data = ''.join([call.args[0] for call in handle.write.call_args_list])
        assert 'key' in written_data
        
        print("FileManagerモックテスト: 成功")

def test_file_manager_load_with_mock():
    """FileManagerの読み込みモックテスト"""
    
    test_data = {'loaded': True, 'data': [1, 2, 3]}
    mock_content = json.dumps(test_data)
    
    # ファイル読み込みのモック
    with patch('builtins.open', mock_open(read_data=mock_content)):
        with patch('os.path.exists', return_value=True):
            file_manager = FileManager()
            result = file_manager.load_data('test.json')
            
            assert result == test_data
            print("FileManager読み込みモックテスト: 成功")

def test_user_service_integration_with_mocks():
    """UserServiceの統合テスト（モック使用）"""
    
    # 依存関係をモック化
    mock_weather_service = Mock()
    mock_file_manager = Mock()
    mock_email_notifier = Mock()
    
    # モックの戻り値を設定
    mock_weather_service.get_weather.return_value = {
        'city': 'Osaka',
        'temperature': 28,
        'condition': 'Cloudy'
    }
    mock_file_manager.save_data.return_value = True
    mock_email_notifier.send_email.return_value = True
    
    # テスト対象のサービス
    user_service = UserService(
        mock_weather_service,
        mock_file_manager,
        mock_email_notifier
    )
    
    # テスト実行
    result = user_service.get_weather_report('Osaka', 'user@example.com')
    
    # アサーション
    assert 'error' not in result
    assert result['weather']['city'] == 'Osaka'
    assert 'timestamp' in result
    
    # モックの呼び出しをチェック
    mock_weather_service.get_weather.assert_called_once_with('Osaka')
    mock_file_manager.save_data.assert_called_once()
    mock_email_notifier.send_email.assert_called_once()
    
    # 詳細な引数チェック
    email_args = mock_email_notifier.send_email.call_args[0]
    assert email_args[0] == 'user@example.com'
    assert 'Osaka' in email_args[1]  # 件名にOsakaが含まれる
    
    print("UserService統合モックテスト: 成功")

# スパイとパーシャルモック
def test_spy_and_partial_mock():
    """スパイとパーシャルモックの例"""
    
    # 実際のオブジェクトをスパイ
    real_calculator = Calculator()
    
    with patch.object(real_calculator, 'add', wraps=real_calculator.add) as spy_add:
        # 実際のメソッドが呼ばれるが、呼び出しを監視
        result = real_calculator.add(3, 5)
        
        assert result == 8  # 実際の結果
        spy_add.assert_called_once_with(3, 5)  # 呼び出しも記録
        
        print("スパイテスト: 成功")

# モックの高度な使用法
def test_advanced_mocking():
    """高度なモック使用法"""
    
    # side_effectを使った例外発生のテスト
    mock_service = Mock()
    mock_service.get_data.side_effect = ValueError("接続エラー")
    
    try:
        mock_service.get_data()
        assert False, "例外が発生すべき"
    except ValueError as e:
        assert str(e) == "接続エラー"
    
    # side_effectを使った複数回呼び出しのテスト
    mock_service.get_data.side_effect = [
        {'data': 1},  # 1回目の呼び出し
        {'data': 2},  # 2回目の呼び出し
        ValueError("3回目はエラー")  # 3回目の呼び出し
    ]
    
    assert mock_service.get_data() == {'data': 1}
    assert mock_service.get_data() == {'data': 2}
    
    try:
        mock_service.get_data()
        assert False, "3回目は例外が発生すべき"
    except ValueError:
        pass
    
    # call_countのチェック
    assert mock_service.get_data.call_count == 3
    
    print("高度なモックテスト: 成功")

# コンテキストマネージャーのモック
def test_context_manager_mock():
    """コンテキストマネージャーのモック"""
    
    # ファイル操作のモック
    with patch('builtins.open', mock_open(read_data='test content')) as mock_file:
        with open('test.txt', 'r') as f:
            content = f.read()
        
        assert content == 'test content'
        mock_file.assert_called_once_with('test.txt', 'r')
    
    # カスタムコンテキストマネージャーのモック
    mock_context = MagicMock()
    mock_context.__enter__.return_value = 'mocked_resource'
    mock_context.__exit__.return_value = None
    
    with mock_context as resource:
        assert resource == 'mocked_resource'
    
    mock_context.__enter__.assert_called_once()
    mock_context.__exit__.assert_called_once()
    
    print("コンテキストマネージャーモックテスト: 成功")

# 全テスト実行
test_weather_service_with_mock()
test_file_manager_with_mock()
test_file_manager_load_with_mock()
test_user_service_integration_with_mocks()
test_spy_and_partial_mock()
test_advanced_mocking()
test_context_manager_mock()
```

## 21.4 【実行】デバッグ技法とツール

```python
# debugging_techniques.py

import pdb
import traceback
import sys
import logging
from functools import wraps
import time

# ログ設定
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# デバッグ対象のクラス
class BuggyCalculator:
    """バグを含む計算機クラス（デバッグ練習用）"""
    
    def __init__(self):
        self.history = []
    
    def add(self, a, b):
        """加算（意図的なバグ含む）"""
        # バグ1: ログを出力
        logger.debug(f"add({a}, {b}) called")
        
        # バグ2: 型チェックなし
        try:
            result = a + b
            self.history.append(f"{a} + {b} = {result}")
            return result
        except TypeError as e:
            logger.error(f"Type error in add: {e}")
            raise
    
    def divide(self, a, b):
        """除算（ゼロ除算のバグ）"""
        logger.debug(f"divide({a}, {b}) called")
        
        # バグ3: ゼロチェックなし
        result = a / b  # ZeroDivisionErrorの可能性
        self.history.append(f"{a} / {b} = {result}")
        return result
    
    def factorial(self, n):
        """階乗（再帰の無限ループバグ）"""
        logger.debug(f"factorial({n}) called")
        
        # バグ4: 終了条件が不完全
        if n == 1:  # n=0の場合を考慮していない
            return 1
        
        return n * self.factorial(n - 1)
    
    def complex_calculation(self, data):
        """複雑な計算（複数のバグ）"""
        logger.debug(f"complex_calculation called with {len(data) if data else 'None'} items")
        
        if not data:
            return 0
        
        total = 0
        for i, value in enumerate(data):
            # バグ5: インデックス境界
            if i < len(data) - 1:
                next_value = data[i + 1]
            else:
                next_value = data[0]  # 循環参照
            
            # バグ6: 型の不一致
            try:
                result = value * next_value / (i + 1)
                total += result
                logger.debug(f"Step {i}: {value} * {next_value} / {i+1} = {result}")
            except Exception as e:
                logger.error(f"Error at step {i}: {e}")
                continue
        
        return total

# ログによるデバッグ
print("=== ログによるデバッグ ===")

def debug_with_logging():
    """ログを使ったデバッグ"""
    calc = BuggyCalculator()
    
    # 正常なケース
    result1 = calc.add(5, 3)
    print(f"5 + 3 = {result1}")
    
    # エラーケース
    try:
        result2 = calc.add("5", 3)  # 型エラー
    except TypeError:
        print("型エラーが発生しました")
    
    # ゼロ除算エラー
    try:
        result3 = calc.divide(10, 0)
    except ZeroDivisionError:
        print("ゼロ除算エラーが発生しました")

debug_with_logging()

# トレースバック解析
print("\n=== トレースバック解析 ===")

def analyze_traceback():
    """トレースバック解析の例"""
    calc = BuggyCalculator()
    
    try:
        result = calc.factorial(0)  # 無限再帰
    except RecursionError:
        print("再帰エラーが発生:")
        exc_type, exc_value, exc_traceback = sys.exc_info()
        
        # トレースバック情報を表示
        print("\nトレースバック詳細:")
        traceback.print_tb(exc_traceback, limit=5)  # 最初の5フレームのみ
        
        # フレーム情報を詳細に調査
        print("\nフレーム情報:")
        frame = exc_traceback.tb_frame
        while frame:
            filename = frame.f_code.co_filename
            line_no = frame.f_lineno
            func_name = frame.f_code.co_name
            
            print(f"  {func_name} at {filename}:{line_no}")
            if func_name == 'factorial':
                local_vars = frame.f_locals
                print(f"    ローカル変数: {local_vars}")
                break
            
            frame = frame.f_back

analyze_traceback()

# カスタムデバッガー
print("\n=== カスタムデバッガー ===")

def debug_decorator(func):
    """デバッグ情報を出力するデコレータ"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        print(f"\n[DEBUG] 関数 {func.__name__} 開始")
        print(f"[DEBUG] 引数: args={args}, kwargs={kwargs}")
        
        start_time = time.time()
        
        try:
            result = func(*args, **kwargs)
            end_time = time.time()
            
            print(f"[DEBUG] 戻り値: {result}")
            print(f"[DEBUG] 実行時間: {end_time - start_time:.4f}秒")
            print(f"[DEBUG] 関数 {func.__name__} 正常終了")
            
            return result
        
        except Exception as e:
            end_time = time.time()
            print(f"[DEBUG] 例外: {type(e).__name__}: {e}")
            print(f"[DEBUG] 実行時間: {end_time - start_time:.4f}秒")
            print(f"[DEBUG] 関数 {func.__name__} 異常終了")
            raise
    
    return wrapper

@debug_decorator
def test_function(x, y, operation='add'):
    """テスト関数"""
    if operation == 'add':
        return x + y
    elif operation == 'divide':
        return x / y
    else:
        raise ValueError(f"不明な操作: {operation}")

# デバッグデコレータのテスト
try:
    result = test_function(10, 5)
    result = test_function(10, 0, 'divide')
except:
    pass

# 変数の監視
print("\n=== 変数の監視 ===")

class DebugVariable:
    """デバッグ用変数ラッパー"""
    
    def __init__(self, value, name="variable"):
        self._value = value
        self._name = name
        self._access_count = 0
        self._modification_count = 0
        print(f"[VAR] {self._name} 初期化: {self._value}")
    
    @property
    def value(self):
        self._access_count += 1
        print(f"[VAR] {self._name} 読み取り #{self._access_count}: {self._value}")
        return self._value
    
    @value.setter
    def value(self, new_value):
        old_value = self._value
        self._value = new_value
        self._modification_count += 1
        print(f"[VAR] {self._name} 更新 #{self._modification_count}: {old_value} -> {new_value}")
    
    def get_stats(self):
        return {
            'access_count': self._access_count,
            'modification_count': self._modification_count,
            'current_value': self._value
        }

# 変数監視のテスト
def variable_monitoring_demo():
    """変数監視のデモ"""
    x = DebugVariable(10, "x")
    y = DebugVariable(20, "y")
    
    # 計算処理
    result = x.value + y.value
    x.value = result
    y.value = x.value * 2
    
    print(f"\n統計情報:")
    print(f"x: {x.get_stats()}")
    print(f"y: {y.get_stats()}")

variable_monitoring_demo()

# プロファイリング
print("\n=== プロファイリング ===")

import cProfile
import pstats
from io import StringIO

def profile_function():
    """プロファイリング対象の関数"""
    # 時間のかかる処理をシミュレート
    total = 0
    for i in range(100000):
        total += i ** 2
    
    # ファイル操作をシミュレート
    data = list(range(1000))
    processed = [x * 2 for x in data if x % 2 == 0]
    
    return total, len(processed)

def run_profiling():
    """プロファイリングの実行"""
    print("プロファイリング実行中...")
    
    # プロファイラーを作成
    profiler = cProfile.Profile()
    
    # プロファイリング開始
    profiler.enable()
    
    # 測定対象の処理
    result = profile_function()
    
    # プロファイリング終了
    profiler.disable()
    
    # 結果を文字列バッファに出力
    s = StringIO()
    ps = pstats.Stats(profiler, stream=s)
    ps.sort_stats('cumulative')
    ps.print_stats(10)  # 上位10関数
    
    print("プロファイリング結果:")
    print(s.getvalue())
    print(f"関数の戻り値: {result}")

run_profiling()

# メモリデバッグ
print("\n=== メモリデバッグ ===")

import gc
import sys

def memory_debugging():
    """メモリデバッグの例"""
    
    # ガベージコレクション前の状態
    print(f"GC前のオブジェクト数: {len(gc.get_objects())}")
    
    # 大量のオブジェクトを作成
    data = []
    for i in range(1000):
        data.append([j for j in range(100)])
    
    print(f"データ作成後のオブジェクト数: {len(gc.get_objects())}")
    print(f"データのメモリ使用量: {sys.getsizeof(data)} bytes")
    
    # 循環参照を作成
    class Node:
        def __init__(self, value):
            self.value = value
            self.children = []
        
        def add_child(self, child):
            child.parent = self
            self.children.append(child)
    
    # 循環参照のあるオブジェクトを作成
    root = Node("root")
    child1 = Node("child1")
    child2 = Node("child2")
    
    root.add_child(child1)
    root.add_child(child2)
    child1.add_child(root)  # 循環参照
    
    print(f"循環参照作成後のオブジェクト数: {len(gc.get_objects())}")
    
    # 参照を削除
    del root, child1, child2, data
    
    # ガベージコレクション実行
    collected = gc.collect()
    print(f"ガベージコレクション: {collected}個回収")
    print(f"GC後のオブジェクト数: {len(gc.get_objects())}")

memory_debugging()

# 実行時アサーション
print("\n=== 実行時アサーション ===")

def runtime_assertions_demo():
    """実行時アサーションのデモ"""
    
    def safe_divide(a, b):
        """安全な除算（アサーション付き）"""
        assert isinstance(a, (int, float)), f"aは数値である必要があります: {type(a)}"
        assert isinstance(b, (int, float)), f"bは数値である必要があります: {type(b)}"
        assert b != 0, "ゼロ除算はできません"
        
        result = a / b
        
        assert result == a / b, "計算結果が一致しません"  # 冗長だが例示用
        
        return result
    
    # 正常ケース
    try:
        result = safe_divide(10, 2)
        print(f"10 / 2 = {result}")
    except AssertionError as e:
        print(f"アサーションエラー: {e}")
    
    # エラーケース
    try:
        result = safe_divide(10, 0)
    except AssertionError as e:
        print(f"アサーションエラー: {e}")
    
    try:
        result = safe_divide("10", 2)
    except AssertionError as e:
        print(f"アサーションエラー: {e}")

runtime_assertions_demo()
```

## 21.5 【実行】継続的インテグレーション

```python
# ci_cd_simulation.py

import json
import subprocess
import os
import tempfile
from pathlib import Path
import time

# CI/CDパイプラインのシミュレーション
class CIPipeline:
    """継続的インテグレーションパイプライン"""
    
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.results = {}
    
    def run_tests(self):
        """テスト実行"""
        print("=== テスト実行 ===")
        
        # Pytestのシミュレーション
        test_results = {
            'total_tests': 25,
            'passed': 23,
            'failed': 2,
            'skipped': 0,
            'duration': 15.3
        }
        
        print(f"テスト実行結果:")
        print(f"  総テスト数: {test_results['total_tests']}")
        print(f"  成功: {test_results['passed']}")
        print(f"  失敗: {test_results['failed']}")
        print(f"  スキップ: {test_results['skipped']}")
        print(f"  実行時間: {test_results['duration']}秒")
        
        self.results['tests'] = test_results
        return test_results['failed'] == 0
    
    def run_linting(self):
        """コード品質チェック"""
        print("\n=== コード品質チェック ===")
        
        # Flake8のシミュレーション
        linting_results = {
            'files_checked': 15,
            'issues': [
                {'file': 'module1.py', 'line': 42, 'issue': 'line too long'},
                {'file': 'module2.py', 'line': 15, 'issue': 'unused import'},
            ],
            'score': 8.5
        }
        
        print(f"コード品質チェック結果:")
        print(f"  チェックファイル数: {linting_results['files_checked']}")
        print(f"  問題数: {len(linting_results['issues'])}")
        print(f"  品質スコア: {linting_results['score']}/10")
        
        for issue in linting_results['issues']:
            print(f"    {issue['file']}:{issue['line']} - {issue['issue']}")
        
        self.results['linting'] = linting_results
        return len(linting_results['issues']) < 5  # 5個未満なら成功
    
    def run_security_scan(self):
        """セキュリティスキャン"""
        print("\n=== セキュリティスキャン ===")
        
        # Banditのシミュレーション
        security_results = {
            'high_severity': 0,
            'medium_severity': 1,
            'low_severity': 3,
            'issues': [
                {'severity': 'medium', 'description': 'hardcoded password'},
                {'severity': 'low', 'description': 'assert used'},
                {'severity': 'low', 'description': 'subprocess without shell=False'},
                {'severity': 'low', 'description': 'use of insecure random'}
            ]
        }
        
        print(f"セキュリティスキャン結果:")
        print(f"  高リスク: {security_results['high_severity']}")
        print(f"  中リスク: {security_results['medium_severity']}")
        print(f"  低リスク: {security_results['low_severity']}")
        
        for issue in security_results['issues']:
            print(f"    [{issue['severity']}] {issue['description']}")
        
        self.results['security'] = security_results
        return security_results['high_severity'] == 0
    
    def run_coverage_analysis(self):
        """カバレッジ解析"""
        print("\n=== カバレッジ解析 ===")
        
        coverage_results = {
            'line_coverage': 85.5,
            'branch_coverage': 78.2,
            'files': {
                'module1.py': 92.3,
                'module2.py': 88.7,
                'module3.py': 76.4,
                'module4.py': 82.1
            }
        }
        
        print(f"カバレッジ解析結果:")
        print(f"  行カバレッジ: {coverage_results['line_coverage']:.1f}%")
        print(f"  分岐カバレッジ: {coverage_results['branch_coverage']:.1f}%")
        
        print(f"  ファイル別カバレッジ:")
        for file, coverage in coverage_results['files'].items():
            status = "✓" if coverage >= 80 else "⚠"
            print(f"    {status} {file}: {coverage:.1f}%")
        
        self.results['coverage'] = coverage_results
        return coverage_results['line_coverage'] >= 80
    
    def build_package(self):
        """パッケージビルド"""
        print("\n=== パッケージビルド ===")
        
        build_results = {
            'success': True,
            'artifacts': [
                'dist/mypackage-1.0.0.tar.gz',
                'dist/mypackage-1.0.0-py3-none-any.whl'
            ],
            'size_mb': 2.3,
            'build_time': 45.2
        }
        
        print(f"ビルド結果:")
        print(f"  ステータス: {'成功' if build_results['success'] else '失敗'}")
        print(f"  生成物:")
        for artifact in build_results['artifacts']:
            print(f"    {artifact}")
        print(f"  サイズ: {build_results['size_mb']}MB")
        print(f"  ビルド時間: {build_results['build_time']}秒")
        
        self.results['build'] = build_results
        return build_results['success']
    
    def deploy_staging(self):
        """ステージング環境へのデプロイ"""
        print("\n=== ステージング環境デプロイ ===")
        
        deploy_results = {
            'environment': 'staging',
            'success': True,
            'url': 'https://staging.myapp.com',
            'deploy_time': 120.5,
            'health_check': True
        }
        
        print(f"デプロイ結果:")
        print(f"  環境: {deploy_results['environment']}")
        print(f"  ステータス: {'成功' if deploy_results['success'] else '失敗'}")
        print(f"  URL: {deploy_results['url']}")
        print(f"  デプロイ時間: {deploy_results['deploy_time']}秒")
        print(f"  ヘルスチェック: {'正常' if deploy_results['health_check'] else '異常'}")
        
        self.results['deploy_staging'] = deploy_results
        return deploy_results['success'] and deploy_results['health_check']
    
    def run_integration_tests(self):
        """統合テスト"""
        print("\n=== 統合テスト ===")
        
        integration_results = {
            'api_tests': {'passed': 15, 'failed': 1},
            'ui_tests': {'passed': 8, 'failed': 0},
            'performance_tests': {'passed': 5, 'failed': 0},
            'total_duration': 180.7
        }
        
        total_passed = sum(test['passed'] for test in integration_results.values() if isinstance(test, dict))
        total_failed = sum(test['failed'] for test in integration_results.values() if isinstance(test, dict))
        
        print(f"統合テスト結果:")
        print(f"  API テスト: {integration_results['api_tests']['passed']}成功, {integration_results['api_tests']['failed']}失敗")
        print(f"  UI テスト: {integration_results['ui_tests']['passed']}成功, {integration_results['ui_tests']['failed']}失敗")
        print(f"  性能テスト: {integration_results['performance_tests']['passed']}成功, {integration_results['performance_tests']['failed']}失敗")
        print(f"  総計: {total_passed}成功, {total_failed}失敗")
        print(f"  実行時間: {integration_results['total_duration']}秒")
        
        self.results['integration_tests'] = integration_results
        return total_failed == 0
    
    def generate_report(self):
        """レポート生成"""
        print("\n=== CI/CDレポート ===")
        
        report = {
            'timestamp': time.time(),
            'overall_status': all([
                self.results.get('tests', {}).get('failed', 1) == 0,
                self.results.get('linting', {}).get('score', 0) >= 8,
                self.results.get('security', {}).get('high_severity', 1) == 0,
                self.results.get('coverage', {}).get('line_coverage', 0) >= 80,
                self.results.get('build', {}).get('success', False),
                self.results.get('deploy_staging', {}).get('success', False),
                self.results.get('integration_tests', {}).get('api_tests', {}).get('failed', 1) == 0
            ]),
            'stages': self.results
        }
        
        status = "成功" if report['overall_status'] else "失敗"
        print(f"全体ステータス: {status}")
        
        # 各ステージの結果
        print("\nステージ別結果:")
        stage_names = {
            'tests': 'ユニットテスト',
            'linting': 'コード品質',
            'security': 'セキュリティ',
            'coverage': 'カバレッジ',
            'build': 'ビルド',
            'deploy_staging': 'ステージングデプロイ',
            'integration_tests': '統合テスト'
        }
        
        for stage, name in stage_names.items():
            if stage in self.results:
                status_icon = "✓" if self._is_stage_successful(stage) else "✗"
                print(f"  {status_icon} {name}")
        
        return report
    
    def _is_stage_successful(self, stage):
        """ステージの成功判定"""
        if stage == 'tests':
            return self.results[stage]['failed'] == 0
        elif stage == 'linting':
            return len(self.results[stage]['issues']) < 5
        elif stage == 'security':
            return self.results[stage]['high_severity'] == 0
        elif stage == 'coverage':
            return self.results[stage]['line_coverage'] >= 80
        elif stage == 'build':
            return self.results[stage]['success']
        elif stage == 'deploy_staging':
            return self.results[stage]['success'] and self.results[stage]['health_check']
        elif stage == 'integration_tests':
            return sum(test['failed'] for test in self.results[stage].values() if isinstance(test, dict)) == 0
        return False
    
    def run_pipeline(self):
        """パイプライン全体の実行"""
        print("CI/CDパイプライン開始\n")
        
        stages = [
            ('テスト実行', self.run_tests),
            ('コード品質チェック', self.run_linting),
            ('セキュリティスキャン', self.run_security_scan),
            ('カバレッジ解析', self.run_coverage_analysis),
            ('パッケージビルド', self.build_package),
            ('ステージングデプロイ', self.deploy_staging),
            ('統合テスト', self.run_integration_tests)
        ]
        
        for stage_name, stage_func in stages:
            print(f"\n{'='*50}")
            print(f"ステージ: {stage_name}")
            print('='*50)
            
            success = stage_func()
            
            if not success:
                print(f"\n❌ ステージ '{stage_name}' が失敗しました。パイプラインを停止します。")
                break
            else:
                print(f"\n✅ ステージ '{stage_name}' が成功しました。")
        
        # 最終レポート
        return self.generate_report()

# GitHub Actions風の設定ファイル生成
def generate_github_actions_config():
    """GitHub Actions設定ファイルの生成"""
    
    config = {
        'name': 'CI/CD Pipeline',
        'on': {
            'push': {'branches': ['main', 'develop']},
            'pull_request': {'branches': ['main']}
        },
        'jobs': {
            'test': {
                'runs-on': 'ubuntu-latest',
                'strategy': {
                    'matrix': {
                        'python-version': ['3.8', '3.9', '3.10', '3.11']
                    }
                },
                'steps': [
                    {'uses': 'actions/checkout@v3'},
                    {
                        'name': 'Set up Python',
                        'uses': 'actions/setup-python@v4',
                        'with': {'python-version': '${{ matrix.python-version }}'}
                    },
                    {
                        'name': 'Install dependencies',
                        'run': 'pip install -r requirements.txt'
                    },
                    {
                        'name': 'Run tests',
                        'run': 'pytest --cov=src --cov-report=xml'
                    },
                    {
                        'name': 'Upload coverage',
                        'uses': 'codecov/codecov-action@v3'
                    }
                ]
            },
            'lint': {
                'runs-on': 'ubuntu-latest',
                'steps': [
                    {'uses': 'actions/checkout@v3'},
                    {
                        'name': 'Set up Python',
                        'uses': 'actions/setup-python@v4',
                        'with': {'python-version': '3.10'}
                    },
                    {
                        'name': 'Install linting tools',
                        'run': 'pip install flake8 black isort'
                    },
                    {
                        'name': 'Run linting',
                        'run': 'flake8 src/ && black --check src/ && isort --check-only src/'
                    }
                ]
            },
            'security': {
                'runs-on': 'ubuntu-latest',
                'steps': [
                    {'uses': 'actions/checkout@v3'},
                    {
                        'name': 'Run security scan',
                        'uses': 'PyCQA/bandit-action@v1'
                    }
                ]
            }
        }
    }
    
    print("=== GitHub Actions設定ファイル (.github/workflows/ci.yml) ===")
    import yaml
    try:
        print(yaml.dump(config, default_flow_style=False, allow_unicode=True))
    except ImportError:
        print(json.dumps(config, indent=2, ensure_ascii=False))

# パイプライン実行のシミュレーション
def run_ci_simulation():
    """CI/CDシミュレーションの実行"""
    
    # 一時プロジェクトディレクトリ
    with tempfile.TemporaryDirectory() as temp_dir:
        pipeline = CIPipeline(temp_dir)
        
        # パイプライン実行
        report = pipeline.run_pipeline()
        
        # 結果の保存
        report_file = Path(temp_dir) / "ci_report.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📋 CI/CDレポートを保存しました: {report_file}")
        
        return report

# 実行
if __name__ == "__main__":
    # CI/CDパイプラインのシミュレーション
    report = run_ci_simulation()
    
    # GitHub Actions設定の例
    print("\n" + "="*80)
    generate_github_actions_config()
```

## 21.6 この章のまとめ

- ユニットテストで個別の機能を検証し、バグを早期発見する
- pytestフレームワークで効率的なテストを作成できる
- モックとスタブで外部依存を排除したテストが可能
- ログ、デバッガー、プロファイラーで効果的にデバッグできる
- 継続的インテグレーションで品質を継続的に保証する
- テスト駆動開発で設計品質も向上させられる

## 練習問題

1. **テスト自動化スイート**
   複数の種類のテスト（ユニット、統合、E2E）を自動実行するスイートを作成してください。

2. **カスタムアサーション**
   ドメイン固有のカスタムアサーション関数を実装してください。

3. **性能テストフレームワーク**
   アプリケーションの性能を継続的に監視するテストフレームワークを作成してください。

4. **モックライブラリ**
   特定のシステム（データベース、API）に特化したモックライブラリを実装してください。

5. **デバッグダッシュボード**
   アプリケーションの実行状態をリアルタイムで監視するダッシュボードを作成してください。

---

次章では、本書の総まとめを行います。

[第22章 まとめと発展的な学習 →](chapter22.md)