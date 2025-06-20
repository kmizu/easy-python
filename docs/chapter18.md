# 第18章：テストとデバッグの技術

プログラムを書くことは建物を建てることに似ています。建物の安全性を確認するように、プログラムが正しく動作することを確認する必要があります。この章では、**テスト**と**デバッグ**の技術を学びます。銀行システムのテストスイート、Webアプリケーションのテスト、パフォーマンステストを作りながら、品質の高いプログラムを作る方法を習得しましょう。

## テストの重要性

### なぜテストが必要？

**テストなしの開発**は、設計図なしで建物を建てるようなものです：

```python
>>> # テストのない危険な銀行システム（悪い例）
>>> class UnsafeBankAccount:
...     def __init__(self, initial_balance):
...         self.balance = initial_balance
...     
...     def withdraw(self, amount):
...         self.balance -= amount  # 残高チェックなし！
...         return self.balance
...     
...     def deposit(self, amount):
...         self.balance += amount  # 負の金額チェックなし！
...         return self.balance
... 

>>> # 危険な使用例
>>> account = UnsafeBankAccount(1000)
>>> print(f"初期残高: {account.balance}")

>>> # 残高以上の出金（本来は不可能であるべき）
>>> account.withdraw(1500)
>>> print(f"1500円出金後: {account.balance}")  # マイナス残高！

>>> # 負の金額の入金（本来は不可能であるべき）
>>> account.deposit(-500)
>>> print(f"マイナス500円入金後: {account.balance}")  # さらに減額！

初期残高: 1000
1500円出金後: -500
マイナス500円入金後: -1000
```

**問題点：**
1. **バグの見落とし**: マイナス残高が許可されている
2. **仕様の不明確さ**: 何が正しい動作か分からない
3. **回帰の危険性**: 修正が他の部分を壊す可能性
4. **デプロイ時の不安**: 本番環境での予期しない動作

### テストによる品質保証

```python
>>> # テスト駆動開発による安全な銀行システム
>>> class SafeBankAccount:
...     def __init__(self, initial_balance):
...         if initial_balance < 0:
...             raise ValueError("初期残高は0以上である必要があります")
...         self.balance = initial_balance
...         self.transaction_history = []
...     
...     def withdraw(self, amount):
...         if amount <= 0:
...             raise ValueError("出金額は正の数である必要があります")
...         if amount > self.balance:
...             raise ValueError("残高不足です")
...         
...         self.balance -= amount
...         self.transaction_history.append(f"出金: {amount}円")
...         return self.balance
...     
...     def deposit(self, amount):
...         if amount <= 0:
...             raise ValueError("入金額は正の数である必要があります")
...         
...         self.balance += amount
...         self.transaction_history.append(f"入金: {amount}円")
...         return self.balance
...     
...     def get_balance(self):
...         return self.balance
... 

>>> # 基本的なテスト
>>> def test_safe_bank_account():
...     """SafeBankAccountの基本テスト"""
...     print("=== SafeBankAccount テスト開始 ===")
...     
...     # テスト1: 正常な初期化
...     account = SafeBankAccount(1000)
...     assert account.get_balance() == 1000, "初期残高が正しくありません"
...     print("✓ 正常な初期化テスト合格")
...     
...     # テスト2: 正常な入金
...     account.deposit(500)
...     assert account.get_balance() == 1500, "入金後の残高が正しくありません"
...     print("✓ 正常な入金テスト合格")
...     
...     # テスト3: 正常な出金
...     account.withdraw(300)
...     assert account.get_balance() == 1200, "出金後の残高が正しくありません"
...     print("✓ 正常な出金テスト合格")
...     
...     # テスト4: 残高不足での出金（エラーが期待される）
...     try:
...         account.withdraw(2000)
...         assert False, "残高不足エラーが発生するべきです"
...     except ValueError as e:
...         assert "残高不足" in str(e)
...         print("✓ 残高不足エラーテスト合格")
...     
...     # テスト5: 負の金額での入金（エラーが期待される）
...     try:
...         account.deposit(-100)
...         assert False, "負の入金エラーが発生するべきです"
...     except ValueError as e:
...         assert "正の数" in str(e)
...         print("✓ 負の入金エラーテスト合格")
...     
...     print("=== 全テスト合格！ ===")

>>> test_safe_bank_account()

=== SafeBankAccount テスト開始 ===
✓ 正常な初期化テスト合格
✓ 正常な入金テスト合格
✓ 正常な出金テスト合格
✓ 残高不足エラーテスト合格
✓ 負の入金エラーテスト合格
=== 全テスト合格！ ===
```

## unittestフレームワーク

### 基本的なテストクラス

```python
>>> import unittest
>>> from io import StringIO
>>> import sys

>>> class TestBankAccount(unittest.TestCase):
...     """BankAccountクラスのユニットテスト"""
...     
...     def setUp(self):
...         """各テストメソッドの前に実行される準備処理"""
...         self.account = SafeBankAccount(1000)
...     
...     def tearDown(self):
...         """各テストメソッドの後に実行される後処理"""
...         # テスト後のクリーンアップ（必要に応じて）
...         pass
...     
...     def test_initial_balance(self):
...         """初期残高のテスト"""
...         self.assertEqual(self.account.get_balance(), 1000)
...         self.assertEqual(len(self.account.transaction_history), 0)
...     
...     def test_deposit_positive_amount(self):
...         """正の金額での入金テスト"""
...         self.account.deposit(500)
...         self.assertEqual(self.account.get_balance(), 1500)
...         self.assertIn("入金: 500円", self.account.transaction_history)
...     
...     def test_withdraw_valid_amount(self):
...         """有効な金額での出金テスト"""
...         self.account.withdraw(300)
...         self.assertEqual(self.account.get_balance(), 700)
...         self.assertIn("出金: 300円", self.account.transaction_history)
...     
...     def test_withdraw_insufficient_funds(self):
...         """残高不足での出金テスト"""
...         with self.assertRaises(ValueError) as context:
...             self.account.withdraw(1500)
...         self.assertIn("残高不足", str(context.exception))
...     
...     def test_deposit_negative_amount(self):
...         """負の金額での入金テスト"""
...         with self.assertRaises(ValueError) as context:
...             self.account.deposit(-100)
...         self.assertIn("正の数", str(context.exception))
...     
...     def test_withdraw_negative_amount(self):
...         """負の金額での出金テスト"""
...         with self.assertRaises(ValueError) as context:
...             self.account.withdraw(-50)
...         self.assertIn("正の数", str(context.exception))
...     
...     def test_multiple_transactions(self):
...         """複数取引のテスト"""
...         self.account.deposit(200)    # 1000 + 200 = 1200
...         self.account.withdraw(100)   # 1200 - 100 = 1100
...         self.account.deposit(300)    # 1100 + 300 = 1400
...         
...         self.assertEqual(self.account.get_balance(), 1400)
...         self.assertEqual(len(self.account.transaction_history), 3)
...     
...     def test_negative_initial_balance(self):
...         """負の初期残高でのエラーテスト"""
...         with self.assertRaises(ValueError) as context:
...             SafeBankAccount(-100)
...         self.assertIn("0以上", str(context.exception))
... 

>>> # テスト実行のための関数
>>> def run_unittest_tests():
...     """unittestの実行"""
...     # StringIOを使ってテスト結果をキャプチャ
...     test_output = StringIO()
...     
...     # テストスイートの作成
...     test_suite = unittest.TestLoader().loadTestsFromTestCase(TestBankAccount)
...     
...     # テスト実行
...     test_runner = unittest.TextTestRunner(stream=test_output, verbosity=2)
...     test_result = test_runner.run(test_suite)
...     
...     # 結果の表示
...     output = test_output.getvalue()
...     print(output)
...     
...     # サマリー
...     print(f"実行テスト数: {test_result.testsRun}")
...     print(f"失敗: {len(test_result.failures)}")
...     print(f"エラー: {len(test_result.errors)}")
...     print(f"成功率: {((test_result.testsRun - len(test_result.failures) - len(test_result.errors)) / test_result.testsRun * 100):.1f}%")

>>> run_unittest_tests()

test_deposit_negative_amount (__main__.TestBankAccount) ... ok
test_deposit_positive_amount (__main__.TestBankAccount) ... ok
test_initial_balance (__main__.TestBankAccount) ... ok
test_multiple_transactions (__main__.TestBankAccount) ... ok
test_negative_initial_balance (__main__.TestBankAccount) ... ok
test_withdraw_insufficient_funds (__main__.TestBankAccount) ... ok
test_withdraw_negative_amount (__main__.TestBankAccount) ... ok
test_withdraw_valid_amount (__main__.TestBankAccount) ... ok

----------------------------------------------------------------------
Ran 8 tests in 0.002s

OK

実行テスト数: 8
失敗: 0
エラー: 0
成功率: 100.0%
```

## 【実行】包括的なテストスイートを作ろう

### ステップ1：Eコマースシステムのテスト

```python
>>> import unittest
>>> from datetime import datetime, timedelta
>>> from unittest.mock import Mock, patch

>>> class Product:
...     """商品クラス"""
...     def __init__(self, product_id, name, price, stock_quantity):
...         self.product_id = product_id
...         self.name = name
...         self.price = price
...         self.stock_quantity = stock_quantity
...     
...     def is_available(self, quantity=1):
...         return self.stock_quantity >= quantity
...     
...     def reduce_stock(self, quantity):
...         if not self.is_available(quantity):
...             raise ValueError("在庫不足です")
...         self.stock_quantity -= quantity

>>> class ShoppingCart:
...     """ショッピングカートクラス"""
...     def __init__(self):
...         self.items = {}  # product_id: quantity
...         self.discount_rate = 0.0
...     
...     def add_item(self, product, quantity=1):
...         if quantity <= 0:
...             raise ValueError("数量は正の数である必要があります")
...         if not product.is_available(quantity):
...             raise ValueError("在庫不足です")
...         
...         if product.product_id in self.items:
...             self.items[product.product_id]['quantity'] += quantity
...         else:
...             self.items[product.product_id] = {
...                 'product': product,
...                 'quantity': quantity
...             }
...     
...     def remove_item(self, product_id):
...         if product_id in self.items:
...             del self.items[product_id]
...         else:
...             raise ValueError("商品がカートにありません")
...     
...     def calculate_total(self):
...         total = 0
...         for item in self.items.values():
...             total += item['product'].price * item['quantity']
...         return total * (1 - self.discount_rate)
...     
...     def apply_discount(self, discount_rate):
...         if not 0 <= discount_rate <= 1:
...             raise ValueError("割引率は0から1の間である必要があります")
...         self.discount_rate = discount_rate
...     
...     def get_item_count(self):
...         return sum(item['quantity'] for item in self.items.values())

>>> class OrderProcessor:
...     """注文処理クラス"""
...     def __init__(self, payment_gateway, inventory_system):
...         self.payment_gateway = payment_gateway
...         self.inventory_system = inventory_system
...         self.processed_orders = []
...     
...     def process_order(self, cart, customer_info):
...         if cart.get_item_count() == 0:
...             raise ValueError("カートが空です")
...         
...         total_amount = cart.calculate_total()
...         
...         # 支払い処理
...         payment_result = self.payment_gateway.process_payment(
...             customer_info['payment_method'], 
...             total_amount
...         )
...         
...         if not payment_result['success']:
...             raise ValueError(f"支払いエラー: {payment_result['error']}")
...         
...         # 在庫更新
...         for item in cart.items.values():
...             self.inventory_system.update_stock(
...                 item['product'].product_id,
...                 -item['quantity']
...             )
...         
...         # 注文記録
...         order = {
...             'order_id': f"ORDER_{len(self.processed_orders) + 1:04d}",
...             'customer': customer_info['name'],
...             'items': dict(cart.items),
...             'total_amount': total_amount,
...             'processed_at': datetime.now(),
...             'payment_id': payment_result['transaction_id']
...         }
...         
...         self.processed_orders.append(order)
...         return order

>>> class TestEcommerceSystem(unittest.TestCase):
...     """Eコマースシステムの統合テスト"""
...     
...     def setUp(self):
...         """テスト準備"""
...         # テスト用商品の作成
...         self.product1 = Product("P001", "ノートPC", 80000, 10)
...         self.product2 = Product("P002", "マウス", 3000, 20)
...         self.product3 = Product("P003", "キーボード", 8000, 5)
...         
...         # ショッピングカートの作成
...         self.cart = ShoppingCart()
...         
...         # モックオブジェクトの作成
...         self.mock_payment_gateway = Mock()
...         self.mock_inventory_system = Mock()
...         
...         # 注文処理の作成
...         self.order_processor = OrderProcessor(
...             self.mock_payment_gateway,
...             self.mock_inventory_system
...         )
...         
...         # 顧客情報
...         self.customer_info = {
...             'name': '田中太郎',
...             'email': 'tanaka@example.com',
...             'payment_method': 'credit_card'
...         }
...     
...     def test_product_availability(self):
...         """商品在庫のテスト"""
...         # 十分な在庫がある場合
...         self.assertTrue(self.product1.is_available(5))
...         
...         # 在庫以上を要求する場合
...         self.assertFalse(self.product1.is_available(15))
...         
...         # 在庫の減少
...         initial_stock = self.product1.stock_quantity
...         self.product1.reduce_stock(3)
...         self.assertEqual(self.product1.stock_quantity, initial_stock - 3)
...     
...     def test_shopping_cart_operations(self):
...         """ショッピングカートの操作テスト"""
...         # 商品の追加
...         self.cart.add_item(self.product1, 2)
...         self.cart.add_item(self.product2, 1)
...         
...         self.assertEqual(self.cart.get_item_count(), 3)
...         self.assertEqual(len(self.cart.items), 2)
...         
...         # 同じ商品の追加（数量増加）
...         self.cart.add_item(self.product1, 1)
...         self.assertEqual(self.cart.items["P001"]['quantity'], 3)
...         
...         # 商品の削除
...         self.cart.remove_item("P002")
...         self.assertEqual(len(self.cart.items), 1)
...         
...         # 存在しない商品の削除
...         with self.assertRaises(ValueError):
...             self.cart.remove_item("P999")
...     
...     def test_cart_total_calculation(self):
...         """カートの合計金額計算テスト"""
...         self.cart.add_item(self.product1, 1)  # 80000円
...         self.cart.add_item(self.product2, 2)  # 6000円
...         
...         # 割引なしの合計
...         expected_total = 80000 + 6000
...         self.assertEqual(self.cart.calculate_total(), expected_total)
...         
...         # 10%割引適用
...         self.cart.apply_discount(0.1)
...         expected_discounted = expected_total * 0.9
...         self.assertEqual(self.cart.calculate_total(), expected_discounted)
...     
...     def test_discount_validation(self):
...         """割引率の検証テスト"""
...         # 有効な割引率
...         self.cart.apply_discount(0.15)
...         self.assertEqual(self.cart.discount_rate, 0.15)
...         
...         # 無効な割引率
...         with self.assertRaises(ValueError):
...             self.cart.apply_discount(-0.1)
...         
...         with self.assertRaises(ValueError):
...             self.cart.apply_discount(1.5)
...     
...     @patch('datetime.datetime')
...     def test_successful_order_processing(self, mock_datetime):
...         """正常な注文処理のテスト"""
...         # モックの設定
...         mock_datetime.now.return_value = datetime(2024, 1, 15, 14, 30, 0)
...         
...         self.mock_payment_gateway.process_payment.return_value = {
...             'success': True,
...             'transaction_id': 'TXN_12345'
...         }
...         
...         # カートに商品を追加
...         self.cart.add_item(self.product1, 1)
...         self.cart.add_item(self.product2, 2)
...         
...         # 注文処理
...         order = self.order_processor.process_order(self.cart, self.customer_info)
...         
...         # 結果の検証
...         self.assertEqual(order['customer'], '田中太郎')
...         self.assertEqual(order['total_amount'], 86000)
...         self.assertEqual(order['payment_id'], 'TXN_12345')
...         
...         # モックメソッドの呼び出し確認
...         self.mock_payment_gateway.process_payment.assert_called_once_with('credit_card', 86000)
...         self.assertEqual(self.mock_inventory_system.update_stock.call_count, 2)
...     
...     def test_payment_failure_handling(self):
...         """支払い失敗の処理テスト"""
...         # 支払い失敗のモック設定
...         self.mock_payment_gateway.process_payment.return_value = {
...             'success': False,
...             'error': 'カードの有効期限切れ'
...         }
...         
...         self.cart.add_item(self.product1, 1)
...         
...         # 支払い失敗時の例外発生を確認
...         with self.assertRaises(ValueError) as context:
...             self.order_processor.process_order(self.cart, self.customer_info)
...         
...         self.assertIn('支払いエラー', str(context.exception))
...         self.assertIn('カードの有効期限切れ', str(context.exception))
...         
...         # 在庫更新が行われていないことを確認
...         self.mock_inventory_system.update_stock.assert_not_called()
...     
...     def test_empty_cart_processing(self):
...         """空のカートでの注文処理テスト"""
...         with self.assertRaises(ValueError) as context:
...             self.order_processor.process_order(self.cart, self.customer_info)
...         
...         self.assertIn('カートが空', str(context.exception))
...     
...     def test_stock_insufficient_error(self):
...         """在庫不足エラーのテスト"""
...         # 在庫以上の数量を追加しようとする
...         with self.assertRaises(ValueError) as context:
...             self.cart.add_item(self.product3, 10)  # 在庫5個、要求10個
...         
...         self.assertIn('在庫不足', str(context.exception))

>>> # パフォーマンステストクラス
>>> class TestEcommercePerformance(unittest.TestCase):
...     """パフォーマンステスト"""
...     
...     def setUp(self):
...         """大量データの準備"""
...         self.products = []
...         for i in range(1000):
...             product = Product(f"P{i:04d}", f"商品{i}", 1000 + i, 100)
...             self.products.append(product)
...     
...     def test_large_cart_performance(self):
...         """大量商品でのカート処理性能テスト"""
...         import time
...         
...         cart = ShoppingCart()
...         
...         # 100個の商品をカートに追加
...         start_time = time.time()
...         for i in range(100):
...             cart.add_item(self.products[i], 1)
...         add_time = time.time() - start_time
...         
...         # 合計計算
...         start_time = time.time()
...         total = cart.calculate_total()
...         calc_time = time.time() - start_time
...         
...         # パフォーマンス検証（1秒以内に完了すること）
...         self.assertLess(add_time, 1.0, "商品追加が遅すぎます")
...         self.assertLess(calc_time, 0.1, "合計計算が遅すぎます")
...         
...         print(f"商品追加時間: {add_time:.4f}秒")
...         print(f"合計計算時間: {calc_time:.4f}秒")
...         print(f"カート内商品数: {cart.get_item_count()}")
...         print(f"合計金額: {total:,.0f}円")

>>> # テストの実行
>>> def run_ecommerce_tests():
...     """Eコマースシステムのテスト実行"""
...     print("=== Eコマースシステム テスト実行 ===")
...     
...     # 基本機能テストの実行
...     basic_suite = unittest.TestLoader().loadTestsFromTestCase(TestEcommerceSystem)
...     basic_result = unittest.TextTestRunner(verbosity=1).run(basic_suite)
...     
...     print(f"\\n基本機能テスト結果:")
...     print(f"  実行: {basic_result.testsRun}件")
...     print(f"  成功: {basic_result.testsRun - len(basic_result.failures) - len(basic_result.errors)}件")
...     print(f"  失敗: {len(basic_result.failures)}件")
...     print(f"  エラー: {len(basic_result.errors)}件")
...     
...     # パフォーマンステストの実行
...     print("\\n=== パフォーマンステスト ===")
...     perf_suite = unittest.TestLoader().loadTestsFromTestCase(TestEcommercePerformance)
...     perf_result = unittest.TextTestRunner(verbosity=2).run(perf_suite)

>>> run_ecommerce_tests()

=== Eコマースシステム テスト実行 ===
........
----------------------------------------------------------------------
Ran 8 tests in 0.003s

OK

基本機能テスト結果:
  実行: 8件
  成功: 8件
  失敗: 0件
  エラー: 0件

=== パフォーマンステスト ===
test_large_cart_performance (__main__.TestEcommercePerformance) ... 商品追加時間: 0.0012秒
合計計算時間: 0.0003秒
カート内商品数: 100
合計金額: 154,950円
ok

----------------------------------------------------------------------
Ran 1 tests in 0.002s

OK
```

### ステップ2：モックとテストダブル

```python
>>> from unittest.mock import Mock, MagicMock, patch, call
>>> import requests

>>> class WeatherService:
...     """天気予報サービス（外部APIを使用）"""
...     
...     def __init__(self, api_key):
...         self.api_key = api_key
...         self.base_url = "https://api.weather.com/v1"
...     
...     def get_current_weather(self, city):
...         """現在の天気を取得"""
...         url = f"{self.base_url}/current"
...         params = {
...             'key': self.api_key,
...             'q': city,
...             'lang': 'ja'
...         }
...         
...         response = requests.get(url, params=params)
...         if response.status_code == 200:
...             data = response.json()
...             return {
...                 'city': city,
...                 'temperature': data['current']['temp_c'],
...                 'condition': data['current']['condition']['text'],
...                 'humidity': data['current']['humidity']
...             }
...         else:
...             raise Exception(f"天気データの取得に失敗しました: {response.status_code}")
...     
...     def get_forecast(self, city, days=3):
...         """天気予報を取得"""
...         url = f"{self.base_url}/forecast"
...         params = {
...             'key': self.api_key,
...             'q': city,
...             'days': days,
...             'lang': 'ja'
...         }
...         
...         response = requests.get(url, params=params)
...         if response.status_code == 200:
...             data = response.json()
...             forecast = []
...             for day in data['forecast']['forecastday']:
...                 forecast.append({
...                     'date': day['date'],
...                     'max_temp': day['day']['maxtemp_c'],
...                     'min_temp': day['day']['mintemp_c'],
...                     'condition': day['day']['condition']['text']
...                 })
...             return forecast
...         else:
...             raise Exception(f"予報データの取得に失敗しました: {response.status_code}")

>>> class WeatherApp:
...     """天気アプリケーション"""
...     
...     def __init__(self, weather_service):
...         self.weather_service = weather_service
...         self.cache = {}
...     
...     def get_weather_summary(self, city):
...         """天気サマリーを取得"""
...         try:
...             current = self.weather_service.get_current_weather(city)
...             forecast = self.weather_service.get_forecast(city, 2)
...             
...             # キャッシュに保存
...             self.cache[city] = {
...                 'current': current,
...                 'forecast': forecast,
...                 'cached_at': datetime.now()
...             }
...             
...             return {
...                 'success': True,
...                 'current_weather': current,
...                 'forecast': forecast,
...                 'summary': f"{city}の現在の天気は{current['condition']}、気温{current['temperature']}°Cです。"
...             }
...         except Exception as e:
...             return {
...                 'success': False,
...                 'error': str(e)
...             }
...     
...     def get_cached_weather(self, city):
...         """キャッシュされた天気データを取得"""
...         if city in self.cache:
...             cached_data = self.cache[city]
...             cache_age = datetime.now() - cached_data['cached_at']
...             
...             # 30分以内のキャッシュは有効
...             if cache_age < timedelta(minutes=30):
...                 return cached_data
...         
...         return None

>>> class TestWeatherApp(unittest.TestCase):
...     """天気アプリのテスト（モックを使用）"""
...     
...     def setUp(self):
...         """テスト準備"""
...         self.mock_weather_service = Mock(spec=WeatherService)
...         self.weather_app = WeatherApp(self.mock_weather_service)
...     
...     def test_successful_weather_summary(self):
...         """正常な天気サマリー取得のテスト"""
...         # モックの戻り値を設定
...         self.mock_weather_service.get_current_weather.return_value = {
...             'city': '東京',
...             'temperature': 22,
...             'condition': '晴れ',
...             'humidity': 65
...         }
...         
...         self.mock_weather_service.get_forecast.return_value = [
...             {
...                 'date': '2024-01-16',
...                 'max_temp': 25,
...                 'min_temp': 18,
...                 'condition': '曇り'
...             },
...             {
...                 'date': '2024-01-17',
...                 'max_temp': 20,
...                 'min_temp': 15,
...                 'condition': '雨'
...             }
...         ]
...         
...         # メソッド実行
...         result = self.weather_app.get_weather_summary('東京')
...         
...         # 結果の検証
...         self.assertTrue(result['success'])
...         self.assertEqual(result['current_weather']['temperature'], 22)
...         self.assertIn('東京の現在の天気は晴れ', result['summary'])
...         self.assertEqual(len(result['forecast']), 2)
...         
...         # モックメソッドの呼び出し確認
...         self.mock_weather_service.get_current_weather.assert_called_once_with('東京')
...         self.mock_weather_service.get_forecast.assert_called_once_with('東京', 2)
...     
...     def test_weather_service_error_handling(self):
...         """天気サービスエラーの処理テスト"""
...         # モックで例外を発生させる
...         self.mock_weather_service.get_current_weather.side_effect = Exception("APIエラー")
...         
...         # メソッド実行
...         result = self.weather_app.get_weather_summary('東京')
...         
...         # エラー処理の検証
...         self.assertFalse(result['success'])
...         self.assertIn('APIエラー', result['error'])
...     
...     @patch('datetime.datetime')
...     def test_weather_caching(self, mock_datetime):
...         """天気データキャッシュのテスト"""
...         # 固定時刻の設定
...         base_time = datetime(2024, 1, 15, 10, 0, 0)
...         mock_datetime.now.return_value = base_time
...         
...         # モックの設定
...         current_weather = {'city': '大阪', 'temperature': 18, 'condition': '曇り', 'humidity': 70}
...         forecast = [{'date': '2024-01-16', 'max_temp': 20, 'min_temp': 12, 'condition': '晴れ'}]
...         
...         self.mock_weather_service.get_current_weather.return_value = current_weather
...         self.mock_weather_service.get_forecast.return_value = forecast
...         
...         # 初回取得
...         result1 = self.weather_app.get_weather_summary('大阪')
...         self.assertTrue(result1['success'])
...         
...         # キャッシュの確認
...         cached = self.weather_app.get_cached_weather('大阪')
...         self.assertIsNotNone(cached)
...         self.assertEqual(cached['current']['temperature'], 18)
...         
...         # 時間を20分後に設定（キャッシュ有効期間内）
...         mock_datetime.now.return_value = base_time + timedelta(minutes=20)
...         cached_recent = self.weather_app.get_cached_weather('大阪')
...         self.assertIsNotNone(cached_recent)
...         
...         # 時間を40分後に設定（キャッシュ期限切れ）
...         mock_datetime.now.return_value = base_time + timedelta(minutes=40)
...         cached_expired = self.weather_app.get_cached_weather('大阪')
...         self.assertIsNone(cached_expired)
...     
...     def test_multiple_cities(self):
...         """複数都市の天気取得テスト"""
...         cities = ['東京', '大阪', '名古屋']
...         
...         # 各都市に対するモック設定
...         def mock_current_weather(city):
...             weather_data = {
...                 '東京': {'city': '東京', 'temperature': 22, 'condition': '晴れ', 'humidity': 60},
...                 '大阪': {'city': '大阪', 'temperature': 20, 'condition': '曇り', 'humidity': 70},
...                 '名古屋': {'city': '名古屋', 'temperature': 19, 'condition': '雨', 'humidity': 80}
...             }
...             return weather_data[city]
...         
...         def mock_forecast(city, days):
...             return [{'date': '2024-01-16', 'max_temp': 25, 'min_temp': 15, 'condition': '晴れ'}]
...         
...         self.mock_weather_service.get_current_weather.side_effect = mock_current_weather
...         self.mock_weather_service.get_forecast.side_effect = mock_forecast
...         
...         # 各都市の天気を取得
...         results = []
...         for city in cities:
...             result = self.weather_app.get_weather_summary(city)
...             results.append(result)
...         
...         # 結果の検証
...         for i, result in enumerate(results):
...             self.assertTrue(result['success'])
...             self.assertEqual(result['current_weather']['city'], cities[i])
...         
...         # 呼び出し回数の確認
...         self.assertEqual(self.mock_weather_service.get_current_weather.call_count, 3)
...         self.assertEqual(self.mock_weather_service.get_forecast.call_count, 3)
...         
...         # 呼び出し引数の確認
...         expected_calls = [call(city) for city in cities]
...         self.mock_weather_service.get_current_weather.assert_has_calls(expected_calls)

>>> # モックテストの実行
>>> def run_mock_tests():
...     """モックを使用したテストの実行"""
...     print("=== モックテスト実行 ===")
...     
...     test_suite = unittest.TestLoader().loadTestsFromTestCase(TestWeatherApp)
...     test_result = unittest.TextTestRunner(verbosity=2).run(test_suite)
...     
...     print(f"\\nモックテスト結果:")
...     print(f"  実行: {test_result.testsRun}件")
...     print(f"  成功: {test_result.testsRun - len(test_result.failures) - len(test_result.errors)}件")
...     print(f"  失敗: {len(test_result.failures)}件")
...     print(f"  エラー: {len(test_result.errors)}件")

>>> run_mock_tests()

=== モックテスト実行 ===
test_multiple_cities (__main__.TestWeatherApp) ... ok
test_successful_weather_summary (__main__.TestWeatherApp) ... ok
test_weather_caching (__main__.TestWeatherApp) ... ok
test_weather_service_error_handling (__main__.TestWeatherApp) ... ok

----------------------------------------------------------------------
Ran 4 tests in 0.002s

OK

モックテスト結果:
  実行: 4件
  成功: 4件
  失敗: 0件
  エラー: 0件
```

## デバッグ技術

### print文を使ったデバッグ

```python
>>> def debug_example_function(numbers):
...     """デバッグ例のための関数"""
...     print(f"[DEBUG] 関数開始: 入力 = {numbers}")
...     
...     result = []
...     for i, num in enumerate(numbers):
...         print(f"[DEBUG] ループ {i}: 処理中の数値 = {num}")
...         
...         if num > 0:
...             squared = num ** 2
...             print(f"[DEBUG] 正の数 {num} の2乗 = {squared}")
...             result.append(squared)
...         else:
...             print(f"[DEBUG] 負または0の数をスキップ: {num}")
...     
...     print(f"[DEBUG] 関数終了: 結果 = {result}")
...     return result

>>> # デバッグ実行
>>> test_numbers = [-2, 3, 0, 5, -1, 7]
>>> debug_result = debug_example_function(test_numbers)

[DEBUG] 関数開始: 入力 = [-2, 3, 0, 5, -1, 7]
[DEBUG] ループ 0: 処理中の数値 = -2
[DEBUG] 負または0の数をスキップ: -2
[DEBUG] ループ 1: 処理中の数値 = 3
[DEBUG] 正の数 3 の2乗 = 9
[DEBUG] ループ 2: 処理中の数値 = 0
[DEBUG] 負または0の数をスキップ: 0
[DEBUG] ループ 3: 処理中の数値 = 5
[DEBUG] 正の数 5 の2乗 = 25
[DEBUG] ループ 4: 処理中の数値 = -1
[DEBUG] 負または0の数をスキップ: -1
[DEBUG] ループ 5: 処理中の数値 = 7
[DEBUG] 正の数 7 の2乗 = 49
[DEBUG] 関数終了: 結果 = [9, 25, 49]
```

### ログを使った高度なデバッグ

```python
>>> import logging
>>> from datetime import datetime

>>> # ログ設定
>>> logging.basicConfig(
...     level=logging.DEBUG,
...     format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
...     handlers=[
...         logging.StreamHandler(),
...         logging.FileHandler('debug.log', encoding='utf-8')
...     ]
... )

>>> class DebuggableCalculator:
...     """デバッグ機能付き計算機"""
...     
...     def __init__(self):
...         self.logger = logging.getLogger(self.__class__.__name__)
...         self.operation_count = 0
...         self.logger.info("計算機を初期化しました")
...     
...     def add(self, a, b):
...         """加算"""
...         self.operation_count += 1
...         self.logger.debug(f"加算操作開始: {a} + {b}")
...         
...         try:
...             result = a + b
...             self.logger.info(f"加算成功: {a} + {b} = {result}")
...             return result
...         except Exception as e:
...             self.logger.error(f"加算エラー: {a} + {b}, エラー: {e}")
...             raise
...     
...     def divide(self, a, b):
...         """除算"""
...         self.operation_count += 1
...         self.logger.debug(f"除算操作開始: {a} / {b}")
...         
...         if b == 0:
...             self.logger.warning(f"ゼロ除算の試行: {a} / {b}")
...             raise ValueError("ゼロで割ることはできません")
...         
...         try:
...             result = a / b
...             self.logger.info(f"除算成功: {a} / {b} = {result}")
...             return result
...         except Exception as e:
...             self.logger.error(f"除算エラー: {a} / {b}, エラー: {e}")
...             raise
...     
...     def complex_calculation(self, numbers):
...         """複雑な計算のデバッグ例"""
...         self.logger.info(f"複雑な計算開始: {len(numbers)}個の数値")
...         
...         total = 0
...         valid_numbers = []
...         
...         for i, num in enumerate(numbers):
...             self.logger.debug(f"数値 {i}: {num} を処理中")
...             
...             if isinstance(num, (int, float)):
...                 if num > 0:
...                     valid_numbers.append(num)
...                     total += num
...                     self.logger.debug(f"有効な数値を追加: {num}, 現在の合計: {total}")
...                 else:
...                     self.logger.warning(f"負または0の数値をスキップ: {num}")
...             else:
...                 self.logger.error(f"無効なデータ型: {num} (型: {type(num)})")
...         
...         if not valid_numbers:
...             self.logger.error("有効な数値がありません")
...             raise ValueError("計算可能な数値がありません")
...         
...         average = total / len(valid_numbers)
...         self.logger.info(f"計算完了: 合計={total}, 平均={average:.2f}, 有効数値数={len(valid_numbers)}")
...         
...         return {
...             'total': total,
...             'average': average,
...             'count': len(valid_numbers),
...             'valid_numbers': valid_numbers
...         }
...     
...     def get_stats(self):
...         """統計情報を取得"""
...         self.logger.debug("統計情報の取得")
...         return {
...             'operation_count': self.operation_count,
...             'timestamp': datetime.now().isoformat()
...         }

>>> # デバッグ付き計算機のテスト
>>> def test_debuggable_calculator():
...     """デバッグ機能付き計算機のテスト"""
...     print("=== デバッグ機能付き計算機のテスト ===")
...     
...     calc = DebuggableCalculator()
...     
...     # 正常な計算
...     result1 = calc.add(10, 5)
...     print(f"加算結果: {result1}")
...     
...     result2 = calc.divide(20, 4)
...     print(f"除算結果: {result2}")
...     
...     # エラーケース
...     try:
...         result3 = calc.divide(10, 0)
...     except ValueError as e:
...         print(f"ゼロ除算エラーをキャッチ: {e}")
...     
...     # 複雑な計算
...     test_data = [1, 2.5, -1, 0, "invalid", 3, 4.7, None, 5]
...     try:
...         complex_result = calc.complex_calculation(test_data)
...         print(f"複雑な計算結果: {complex_result}")
...     except ValueError as e:
...         print(f"計算エラー: {e}")
...     
...     # 統計情報
...     stats = calc.get_stats()
...     print(f"統計情報: {stats}")

>>> # ログレベルを調整してテスト実行
>>> test_debuggable_calculator()

=== デバッグ機能付き計算機のテスト ===
加算結果: 15
除算結果: 5.0
ゼロ除算エラーをキャッチ: ゼロで割ることはできません
複雑な計算結果: {'total': 16.2, 'average': 3.24, 'count': 5, 'valid_numbers': [1, 2.5, 3, 4.7, 5]}
統計情報: {'operation_count': 4, 'timestamp': '2024-12-19T11:30:00.123456'}
```

## テストカバレッジと品質測定

### カバレッジ測定のシミュレーション

```python
>>> class CoverageSimulator:
...     """テストカバレッジのシミュレーター"""
...     
...     def __init__(self):
...         self.executed_lines = set()
...         self.total_lines = set()
...     
...     def mark_line_executed(self, line_number):
...         """実行された行をマーク"""
...         self.executed_lines.add(line_number)
...         self.total_lines.add(line_number)
...     
...     def mark_line_exists(self, line_number):
...         """存在する行をマーク"""
...         self.total_lines.add(line_number)
...     
...     def get_coverage_report(self):
...         """カバレッジレポートを生成"""
...         if not self.total_lines:
...             return 0.0
...         
...         coverage_percentage = (len(self.executed_lines) / len(self.total_lines)) * 100
...         
...         report = {
...             'total_lines': len(self.total_lines),
...             'executed_lines': len(self.executed_lines),
...             'coverage_percentage': coverage_percentage,
...             'uncovered_lines': self.total_lines - self.executed_lines
...         }
...         
...         return report

>>> def demonstrate_test_coverage():
...     """テストカバレッジのデモンストレーション"""
...     print("=== テストカバレッジデモ ===")
...     
...     coverage = CoverageSimulator()
...     
...     # 架空のコードの行番号をマーク
...     code_lines = range(1, 21)  # 20行のコード
...     for line in code_lines:
...         coverage.mark_line_exists(line)
...     
...     # テスト実行による実行行のシミュレーション
...     executed_by_test1 = [1, 2, 3, 5, 6, 8, 10]
...     executed_by_test2 = [1, 2, 4, 7, 9, 11, 12]
...     executed_by_test3 = [13, 14, 15, 16]
...     
...     print("テスト1実行後:")
...     for line in executed_by_test1:
...         coverage.mark_line_executed(line)
...     report1 = coverage.get_coverage_report()
...     print(f"  カバレッジ: {report1['coverage_percentage']:.1f}%")
...     
...     print("テスト2実行後:")
...     for line in executed_by_test2:
...         coverage.mark_line_executed(line)
...     report2 = coverage.get_coverage_report()
...     print(f"  カバレッジ: {report2['coverage_percentage']:.1f}%")
...     
...     print("テスト3実行後:")
...     for line in executed_by_test3:
...         coverage.mark_line_executed(line)
...     final_report = coverage.get_coverage_report()
...     
...     print(f"\\n最終カバレッジレポート:")
...     print(f"  総行数: {final_report['total_lines']}")
...     print(f"  実行行数: {final_report['executed_lines']}")
...     print(f"  カバレッジ: {final_report['coverage_percentage']:.1f}%")
...     print(f"  未実行行: {sorted(final_report['uncovered_lines'])}")
...     
...     # カバレッジ品質の評価
...     coverage_percentage = final_report['coverage_percentage']
...     if coverage_percentage >= 90:
...         quality = "優秀"
...     elif coverage_percentage >= 80:
...         quality = "良好"
...     elif coverage_percentage >= 70:
...         quality = "普通"
...     else:
...         quality = "改善が必要"
...     
...     print(f"  品質評価: {quality}")

>>> demonstrate_test_coverage()

=== テストカバレッジデモ ===
テスト1実行後:
  カバレッジ: 35.0%
テスト2実行後:
  カバレッジ: 60.0%
テスト3実行後:
  カバレッジ: 80.0%

最終カバレッジレポート:
  総行数: 20
  実行行数: 16
  カバレッジ: 80.0%
  未実行行: [17, 18, 19, 20]
  品質評価: 良好
```

## まとめ：テストとデバッグのベストプラクティス

この章で学んだことをまとめましょう：

### テストの種類と目的
1. **ユニットテスト**: 個別の関数・クラスの動作確認
2. **統合テスト**: 複数コンポーネントの連携確認
3. **パフォーマンステスト**: 性能・速度の確認
4. **モックテスト**: 外部依存を排除したテスト

### テスト設計の原則
```python
# AAA パターン (Arrange, Act, Assert)
def test_example():
    # Arrange: テスト準備
    account = BankAccount(1000)
    
    # Act: テスト実行
    account.deposit(500)
    
    # Assert: 結果確認
    assert account.get_balance() == 1500
```

### unittestフレームワークの基本
- **setUp/tearDown**: テスト前後の処理
- **assert メソッド**: 結果の検証
- **例外テスト**: 期待するエラーの確認
- **テストスイート**: 複数テストの管理

### モックとテストダブル
```python
# モックオブジェクトの使用
mock_service = Mock()
mock_service.get_data.return_value = "test_data"
mock_service.process.side_effect = Exception("test_error")

# 呼び出し確認
mock_service.get_data.assert_called_once_with("param")
```

### デバッグ技術
1. **print文デバッグ**: シンプルで効果的
2. **ログデバッグ**: レベル別の詳細な情報
3. **ブレークポイント**: IDEでの対話的デバッグ
4. **単体テスト**: 問題の局所化

### テストカバレッジ
- **行カバレッジ**: 実行された行の割合
- **分岐カバレッジ**: 条件分岐の網羅性
- **目標値**: 80%以上が一般的な目標

### 品質保証のプロセス
1. **テスト駆動開発（TDD）**: テスト先行の開発
2. **継続的インテグレーション**: 自動テスト実行
3. **コードレビュー**: チームでの品質確認
4. **回帰テスト**: 既存機能の保護

### 実用的なテスト戦略
- **重要な機能から優先してテスト**
- **エッジケースと異常系の考慮**
- **外部依存はモックで分離**
- **テストは簡潔で理解しやすく**

次の章では、**Pythonの標準ライブラリ**について学びます。datetime、json、re、os、collectionsなど、実際の開発で頻繁に使用される強力なライブラリの活用方法を習得しましょう！

---

**第18章執筆完了ログ:**
第18章ではテストとデバッグの技術を包括的に学習。テストの重要性、unittestフレームワークの基本から高度な機能まで段階的に説明。実践例として銀行システム、Eコマースシステムの包括的なテストスイートを構築。モックとテストダブルを使った外部依存の分離、パフォーマンステスト、デバッグ技術、テストカバレッジまで含む完全なテスト体系を実装。次は第19章のPython標準ライブラリに進みます。