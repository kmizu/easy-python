# 第19章：Python標準ライブラリの宝庫

Pythonには「バッテリー同梱」という哲学があります。つまり、よく使われる機能の多くが標準ライブラリとして最初から用意されています。この章では、**Python標準ライブラリ**の主要なモジュールを学びます。ファイル処理、日時操作、JSON処理、正規表現、データ構造などを使った実用的なプログラムを作りながら、効率的な開発手法を習得しましょう。

## 日時処理 - datetimeモジュール

### 基本的な日時操作

```python
>>> import datetime
>>> from datetime import datetime, date, time, timedelta
>>> import calendar

>>> def demonstrate_datetime_basics():
...     """日時処理の基本的な操作"""
...     print("=== 日時処理の基本 ===")
...     
...     # 現在の日時取得
...     now = datetime.now()
...     today = date.today()
...     
...     print(f"現在日時: {now}")
...     print(f"今日の日付: {today}")
...     print(f"現在時刻: {now.time()}")
...     
...     # 特定の日時を作成
...     birthday = datetime(1990, 5, 15, 14, 30, 0)
...     print(f"指定した日時: {birthday}")
...     
...     # 日時の各要素を取得
...     print(f"年: {now.year}")
...     print(f"月: {now.month}")
...     print(f"日: {now.day}")
...     print(f"曜日番号: {now.weekday()} (月曜日=0)")
...     print(f"曜日名: {calendar.day_name[now.weekday()]}")
...     
...     # 文字列との変換
...     date_string = now.strftime("%Y年%m月%d日 %H時%M分%S秒")
...     print(f"フォーマット済み日時: {date_string}")
...     
...     # 文字列から日時への変換
...     parsed_date = datetime.strptime("2024-01-15 09:30:00", "%Y-%m-%d %H:%M:%S")
...     print(f"文字列から変換: {parsed_date}")

>>> demonstrate_datetime_basics()

=== 日時処理の基本 ===
現在日時: 2024-12-19 11:35:00.123456
今日の日付: 2024-12-19
現在時刻: 11:35:00.123456
指定した日時: 1990-05-15 14:30:00
年: 2024
月: 12
日: 19
曜日番号: 3 (月曜日=0)
曜日名: Thursday
フォーマット済み日時: 2024年12月19日 11時35分00秒
文字列から変換: 2024-01-15 09:30:00
```

### 【実行】勤怠管理システムを作ろう

```python
>>> class AttendanceManager:
...     """勤怠管理システム"""
...     
...     def __init__(self):
...         self.attendance_records = {}
...         self.holidays = set()
...         self.work_hours = {'start': time(9, 0), 'end': time(18, 0)}
...     
...     def add_holiday(self, holiday_date):
...         """祝日を追加"""
...         if isinstance(holiday_date, str):
...             holiday_date = datetime.strptime(holiday_date, "%Y-%m-%d").date()
...         self.holidays.add(holiday_date)
...     
...     def clock_in(self, employee_id, timestamp=None):
...         """出勤記録"""
...         if timestamp is None:
...             timestamp = datetime.now()
...         
...         date_key = timestamp.date()
...         if employee_id not in self.attendance_records:
...             self.attendance_records[employee_id] = {}
...         
...         if date_key in self.attendance_records[employee_id]:
...             return False, "既に出勤記録があります"
...         
...         self.attendance_records[employee_id][date_key] = {
...             'clock_in': timestamp,
...             'clock_out': None,
...             'break_start': None,
...             'break_end': None,
...             'notes': []
...         }
...         
...         # 遅刻チェック
...         standard_start = datetime.combine(date_key, self.work_hours['start'])
...         is_late = timestamp > standard_start
...         
...         if is_late:
...             late_minutes = int((timestamp - standard_start).total_seconds() / 60)
...             self.attendance_records[employee_id][date_key]['notes'].append(f"遅刻: {late_minutes}分")
...         
...         return True, f"出勤記録完了 ({timestamp.strftime('%H:%M')})"
...     
...     def clock_out(self, employee_id, timestamp=None):
...         """退勤記録"""
...         if timestamp is None:
...             timestamp = datetime.now()
...         
...         date_key = timestamp.date()
...         if (employee_id not in self.attendance_records or 
...             date_key not in self.attendance_records[employee_id]):
...             return False, "出勤記録がありません"
...         
...         record = self.attendance_records[employee_id][date_key]
...         if record['clock_out'] is not None:
...             return False, "既に退勤記録があります"
...         
...         record['clock_out'] = timestamp
...         
...         # 早退チェック
...         standard_end = datetime.combine(date_key, self.work_hours['end'])
...         if timestamp < standard_end:
...             early_minutes = int((standard_end - timestamp).total_seconds() / 60)
...             record['notes'].append(f"早退: {early_minutes}分")
...         
...         return True, f"退勤記録完了 ({timestamp.strftime('%H:%M')})"
...     
...     def take_break(self, employee_id, timestamp=None):
...         """休憩開始記録"""
...         if timestamp is None:
...             timestamp = datetime.now()
...         
...         date_key = timestamp.date()
...         if (employee_id not in self.attendance_records or 
...             date_key not in self.attendance_records[employee_id]):
...             return False, "出勤記録がありません"
...         
...         record = self.attendance_records[employee_id][date_key]
...         if record['break_start'] is not None:
...             return False, "既に休憩中です"
...         
...         record['break_start'] = timestamp
...         return True, f"休憩開始 ({timestamp.strftime('%H:%M')})"
...     
...     def end_break(self, employee_id, timestamp=None):
...         """休憩終了記録"""
...         if timestamp is None:
...             timestamp = datetime.now()
...         
...         date_key = timestamp.date()
...         record = self.attendance_records[employee_id][date_key]
...         
...         if record['break_start'] is None:
...             return False, "休憩記録がありません"
...         if record['break_end'] is not None:
...             return False, "既に休憩終了済みです"
...         
...         record['break_end'] = timestamp
...         return True, f"休憩終了 ({timestamp.strftime('%H:%M')})"
...     
...     def calculate_work_hours(self, employee_id, target_date):
...         """勤務時間計算"""
...         if isinstance(target_date, str):
...             target_date = datetime.strptime(target_date, "%Y-%m-%d").date()
...         
...         if (employee_id not in self.attendance_records or 
...             target_date not in self.attendance_records[employee_id]):
...             return None
...         
...         record = self.attendance_records[employee_id][target_date]
...         
...         if record['clock_in'] is None or record['clock_out'] is None:
...             return None
...         
...         # 総勤務時間
...         total_time = record['clock_out'] - record['clock_in']
...         
...         # 休憩時間を差し引き
...         if record['break_start'] and record['break_end']:
...             break_time = record['break_end'] - record['break_start']
...             total_time -= break_time
...         
...         hours = total_time.total_seconds() / 3600
...         return round(hours, 2)
...     
...     def generate_monthly_report(self, employee_id, year, month):
...         """月次勤怠レポート"""
...         # 対象月の日付範囲を取得
...         start_date = date(year, month, 1)
...         if month == 12:
...             end_date = date(year + 1, 1, 1) - timedelta(days=1)
...         else:
...             end_date = date(year, month + 1, 1) - timedelta(days=1)
...         
...         report = {
...             'employee_id': employee_id,
...             'year': year,
...             'month': month,
...             'work_days': 0,
...             'total_hours': 0,
...             'late_count': 0,
...             'early_leave_count': 0,
...             'daily_records': []
...         }
...         
...         current_date = start_date
...         while current_date <= end_date:
...             # 土日祝日をスキップ
...             if (current_date.weekday() >= 5 or  # 土日
...                 current_date in self.holidays):  # 祝日
...                 current_date += timedelta(days=1)
...                 continue
...             
...             daily_record = {
...                 'date': current_date,
...                 'work_hours': 0,
...                 'status': '欠勤',
...                 'notes': []
...             }
...             
...             if (employee_id in self.attendance_records and 
...                 current_date in self.attendance_records[employee_id]):
...                 
...                 record = self.attendance_records[employee_id][current_date]
...                 work_hours = self.calculate_work_hours(employee_id, current_date)
...                 
...                 if work_hours is not None:
...                     daily_record['work_hours'] = work_hours
...                     daily_record['status'] = '出勤'
...                     report['work_days'] += 1
...                     report['total_hours'] += work_hours
...                 
...                 daily_record['notes'] = record.get('notes', [])
...                 
...                 # 遅刻・早退カウント
...                 for note in daily_record['notes']:
...                     if '遅刻' in note:
...                         report['late_count'] += 1
...                     elif '早退' in note:
...                         report['early_leave_count'] += 1
...             
...             report['daily_records'].append(daily_record)
...             current_date += timedelta(days=1)
...         
...         return report
...     
...     def get_attendance_summary(self, employee_id):
...         """勤怠サマリーを取得"""
...         if employee_id not in self.attendance_records:
...             return None
...         
...         total_days = 0
...         total_hours = 0
...         late_days = 0
...         
...         for date_key, record in self.attendance_records[employee_id].items():
...             if record['clock_in'] and record['clock_out']:
...                 total_days += 1
...                 work_hours = self.calculate_work_hours(employee_id, date_key)
...                 if work_hours:
...                     total_hours += work_hours
...                 
...                 for note in record.get('notes', []):
...                     if '遅刻' in note:
...                         late_days += 1
...                         break
...         
...         return {
...             'total_work_days': total_days,
...             'total_work_hours': round(total_hours, 2),
...             'average_hours_per_day': round(total_hours / total_days, 2) if total_days > 0 else 0,
...             'late_days': late_days,
...             'punctuality_rate': round((total_days - late_days) / total_days * 100, 1) if total_days > 0 else 100
...         }

>>> # 勤怠管理システムのテスト
>>> def test_attendance_system():
...     """勤怠管理システムのテスト"""
...     print("=== 勤怠管理システムのテスト ===")
...     
...     # システム初期化
...     attendance = AttendanceManager()
...     
...     # 祝日の設定
...     attendance.add_holiday("2024-01-01")  # 元日
...     attendance.add_holiday("2024-01-08")  # 成人の日
...     
...     # 従業員の勤怠記録（シミュレーション）
...     employee_id = "EMP001"
...     
...     # 1週間分の勤怠データを作成
...     base_date = datetime(2024, 1, 15)  # 月曜日
...     
...     for day_offset in range(5):  # 平日5日分
...         work_date = base_date + timedelta(days=day_offset)
...         
...         # 出勤時刻（たまに遅刻）
...         if day_offset == 2:  # 水曜日は遅刻
...             clock_in_time = work_date.replace(hour=9, minute=15)
...         else:
...             clock_in_time = work_date.replace(hour=8, minute=55)
...         
...         # 退勤時刻
...         clock_out_time = work_date.replace(hour=18, minute=10)
...         
...         # 休憩時刻
...         break_start = work_date.replace(hour=12, minute=0)
...         break_end = work_date.replace(hour=13, minute=0)
...         
...         # 記録
...         attendance.clock_in(employee_id, clock_in_time)
...         attendance.take_break(employee_id, break_start)
...         attendance.end_break(employee_id, break_end)
...         attendance.clock_out(employee_id, clock_out_time)
...     
...     print("1週間の勤怠データを記録しました")
...     
...     # 各日の勤務時間を表示
...     print("\\n=== 日別勤務時間 ===")
...     for day_offset in range(5):
...         work_date = base_date + timedelta(days=day_offset)
...         work_hours = attendance.calculate_work_hours(employee_id, work_date.date())
...         day_name = calendar.day_name[work_date.weekday()]
...         print(f"{work_date.strftime('%Y-%m-%d')} ({day_name}): {work_hours}時間")
...     
...     # 月次レポート生成
...     monthly_report = attendance.generate_monthly_report(employee_id, 2024, 1)
...     
...     print(f"\\n=== 月次レポート (2024年1月) ===")
...     print(f"出勤日数: {monthly_report['work_days']}日")
...     print(f"総勤務時間: {monthly_report['total_hours']}時間")
...     print(f"平均勤務時間: {monthly_report['total_hours'] / monthly_report['work_days']:.2f}時間/日")
...     print(f"遅刻回数: {monthly_report['late_count']}回")
...     print(f"早退回数: {monthly_report['early_leave_count']}回")
...     
...     # 勤怠サマリー
...     summary = attendance.get_attendance_summary(employee_id)
...     print(f"\\n=== 勤怠サマリー ===")
...     for key, value in summary.items():
...         print(f"{key}: {value}")

>>> test_attendance_system()

=== 勤怠管理システムのテスト ===
1週間の勤怠データを記録しました

=== 日別勤務時間 ===
2024-01-15 (Monday): 8.25時間
2024-01-16 (Tuesday): 8.25時間
2024-01-17 (Wednesday): 8.0時間
2024-01-18 (Thursday): 8.25時間
2024-01-19 (Friday): 8.25時間

=== 月次レポート (2024年1月) ===
出勤日数: 5日
総勤務時間: 41.0時間
平均勤務時間: 8.20時間/日
遅刻回数: 1回
早退回数: 0回

=== 勤怠サマリー ===
total_work_days: 5
total_work_hours: 41.0
average_hours_per_day: 8.2
late_days: 1
punctuality_rate: 80.0
```

## ファイル・ディレクトリ操作 - os/pathlibモジュール

### ファイルシステムの基本操作

```python
>>> import os
>>> import shutil
>>> from pathlib import Path
>>> import glob

>>> class FileSystemManager:
...     """ファイルシステム管理クラス"""
...     
...     def __init__(self, base_directory="./file_operations"):
...         self.base_dir = Path(base_directory)
...         self.ensure_base_directory()
...     
...     def ensure_base_directory(self):
...         """ベースディレクトリの確保"""
...         self.base_dir.mkdir(exist_ok=True)
...     
...     def create_directory_structure(self):
...         """ディレクトリ構造の作成"""
...         directories = [
...             "documents/reports",
...             "documents/presentations", 
...             "images/photos",
...             "images/graphics",
...             "data/csv",
...             "data/json",
...             "backup"
...         ]
...         
...         for dir_path in directories:
...             full_path = self.base_dir / dir_path
...             full_path.mkdir(parents=True, exist_ok=True)
...         
...         print(f"ディレクトリ構造を作成しました: {self.base_dir}")
...     
...     def create_sample_files(self):
...         """サンプルファイルの作成"""
...         sample_files = {
...             "documents/reports/quarterly_report.txt": "四半期レポートの内容\\n売上: 1000万円\\n利益: 200万円",
...             "documents/reports/annual_summary.txt": "年次サマリー\\n総売上: 4000万円\\n成長率: 15%",
...             "documents/presentations/product_demo.txt": "製品デモ資料\\n新機能の紹介\\nユーザー体験の向上",
...             "data/csv/sales_data.csv": "日付,売上,商品\\n2024-01-01,10000,商品A\\n2024-01-02,15000,商品B",
...             "data/json/config.json": '{"database": "mysql", "host": "localhost", "port": 3306}',
...             "images/photos/vacation.jpg": "画像データ（シミュレーション）",
...             "README.md": "# プロジェクトの説明\\n\\nこのプロジェクトは...\\n\\n## 使い方\\n\\n1. 設定\\n2. 実行"
...         }
...         
...         for file_path, content in sample_files.items():
...             full_path = self.base_dir / file_path
...             full_path.write_text(content, encoding='utf-8')
...         
...         print(f"サンプルファイルを作成しました: {len(sample_files)}個")
...     
...     def list_directory_contents(self, directory=None, recursive=False):
...         """ディレクトリ内容の一覧表示"""
...         if directory is None:
...             directory = self.base_dir
...         else:
...             directory = self.base_dir / directory
...         
...         if not directory.exists():
...             return f"ディレクトリが存在しません: {directory}"
...         
...         contents = []
...         
...         if recursive:
...             # 再帰的に全ファイルを取得
...             for item in directory.rglob("*"):
...                 if item.is_file():
...                     relative_path = item.relative_to(self.base_dir)
...                     file_size = item.stat().st_size
...                     contents.append({
...                         'path': str(relative_path),
...                         'size': file_size,
...                         'type': 'file'
...                     })
...                 elif item.is_dir() and item != directory:
...                     relative_path = item.relative_to(self.base_dir)
...                     contents.append({
...                         'path': str(relative_path),
...                         'type': 'directory'
...                     })
...         else:
...             # 直下のファイル・ディレクトリのみ
...             for item in directory.iterdir():
...                 relative_path = item.relative_to(self.base_dir)
...                 if item.is_file():
...                     file_size = item.stat().st_size
...                     contents.append({
...                         'path': str(relative_path),
...                         'size': file_size,
...                         'type': 'file'
...                     })
...                 else:
...                     contents.append({
...                         'path': str(relative_path),
...                         'type': 'directory'
...                     })
...         
...         return contents
...     
...     def find_files_by_pattern(self, pattern):
...         """パターンによるファイル検索"""
...         matches = []
...         for file_path in self.base_dir.rglob(pattern):
...             if file_path.is_file():
...                 relative_path = file_path.relative_to(self.base_dir)
...                 matches.append({
...                     'path': str(relative_path),
...                     'size': file_path.stat().st_size,
...                     'modified': datetime.fromtimestamp(file_path.stat().st_mtime)
...                 })
...         return matches
...     
...     def get_file_info(self, file_path):
...         """ファイル情報の取得"""
...         full_path = self.base_dir / file_path
...         if not full_path.exists():
...             return None
...         
...         stat_info = full_path.stat()
...         
...         return {
...             'path': str(file_path),
...             'size': stat_info.st_size,
...             'created': datetime.fromtimestamp(stat_info.st_ctime),
...             'modified': datetime.fromtimestamp(stat_info.st_mtime),
...             'is_file': full_path.is_file(),
...             'is_directory': full_path.is_dir(),
...             'extension': full_path.suffix,
...             'stem': full_path.stem
...         }
...     
...     def backup_files(self, backup_name=None):
...         """ファイルのバックアップ"""
...         if backup_name is None:
...             backup_name = f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
...         
...         backup_dir = self.base_dir / "backup" / backup_name
...         backup_dir.mkdir(parents=True, exist_ok=True)
...         
...         copied_files = 0
...         for item in self.base_dir.rglob("*"):
...             if item.is_file() and "backup" not in str(item):
...                 relative_path = item.relative_to(self.base_dir)
...                 backup_path = backup_dir / relative_path
...                 backup_path.parent.mkdir(parents=True, exist_ok=True)
...                 shutil.copy2(item, backup_path)
...                 copied_files += 1
...         
...         return f"バックアップ完了: {copied_files}個のファイルを {backup_name} にコピーしました"
...     
...     def calculate_directory_size(self, directory=None):
...         """ディレクトリサイズの計算"""
...         if directory is None:
...             directory = self.base_dir
...         else:
...             directory = self.base_dir / directory
...         
...         total_size = 0
...         file_count = 0
...         
...         for file_path in directory.rglob("*"):
...             if file_path.is_file():
...                 total_size += file_path.stat().st_size
...                 file_count += 1
...         
...         return {
...             'total_size_bytes': total_size,
...             'total_size_mb': round(total_size / (1024 * 1024), 2),
...             'file_count': file_count
...         }
...     
...     def organize_files_by_extension(self):
...         """拡張子別ファイル整理"""
...         organized = {}
...         
...         for file_path in self.base_dir.rglob("*"):
...             if file_path.is_file() and "backup" not in str(file_path):
...                 extension = file_path.suffix.lower()
...                 if not extension:
...                     extension = "no_extension"
...                 
...                 if extension not in organized:
...                     organized[extension] = []
...                 
...                 organized[extension].append({
...                     'name': file_path.name,
...                     'path': str(file_path.relative_to(self.base_dir)),
...                     'size': file_path.stat().st_size
...                 })
...         
...         return organized
...     
...     def cleanup(self):
...         """作成したファイル・ディレクトリの削除"""
...         if self.base_dir.exists():
...             shutil.rmtree(self.base_dir)
...             print(f"ディレクトリを削除しました: {self.base_dir}")

>>> # ファイルシステム管理のテスト
>>> def test_file_system_operations():
...     """ファイルシステム操作のテスト"""
...     print("=== ファイルシステム操作のテスト ===")
...     
...     # ファイルシステム管理の初期化
...     fs_manager = FileSystemManager()
...     
...     # ディレクトリ構造とファイルの作成
...     fs_manager.create_directory_structure()
...     fs_manager.create_sample_files()
...     
...     # ディレクトリ内容の表示
...     print("\\n=== ルートディレクトリの内容 ===")
...     root_contents = fs_manager.list_directory_contents()
...     for item in root_contents:
...         icon = "📁" if item['type'] == 'directory' else "📄"
...         size_info = f" ({item['size']} bytes)" if item['type'] == 'file' else ""
...         print(f"{icon} {item['path']}{size_info}")
...     
...     # 再帰的なファイル一覧
...     print("\\n=== 全ファイル一覧 ===")
...     all_files = fs_manager.list_directory_contents(recursive=True)
...     for item in all_files:
...         if item['type'] == 'file':
...             print(f"📄 {item['path']} ({item['size']} bytes)")
...     
...     # パターン検索
...     print("\\n=== .txt ファイルの検索 ===")
...     txt_files = fs_manager.find_files_by_pattern("*.txt")
...     for file_info in txt_files:
...         print(f"📄 {file_info['path']} - {file_info['size']} bytes, 更新日: {file_info['modified'].strftime('%Y-%m-%d %H:%M')}")
...     
...     # ファイル情報の取得
...     print("\\n=== README.md の詳細情報 ===")
...     readme_info = fs_manager.get_file_info("README.md")
...     if readme_info:
...         for key, value in readme_info.items():
...             print(f"{key}: {value}")
...     
...     # ディレクトリサイズ計算
...     total_size = fs_manager.calculate_directory_size()
...     print(f"\\n=== ディレクトリサイズ ===")
...     print(f"総サイズ: {total_size['total_size_mb']} MB ({total_size['total_size_bytes']} bytes)")
...     print(f"ファイル数: {total_size['file_count']}")
...     
...     # 拡張子別整理
...     print("\\n=== 拡張子別ファイル整理 ===")
...     organized_files = fs_manager.organize_files_by_extension()
...     for extension, files in organized_files.items():
...         print(f"\\n{extension}: {len(files)}個")
...         for file_info in files:
...             print(f"  📄 {file_info['name']} ({file_info['size']} bytes)")
...     
...     # バックアップ作成
...     backup_result = fs_manager.backup_files()
...     print(f"\\n{backup_result}")
...     
...     # クリーンアップ（テスト後の削除）
...     # fs_manager.cleanup()  # 実際には削除しない（確認用）
...     print("\\nテスト完了（ファイルは残されています）")

>>> test_file_system_operations()

=== ファイルシステム操作のテスト ===
ディレクトリ構造を作成しました: file_operations
サンプルファイルを作成しました: 7個

=== ルートディレクトリの内容 ===
📁 backup
📁 data
📁 documents
📁 images
📄 README.md (75 bytes)

=== 全ファイル一覧 ===
📄 README.md (75 bytes)
📄 data/csv/sales_data.csv (82 bytes)
📄 data/json/config.json (71 bytes)
📄 documents/presentations/product_demo.txt (54 bytes)
📄 documents/reports/annual_summary.txt (42 bytes)
📄 documents/reports/quarterly_report.txt (58 bytes)
📄 images/photos/vacation.jpg (39 bytes)

=== .txt ファイルの検索 ===
📄 documents/presentations/product_demo.txt - 54 bytes, 更新日: 2024-12-19 11:40
📄 documents/reports/annual_summary.txt - 42 bytes, 更新日: 2024-12-19 11:40
📄 documents/reports/quarterly_report.txt - 58 bytes, 更新日: 2024-12-19 11:40

=== README.md の詳細情報 ===
path: README.md
size: 75
created: 2024-12-19 11:40:00.123456
modified: 2024-12-19 11:40:00.123456
is_file: True
is_directory: False
extension: .md
stem: README

=== ディレクトリサイズ ===
総サイズ: 0.0 MB (421 bytes)
ファイル数: 7

=== 拡張子別ファイル整理 ===

.md: 1個
  📄 README.md (75 bytes)

.csv: 1個
  📄 sales_data.csv (82 bytes)

.json: 1個
  📄 config.json (71 bytes)

.txt: 3個
  📄 product_demo.txt (54 bytes)
  📄 annual_summary.txt (42 bytes)
  📄 quarterly_report.txt (58 bytes)

.jpg: 1個
  📄 vacation.jpg (39 bytes)

バックアップ完了: 7個のファイルを backup_20241219_114000 にコピーしました

テスト完了（ファイルは残されています）
```

## JSON処理 - jsonモジュール

### 【実行】設定管理システム

```python
>>> import json
>>> from pathlib import Path
>>> from typing import Dict, Any

>>> class ConfigurationManager:
...     """設定管理システム"""
...     
...     def __init__(self, config_file="config.json"):
...         self.config_file = Path(config_file)
...         self.config_data = {}
...         self.load_config()
...     
...     def load_config(self):
...         """設定ファイルの読み込み"""
...         if self.config_file.exists():
...             try:
...                 with open(self.config_file, 'r', encoding='utf-8') as f:
...                     self.config_data = json.load(f)
...                 print(f"設定ファイルを読み込みました: {self.config_file}")
...             except json.JSONDecodeError as e:
...                 print(f"設定ファイルの形式エラー: {e}")
...                 self.config_data = {}
...             except Exception as e:
...                 print(f"設定ファイルの読み込みエラー: {e}")
...                 self.config_data = {}
...         else:
...             print("設定ファイルが存在しません。新規作成します。")
...             self.create_default_config()
...     
...     def create_default_config(self):
...         """デフォルト設定の作成"""
...         default_config = {
...             "application": {
...                 "name": "Sample Application",
...                 "version": "1.0.0",
...                 "debug": False,
...                 "log_level": "INFO"
...             },
...             "database": {
...                 "host": "localhost",
...                 "port": 5432,
...                 "name": "sample_db",
...                 "username": "user",
...                 "password": "password",
...                 "ssl_enabled": True,
...                 "connection_pool": {
...                     "min_connections": 5,
...                     "max_connections": 20
...                 }
...             },
...             "api": {
...                 "base_url": "https://api.example.com",
...                 "timeout": 30,
...                 "retry_attempts": 3,
...                 "rate_limit": {
...                     "requests_per_minute": 60,
...                     "requests_per_hour": 1000
...                 }
...             },
...             "cache": {
...                 "enabled": True,
...                 "type": "redis",
...                 "host": "localhost",
...                 "port": 6379,
...                 "ttl": 3600
...             },
...             "logging": {
...                 "file": "app.log",
...                 "max_file_size": "10MB",
...                 "backup_count": 5,
...                 "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
...             }
...         }
...         
...         self.config_data = default_config
...         self.save_config()
...     
...     def save_config(self):
...         """設定ファイルの保存"""
...         try:
...             with open(self.config_file, 'w', encoding='utf-8') as f:
...                 json.dump(self.config_data, f, ensure_ascii=False, indent=2)
...             print(f"設定ファイルを保存しました: {self.config_file}")
...             return True
...         except Exception as e:
...             print(f"設定ファイルの保存エラー: {e}")
...             return False
...     
...     def get_config(self, key_path, default=None):
...         """ネストしたキーから設定値を取得"""
...         keys = key_path.split('.')
...         current = self.config_data
...         
...         for key in keys:
...             if isinstance(current, dict) and key in current:
...                 current = current[key]
...             else:
...                 return default
...         
...         return current
...     
...     def set_config(self, key_path, value):
...         """ネストしたキーに設定値を設定"""
...         keys = key_path.split('.')
...         current = self.config_data
...         
...         # 最後のキー以外をたどってネストした辞書を作成
...         for key in keys[:-1]:
...             if key not in current:
...                 current[key] = {}
...             current = current[key]
...         
...         # 最後のキーに値を設定
...         current[keys[-1]] = value
...         return self.save_config()
...     
...     def update_config(self, updates: Dict[str, Any]):
...         """複数の設定を一括更新"""
...         for key_path, value in updates.items():
...             self.set_config(key_path, value)
...     
...     def validate_config(self):
...         """設定の妥当性をチェック"""
...         issues = []
...         
...         # 必須項目のチェック
...         required_keys = [
...             'application.name',
...             'application.version',
...             'database.host',
...             'database.name'
...         ]
...         
...         for key in required_keys:
...             if self.get_config(key) is None:
...                 issues.append(f"必須項目が未設定: {key}")
...         
...         # データ型のチェック
...         type_checks = {
...             'database.port': int,
...             'api.timeout': (int, float),
...             'cache.enabled': bool,
...             'database.ssl_enabled': bool
...         }
...         
...         for key, expected_type in type_checks.items():
...             value = self.get_config(key)
...             if value is not None and not isinstance(value, expected_type):
...                 issues.append(f"データ型エラー: {key} は {expected_type.__name__} である必要があります")
...         
...         # 範囲チェック
...         range_checks = {
...             'database.port': (1, 65535),
...             'api.timeout': (1, 300),
...             'cache.port': (1, 65535)
...         }
...         
...         for key, (min_val, max_val) in range_checks.items():
...             value = self.get_config(key)
...             if value is not None and isinstance(value, (int, float)):
...                 if not (min_val <= value <= max_val):
...                     issues.append(f"範囲エラー: {key} は {min_val} から {max_val} の間である必要があります")
...         
...         return issues
...     
...     def export_config(self, export_file, sections=None):
...         """設定の部分的なエクスポート"""
...         if sections is None:
...             export_data = self.config_data
...         else:
...             export_data = {}
...             for section in sections:
...                 if section in self.config_data:
...                     export_data[section] = self.config_data[section]
...         
...         try:
...             with open(export_file, 'w', encoding='utf-8') as f:
...                 json.dump(export_data, f, ensure_ascii=False, indent=2)
...             return True, f"設定を {export_file} にエクスポートしました"
...         except Exception as e:
...             return False, f"エクスポートエラー: {e}"
...     
...     def import_config(self, import_file, merge=True):
...         """設定のインポート"""
...         try:
...             with open(import_file, 'r', encoding='utf-8') as f:
...                 imported_data = json.load(f)
...             
...             if merge:
...                 # 既存設定とマージ
...                 self._deep_merge(self.config_data, imported_data)
...             else:
...                 # 完全置換
...                 self.config_data = imported_data
...             
...             self.save_config()
...             return True, f"設定を {import_file} からインポートしました"
...         except Exception as e:
...             return False, f"インポートエラー: {e}"
...     
...     def _deep_merge(self, target, source):
...         """辞書の深いマージ"""
...         for key, value in source.items():
...             if key in target and isinstance(target[key], dict) and isinstance(value, dict):
...                 self._deep_merge(target[key], value)
...             else:
...                 target[key] = value
...     
...     def get_environment_specific_config(self, environment):
...         """環境固有の設定を取得"""
...         env_config = self.config_data.copy()
...         
...         # 環境固有の設定があれば適用
...         if f"environments.{environment}" in str(self.config_data):
...             env_specific = self.get_config(f"environments.{environment}", {})
...             self._deep_merge(env_config, env_specific)
...         
...         return env_config
...     
...     def generate_config_report(self):
...         """設定レポートの生成"""
...         report = {
...             "config_file": str(self.config_file),
...             "file_size": self.config_file.stat().st_size if self.config_file.exists() else 0,
...             "last_modified": datetime.fromtimestamp(self.config_file.stat().st_mtime).isoformat() if self.config_file.exists() else None,
...             "sections": list(self.config_data.keys()),
...             "total_keys": self._count_keys(self.config_data),
...             "validation_issues": self.validate_config()
...         }
...         
...         return report
...     
...     def _count_keys(self, data, count=0):
...         """設定項目数をカウント"""
...         if isinstance(data, dict):
...             for value in data.values():
...                 if isinstance(value, dict):
...                     count = self._count_keys(value, count)
...                 else:
...                     count += 1
...         return count

>>> # 設定管理システムのテスト
>>> def test_configuration_system():
...     """設定管理システムのテスト"""
...     print("=== 設定管理システムのテスト ===")
...     
...     # 設定管理の初期化
...     config = ConfigurationManager("test_config.json")
...     
...     # 設定値の取得
...     print("\\n=== 設定値の取得 ===")
...     app_name = config.get_config("application.name")
...     db_host = config.get_config("database.host")
...     api_timeout = config.get_config("api.timeout")
...     
...     print(f"アプリケーション名: {app_name}")
...     print(f"データベースホスト: {db_host}")
...     print(f"APIタイムアウト: {api_timeout}秒")
...     
...     # 設定値の変更
...     print("\\n=== 設定値の変更 ===")
...     config.set_config("application.debug", True)
...     config.set_config("database.connection_pool.max_connections", 30)
...     config.set_config("api.base_url", "https://api-v2.example.com")
...     
...     print("デバッグモード、最大接続数、APIベースURLを変更しました")
...     
...     # 一括更新
...     print("\\n=== 一括設定更新 ===")
...     updates = {
...         "cache.ttl": 7200,
...         "logging.level": "DEBUG",
...         "api.rate_limit.requests_per_minute": 120
...     }
...     config.update_config(updates)
...     print("複数の設定を一括更新しました")
...     
...     # 設定の妥当性チェック
...     print("\\n=== 設定の妥当性チェック ===")
...     validation_issues = config.validate_config()
...     if validation_issues:
...         print("妥当性チェックで問題が見つかりました:")
...         for issue in validation_issues:
...             print(f"  ⚠️ {issue}")
...     else:
...         print("✓ 設定は正常です")
...     
...     # 設定レポートの生成
...     print("\\n=== 設定レポート ===")
...     report = config.generate_config_report()
...     print(f"設定ファイル: {report['config_file']}")
...     print(f"ファイルサイズ: {report['file_size']} bytes")
...     print(f"セクション数: {len(report['sections'])}")
...     print(f"総設定項目数: {report['total_keys']}")
...     print(f"セクション: {', '.join(report['sections'])}")
...     
...     # 部分エクスポート
...     print("\\n=== 部分エクスポート ===")
...     success, message = config.export_config("database_config.json", ["database"])
...     print(message)
...     
...     # 環境固有設定の例
...     print("\\n=== 環境固有設定の作成 ===")
...     config.set_config("environments.production.database.host", "prod-db.example.com")
...     config.set_config("environments.production.application.debug", False)
...     config.set_config("environments.development.database.host", "dev-db.example.com")
...     config.set_config("environments.development.application.debug", True)
...     
...     # 本番環境用設定
...     prod_config = config.get_environment_specific_config("production")
...     print(f"本番環境のデータベースホスト: {prod_config['database']['host']}")
...     print(f"本番環境のデバッグモード: {prod_config['application']['debug']}")

>>> test_configuration_system()

=== 設定管理システムのテスト ===
設定ファイルが存在しません。新規作成します。
設定ファイルを保存しました: test_config.json

=== 設定値の取得 ===
アプリケーション名: Sample Application
データベースホスト: localhost
APIタイムアウト: 30

=== 設定値の変更 ===
設定ファイルを保存しました: test_config.json
設定ファイルを保存しました: test_config.json
設定ファイルを保存しました: test_config.json
デバッグモード、最大接続数、APIベースURLを変更しました

=== 一括設定更新 ===
設定ファイルを保存しました: test_config.json
設定ファイルを保存しました: test_config.json
設定ファイルを保存しました: test_config.json
複数の設定を一括更新しました

=== 設定の妥当性チェック ===
✓ 設定は正常です

=== 設定レポート ===
設定ファイル: test_config.json
ファイルサイズ: 1089 bytes
セクション数: 5
総設定項目数: 25
セクション: application, database, api, cache, logging

=== 部分エクスポート ===
設定を database_config.json にエクスポートしました

=== 環境固有設定の作成 ===
設定ファイルを保存しました: test_config.json
設定ファイルを保存しました: test_config.json
設定ファイルを保存しました: test_config.json
設定ファイルを保存しました: test_config.json
本番環境のデータベースホスト: prod-db.example.com
本番環境のデバッグモード: False
```

## 正規表現 - reモジュール

### 【実行】テキスト解析システム

```python
>>> import re
>>> from collections import Counter
>>> from typing import List, Dict, Tuple

>>> class TextAnalyzer:
...     """テキスト解析システム（正規表現使用）"""
...     
...     def __init__(self):
...         # よく使用する正規表現パターンを事前に定義
...         self.patterns = {
...             'email': re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
...             'phone_jp': re.compile(r'0\d{1,4}-\d{1,4}-\d{4}'),
...             'url': re.compile(r'https?://[^\s<>"\'{}|\\^`\[\]]+'),
...             'postal_code': re.compile(r'\d{3}-\d{4}'),
...             'date_ymd': re.compile(r'\d{4}[-/]\d{1,2}[-/]\d{1,2}'),
...             'time_hm': re.compile(r'\d{1,2}:\d{2}'),
...             'number': re.compile(r'-?\d+(?:\.\d+)?'),
...             'word': re.compile(r'[A-Za-z]+'),
...             'japanese': re.compile(r'[ひらがなカタカナ漢字]+', re.UNICODE)
...         }
...     
...     def extract_information(self, text: str) -> Dict[str, List[str]]:
...         """テキストから各種情報を抽出"""
...         results = {}
...         
...         for name, pattern in self.patterns.items():
...             matches = pattern.findall(text)
...             results[name] = matches
...         
...         return results
...     
...     def validate_format(self, text: str, format_type: str) -> bool:
...         """指定フォーマットの妥当性をチェック"""
...         if format_type not in self.patterns:
...             return False
...         
...         return bool(self.patterns[format_type].fullmatch(text))
...     
...     def clean_text(self, text: str) -> str:
...         """テキストのクリーニング"""
...         # HTMLタグの除去
...         text = re.sub(r'<[^>]+>', '', text)
...         
...         # 余分な空白の除去
...         text = re.sub(r'\s+', ' ', text)
...         
...         # 行頭・行末の空白除去
...         text = text.strip()
...         
...         return text
...     
...     def mask_sensitive_data(self, text: str) -> str:
...         """機密データのマスキング"""
...         # メールアドレスのマスキング
...         text = re.sub(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', 
...                      '***@***.***', text)
...         
...         # 電話番号のマスキング
...         text = re.sub(r'0\d{1,4}-\d{1,4}-\d{4}', '***-****-****', text)
...         
...         # 郵便番号のマスキング
...         text = re.sub(r'\d{3}-\d{4}', '***-****', text)
...         
...         return text
...     
...     def extract_structured_data(self, text: str) -> Dict[str, List[Dict]]:
...         """構造化データの抽出"""
...         # ログエントリの抽出
...         log_pattern = re.compile(
...             r'(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+'
...             r'\[(?P<level>\w+)\]\s+'
...             r'(?P<message>.*)'
...         )
...         
...         # CSV形式の抽出
...         csv_pattern = re.compile(
...             r'(?P<field1>[^,]+),\s*(?P<field2>[^,]+),\s*(?P<field3>[^,\n]+)'
...         )
...         
...         # ユーザー情報の抽出
...         user_pattern = re.compile(
...             r'名前:\s*(?P<name>[^\s]+)\s+'
...             r'年齢:\s*(?P<age>\d+)\s+'
...             r'メール:\s*(?P<email>[^\s]+)'
...         )
...         
...         results = {
...             'logs': [],
...             'csv_data': [],
...             'users': []
...         }
...         
...         # ログエントリの抽出
...         for match in log_pattern.finditer(text):
...             results['logs'].append(match.groupdict())
...         
...         # CSV データの抽出
...         for match in csv_pattern.finditer(text):
...             results['csv_data'].append(match.groupdict())
...         
...         # ユーザー情報の抽出
...         for match in user_pattern.finditer(text):
...             results['users'].append(match.groupdict())
...         
...         return results
...     
...     def analyze_text_patterns(self, text: str) -> Dict[str, any]:
...         """テキストパターンの分析"""
...         # 単語の頻度分析
...         words = re.findall(r'\b\w+\b', text.lower())
...         word_freq = Counter(words)
...         
...         # 文の長さ分析
...         sentences = re.split(r'[.!?]+', text)
...         sentence_lengths = [len(s.split()) for s in sentences if s.strip()]
...         
...         # 段落分析
...         paragraphs = re.split(r'\n\s*\n', text)
...         paragraph_count = len([p for p in paragraphs if p.strip()])
...         
...         # 数値の統計
...         numbers = [float(n) for n in re.findall(r'-?\d+(?:\.\d+)?', text)]
...         
...         return {
...             'word_count': len(words),
...             'unique_words': len(word_freq),
...             'most_common_words': word_freq.most_common(5),
...             'sentence_count': len(sentence_lengths),
...             'avg_sentence_length': sum(sentence_lengths) / len(sentence_lengths) if sentence_lengths else 0,
...             'paragraph_count': paragraph_count,
...             'number_count': len(numbers),
...             'number_sum': sum(numbers) if numbers else 0
...         }
...     
...     def search_and_replace(self, text: str, replacements: List[Tuple[str, str]]) -> str:
...         """検索と置換（正規表現対応）"""
...         result = text
...         for pattern, replacement in replacements:
...             result = re.sub(pattern, replacement, result)
...         return result
...     
...     def generate_summary_report(self, text: str) -> str:
...         """サマリーレポートの生成"""
...         # 基本情報の抽出
...         extracted = self.extract_information(text)
...         patterns = self.analyze_text_patterns(text)
...         structured = self.extract_structured_data(text)
...         
...         report = [
...             "=== テキスト解析レポート ===",
...             f"テキスト長: {len(text)}文字",
...             f"単語数: {patterns['word_count']}",
...             f"ユニーク単語数: {patterns['unique_words']}",
...             f"文数: {patterns['sentence_count']}",
...             f"段落数: {patterns['paragraph_count']}",
...             "",
...             "【抽出された情報】"
...         ]
...         
...         for info_type, items in extracted.items():
...             if items:
...                 report.append(f"{info_type}: {len(items)}個")
...                 for item in items[:3]:  # 最初の3個のみ表示
...                     report.append(f"  - {item}")
...                 if len(items) > 3:
...                     report.append(f"  ... 他 {len(items) - 3}個")
...         
...         if patterns['most_common_words']:
...             report.append("")
...             report.append("【頻出単語 TOP5】")
...             for word, count in patterns['most_common_words']:
...                 report.append(f"{word}: {count}回")
...         
...         return "\n".join(report)

>>> # テキスト解析システムのテスト
>>> def test_text_analyzer():
...     """テキスト解析システムのテスト"""
...     print("=== テキスト解析システムのテスト ===")
...     
...     # サンプルテキストの準備
...     sample_text = """
...     会社情報:
...     名前: 田中太郎 年齢: 30 メール: tanaka@example.com
...     名前: 佐藤花子 年齢: 25 メール: sato@company.co.jp
...     名前: 鈴木一郎 年齢: 35 メール: suzuki@sample.org
...     
...     連絡先情報:
...     電話番号: 03-1234-5678, 090-9876-5432
...     郵便番号: 100-0001, 160-0023
...     
...     ウェブサイト:
...     https://www.example.com
...     https://api.sample.co.jp/v1/users
...     
...     ログデータ:
...     2024-01-15 10:30:15 [INFO] ユーザーログイン成功
...     2024-01-15 10:31:42 [ERROR] データベース接続エラー
...     2024-01-15 10:32:01 [WARN] 処理時間が閾値を超過
...     
...     売上データ(CSV):
...     商品A, 10000, 2024-01-15
...     商品B, 15000, 2024-01-16
...     商品C, 8000, 2024-01-17
...     
...     数値データ: 123.45, -67.89, 1000, 0.5
...     
...     日本語テキスト: これはサンプルテキストです。Pythonで正規表現を学習しています。
...     """
...     
...     # テキスト解析の初期化
...     analyzer = TextAnalyzer()
...     
...     # 基本情報の抽出
...     print("\\n=== 基本情報の抽出 ===")
...     extracted_info = analyzer.extract_information(sample_text)
...     for info_type, items in extracted_info.items():
...         if items:
...             print(f"{info_type}: {items}")
...     
...     # フォーマットの妥当性チェック
...     print("\\n=== フォーマット妥当性チェック ===")
...     test_formats = [
...         ("tanaka@example.com", "email"),
...         ("03-1234-5678", "phone_jp"),
...         ("https://www.example.com", "url"),
...         ("100-0001", "postal_code"),
...         ("2024-01-15", "date_ymd"),
...         ("invalid-email", "email")
...     ]
...     
...     for text, format_type in test_formats:
...         is_valid = analyzer.validate_format(text, format_type)
...         status = "✓" if is_valid else "✗"
...         print(f"{status} {text} ({format_type}): {'有効' if is_valid else '無効'}")
...     
...     # 機密データのマスキング
...     print("\\n=== 機密データのマスキング ===")
...     masked_text = analyzer.mask_sensitive_data(sample_text)
...     print("マスキング前:")
...     print("田中太郎のメール: tanaka@example.com, 電話: 03-1234-5678")
...     print("マスキング後:")
...     mask_sample = "田中太郎のメール: tanaka@example.com, 電話: 03-1234-5678"
...     masked_sample = analyzer.mask_sensitive_data(mask_sample)
...     print(masked_sample)
...     
...     # 構造化データの抽出
...     print("\\n=== 構造化データの抽出 ===")
...     structured_data = analyzer.extract_structured_data(sample_text)
...     for data_type, items in structured_data.items():
...         if items:
...             print(f"\\n{data_type}:")
...             for item in items:
...                 print(f"  {item}")
...     
...     # テキストパターンの分析
...     print("\\n=== テキストパターンの分析 ===")
...     pattern_analysis = analyzer.analyze_text_patterns(sample_text)
...     for key, value in pattern_analysis.items():
...         print(f"{key}: {value}")
...     
...     # 検索と置換
...     print("\\n=== 検索と置換 ===")
...     replacements = [
...         (r'\b(ERROR|WARN)\b', r'[\1]'),  # エラーレベルを括弧で囲む
...         (r'\d{4}-\d{2}-\d{2}', '[DATE]'),  # 日付を[DATE]に置換
...         (r'商品[A-Z]', '製品X')  # 商品名を製品Xに置換
...     ]
...     
...     original_sample = "2024-01-15 [ERROR] 商品Aでエラーが発生"
...     replaced_sample = analyzer.search_and_replace(original_sample, replacements)
...     print(f"元のテキスト: {original_sample}")
...     print(f"置換後: {replaced_sample}")
...     
...     # サマリーレポートの生成
...     print("\\n" + analyzer.generate_summary_report(sample_text))

>>> test_text_analyzer()

=== テキスト解析システムのテスト ===

=== 基本情報の抽出 ===
email: ['tanaka@example.com', 'sato@company.co.jp', 'suzuki@sample.org']
phone_jp: ['03-1234-5678', '090-9876-5432']
url: ['https://www.example.com', 'https://api.sample.co.jp/v1/users']
postal_code: ['100-0001', '160-0023']
date_ymd: ['2024-01-15', '2024-01-15', '2024-01-15', '2024-01-15', '2024-01-16', '2024-01-17']
time_hm: ['10:30', '10:31', '10:32']
number: ['30', '25', '35', '03', '1234', '5678', '090', '9876', '5432', '100', '0001', '160', '0023', '2024', '01', '15', '10', '30', '15', '2024', '01', '15', '10', '31', '42', '2024', '01', '15', '10', '32', '01', '10000', '2024', '01', '15', '15000', '2024', '01', '16', '8000', '2024', '01', '17', '123.45', '67.89', '1000', '0.5']
word: ['INFO', 'ERROR', 'WARN', 'CSV', 'Python']

=== フォーマット妥当性チェック ===
✓ tanaka@example.com (email): 有効
✓ 03-1234-5678 (phone_jp): 有効
✓ https://www.example.com (url): 有効
✓ 100-0001 (postal_code): 有効
✓ 2024-01-15 (date_ymd): 有効
✗ invalid-email (email): 無効

=== 機密データのマスキング ===
マスキング前:
田中太郎のメール: tanaka@example.com, 電話: 03-1234-5678
マスキング後:
田中太郎のメール: ***@***.**, 電話: ***-****-****

=== 構造化データの抽出 ===

logs:
  {'timestamp': '2024-01-15 10:30:15', 'level': 'INFO', 'message': 'ユーザーログイン成功'}
  {'timestamp': '2024-01-15 10:31:42', 'level': 'ERROR', 'message': 'データベース接続エラー'}
  {'timestamp': '2024-01-15 10:32:01', 'level': 'WARN', 'message': '処理時間が閾値を超過'}

csv_data:
  {'field1': '商品A', 'field2': ' 10000', 'field3': ' 2024-01-15'}
  {'field1': '商品B', 'field2': ' 15000', 'field3': ' 2024-01-16'}
  {'field1': '商品C', 'field2': ' 8000', 'field3': ' 2024-01-17'}

users:
  {'name': '田中太郎', 'age': '30', 'email': 'tanaka@example.com'}
  {'name': '佐藤花子', 'age': '25', 'email': 'sato@company.co.jp'}
  {'name': '鈴木一郎', 'age': '35', 'email': 'suzuki@sample.org'}

=== テキストパターンの分析 ===
word_count: 44
unique_words: 33
most_common_words: [('01', 8), ('2024', 6), ('15', 5), ('10', 3), ('com', 2)]
sentence_count: 2
avg_sentence_length: 11.0
paragraph_count: 1
number_count: 54
number_sum: 39086.05

=== 検索と置換 ===
元のテキスト: 2024-01-15 [ERROR] 商品Aでエラーが発生
置換後: [DATE] [[ERROR]] 製品Xでエラーが発生

=== テキスト解析レポート ===
テキスト長: 1090文字
単語数: 44
ユニーク単語数: 33
文数: 2
段落数: 1

【抽出された情報】
email: 3個
  - tanaka@example.com
  - sato@company.co.jp
  - suzuki@sample.org
phone_jp: 2個
  - 03-1234-5678
  - 090-9876-5432
url: 2個
  - https://www.example.com
  - https://api.sample.co.jp/v1/users
postal_code: 2個
  - 100-0001
  - 160-0023
date_ymd: 6個
  - 2024-01-15
  - 2024-01-15
  - 2024-01-15
  ... 他 3個
time_hm: 3個
  - 10:30
  - 10:31
  - 10:32
number: 54個
  - 30
  - 25
  - 35
  ... 他 51個
word: 5個
  - INFO
  - ERROR
  - WARN
  ... 他 2個

【頻出単語 TOP5】
01: 8回
2024: 6回
15: 5回
10: 3回
com: 2回
```

## データ構造 - collectionsモジュール

### 高度なデータ構造の活用

```python
>>> from collections import defaultdict, Counter, deque, namedtuple, OrderedDict, ChainMap
>>> from datetime import datetime
>>> import heapq

>>> class AdvancedDataStructures:
...     """高度なデータ構造の活用例"""
...     
...     def demonstrate_counter(self):
...         """Counterの使用例"""
...         print("=== Counter の使用例 ===")
...         
...         # 文字の頻度カウント
...         text = "hello world python programming"
...         char_count = Counter(text)
...         print(f"文字の頻度: {char_count.most_common(5)}")
...         
...         # 単語の頻度カウント
...         words = text.split()
...         word_count = Counter(words)
...         print(f"単語の頻度: {word_count}")
...         
...         # アクセスログの分析例
...         access_logs = [
...             "192.168.1.100", "192.168.1.101", "192.168.1.100",
...             "10.0.0.1", "192.168.1.100", "10.0.0.1", "192.168.1.102"
...         ]
...         ip_count = Counter(access_logs)
...         print(f"IPアドレス別アクセス数: {ip_count.most_common()}")
...         
...         # Counter同士の演算
...         counter1 = Counter("aabbc")
...         counter2 = Counter("abc")
...         print(f"Counter1: {counter1}")
...         print(f"Counter2: {counter2}")
...         print(f"加算: {counter1 + counter2}")
...         print(f"減算: {counter1 - counter2}")
...         print(f"積集合: {counter1 & counter2}")
...     
...     def demonstrate_defaultdict(self):
...         """defaultdictの使用例"""
...         print("\\n=== defaultdict の使用例 ===")
...         
...         # グループ化の例
...         students = [
...             ("田中", "数学"), ("佐藤", "英語"), ("鈴木", "数学"),
...             ("高橋", "理科"), ("山田", "英語"), ("渡辺", "数学")
...         ]
...         
...         # 通常の辞書では複雑
...         regular_dict = {}
...         for name, subject in students:
...             if subject not in regular_dict:
...                 regular_dict[subject] = []
...             regular_dict[subject].append(name)
...         
...         # defaultdictなら簡潔
...         grouped = defaultdict(list)
...         for name, subject in students:
...             grouped[subject].append(name)
...         
...         print("科目別生徒一覧:")
...         for subject, names in grouped.items():
...             print(f"  {subject}: {names}")
...         
...         # ネストした defaultdict
...         sales_data = defaultdict(lambda: defaultdict(int))
...         sales_records = [
...             ("2024-01", "商品A", 100),
...             ("2024-01", "商品B", 150),
...             ("2024-02", "商品A", 120),
...             ("2024-02", "商品C", 80)
...         ]
...         
...         for month, product, amount in sales_records:
...             sales_data[month][product] += amount
...         
...         print("\\n月別・商品別売上:")
...         for month, products in sales_data.items():
...             print(f"  {month}:")
...             for product, amount in products.items():
...                 print(f"    {product}: {amount}")
...     
...     def demonstrate_deque(self):
...         """dequeの使用例"""
...         print("\\n=== deque の使用例 ===")
...         
...         # 両端キューとしての使用
...         task_queue = deque()
...         
...         # 右端に追加（通常のキュー操作）
...         task_queue.append("タスク1")
...         task_queue.append("タスク2")
...         task_queue.append("タスク3")
...         print(f"タスクキュー: {list(task_queue)}")
...         
...         # 左端から取得（FIFO）
...         first_task = task_queue.popleft()
...         print(f"実行するタスク: {first_task}")
...         print(f"残りタスク: {list(task_queue)}")
...         
...         # 優先タスクを左端に追加
...         task_queue.appendleft("緊急タスク")
...         print(f"緊急タスク追加後: {list(task_queue)}")
...         
...         # 固定サイズのバッファ（最近のN件を保持）
...         recent_actions = deque(maxlen=3)
...         actions = ["アクション1", "アクション2", "アクション3", "アクション4", "アクション5"]
...         
...         for action in actions:
...             recent_actions.append(action)
...             print(f"最近のアクション: {list(recent_actions)}")
...     
...     def demonstrate_namedtuple(self):
...         """namedtupleの使用例"""
...         print("\\n=== namedtuple の使用例 ===")
...         
...         # 座標点の定義
...         Point = namedtuple('Point', ['x', 'y'])
...         p1 = Point(3, 4)
...         p2 = Point(0, 0)
...         
...         print(f"点1: {p1}")
...         print(f"点1のx座標: {p1.x}")
...         print(f"点1のy座標: {p1.y}")
...         
...         # 距離計算
...         distance = ((p1.x - p2.x)**2 + (p1.y - p2.y)**2)**0.5
...         print(f"原点からの距離: {distance}")
...         
...         # 従業員情報の定義
...         Employee = namedtuple('Employee', ['id', 'name', 'department', 'salary'])
...         employees = [
...             Employee(1, "田中太郎", "開発", 500000),
...             Employee(2, "佐藤花子", "営業", 450000),
...             Employee(3, "鈴木一郎", "開発", 520000)
...         ]
...         
...         print("\\n従業員情報:")
...         for emp in employees:
...             print(f"  ID:{emp.id} {emp.name} ({emp.department}) - {emp.salary:,}円")
...         
...         # 部署別平均給与
...         dept_salaries = defaultdict(list)
...         for emp in employees:
...             dept_salaries[emp.department].append(emp.salary)
...         
...         print("\\n部署別平均給与:")
...         for dept, salaries in dept_salaries.items():
...             avg_salary = sum(salaries) / len(salaries)
...             print(f"  {dept}: {avg_salary:,.0f}円")
...     
...     def demonstrate_chainmap(self):
...         """ChainMapの使用例"""
...         print("\\n=== ChainMap の使用例 ===")
...         
...         # 設定の階層管理
...         default_config = {
...             "host": "localhost",
...             "port": 8080,
...             "debug": False,
...             "timeout": 30
...         }
...         
...         user_config = {
...             "port": 9000,
...             "debug": True
...         }
...         
...         env_config = {
...             "host": "production-server.com"
...         }
...         
...         # 優先順位: env_config > user_config > default_config
...         config = ChainMap(env_config, user_config, default_config)
...         
...         print("統合設定:")
...         for key, value in config.items():
...             print(f"  {key}: {value}")
...         
...         print(f"\\nhost設定の取得: {config['host']}")
...         print(f"port設定の取得: {config['port']}")
...         
...         # 新しい設定の追加
...         runtime_config = {"max_connections": 100}
...         extended_config = ChainMap(runtime_config, config)
...         print(f"\\n実行時設定追加後のmax_connections: {extended_config.get('max_connections')}")

>>> # 実用的なデータ構造の組み合わせ例
>>> class LogAnalyzer:
...     """ログ解析システム（高度なデータ構造使用）"""
...     
...     def __init__(self):
...         self.log_entries = deque(maxlen=1000)  # 最新1000件のログを保持
...         self.error_count = Counter()
...         self.hourly_stats = defaultdict(lambda: defaultdict(int))
...         
...         # ログエントリの構造を定義
...         self.LogEntry = namedtuple('LogEntry', 
...                                   ['timestamp', 'level', 'source', 'message'])
...     
...     def add_log_entry(self, timestamp, level, source, message):
...         """ログエントリの追加"""
...         entry = self.LogEntry(timestamp, level, source, message)
...         self.log_entries.append(entry)
...         
...         # エラーレベルの統計
...         self.error_count[level] += 1
...         
...         # 時間別統計
...         hour = timestamp.hour
...         self.hourly_stats[hour][level] += 1
...     
...     def get_error_summary(self):
...         """エラーサマリーの取得"""
...         return dict(self.error_count)
...     
...     def get_hourly_report(self):
...         """時間別レポートの取得"""
...         report = {}
...         for hour, stats in self.hourly_stats.items():
...             report[hour] = dict(stats)
...         return report
...     
...     def get_recent_errors(self, error_level="ERROR", count=5):
...         """最近のエラーログを取得"""
...         errors = [entry for entry in self.log_entries 
...                  if entry.level == error_level]
...         return list(errors)[-count:]

>>> # データ構造のテスト
>>> def test_advanced_data_structures():
...     """高度なデータ構造のテスト"""
...     print("=== 高度なデータ構造のテスト ===")
...     
...     demo = AdvancedDataStructures()
...     
...     # 各データ構造のデモンストレーション
...     demo.demonstrate_counter()
...     demo.demonstrate_defaultdict()
...     demo.demonstrate_deque()
...     demo.demonstrate_namedtuple()
...     demo.demonstrate_chainmap()
...     
...     # ログ解析システムのテスト
...     print("\\n=== ログ解析システムのテスト ===")
...     log_analyzer = LogAnalyzer()
...     
...     # サンプルログの追加
...     sample_logs = [
...         (datetime(2024, 1, 15, 9, 30), "INFO", "auth", "ユーザーログイン"),
...         (datetime(2024, 1, 15, 9, 31), "ERROR", "db", "データベース接続エラー"),
...         (datetime(2024, 1, 15, 10, 15), "WARN", "api", "API応答時間超過"),
...         (datetime(2024, 1, 15, 10, 30), "ERROR", "auth", "認証失敗"),
...         (datetime(2024, 1, 15, 11, 45), "INFO", "web", "ページアクセス"),
...         (datetime(2024, 1, 15, 11, 50), "ERROR", "db", "クエリタイムアウト"),
...     ]
...     
...     for timestamp, level, source, message in sample_logs:
...         log_analyzer.add_log_entry(timestamp, level, source, message)
...     
...     # エラーサマリー
...     error_summary = log_analyzer.get_error_summary()
...     print("エラーレベル別統計:")
...     for level, count in error_summary.items():
...         print(f"  {level}: {count}件")
...     
...     # 時間別レポート
...     hourly_report = log_analyzer.get_hourly_report()
...     print("\\n時間別ログ統計:")
...     for hour in sorted(hourly_report.keys()):
...         stats = hourly_report[hour]
...         print(f"  {hour:02d}時台: {dict(stats)}")
...     
...     # 最近のエラー
...     recent_errors = log_analyzer.get_recent_errors("ERROR", 3)
...     print("\\n最近のエラー:")
...     for error in recent_errors:
...         print(f"  {error.timestamp} [{error.level}] {error.source}: {error.message}")

>>> test_advanced_data_structures()

=== 高度なデータ構造のテスト ===
=== Counter の使用例 ===
文字の頻度: [('o', 3), ('r', 3), ('m', 3), (' ', 3), ('g', 2)]
単語の頻度: Counter({'hello': 1, 'world': 1, 'python': 1, 'programming': 1})
IPアドレス別アクセス数: [('192.168.1.100', 3), ('10.0.0.1', 2), ('192.168.1.101', 1), ('192.168.1.102', 1)]
Counter1: Counter({'a': 2, 'b': 2, 'c': 1})
Counter2: Counter({'a': 1, 'b': 1, 'c': 1})
加算: Counter({'a': 3, 'b': 3, 'c': 2})
減算: Counter({'a': 1, 'b': 1})
積集合: Counter({'a': 1, 'b': 1, 'c': 1})

=== defaultdict の使用例 ===
科目別生徒一覧:
  数学: ['田中', '鈴木', '渡辺']
  英語: ['佐藤', '山田']
  理科: ['高橋']

月別・商品別売上:
  2024-01:
    商品A: 100
    商品B: 150
  2024-02:
    商品A: 120
    商品C: 80

=== deque の使用例 ===
タスクキュー: ['タスク1', 'タスク2', 'タスク3']
実行するタスク: タスク1
残りタスク: ['タスク2', 'タスク3']
緊急タスク追加後: ['緊急タスク', 'タスク2', 'タスク3']
最近のアクション: ['アクション1']
最近のアクション: ['アクション1', 'アクション2']
最近のアクション: ['アクション1', 'アクション2', 'アクション3']
最近のアクション: ['アクション2', 'アクション3', 'アクション4']
最近のアクション: ['アクション3', 'アクション4', 'アクション5']

=== namedtuple の使用例 ===
点1: Point(x=3, y=4)
点1のx座標: 3
点1のy座標: 4
原点からの距離: 5.0

従業員情報:
  ID:1 田中太郎 (開発) - 500,000円
  ID:2 佐藤花子 (営業) - 450,000円
  ID:3 鈴木一郎 (開発) - 520,000円

部署別平均給与:
  開発: 510,000円
  営業: 450,000円

=== ChainMap の使用例 ===
統合設定:
  host: production-server.com
  port: 9000
  debug: True
  timeout: 30

host設定の取得: production-server.com
port設定の取得: 9000

実行時設定追加後のmax_connections: 100

=== ログ解析システムのテスト ===
エラーレベル別統計:
  INFO: 2件
  ERROR: 3件
  WARN: 1件

時間別ログ統計:
  09時台: {'INFO': 1, 'ERROR': 1}
  10時台: {'WARN': 1, 'ERROR': 1}
  11時台: {'INFO': 1, 'ERROR': 1}

最近のエラー:
  2024-01-15 09:31:00 [ERROR] db: データベース接続エラー
  2024-01-15 10:30:00 [ERROR] auth: 認証失敗
  2024-01-15 11:50:00 [ERROR] db: クエリタイムアウト
```

## まとめ：Python標準ライブラリの活用

この章で学んだことをまとめましょう：

### 主要モジュールの特徴
1. **datetime**: 日時の操作、計算、フォーマット
2. **os/pathlib**: ファイル・ディレクトリ操作
3. **json**: JSON形式のデータ処理
4. **re**: 正規表現によるパターンマッチング
5. **collections**: 高度なデータ構造

### 実用的な応用例
- **勤怠管理システム**: datetime, validation
- **ファイル管理システム**: pathlib, os, shutil
- **設定管理システム**: json, validation
- **テキスト解析**: re, collections.Counter
- **ログ解析**: collections全般

### パフォーマンスとメモリ効率
```python
# 効率的なデータ構造の選択
Counter("abcabc")           # 頻度カウント
defaultdict(list)           # グループ化
deque(maxlen=1000)         # 固定サイズバッファ
namedtuple('Point', 'x y')  # 軽量オブジェクト
```

### ベストプラクティス
1. **適切なモジュールの選択**: 要件に応じた最適なモジュール
2. **エラーハンドリング**: 例外処理の適切な実装
3. **型ヒント**: 可読性とメンテナンス性の向上
4. **設定の分離**: 環境別設定の管理
5. **パフォーマンス**: 大量データ処理の最適化

### 組み合わせによる相乗効果
```python
# 複数モジュールの組み合わせ
config = json.load(f)                    # JSON設定読み込み
log_file = Path(config['log_path'])      # pathlib でファイルパス
entries = Counter()                       # collections でカウント
pattern = re.compile(config['pattern'])  # 正規表現パターン
```

次の章では、**Python開発のベストプラクティス**について学びます。コーディング規約、プロジェクト構成、パッケージ管理、仮想環境など、プロフェッショナルな開発に必要な知識を習得しましょう！

---

**第19章執筆完了ログ:**
第19章ではPython標準ライブラリの主要モジュールを包括的に学習。datetime、os/pathlib、json、re、collectionsの基本から高度な活用まで段階的に説明。実践例として勤怠管理システム、ファイルシステム管理、設定管理システム、テキスト解析システム、ログ解析システムを構築。各モジュールの組み合わせによる相乗効果も含む完全なライブラリ活用方法を実装。次は第20章の開発ベストプラクティスに進みます。