# 第19章：並行処理とマルチスレッド

## この章で学ぶこと

- スレッドとプロセスの違い
- GIL（Global Interpreter Lock）の影響
- threading モジュールの使用法
- multiprocessing による並列処理
- asyncio による非同期処理
- 並行処理のパターンと落とし穴

## 19.1 【実行】スレッドの基本とGILの影響

```python
# threading_basics.py

import threading
import time
import sys

# 基本的なスレッド作成
print("=== 基本的なスレッド ===")

def worker(name, delay):
    """ワーカー関数"""
    print(f"スレッド {name} 開始")
    time.sleep(delay)
    print(f"スレッド {name} 完了")

# スレッドを作成して実行
thread1 = threading.Thread(target=worker, args=("A", 2))
thread2 = threading.Thread(target=worker, args=("B", 1))

print("メインスレッド: スレッドを開始")
thread1.start()
thread2.start()

print("メインスレッド: 他の処理")
time.sleep(0.5)

# スレッドの完了を待つ
thread1.join()
thread2.join()
print("メインスレッド: 全スレッド完了")

# スレッドクラスの継承
print("\n=== スレッドクラスの継承 ===")

class WorkerThread(threading.Thread):
    def __init__(self, name, task_count):
        super().__init__()
        self.name = name
        self.task_count = task_count
        self.results = []
    
    def run(self):
        """スレッドのメイン処理"""
        print(f"{self.name}: 開始")
        for i in range(self.task_count):
            # 何らかの処理をシミュレート
            result = i ** 2
            self.results.append(result)
            print(f"{self.name}: タスク {i} 完了")
            time.sleep(0.1)
        print(f"{self.name}: 全タスク完了")

# カスタムスレッドを実行
worker_threads = []
for i in range(3):
    thread = WorkerThread(f"Worker-{i}", 3)
    worker_threads.append(thread)
    thread.start()

# 全スレッドの完了を待つ
for thread in worker_threads:
    thread.join()
    print(f"{thread.name}の結果: {thread.results}")

# GILの影響を確認
print("\n=== GILの影響 ===")

def cpu_intensive_task(n):
    """CPU集約的なタスク"""
    total = 0
    for i in range(n):
        total += i ** 2
    return total

def io_intensive_task(duration):
    """I/O集約的なタスク"""
    time.sleep(duration)
    return f"I/O完了: {duration}秒"

# CPU集約的タスクの並列化テスト
print("CPU集約的タスク:")
n = 1000000

# シーケンシャル実行
start_time = time.time()
result1 = cpu_intensive_task(n)
result2 = cpu_intensive_task(n)
sequential_time = time.time() - start_time

# マルチスレッド実行
start_time = time.time()
threads = []
results = []

def cpu_worker(n, results, index):
    result = cpu_intensive_task(n)
    results.append((index, result))

for i in range(2):
    thread = threading.Thread(target=cpu_worker, args=(n, results, i))
    threads.append(thread)
    thread.start()

for thread in threads:
    thread.join()

threaded_time = time.time() - start_time

print(f"シーケンシャル実行: {sequential_time:.4f}秒")
print(f"マルチスレッド実行: {threaded_time:.4f}秒")
print(f"効果: {sequential_time / threaded_time:.2f}倍")

# I/O集約的タスクの並列化テスト
print("\nI/O集約的タスク:")

# シーケンシャル実行
start_time = time.time()
io_result1 = io_intensive_task(1)
io_result2 = io_intensive_task(1)
sequential_io_time = time.time() - start_time

# マルチスレッド実行
start_time = time.time()
io_threads = []
io_results = []

def io_worker(duration, results):
    result = io_intensive_task(duration)
    results.append(result)

for _ in range(2):
    thread = threading.Thread(target=io_worker, args=(1, io_results))
    io_threads.append(thread)
    thread.start()

for thread in io_threads:
    thread.join()

threaded_io_time = time.time() - start_time

print(f"シーケンシャル実行: {sequential_io_time:.4f}秒")
print(f"マルチスレッド実行: {threaded_io_time:.4f}秒")
print(f"効果: {sequential_io_time / threaded_io_time:.2f}倍")

# スレッド情報の取得
print("\n=== スレッド情報 ===")
print(f"現在のスレッド: {threading.current_thread().name}")
print(f"メインスレッドか: {threading.current_thread() is threading.main_thread()}")
print(f"アクティブなスレッド数: {threading.active_count()}")
print(f"すべてのスレッド: {[t.name for t in threading.enumerate()]}")
```

### 【実行】スレッド同期とロック

```python
# thread_synchronization.py

import threading
import time
import random

# 共有リソースへの競合状態
print("=== 競合状態（Race Condition）===")

class Counter:
    def __init__(self):
        self.value = 0
    
    def increment(self):
        """カウンターをインクリメント（非同期的）"""
        temp = self.value
        time.sleep(0.0001)  # 他のスレッドに実行機会を与える
        self.value = temp + 1

# 競合状態のデモ
def unsafe_counting():
    counter = Counter()
    threads = []
    
    def worker():
        for _ in range(100):
            counter.increment()
    
    # 10個のスレッドでカウンターを操作
    for _ in range(10):
        thread = threading.Thread(target=worker)
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()
    
    print(f"期待値: 1000, 実際の値: {counter.value}")

unsafe_counting()

# ロックによる同期
print("\n=== ロックによる同期 ===")

class SafeCounter:
    def __init__(self):
        self.value = 0
        self.lock = threading.Lock()
    
    def increment(self):
        """ロックを使った安全なインクリメント"""
        with self.lock:
            temp = self.value
            time.sleep(0.0001)
            self.value = temp + 1

def safe_counting():
    counter = SafeCounter()
    threads = []
    
    def worker():
        for _ in range(100):
            counter.increment()
    
    for _ in range(10):
        thread = threading.Thread(target=worker)
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()
    
    print(f"期待値: 1000, 実際の値: {counter.value}")

safe_counting()

# RLock（再帰ロック）
print("\n=== RLock（再帰ロック）===")

class RecursiveCounter:
    def __init__(self):
        self.value = 0
        self.lock = threading.RLock()  # 再帰ロック
    
    def increment(self):
        with self.lock:
            self.value += 1
            if self.value < 5:
                self.increment()  # 再帰呼び出し
    
    def get_value(self):
        with self.lock:
            return self.value

recursive_counter = RecursiveCounter()
recursive_counter.increment()
print(f"再帰カウンター: {recursive_counter.get_value()}")

# セマフォ
print("\n=== セマフォ ===")

class ResourcePool:
    def __init__(self, size):
        self.semaphore = threading.Semaphore(size)
        self.resources = list(range(size))
        self.in_use = set()
        self.lock = threading.Lock()
    
    def acquire_resource(self):
        """リソースを取得"""
        self.semaphore.acquire()
        with self.lock:
            resource = self.resources.pop()
            self.in_use.add(resource)
            print(f"  スレッド{threading.current_thread().name}: "
                  f"リソース{resource}を取得")
            return resource
    
    def release_resource(self, resource):
        """リソースを解放"""
        with self.lock:
            self.in_use.remove(resource)
            self.resources.append(resource)
            print(f"  スレッド{threading.current_thread().name}: "
                  f"リソース{resource}を解放")
        self.semaphore.release()

def use_resource_pool():
    pool = ResourcePool(3)  # 3つのリソースを持つプール
    threads = []
    
    def worker(worker_id):
        resource = pool.acquire_resource()
        time.sleep(random.uniform(1, 3))  # リソースを使用
        pool.release_resource(resource)
    
    # 5つのスレッドが3つのリソースを競う
    for i in range(5):
        thread = threading.Thread(target=worker, args=(i,), name=f"Worker-{i}")
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()

use_resource_pool()

# イベント
print("\n=== イベント ===")

def event_example():
    """イベントを使った同期"""
    event = threading.Event()
    
    def waiter(name):
        print(f"{name}: イベントを待機中...")
        event.wait()
        print(f"{name}: イベントが発生しました！")
    
    def setter():
        time.sleep(2)
        print("Setter: イベントを設定")
        event.set()
    
    # 複数のスレッドがイベントを待つ
    waiters = []
    for i in range(3):
        thread = threading.Thread(target=waiter, args=(f"Waiter-{i}",))
        waiters.append(thread)
        thread.start()
    
    # イベントを設定するスレッド
    setter_thread = threading.Thread(target=setter)
    setter_thread.start()
    
    # すべてのスレッドの完了を待つ
    for thread in waiters:
        thread.join()
    setter_thread.join()

event_example()

# 条件変数
print("\n=== 条件変数 ===")

class ProducerConsumer:
    def __init__(self):
        self.items = []
        self.condition = threading.Condition()
    
    def produce(self, item):
        """アイテムを生産"""
        with self.condition:
            self.items.append(item)
            print(f"生産: {item}")
            self.condition.notify_all()  # 待機中の消費者に通知
    
    def consume(self):
        """アイテムを消費"""
        with self.condition:
            while not self.items:
                print("消費者: アイテムを待機中...")
                self.condition.wait()  # アイテムが来るまで待機
            
            item = self.items.pop(0)
            print(f"消費: {item}")
            return item

def producer_consumer_example():
    pc = ProducerConsumer()
    
    def producer():
        for i in range(5):
            time.sleep(1)
            pc.produce(f"item-{i}")
    
    def consumer(name):
        for _ in range(2):
            pc.consume()
    
    # 生産者1つ、消費者3つ
    producer_thread = threading.Thread(target=producer)
    consumer_threads = []
    
    for i in range(3):
        thread = threading.Thread(target=consumer, args=(f"Consumer-{i}",))
        consumer_threads.append(thread)
        thread.start()
    
    producer_thread.start()
    
    producer_thread.join()
    for thread in consumer_threads:
        thread.join()

producer_consumer_example()
```

## 19.2 【実行】multiprocessing による並列処理

```python
# multiprocessing_demo.py

import multiprocessing
import time
import os

# プロセスの基本
print("=== プロセスの基本 ===")

def worker_process(name, delay):
    """ワーカープロセス"""
    pid = os.getpid()
    print(f"プロセス {name} (PID: {pid}) 開始")
    time.sleep(delay)
    print(f"プロセス {name} (PID: {pid}) 完了")

def basic_multiprocessing():
    """基本的なマルチプロセシング"""
    print(f"メインプロセス PID: {os.getpid()}")
    
    # プロセスを作成
    processes = []
    for i in range(3):
        process = multiprocessing.Process(
            target=worker_process, 
            args=(f"Worker-{i}", i+1)
        )
        processes.append(process)
        process.start()
    
    # すべてのプロセスの完了を待つ
    for process in processes:
        process.join()
    
    print("全プロセス完了")

# GILの制約を回避したCPU集約的処理
print("\n=== CPU集約的処理の並列化 ===")

def cpu_intensive_task(n):
    """CPU集約的なタスク"""
    total = 0
    for i in range(n):
        total += i ** 2
    return total

def compare_performance():
    """性能比較"""
    n = 1000000
    num_processes = multiprocessing.cpu_count()
    
    print(f"CPU コア数: {num_processes}")
    
    # シーケンシャル実行
    start_time = time.time()
    results = []
    for _ in range(4):
        result = cpu_intensive_task(n)
        results.append(result)
    sequential_time = time.time() - start_time
    
    # マルチプロセッシング実行
    start_time = time.time()
    with multiprocessing.Pool(processes=num_processes) as pool:
        results = pool.map(cpu_intensive_task, [n] * 4)
    parallel_time = time.time() - start_time
    
    print(f"シーケンシャル実行: {sequential_time:.4f}秒")
    print(f"並列実行: {parallel_time:.4f}秒")
    print(f"高速化: {sequential_time / parallel_time:.2f}倍")

if __name__ == '__main__':
    basic_multiprocessing()
    compare_performance()

# プロセス間通信
print("\n=== プロセス間通信 ===")

def queue_communication():
    """キューを使ったプロセス間通信"""
    
    def producer(queue, name):
        """データを生産してキューに送信"""
        for i in range(5):
            item = f"{name}-item-{i}"
            queue.put(item)
            print(f"生産: {item}")
            time.sleep(0.5)
        queue.put(None)  # 終了シグナル
    
    def consumer(queue, name):
        """キューからデータを消費"""
        while True:
            item = queue.get()
            if item is None:
                break
            print(f"{name} 消費: {item}")
            time.sleep(0.3)
    
    # キューを作成
    queue = multiprocessing.Queue()
    
    # プロデューサーとコンシューマーを起動
    producer_process = multiprocessing.Process(
        target=producer, args=(queue, "Producer")
    )
    consumer_process = multiprocessing.Process(
        target=consumer, args=(queue, "Consumer")
    )
    
    producer_process.start()
    consumer_process.start()
    
    producer_process.join()
    consumer_process.join()

def pipe_communication():
    """パイプを使った双方向通信"""
    
    def child_process(conn):
        """子プロセス"""
        while True:
            try:
                data = conn.recv()
                if data == "exit":
                    break
                response = f"受信: {data}"
                conn.send(response)
                print(f"子プロセス: {response}")
            except EOFError:
                break
        conn.close()
    
    # パイプを作成
    parent_conn, child_conn = multiprocessing.Pipe()
    
    # 子プロセスを起動
    process = multiprocessing.Process(target=child_process, args=(child_conn,))
    process.start()
    
    # 親プロセスから送信
    for i in range(3):
        message = f"メッセージ-{i}"
        parent_conn.send(message)
        response = parent_conn.recv()
        print(f"親プロセス受信: {response}")
    
    parent_conn.send("exit")
    process.join()
    parent_conn.close()

def shared_memory():
    """共有メモリ"""
    
    def worker(shared_value, shared_array, index):
        """共有メモリを操作するワーカー"""
        with shared_value.get_lock():
            shared_value.value += 1
        
        for i in range(len(shared_array)):
            shared_array[i] += index
    
    # 共有変数と配列を作成
    shared_value = multiprocessing.Value('i', 0)
    shared_array = multiprocessing.Array('d', [1.0, 2.0, 3.0, 4.0])
    
    print(f"初期値: {shared_value.value}")
    print(f"初期配列: {list(shared_array)}")
    
    # 複数のプロセスで共有メモリを操作
    processes = []
    for i in range(3):
        process = multiprocessing.Process(
            target=worker, args=(shared_value, shared_array, i+1)
        )
        processes.append(process)
        process.start()
    
    for process in processes:
        process.join()
    
    print(f"最終値: {shared_value.value}")
    print(f"最終配列: {list(shared_array)}")

if __name__ == '__main__':
    print("キュー通信:")
    queue_communication()
    
    print("\nパイプ通信:")
    pipe_communication()
    
    print("\n共有メモリ:")
    shared_memory()

# プロセスプール
print("\n=== プロセスプール ===")

def process_pool_example():
    """プロセスプールの使用例"""
    
    def square(x):
        """数値の2乗を計算"""
        print(f"PID {os.getpid()}: {x}^2 を計算中")
        time.sleep(0.1)
        return x ** 2
    
    numbers = list(range(1, 11))
    
    # プロセスプールで並列処理
    with multiprocessing.Pool() as pool:
        print("プロセスプールで並列処理:")
        start_time = time.time()
        results = pool.map(square, numbers)
        pool_time = time.time() - start_time
        print(f"結果: {results}")
        print(f"実行時間: {pool_time:.4f}秒")
    
    # 非同期実行
    with multiprocessing.Pool() as pool:
        print("\n非同期実行:")
        start_time = time.time()
        async_result = pool.map_async(square, numbers)
        
        # 他の処理をしながら結果を待つ
        while not async_result.ready():
            print("他の処理を実行中...")
            time.sleep(0.2)
        
        results = async_result.get()
        async_time = time.time() - start_time
        print(f"結果: {results}")
        print(f"実行時間: {async_time:.4f}秒")

if __name__ == '__main__':
    process_pool_example()
```

## 19.3 【実行】asyncio による非同期処理

```python
# asyncio_demo.py

import asyncio
import time
import aiohttp
import aiofiles

# 基本的な非同期処理
print("=== 基本的な非同期処理 ===")

async def simple_coroutine(name, delay):
    """シンプルなコルーチン"""
    print(f"コルーチン {name} 開始")
    await asyncio.sleep(delay)
    print(f"コルーチン {name} 完了")
    return f"結果-{name}"

async def basic_async_example():
    """基本的な非同期実行の例"""
    start_time = time.time()
    
    # 順次実行
    print("順次実行:")
    await simple_coroutine("A", 2)
    await simple_coroutine("B", 1)
    sequential_time = time.time() - start_time
    
    # 並行実行
    print("\n並行実行:")
    start_time = time.time()
    task_a = simple_coroutine("X", 2)
    task_b = simple_coroutine("Y", 1)
    results = await asyncio.gather(task_a, task_b)
    concurrent_time = time.time() - start_time
    
    print(f"結果: {results}")
    print(f"順次実行時間: {sequential_time:.2f}秒")
    print(f"並行実行時間: {concurrent_time:.2f}秒")

# イベントループの操作
print("\n=== イベントループ ===")

async def event_loop_example():
    """イベントループの操作例"""
    
    # 現在のループを取得
    loop = asyncio.get_running_loop()
    print(f"現在のループ: {loop}")
    
    # タスクの作成と管理
    async def worker(name, work_time):
        print(f"タスク {name} 開始")
        await asyncio.sleep(work_time)
        print(f"タスク {name} 完了")
        return name
    
    # タスクを作成
    tasks = []
    for i in range(3):
        task = loop.create_task(worker(f"Task-{i}", i+1))
        tasks.append(task)
    
    # タスクの状態を確認
    print(f"作成されたタスク数: {len(tasks)}")
    
    # すべてのタスクの完了を待つ
    results = await asyncio.gather(*tasks)
    print(f"全タスク完了: {results}")

# 非同期コンテキストマネージャー
print("\n=== 非同期コンテキストマネージャー ===")

class AsyncResource:
    """非同期リソース管理"""
    
    def __init__(self, name):
        self.name = name
    
    async def __aenter__(self):
        print(f"リソース {self.name} を非同期で取得")
        await asyncio.sleep(0.1)  # 取得に時間がかかる
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        print(f"リソース {self.name} を非同期で解放")
        await asyncio.sleep(0.1)  # 解放に時間がかかる
        return False

async def async_context_example():
    """非同期コンテキストマネージャーの使用"""
    async with AsyncResource("Database") as resource:
        print(f"リソース {resource.name} を使用中")
        await asyncio.sleep(1)

# 非同期イテレータ
print("\n=== 非同期イテレータ ===")

class AsyncCounter:
    """非同期カウンター"""
    
    def __init__(self, max_count):
        self.max_count = max_count
        self.count = 0
    
    def __aiter__(self):
        return self
    
    async def __anext__(self):
        if self.count >= self.max_count:
            raise StopAsyncIteration
        
        await asyncio.sleep(0.5)  # 各要素の生成に時間がかかる
        self.count += 1
        return self.count

async def async_iterator_example():
    """非同期イテレータの使用"""
    print("非同期イテレーション開始:")
    async for number in AsyncCounter(5):
        print(f"受信: {number}")

# 非同期ジェネレータ
async def async_generator_example():
    """非同期ジェネレータ"""
    
    async def fetch_data():
        """データを非同期で取得するジェネレータ"""
        for i in range(5):
            await asyncio.sleep(0.3)
            yield f"データ-{i}"
    
    print("非同期ジェネレータ:")
    async for data in fetch_data():
        print(f"処理: {data}")

# 例外処理
print("\n=== 非同期での例外処理 ===")

async def failing_coroutine(name, should_fail=False):
    """失敗する可能性のあるコルーチン"""
    await asyncio.sleep(1)
    if should_fail:
        raise ValueError(f"コルーチン {name} でエラー発生")
    return f"成功: {name}"

async def exception_handling_example():
    """非同期での例外処理"""
    
    # 個別の例外処理
    try:
        result = await failing_coroutine("Test", should_fail=True)
        print(result)
    except ValueError as e:
        print(f"例外をキャッチ: {e}")
    
    # 複数タスクでの例外処理
    tasks = [
        failing_coroutine("A", False),
        failing_coroutine("B", True),
        failing_coroutine("C", False)
    ]
    
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    for i, result in enumerate(results):
        if isinstance(result, Exception):
            print(f"タスク {i}: 例外 - {result}")
        else:
            print(f"タスク {i}: 成功 - {result}")

# タイムアウト処理
async def timeout_example():
    """タイムアウト処理"""
    
    async def slow_operation():
        await asyncio.sleep(3)
        return "完了"
    
    try:
        # 2秒でタイムアウト
        result = await asyncio.wait_for(slow_operation(), timeout=2.0)
        print(f"結果: {result}")
    except asyncio.TimeoutError:
        print("タイムアウトしました")
    
    # キャンセル処理
    async def cancellable_task():
        try:
            await asyncio.sleep(5)
            return "キャンセルされませんでした"
        except asyncio.CancelledError:
            print("タスクがキャンセルされました")
            raise
    
    task = asyncio.create_task(cancellable_task())
    await asyncio.sleep(1)
    task.cancel()
    
    try:
        await task
    except asyncio.CancelledError:
        print("キャンセルされたタスクを処理")

# 非同期HTTP クライアント（aiohttp必要）
async def http_client_example():
    """非同期HTTPクライアントの例"""
    
    urls = [
        "https://httpbin.org/delay/1",
        "https://httpbin.org/delay/2",
        "https://httpbin.org/delay/1"
    ]
    
    async def fetch_url(session, url):
        """URLからデータを取得"""
        try:
            async with session.get(url) as response:
                data = await response.json()
                return f"取得成功: {url}"
        except Exception as e:
            return f"エラー {url}: {e}"
    
    # 順次実行
    start_time = time.time()
    async with aiohttp.ClientSession() as session:
        results = []
        for url in urls:
            result = await fetch_url(session, url)
            results.append(result)
    sequential_time = time.time() - start_time
    
    # 並行実行
    start_time = time.time()
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
    concurrent_time = time.time() - start_time
    
    print(f"順次実行: {sequential_time:.2f}秒")
    print(f"並行実行: {concurrent_time:.2f}秒")
    print(f"高速化: {sequential_time / concurrent_time:.2f}倍")

# メイン実行
async def main():
    """メイン実行関数"""
    print("=== Asyncio デモ ===")
    
    await basic_async_example()
    await event_loop_example()
    await async_context_example()
    await async_iterator_example()
    await async_generator_example()
    await exception_handling_example()
    await timeout_example()
    
    # HTTP例示（aiohttp が利用可能な場合）
    try:
        await http_client_example()
    except ImportError:
        print("aiohttp がインストールされていません")

# 実行
if __name__ == "__main__":
    asyncio.run(main())
```

## 19.4 【実行】並行処理のパターンと落とし穴

```python
# concurrency_patterns.py

import threading
import asyncio
import queue
import time
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import weakref

# プロデューサー・コンシューマーパターン
print("=== プロデューサー・コンシューマーパターン ===")

class ThreadSafeProducerConsumer:
    """スレッドセーフなプロデューサー・コンシューマー"""
    
    def __init__(self, max_size=10):
        self.queue = queue.Queue(maxsize=max_size)
        self.producers_done = False
        self.lock = threading.Lock()
    
    def produce(self, producer_id, items):
        """アイテムを生産"""
        for item in items:
            self.queue.put(f"{producer_id}-{item}")
            print(f"生産: {producer_id}-{item}")
            time.sleep(0.1)
        
        with self.lock:
            self.producers_done = True
        print(f"プロデューサー {producer_id} 完了")
    
    def consume(self, consumer_id):
        """アイテムを消費"""
        while True:
            try:
                item = self.queue.get(timeout=1)
                print(f"消費 ({consumer_id}): {item}")
                time.sleep(0.2)
                self.queue.task_done()
            except queue.Empty:
                with self.lock:
                    if self.producers_done and self.queue.empty():
                        break
        print(f"コンシューマー {consumer_id} 完了")

def producer_consumer_demo():
    """プロデューサー・コンシューマーのデモ"""
    pc = ThreadSafeProducerConsumer()
    threads = []
    
    # プロデューサーを起動
    for i in range(2):
        items = [f"item-{j}" for j in range(5)]
        thread = threading.Thread(
            target=pc.produce, 
            args=(f"Producer-{i}", items)
        )
        threads.append(thread)
        thread.start()
    
    # コンシューマーを起動
    for i in range(3):
        thread = threading.Thread(
            target=pc.consume, 
            args=(f"Consumer-{i}",)
        )
        threads.append(thread)
        thread.start()
    
    # すべてのスレッドの完了を待つ
    for thread in threads:
        thread.join()

producer_consumer_demo()

# ワーカープールパターン
print("\n=== ワーカープールパターン ===")

def worker_pool_pattern():
    """ワーカープールパターンの実装"""
    
    def cpu_task(n):
        """CPU集約的なタスク"""
        result = sum(i*i for i in range(n))
        return result
    
    def io_task(delay):
        """I/O集約的なタスク"""
        time.sleep(delay)
        return f"I/O完了: {delay}秒"
    
    # ThreadPoolExecutor（I/O集約的タスク向け）
    print("ThreadPoolExecutor:")
    with ThreadPoolExecutor(max_workers=4) as executor:
        start_time = time.time()
        future_to_delay = {
            executor.submit(io_task, delay): delay 
            for delay in [1, 1, 1, 1]
        }
        
        for future in future_to_delay:
            delay = future_to_delay[future]
            try:
                result = future.result()
                print(f"  {result}")
            except Exception as exc:
                print(f"  遅延{delay}でエラー: {exc}")
        
        thread_time = time.time() - start_time
    
    # ProcessPoolExecutor（CPU集約的タスク向け）
    print(f"\nThreadPool実行時間: {thread_time:.2f}秒")
    print("\nProcessPoolExecutor:")
    with ProcessPoolExecutor(max_workers=4) as executor:
        start_time = time.time()
        future_to_n = {
            executor.submit(cpu_task, n): n 
            for n in [100000, 100000, 100000, 100000]
        }
        
        for future in future_to_n:
            n = future_to_n[future]
            try:
                result = future.result()
                print(f"  CPU タスク({n}): {result}")
            except Exception as exc:
                print(f"  n={n}でエラー: {exc}")
        
        process_time = time.time() - start_time
    
    print(f"ProcessPool実行時間: {process_time:.2f}秒")

worker_pool_pattern()

# デッドロックの例と回避
print("\n=== デッドロックと回避方法 ===")

def deadlock_example():
    """デッドロックの例"""
    lock1 = threading.Lock()
    lock2 = threading.Lock()
    
    def thread1():
        print("スレッド1: lock1を取得")
        with lock1:
            time.sleep(0.1)
            print("スレッド1: lock2を取得しようとしています")
            with lock2:
                print("スレッド1: 両方のロックを取得")
    
    def thread2():
        print("スレッド2: lock2を取得")
        with lock2:
            time.sleep(0.1)
            print("スレッド2: lock1を取得しようとしています")
            with lock1:
                print("スレッド2: 両方のロックを取得")
    
    print("デッドロックの例（注意：ハングする可能性があります）")
    # 実際にはコメントアウトしてデッドロックを避ける
    # t1 = threading.Thread(target=thread1)
    # t2 = threading.Thread(target=thread2)
    # t1.start()
    # t2.start()
    # t1.join()
    # t2.join()

def deadlock_prevention():
    """デッドロック回避方法"""
    lock1 = threading.Lock()
    lock2 = threading.Lock()
    
    def thread1():
        print("スレッド1: 順序付きロック取得")
        with lock1:
            with lock2:  # 常に同じ順序でロックを取得
                print("スレッド1: 処理完了")
    
    def thread2():
        print("スレッド2: 順序付きロック取得")
        with lock1:  # 同じ順序
            with lock2:
                print("スレッド2: 処理完了")
    
    print("デッドロック回避（ロックの順序統一）:")
    t1 = threading.Thread(target=thread1)
    t2 = threading.Thread(target=thread2)
    
    t1.start()
    t2.start()
    t1.join()
    t2.join()

deadlock_example()
deadlock_prevention()

# メモリリークとリソース管理
print("\n=== メモリリークとリソース管理 ===")

class LeakyResource:
    """リークの可能性があるリソース"""
    instances = []  # 全インスタンスを保持（リーク原因）
    
    def __init__(self, name):
        self.name = name
        self.data = [0] * 10000  # 大量のデータ
        LeakyResource.instances.append(self)
    
    def cleanup(self):
        # 手動クリーンアップが必要
        LeakyResource.instances.remove(self)

class SafeResource:
    """安全なリソース管理"""
    _instances = weakref.WeakSet()
    
    def __init__(self, name):
        self.name = name
        self.data = [0] * 10000
        SafeResource._instances.add(self)
    
    @classmethod
    def get_instance_count(cls):
        return len(cls._instances)

def resource_management_demo():
    """リソース管理のデモ"""
    
    print(f"初期LeakyResourceインスタンス: {len(LeakyResource.instances)}")
    print(f"初期SafeResourceインスタンス: {SafeResource.get_instance_count()}")
    
    # リーキーリソースを作成
    leaky_resources = []
    for i in range(10):
        resource = LeakyResource(f"leaky-{i}")
        if i < 5:  # 半分だけ参照を保持
            leaky_resources.append(resource)
    
    # セーフリソースを作成
    safe_resources = []
    for i in range(10):
        resource = SafeResource(f"safe-{i}")
        if i < 5:  # 半分だけ参照を保持
            safe_resources.append(resource)
    
    print(f"作成後LeakyResourceインスタンス: {len(LeakyResource.instances)}")
    print(f"作成後SafeResourceインスタンス: {SafeResource.get_instance_count()}")
    
    # 参照を削除
    del leaky_resources
    del safe_resources
    
    import gc
    gc.collect()
    
    print(f"削除後LeakyResourceインスタンス: {len(LeakyResource.instances)}")
    print(f"削除後SafeResourceインスタンス: {SafeResource.get_instance_count()}")

resource_management_demo()

# 非同期での並行処理パターン
async def async_patterns():
    """非同期での並行処理パターン"""
    
    # セマフォによる同時実行数制限
    async def limited_concurrency_pattern():
        """同時実行数を制限するパターン"""
        semaphore = asyncio.Semaphore(3)  # 最大3つまで同時実行
        
        async def limited_task(task_id):
            async with semaphore:
                print(f"タスク {task_id} 開始")
                await asyncio.sleep(1)
                print(f"タスク {task_id} 完了")
                return task_id
        
        # 10個のタスクを作成（3つずつ実行される）
        tasks = [limited_task(i) for i in range(10)]
        results = await asyncio.gather(*tasks)
        print(f"制限付き並行実行結果: {results}")
    
    # バッチ処理パターン
    async def batch_processing_pattern():
        """バッチ処理パターン"""
        
        async def process_batch(batch_id, items):
            print(f"バッチ {batch_id} 処理開始: {items}")
            await asyncio.sleep(0.5)
            return [item * 2 for item in items]
        
        # データを分割してバッチ処理
        data = list(range(20))
        batch_size = 5
        batches = [data[i:i+batch_size] for i in range(0, len(data), batch_size)]
        
        tasks = [
            process_batch(i, batch) 
            for i, batch in enumerate(batches)
        ]
        
        results = await asyncio.gather(*tasks)
        flattened = [item for batch in results for item in batch]
        print(f"バッチ処理結果: {flattened}")
    
    # リトライパターン
    async def retry_pattern():
        """リトライパターン"""
        
        async def unreliable_operation(attempt_id):
            if attempt_id < 2:  # 最初の2回は失敗
                raise ValueError(f"失敗 {attempt_id}")
            return f"成功 {attempt_id}"
        
        async def retry_with_backoff(operation, max_retries=3):
            for attempt in range(max_retries):
                try:
                    result = await operation(attempt)
                    return result
                except Exception as e:
                    if attempt == max_retries - 1:
                        raise
                    wait_time = 2 ** attempt  # 指数バックオフ
                    print(f"試行 {attempt + 1} 失敗: {e}, {wait_time}秒待機")
                    await asyncio.sleep(wait_time)
        
        try:
            result = await retry_with_backoff(unreliable_operation)
            print(f"リトライ結果: {result}")
        except Exception as e:
            print(f"最終的に失敗: {e}")
    
    print("=== 非同期パターン ===")
    await limited_concurrency_pattern()
    await batch_processing_pattern()
    await retry_pattern()

# 実行
if __name__ == "__main__":
    asyncio.run(async_patterns())
```

## 19.5 この章のまとめ

- スレッドは軽量だがGILによりCPU集約的処理では制限される
- プロセスはGILを回避できるが、作成コストとメモリ使用量が大きい
- asyncioは単一スレッドでI/O集約的処理を効率化する
- 適切な同期プリミティブで競合状態を防ぐ
- デッドロックは適切な設計で回避可能
- リソース管理と例外処理が並行処理では特に重要

## 練習問題

1. **Webスクレイパー**
   複数のWebサイトから並行してデータを取得するスクレイパーを作成してください。

2. **ファイル処理システム**
   大量のファイルを並列処理するシステムを実装してください。

3. **チャットサーバー**
   複数のクライアントが同時接続できるチャットサーバーをasyncioで実装してください。

4. **監視システム**
   システムリソースを定期的に監視し、異常を検出するシステムを作成してください。

5. **負荷分散システム**
   複数のワーカープロセス間でタスクを分散するシステムを実装してください。

---

次章では、外部システムとの連携について学びます。

[第20章 外部システムとの連携 →](chapter20.md)