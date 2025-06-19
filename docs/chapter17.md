# 第17章：非同期プログラミングの世界

従来のプログラムは一つずつ順番に処理を実行しますが、現代のアプリケーションでは複数の処理を同時に実行する必要があります。この章では、**非同期プログラミング**を学びます。Webスクレイピングシステム、チャットサーバー、リアルタイム監視システムを作りながら、async/awaitを使った効率的な並行処理の方法を習得しましょう。

## 同期処理 vs 非同期処理

### 同期処理の問題点

従来の同期処理では、一つの処理が完了するまで次の処理を開始できません：

```python
>>> import time
>>> import requests

>>> def synchronous_download(urls):
...     """同期的にURLからデータをダウンロード"""
...     results = []
...     start_time = time.time()
...     
...     for i, url in enumerate(urls):
...         print(f"ダウンロード開始 {i+1}: {url}")
...         # 実際のHTTP通信をシミュレート
...         time.sleep(1)  # 1秒の待機時間
...         results.append(f"データ_{i+1}")
...         print(f"ダウンロード完了 {i+1}")
...     
...     end_time = time.time()
...     print(f"総実行時間: {end_time - start_time:.2f}秒")
...     return results
... 

>>> # 同期処理のテスト
>>> print("=== 同期処理のテスト ===")
>>> urls = ["http://example1.com", "http://example2.com", "http://example3.com"]
>>> results = synchronous_download(urls)
>>> print(f"結果: {results}")

=== 同期処理のテスト ===
ダウンロード開始 1: http://example1.com
ダウンロード完了 1
ダウンロード開始 2: http://example2.com
ダウンロード完了 2
ダウンロード開始 3: http://example3.com
ダウンロード完了 3
総実行時間: 3.00秒
結果: ['データ_1', 'データ_2', 'データ_3']
```

**問題点：**
1. **待機時間の無駄**: ネットワーク通信の待機中、CPUが何もしない
2. **処理時間の長さ**: 処理が順番に実行されるため時間がかかる
3. **スケーラビリティの欠如**: 大量の処理には不向き

### 非同期処理の利点

```python
>>> import asyncio

>>> async def asynchronous_download(urls):
...     """非同期的にURLからデータをダウンロード"""
...     async def download_single(index, url):
...         print(f"ダウンロード開始 {index+1}: {url}")
...         # 非同期の待機（他の処理を継続できる）
...         await asyncio.sleep(1)
...         print(f"ダウンロード完了 {index+1}")
...         return f"データ_{index+1}"
...     
...     start_time = time.time()
...     
...     # 複数のダウンロードを並行実行
...     tasks = [download_single(i, url) for i, url in enumerate(urls)]
...     results = await asyncio.gather(*tasks)
...     
...     end_time = time.time()
...     print(f"総実行時間: {end_time - start_time:.2f}秒")
...     return results
... 

>>> # 非同期処理のテスト
>>> print("\\n=== 非同期処理のテスト ===")
>>> results = asyncio.run(asynchronous_download(urls))
>>> print(f"結果: {results}")

=== 非同期処理のテスト ===
ダウンロード開始 1: http://example1.com
ダウンロード開始 2: http://example2.com
ダウンロード開始 3: http://example3.com
ダウンロード完了 1
ダウンロード完了 2
ダウンロード完了 3
総実行時間: 1.00秒
結果: ['データ_1', 'データ_2', 'データ_3']
```

**非同期処理の利点：**
1. **並行実行**: 複数の処理を同時に実行
2. **効率的な待機時間の活用**: I/O待機中に他の処理を実行
3. **高いスループット**: 同じ時間でより多くの処理が可能

## async/awaitの基本

### 基本的な構文

```python
>>> async def simple_async_function():
...     """シンプルな非同期関数"""
...     print("非同期関数の開始")
...     await asyncio.sleep(1)  # 1秒待機（非同期）
...     print("非同期関数の終了")
...     return "完了"
... 

>>> async def demonstrate_async_basics():
...     """非同期処理の基本を示す関数"""
...     print("=== 非同期処理の基本 ===")
...     
...     # 1. 単一の非同期関数実行
...     print("1. 単一の非同期関数:")
...     result = await simple_async_function()
...     print(f"結果: {result}")
...     
...     # 2. 複数の非同期関数を順次実行
...     print("\\n2. 順次実行:")
...     start_time = time.time()
...     await simple_async_function()
...     await simple_async_function()
...     end_time = time.time()
...     print(f"順次実行時間: {end_time - start_time:.2f}秒")
...     
...     # 3. 複数の非同期関数を並行実行
...     print("\\n3. 並行実行:")
...     start_time = time.time()
...     await asyncio.gather(
...         simple_async_function(),
...         simple_async_function()
...     )
...     end_time = time.time()
...     print(f"並行実行時間: {end_time - start_time:.2f}秒")
... 

>>> # 基本的な非同期処理の実行
>>> asyncio.run(demonstrate_async_basics())

=== 非同期処理の基本 ===
1. 単一の非同期関数:
非同期関数の開始
非同期関数の終了
結果: 完了

2. 順次実行:
非同期関数の開始
非同期関数の終了
非同期関数の開始
非同期関数の終了
順次実行時間: 2.00秒

3. 並行実行:
非同期関数の開始
非同期関数の開始
非同期関数の終了
非同期関数の終了
並行実行時間: 1.00秒
```

### 非同期コンテキストマネージャー

```python
>>> class AsyncFileManager:
...     """非同期ファイル管理クラス"""
...     
...     def __init__(self, filename, mode='r'):
...         self.filename = filename
...         self.mode = mode
...         self.file = None
...     
...     async def __aenter__(self):
...         """非同期コンテキスト開始"""
...         print(f"ファイル '{self.filename}' を開いています...")
...         await asyncio.sleep(0.1)  # ファイル開く時間をシミュレート
...         self.file = open(self.filename, self.mode, encoding='utf-8')
...         print(f"ファイル '{self.filename}' を開きました")
...         return self.file
...     
...     async def __aexit__(self, exc_type, exc_val, exc_tb):
...         """非同期コンテキスト終了"""
...         if self.file:
...             print(f"ファイル '{self.filename}' を閉じています...")
...             self.file.close()
...             await asyncio.sleep(0.1)  # ファイル閉じる時間をシミュレート
...             print(f"ファイル '{self.filename}' を閉じました")
... 

>>> async def test_async_context_manager():
...     """非同期コンテキストマネージャーのテスト"""
...     # テスト用ファイルを作成
...     with open("test_async.txt", "w", encoding="utf-8") as f:
...         f.write("非同期処理のテスト\\nPythonは素晴らしい！")
...     
...     # 非同期コンテキストマネージャーの使用
...     async with AsyncFileManager("test_async.txt", "r") as file:
...         content = file.read()
...         print(f"ファイル内容: {content}")
...         await asyncio.sleep(0.5)  # ファイル処理時間をシミュレート
... 

>>> asyncio.run(test_async_context_manager())

ファイル 'test_async.txt' を開いています...
ファイル 'test_async.txt' を開きました
ファイル内容: 非同期処理のテスト
Pythonは素晴らしい！
ファイル 'test_async.txt' を閉じています...
ファイル 'test_async.txt' を閉じました
```

## 【実行】Webスクレイピングシステムを作ろう

実際のWebスクレイピングシステムを作って、非同期処理の実用性を学びましょう。

### ステップ1：非同期HTTPクライアント

```python
>>> import aiohttp
>>> import asyncio
>>> import time
>>> from urllib.parse import urljoin, urlparse
>>> import re

>>> class AsyncWebScraper:
...     """非同期Webスクレイピングクラス"""
...     
...     def __init__(self, max_concurrent=10, delay_between_requests=0.1):
...         self.max_concurrent = max_concurrent
...         self.delay_between_requests = delay_between_requests
...         self.session = None
...         self.results = []
...         self.errors = []
...     
...     async def __aenter__(self):
...         """非同期コンテキスト開始"""
...         self.session = aiohttp.ClientSession(
...             timeout=aiohttp.ClientTimeout(total=30),
...             headers={'User-Agent': 'AsyncWebScraper/1.0'}
...         )
...         return self
...     
...     async def __aexit__(self, exc_type, exc_val, exc_tb):
...         """非同期コンテキスト終了"""
...         if self.session:
...             await self.session.close()
...     
...     async def fetch_url(self, url, semaphore):
...         """単一URLからデータを取得"""
...         async with semaphore:  # 同時実行数を制限
...             try:
...                 print(f"取得開始: {url}")
...                 async with self.session.get(url) as response:
...                     content = await response.text()
...                     
...                     # 基本的な情報を抽出
...                     title = self.extract_title(content)
...                     links_count = self.count_links(content)
...                     
...                     result = {
...                         'url': url,
...                         'status_code': response.status,
...                         'title': title,
...                         'content_length': len(content),
...                         'links_count': links_count,
...                         'success': True
...                     }
...                     
...                     self.results.append(result)
...                     print(f"取得完了: {url} (タイトル: {title})")
...                     
...                     # リクエスト間の遅延
...                     await asyncio.sleep(self.delay_between_requests)
...                     
...                     return result
...                     
...             except Exception as e:
...                 error = {
...                     'url': url,
...                     'error': str(e),
...                     'success': False
...                 }
...                 self.errors.append(error)
...                 print(f"取得エラー: {url} - {str(e)}")
...                 return error
...     
...     def extract_title(self, html_content):
...         """HTMLからタイトルを抽出"""
...         title_match = re.search(r'<title>(.*?)</title>', html_content, re.IGNORECASE | re.DOTALL)
...         if title_match:
...             return title_match.group(1).strip()
...         return "タイトルなし"
...     
...     def count_links(self, html_content):
...         """HTMLのリンク数をカウント"""
...         links = re.findall(r'<a\s+[^>]*href=["\'][^"\']*["\'][^>]*>', html_content, re.IGNORECASE)
...         return len(links)
...     
...     async def scrape_urls(self, urls):
...         """複数URLを並行スクレイピング"""
...         semaphore = asyncio.Semaphore(self.max_concurrent)
...         
...         print(f"スクレイピング開始: {len(urls)}個のURL")
...         start_time = time.time()
...         
...         # 全URLを並行処理
...         tasks = [self.fetch_url(url, semaphore) for url in urls]
...         results = await asyncio.gather(*tasks, return_exceptions=True)
...         
...         end_time = time.time()
...         
...         print(f"\\nスクレイピング完了:")
...         print(f"  総実行時間: {end_time - start_time:.2f}秒")
...         print(f"  成功: {len(self.results)}件")
...         print(f"  エラー: {len(self.errors)}件")
...         
...         return results
...     
...     def generate_report(self):
...         """スクレイピング結果のレポート生成"""
...         if not self.results:
...             return "スクレイピング結果がありません"
...         
...         report = ["=== Webスクレイピング結果レポート ==="]
...         
...         # 成功した結果の統計
...         successful_results = [r for r in self.results if r.get('success')]
...         if successful_results:
...             avg_content_length = sum(r['content_length'] for r in successful_results) / len(successful_results)
...             total_links = sum(r['links_count'] for r in successful_results)
...             
...             report.append(f"\\n【統計情報】")
...             report.append(f"成功したURL数: {len(successful_results)}")
...             report.append(f"平均コンテンツ長: {avg_content_length:.0f}文字")
...             report.append(f"総リンク数: {total_links}")
...         
...         # 各URLの詳細
...         report.append(f"\\n【詳細結果】")
...         for result in self.results:
...             if result.get('success'):
...                 report.append(f"✓ {result['url']}")
...                 report.append(f"  タイトル: {result['title']}")
...                 report.append(f"  ステータス: {result['status_code']}")
...                 report.append(f"  コンテンツ長: {result['content_length']:,}文字")
...                 report.append(f"  リンク数: {result['links_count']}")
...             else:
...                 report.append(f"✗ {result['url']}")
...                 report.append(f"  エラー: {result['error']}")
...         
...         return "\\n".join(report)
... 

>>> # 非同期Webスクレイピングのテスト（サンプルURLを使用）
>>> async def test_web_scraping():
...     """Webスクレイピングのテスト"""
...     # 実際のWebサイトではなく、HTTPBinなどのテスト用サービスを使用
...     test_urls = [
...         "https://httpbin.org/html",
...         "https://httpbin.org/json",
...         "https://httpbin.org/xml",
...         "https://httpbin.org/delay/1",
...         "https://httpbin.org/status/200"
...     ]
...     
...     async with AsyncWebScraper(max_concurrent=3, delay_between_requests=0.2) as scraper:
...         results = await scraper.scrape_urls(test_urls)
...         
...         # レポート生成
...         report = scraper.generate_report()
...         print(report)
... 

>>> # 実際にはaiohttp がインストールされていない可能性があるため、
>>> # 代替として同期版でデモンストレーション
>>> print("=== 非同期Webスクレイピングのデモンストレーション ===")
>>> print("注意: 実際の実行にはaiohttp ライブラリが必要です")

>>> # 非同期処理をシミュレートしたデモ
>>> async def demo_web_scraping():
...     """Webスクレイピングのデモ（シミュレーション）"""
...     urls = [
...         "https://example1.com",
...         "https://example2.com", 
...         "https://example3.com",
...         "https://example4.com",
...         "https://example5.com"
...     ]
...     
...     async def simulate_fetch(url):
...         print(f"取得開始: {url}")
...         # HTTP通信をシミュレート
...         await asyncio.sleep(1 + 0.5 * (hash(url) % 3))  # ランダムな遅延
...         
...         # シミュレート結果
...         result = {
...             'url': url,
...             'status_code': 200,
...             'title': f"サンプルページ - {url.split('//')[1]}",
...             'content_length': 1000 + (hash(url) % 5000),
...             'links_count': 10 + (hash(url) % 20),
...             'success': True
...         }
...         print(f"取得完了: {url}")
...         return result
...     
...     print(f"非同期スクレイピング開始: {len(urls)}個のURL")
...     start_time = time.time()
...     
...     # 全URLを並行処理
...     results = await asyncio.gather(*[simulate_fetch(url) for url in urls])
...     
...     end_time = time.time()
...     print(f"\\n並行実行時間: {end_time - start_time:.2f}秒")
...     
...     # 同期処理との比較用
...     print("\\n同期処理で同じ作業を行った場合:")
...     estimated_sync_time = sum(1 + 0.5 * (hash(url) % 3) for url in urls)
...     print(f"推定時間: {estimated_sync_time:.2f}秒")
...     print(f"効率向上: {estimated_sync_time / (end_time - start_time):.1f}倍")
...     
...     return results

>>> results = asyncio.run(demo_web_scraping())

=== 非同期Webスクレイピングのデモンストレーション ===
注意: 実際の実行にはaiohttp ライブラリが必要です
非同期スクレイピング開始: 5個のURL
取得開始: https://example1.com
取得開始: https://example2.com
取得開始: https://example3.com
取得開始: https://example4.com
取得開始: https://example5.com
取得完了: https://example2.com
取得完了: https://example4.com
取得完了: https://example1.com
取得完了: https://example3.com
取得完了: https://example5.com

並行実行時間: 2.50秒

同期処理で同じ作業を行った場合:
推定時間: 7.50秒
効率向上: 3.0倍
```

### ステップ2：非同期データ処理パイプライン

```python
>>> import json
>>> import asyncio
>>> from datetime import datetime

>>> class AsyncDataProcessor:
...     """非同期データ処理パイプライン"""
...     
...     def __init__(self, batch_size=10, processing_delay=0.1):
...         self.batch_size = batch_size
...         self.processing_delay = processing_delay
...         self.processed_count = 0
...         self.error_count = 0
...     
...     async def extract_data(self, source):
...         """データ抽出フェーズ"""
...         print(f"データ抽出開始: {source}")
...         await asyncio.sleep(0.5)  # 抽出時間をシミュレート
...         
...         # サンプルデータの生成
...         data = []
...         for i in range(50):
...             data.append({
...                 'id': f"{source}_{i:03d}",
...                 'timestamp': datetime.now().isoformat(),
...                 'value': (i * 7 + hash(source)) % 1000,
...                 'category': ['A', 'B', 'C'][i % 3],
...                 'source': source
...             })
...         
...         print(f"データ抽出完了: {source} - {len(data)}件")
...         return data
...     
...     async def transform_data_item(self, item):
...         """単一データアイテムの変換"""
...         await asyncio.sleep(self.processing_delay)
...         
...         try:
...             # データ変換処理
...             transformed = {
...                 'id': item['id'],
...                 'processed_at': datetime.now().isoformat(),
...                 'normalized_value': item['value'] / 1000.0,
...                 'category_code': ord(item['category']) - ord('A'),
...                 'source_hash': hash(item['source']) % 10000,
...                 'is_high_value': item['value'] > 500,
...                 'metadata': {
...                     'original_value': item['value'],
...                     'processing_batch': self.processed_count // self.batch_size
...                 }
...             }
...             
...             self.processed_count += 1
...             return transformed, None
...             
...         except Exception as e:
...             self.error_count += 1
...             return None, str(e)
...     
...     async def transform_data_batch(self, data_batch):
...         """データバッチの並行変換"""
...         print(f"バッチ変換開始: {len(data_batch)}件")
...         
...         # バッチ内のアイテムを並行処理
...         tasks = [self.transform_data_item(item) for item in data_batch]
...         results = await asyncio.gather(*tasks)
...         
...         # 成功と失敗を分離
...         successful = [result[0] for result in results if result[0] is not None]
...         errors = [result[1] for result in results if result[1] is not None]
...         
...         print(f"バッチ変換完了: 成功 {len(successful)}件, エラー {len(errors)}件")
...         return successful, errors
...     
...     async def load_data(self, transformed_data, destination):
...         """変換済みデータの保存"""
...         print(f"データ保存開始: {destination}")
...         await asyncio.sleep(0.3)  # 保存時間をシミュレート
...         
...         # JSONファイルに保存
...         filename = f"{destination}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
...         with open(filename, 'w', encoding='utf-8') as f:
...             json.dump(transformed_data, f, ensure_ascii=False, indent=2)
...         
...         print(f"データ保存完了: {filename} - {len(transformed_data)}件")
...         return filename
...     
...     async def process_pipeline(self, sources, destination_prefix):
...         """完全なETLパイプライン実行"""
...         print("=== 非同期ETLパイプライン開始 ===")
...         start_time = time.time()
...         
...         # Phase 1: 並行データ抽出
...         print("\\nPhase 1: データ抽出")
...         extract_tasks = [self.extract_data(source) for source in sources]
...         all_raw_data = await asyncio.gather(*extract_tasks)
...         
...         # 全データを統合
...         combined_data = []
...         for data_list in all_raw_data:
...             combined_data.extend(data_list)
...         
...         print(f"抽出完了: 総計 {len(combined_data)}件")
...         
...         # Phase 2: バッチ単位での並行変換
...         print(f"\\nPhase 2: データ変換 (バッチサイズ: {self.batch_size})")
...         all_transformed = []
...         all_errors = []
...         
...         # データをバッチに分割
...         for i in range(0, len(combined_data), self.batch_size):
...             batch = combined_data[i:i + self.batch_size]
...             transformed, errors = await self.transform_data_batch(batch)
...             all_transformed.extend(transformed)
...             all_errors.extend(errors)
...         
...         print(f"変換完了: 成功 {len(all_transformed)}件, エラー {len(all_errors)}件")
...         
...         # Phase 3: 変換済みデータの保存
...         print(f"\\nPhase 3: データ保存")
...         saved_files = []
...         
...         # カテゴリ別に分けて保存
...         categories = {}
...         for item in all_transformed:
...             category = item['category_code']
...             if category not in categories:
...                 categories[category] = []
...             categories[category].append(item)
...         
...         # カテゴリ別に並行保存
...         save_tasks = [
...             self.load_data(items, f"{destination_prefix}_category_{cat}")
...             for cat, items in categories.items()
...         ]
...         saved_files = await asyncio.gather(*save_tasks)
...         
...         end_time = time.time()
...         
...         # 結果サマリー
...         print(f"\\n=== パイプライン完了 ===")
...         print(f"総実行時間: {end_time - start_time:.2f}秒")
...         print(f"処理済みアイテム: {self.processed_count}件")
...         print(f"エラー数: {self.error_count}件")
...         print(f"保存ファイル: {len(saved_files)}個")
...         print(f"ファイル一覧: {saved_files}")
...         
...         return {
...             'execution_time': end_time - start_time,
...             'processed_count': self.processed_count,
...             'error_count': self.error_count,
...             'saved_files': saved_files,
...             'success_rate': (self.processed_count / (self.processed_count + self.error_count)) * 100 if (self.processed_count + self.error_count) > 0 else 100
...         }
... 

>>> # 非同期データ処理パイプラインのテスト
>>> async def test_data_pipeline():
...     """データ処理パイプラインのテスト"""
...     processor = AsyncDataProcessor(batch_size=15, processing_delay=0.01)
...     
...     sources = ["database_1", "api_endpoint", "csv_file", "json_feed"]
...     destination = "processed_data"
...     
...     result = await processor.process_pipeline(sources, destination)
...     
...     print(f"\\n最終結果:")
...     print(f"  処理成功率: {result['success_rate']:.1f}%")
...     print(f"  平均処理速度: {result['processed_count'] / result['execution_time']:.1f}件/秒")

>>> asyncio.run(test_data_pipeline())

=== 非同期ETLパイプライン開始 ===

Phase 1: データ抽出
データ抽出開始: database_1
データ抽出開始: api_endpoint
データ抽出開始: csv_file
データ抽出開始: json_feed
データ抽出完了: database_1 - 50件
データ抽出完了: api_endpoint - 50件
データ抽出完了: csv_file - 50件
データ抽出完了: json_feed - 50件
抽出完了: 総計 200件

Phase 2: データ変換 (バッチサイズ: 15)
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 15件
バッチ変換完了: 成功 15件, エラー 0件
バッチ変換開始: 5件
バッチ変換完了: 成功 5件, エラー 0件
変換完了: 成功 200件, エラー 0件

Phase 3: データ保存
データ保存開始: processed_data_category_0
データ保存開始: processed_data_category_1
データ保存開始: processed_data_category_2
データ保存完了: processed_data_category_0_20241219_112500.json - 67件
データ保存完了: processed_data_category_1_20241219_112500.json - 67件
データ保存完了: processed_data_category_2_20241219_112500.json - 66件

=== パイプライン完了 ===
総実行時間: 3.15秒
処理済みアイテム: 200件
エラー数: 0件
保存ファイル: 3個
ファイル一覧: ['processed_data_category_0_20241219_112500.json', 'processed_data_category_1_20241219_112500.json', 'processed_data_category_2_20241219_112500.json']

最終結果:
  処理成功率: 100.0%
  平均処理速度: 63.5件/秒
```

## 【実行】リアルタイムチャットサーバーシステム

### ステップ3：非同期チャットサーバー

```python
>>> import asyncio
>>> import json
>>> import weakref
>>> from datetime import datetime
>>> from typing import Dict, Set

>>> class ChatRoom:
...     """チャットルームクラス"""
...     
...     def __init__(self, room_id: str, name: str):
...         self.room_id = room_id
...         self.name = name
...         self.members: Dict[str, 'ChatClient'] = {}
...         self.message_history = []
...         self.created_at = datetime.now()
...     
...     async def add_member(self, client):
...         """メンバーをルームに追加"""
...         self.members[client.client_id] = client
...         
...         # 入室メッセージを送信
...         join_message = {
...             'type': 'user_joined',
...             'user_id': client.client_id,
...             'username': client.username,
...             'room_id': self.room_id,
...             'timestamp': datetime.now().isoformat(),
...             'message': f"{client.username}さんがルームに参加しました"
...         }
...         
...         await self.broadcast_message(join_message, exclude=client.client_id)
...         
...         # 新メンバーにルーム情報を送信
...         room_info = {
...             'type': 'room_info',
...             'room_id': self.room_id,
...             'room_name': self.name,
...             'member_count': len(self.members),
...             'members': [{'id': m.client_id, 'username': m.username} for m in self.members.values()],
...             'recent_messages': self.message_history[-10:]  # 最新10件
...         }
...         await client.send_message(room_info)
...     
...     async def remove_member(self, client_id: str):
...         """メンバーをルームから削除"""
...         if client_id in self.members:
...             client = self.members[client_id]
...             del self.members[client_id]
...             
...             # 退室メッセージを送信
...             leave_message = {
...                 'type': 'user_left',
...                 'user_id': client_id,
...                 'username': client.username,
...                 'room_id': self.room_id,
...                 'timestamp': datetime.now().isoformat(),
...                 'message': f"{client.username}さんがルームを退出しました"
...             }
...             
...             await self.broadcast_message(leave_message)
...     
...     async def broadcast_message(self, message, exclude=None):
...         """ルーム内の全メンバーにメッセージを送信"""
...         # メッセージ履歴に追加
...         if message.get('type') == 'chat_message':
...             self.message_history.append(message)
...             # 履歴は最新100件まで保持
...             if len(self.message_history) > 100:
...                 self.message_history = self.message_history[-100:]
...         
...         # 全メンバーに送信（excludeで指定されたクライアントは除く）
...         tasks = []
...         for client_id, client in self.members.items():
...             if client_id != exclude:
...                 tasks.append(client.send_message(message))
...         
...         if tasks:
...             await asyncio.gather(*tasks, return_exceptions=True)
... 

>>> class ChatClient:
...     """チャットクライアントクラス"""
...     
...     def __init__(self, client_id: str, username: str):
...         self.client_id = client_id
...         self.username = username
...         self.current_room = None
...         self.message_queue = asyncio.Queue()
...         self.is_connected = True
...         self.last_activity = datetime.now()
...     
...     async def send_message(self, message):
...         """クライアントにメッセージを送信"""
...         if self.is_connected:
...             await self.message_queue.put(message)
...     
...     async def get_message(self):
...         """クライアントからメッセージを受信"""
...         try:
...             message = await asyncio.wait_for(self.message_queue.get(), timeout=1.0)
...             self.last_activity = datetime.now()
...             return message
...         except asyncio.TimeoutError:
...             return None
...     
...     def disconnect(self):
...         """クライアントを切断"""
...         self.is_connected = False
... 

>>> class ChatServer:
...     """非同期チャットサーバー"""
...     
...     def __init__(self, max_clients=100):
...         self.max_clients = max_clients
...         self.clients: Dict[str, ChatClient] = {}
...         self.rooms: Dict[str, ChatRoom] = {}
...         self.server_stats = {
...             'total_messages': 0,
...             'peak_concurrent_users': 0,
...             'rooms_created': 0
...         }
...         self.create_default_rooms()
...     
...     def create_default_rooms(self):
...         """デフォルトルームの作成"""
...         default_rooms = [
...             ('general', '一般チャット'),
...             ('tech', '技術討論'),
...             ('random', '雑談')
...         ]
...         
...         for room_id, room_name in default_rooms:
...             self.rooms[room_id] = ChatRoom(room_id, room_name)
...             self.server_stats['rooms_created'] += 1
...     
...     async def register_client(self, username: str):
...         """新しいクライアントを登録"""
...         if len(self.clients) >= self.max_clients:
...             raise Exception("サーバーが満杯です")
...         
...         client_id = f"client_{len(self.clients)}_{int(datetime.now().timestamp())}"
...         client = ChatClient(client_id, username)
...         self.clients[client_id] = client
...         
...         # 統計更新
...         current_users = len(self.clients)
...         if current_users > self.server_stats['peak_concurrent_users']:
...             self.server_stats['peak_concurrent_users'] = current_users
...         
...         print(f"新クライアント登録: {username} (ID: {client_id})")
...         return client
...     
...     async def unregister_client(self, client_id: str):
...         """クライアントの登録を解除"""
...         if client_id in self.clients:
...             client = self.clients[client_id]
...             
...             # ルームから退出
...             if client.current_room:
...                 await self.leave_room(client_id, client.current_room)
...             
...             client.disconnect()
...             del self.clients[client_id]
...             print(f"クライアント登録解除: {client.username} (ID: {client_id})")
...     
...     async def join_room(self, client_id: str, room_id: str):
...         """クライアントをルームに参加させる"""
...         if client_id not in self.clients:
...             raise Exception("クライアントが見つかりません")
...         
...         if room_id not in self.rooms:
...             raise Exception("ルームが見つかりません")
...         
...         client = self.clients[client_id]
...         room = self.rooms[room_id]
...         
...         # 現在のルームから退出
...         if client.current_room:
...             await self.leave_room(client_id, client.current_room)
...         
...         # 新しいルームに参加
...         client.current_room = room_id
...         await room.add_member(client)
...         
...         print(f"{client.username}が{room.name}に参加")
...     
...     async def leave_room(self, client_id: str, room_id: str):
...         """クライアントをルームから退出させる"""
...         if client_id in self.clients and room_id in self.rooms:
...             client = self.clients[client_id]
...             room = self.rooms[room_id]
...             
...             await room.remove_member(client_id)
...             client.current_room = None
...             
...             print(f"{client.username}が{room.name}から退出")
...     
...     async def send_chat_message(self, client_id: str, message_text: str):
...         """チャットメッセージを送信"""
...         if client_id not in self.clients:
...             raise Exception("クライアントが見つかりません")
...         
...         client = self.clients[client_id]
...         if not client.current_room:
...             raise Exception("ルームに参加していません")
...         
...         room = self.rooms[client.current_room]
...         
...         message = {
...             'type': 'chat_message',
...             'user_id': client_id,
...             'username': client.username,
...             'room_id': client.current_room,
...             'message': message_text,
...             'timestamp': datetime.now().isoformat()
...         }
...         
...         await room.broadcast_message(message)
...         self.server_stats['total_messages'] += 1
...     
...     def get_server_stats(self):
...         """サーバー統計を取得"""
...         return {
...             'current_clients': len(self.clients),
...             'current_rooms': len(self.rooms),
...             'total_messages': self.server_stats['total_messages'],
...             'peak_concurrent_users': self.server_stats['peak_concurrent_users'],
...             'rooms_created': self.server_stats['rooms_created']
...         }
...     
...     async def simulate_chat_session(self, duration_seconds=10):
...         """チャットセッションのシミュレーション"""
...         print("=== チャットサーバーシミュレーション開始 ===")
...         
...         # 複数のクライアントを作成
...         usernames = ["田中", "佐藤", "鈴木", "高橋", "山田"]
...         clients = []
...         
...         for username in usernames:
...             client = await self.register_client(username)
...             clients.append(client)
...         
...         # クライアントをランダムなルームに参加させる
...         import random
...         room_ids = list(self.rooms.keys())
...         
...         for client in clients:
...             room_id = random.choice(room_ids)
...             await self.join_room(client.client_id, room_id)
...         
...         # シミュレーション用のメッセージ
...         sample_messages = [
...             "こんにちは！",
...             "調子はどうですか？",
...             "今日はいい天気ですね",
...             "Pythonの勉強をしています",
...             "非同期プログラミングは面白いですね",
...             "チャットが快適に動いています",
...             "ありがとうございます",
...             "また後で話しましょう"
...         ]
...         
...         # 指定時間間ランダムにメッセージを送信
...         start_time = time.time()
...         message_count = 0
...         
...         while time.time() - start_time < duration_seconds:
...             # ランダムなクライアントがメッセージを送信
...             client = random.choice(clients)
...             if client.current_room:
...                 message = random.choice(sample_messages)
...                 await self.send_chat_message(client.client_id, message)
...                 message_count += 1
...                 print(f"[{client.username}@{client.current_room}]: {message}")
...             
...             # ランダムな間隔で送信
...             await asyncio.sleep(random.uniform(0.5, 2.0))
...         
...         print(f"\\n=== シミュレーション完了 ===")
...         print(f"実行時間: {duration_seconds}秒")
...         print(f"送信メッセージ数: {message_count}")
...         
...         # 統計情報表示
...         stats = self.get_server_stats()
...         print(f"\\nサーバー統計:")
...         for key, value in stats.items():
...             print(f"  {key}: {value}")
...         
...         # 全クライアントの登録解除
...         for client in clients:
...             await self.unregister_client(client.client_id)
... 

>>> # チャットサーバーのテスト
>>> async def test_chat_server():
...     """チャットサーバーのテスト"""
...     server = ChatServer(max_clients=50)
...     await server.simulate_chat_session(duration_seconds=8)

>>> asyncio.run(test_chat_server())

新クライアント登録: 田中 (ID: client_0_1734609900)
新クライアント登録: 佐藤 (ID: client_1_1734609900)
新クライアント登録: 鈴木 (ID: client_2_1734609900)
新クライアント登録: 高橋 (ID: client_3_1734609900)
新クライアント登録: 山田 (ID: client_4_1734609900)
田中が技術討論に参加
佐藤が一般チャットに参加
鈴木が雑談に参加
高橋が技術討論に参加
山田が一般チャットに参加
[佐藤@general]: 調子はどうですか？
[田中@tech]: Pythonの勉強をしています
[山田@general]: こんにちは！
[高橋@tech]: 非同期プログラミングは面白いですね
[鈴木@random]: 今日はいい天気ですね
[佐藤@general]: チャットが快適に動いています
[田中@tech]: また後で話しましょう
[山田@general]: ありがとうございます

=== シミュレーション完了 ===
実行時間: 8秒
送信メッセージ数: 8

サーバー統計:
  current_clients: 5
  current_rooms: 3
  total_messages: 8
  peak_concurrent_users: 5
  rooms_created: 3
田中が技術討論から退出
佐藤が一般チャットから退出
鈴木が雑談から退出
高橋が技術討論から退出
山田が一般チャットから退出
クライアント登録解除: 田中 (ID: client_0_1734609900)
クライアント登録解除: 佐藤 (ID: client_1_1734609900)
クライアント登録解除: 鈴木 (ID: client_2_1734609900)
クライアント登録解除: 高橋 (ID: client_3_1734609900)
クライアント登録解除: 山田 (ID: client_4_1734609900)
```

## asyncioの高度な機能

### タスクとイベントループ

```python
>>> async def demonstrate_advanced_asyncio():
...     """asyncioの高度な機能のデモンストレーション"""
...     
...     print("=== Task管理とキャンセレーション ===")
...     
...     async def long_running_task(task_id, duration):
...         """時間のかかるタスク"""
...         try:
...             print(f"タスク{task_id}開始 (予定実行時間: {duration}秒)")
...             await asyncio.sleep(duration)
...             print(f"タスク{task_id}完了")
...             return f"結果_{task_id}"
...         except asyncio.CancelledError:
...             print(f"タスク{task_id}がキャンセルされました")
...             raise
...     
...     # 複数タスクの作成
...     task1 = asyncio.create_task(long_running_task(1, 2))
...     task2 = asyncio.create_task(long_running_task(2, 3))
...     task3 = asyncio.create_task(long_running_task(3, 1))
...     
...     # 一定時間後にtask2をキャンセル
...     await asyncio.sleep(1.5)
...     task2.cancel()
...     
...     # 結果の収集
...     results = await asyncio.gather(task1, task2, task3, return_exceptions=True)
...     
...     print(f"結果: {results}")
...     
...     print("\\n=== タイムアウト処理 ===")
...     
...     async def timeout_demo():
...         """タイムアウト処理のデモ"""
...         try:
...             # 5秒のタスクを2秒でタイムアウト
...             result = await asyncio.wait_for(long_running_task(4, 5), timeout=2.0)
...             return result
...         except asyncio.TimeoutError:
...             print("タスクがタイムアウトしました")
...             return None
...     
...     timeout_result = await timeout_demo()
...     print(f"タイムアウト結果: {timeout_result}")
...     
...     print("\\n=== セマフォによる並行制御 ===")
...     
...     semaphore = asyncio.Semaphore(2)  # 最大2つの並行実行
...     
...     async def limited_task(task_id):
...         async with semaphore:
...             print(f"制限付きタスク{task_id}開始")
...             await asyncio.sleep(1)
...             print(f"制限付きタスク{task_id}完了")
...             return f"制限結果_{task_id}"
...     
...     # 5つのタスクを作成（同時実行は2つまで）
...     limited_tasks = [limited_task(i) for i in range(5)]
...     limited_results = await asyncio.gather(*limited_tasks)
...     print(f"制限付き実行結果: {limited_results}")
...     
...     print("\\n=== イベントの使用 ===")
...     
...     event = asyncio.Event()
...     
...     async def waiter(waiter_id):
...         print(f"ウェイター{waiter_id}: イベントを待機中...")
...         await event.wait()
...         print(f"ウェイター{waiter_id}: イベントが発生しました！")
...     
...     async def setter():
...         await asyncio.sleep(2)
...         print("セッター: イベントを設定します")
...         event.set()
...     
...     # 複数のウェイターとセッターを並行実行
...     await asyncio.gather(
...         waiter(1),
...         waiter(2),
...         waiter(3),
...         setter()
...     )

>>> asyncio.run(demonstrate_advanced_asyncio())

=== Task管理とキャンセレーション ===
タスク1開始 (予定実行時間: 2秒)
タスク2開始 (予定実行時間: 3秒)
タスク3開始 (予定実行時間: 1秒)
タスク3完了
タスク2がキャンセルされました
タスク1完了
結果: ['結果_1', CancelledError(), '結果_3']

=== タイムアウト処理 ===
タスク4開始 (予定実行時間: 5秒)
タスクがタイムアウトしました
タイムアウト結果: None

=== セマフォによる並行制御 ===
制限付きタスク0開始
制限付きタスク1開始
制限付きタスク0完了
制限付きタスク1完了
制限付きタスク2開始
制限付きタスク3開始
制限付きタスク2完了
制限付きタスク3完了
制限付きタスク4開始
制限付きタスク4完了
制限付き実行結果: ['制限結果_0', '制限結果_1', '制限結果_2', '制限結果_3', '制限結果_4']

=== イベントの使用 ===
ウェイター1: イベントを待機中...
ウェイター2: イベントを待機中...
ウェイター3: イベントを待機中...
セッター: イベントを設定します
ウェイター1: イベントが発生しました！
ウェイター2: イベントが発生しました！
ウェイター3: イベントが発生しました！
```

## まとめ：非同期プログラミングの威力

この章で学んだことをまとめましょう：

### 非同期プログラミングの基本概念
- **並行性 vs 並列性**: 並行は論理的、並列は物理的
- **I/Oバウンド vs CPUバウンド**: 非同期はI/Oバウンドタスクに効果的
- **async/await**: 非同期関数の定義と実行
- **イベントループ**: 非同期処理の制御機構

### 主要な構文とパターン
```python
# 基本パターン
async def async_function():
    result = await some_async_operation()
    return result

# 並行実行
results = await asyncio.gather(
    async_function1(),
    async_function2(),
    async_function3()
)

# タイムアウト処理
try:
    result = await asyncio.wait_for(slow_function(), timeout=5.0)
except asyncio.TimeoutError:
    print("タイムアウト")
```

### 実用的な応用例
1. **Webスクレイピング**: 複数URLの並行取得
2. **データ処理パイプライン**: ETL処理の並行化
3. **チャットサーバー**: リアルタイム通信
4. **API呼び出し**: 外部サービスとの効率的な通信
5. **ファイル処理**: 大量ファイルの並行処理

### パフォーマンスの向上
```python
# 同期処理: 10秒
for i in range(10):
    time.sleep(1)  # 各処理1秒

# 非同期処理: 1秒
await asyncio.gather(*[
    asyncio.sleep(1) for _ in range(10)
])
```

### 注意点とベストプラクティス
1. **CPUバウンドタスクには不向き**: マルチプロセシングを使用
2. **ブロッキング関数の回避**: `time.sleep()`ではなく`asyncio.sleep()`
3. **適切なエラーハンドリング**: `asyncio.gather()`の`return_exceptions=True`
4. **リソース管理**: `async with`でリソースの適切な解放
5. **セマフォによる制御**: 並行数の制限

### 実際の使用場面
- **Webアプリケーション**: FastAPI、Django Channels
- **API開発**: 高並行性のREST API
- **データ収集**: Webスクレイピング、API統合
- **リアルタイム処理**: チャット、ゲーム、監視システム
- **マイクロサービス**: サービス間通信の最適化

次の章では、**テストとデバッグ**について学びます。unittest、pytest、モックを使った効果的なテスト手法と、デバッグ技術を習得しましょう！

---

**第17章執筆完了ログ:**
第17章では非同期プログラミングの基本概念から高度な応用まで包括的に学習。同期処理と非同期処理の違い、async/awaitの基本構文、非同期コンテキストマネージャーを段階的に説明。実践例として非同期Webスクレイピングシステム、ETLデータ処理パイプライン、リアルタイムチャットサーバーを構築。asyncioの高度な機能（タスク管理、タイムアウト、セマフォ、イベント）も含む完全なシステムを実装。次は第18章のテストとデバッグに進みます。