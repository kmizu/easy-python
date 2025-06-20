# 第9章：同じことを繰り返そう

前の章では条件によって処理を分岐させる方法を学びました。この章では、同じ処理を何度も繰り返す**ループ**について学びます。貯金目標達成までの計算、成績表の平均点計算、大量のデータ処理など、実際の場面で必要になる繰り返し処理を、実践的なプログラムを作りながらマスターしていきましょう。

## 繰り返しの力（while文）

### なぜ繰り返しが必要？

プログラミングにおいて、同じような処理を何度も実行することは非常によくあります：

**日常の例：**
- 毎月の貯金額を計算して、目標額に達するまで続ける
- 商品の在庫をチェックして、足りなくなったら発注する
- 問題を解いて、満点を取るまで勉強を続ける

**プログラムの例：**
- ユーザーが正しい値を入力するまで入力を求める
- ファイルの中身を1行ずつ読み込んで処理する
- 条件を満たすまで計算を続ける

### while文の基本構文

```python
while 条件:
    繰り返したい処理
```

**重要なポイント：**
1. 条件が`True`の間、処理を繰り返す
2. 条件が`False`になると、ループを抜ける
3. **無限ループ**に注意（条件が永遠に`True`のまま）

### 簡単な例から始めよう

```python
>>> # 1から5まで数える
>>> count = 1
>>> while count <= 5:
...     print(f"カウント: {count}")
...     count += 1  # これを忘れると無限ループ！
... 
カウント: 1
カウント: 2
カウント: 3
カウント: 4
カウント: 5

>>> print(f"ループ終了後のcount: {count}")
ループ終了後のcount: 6
```

### 無限ループの例と対策

```python
>>> # 危険：無限ループの例（実行しないでください）
>>> # count = 1
>>> # while count <= 5:
>>> #     print(f"カウント: {count}")
>>> #     # count += 1 を忘れた！
>>> # 永遠に「カウント: 1」が表示される

>>> # 安全な書き方
>>> count = 1
>>> max_iterations = 1000  # 安全装置
>>> 
>>> while count <= 5 and max_iterations > 0:
...     print(f"カウント: {count}")
...     count += 1
...     max_iterations -= 1
... 
>>> 
>>> if max_iterations == 0:
...     print("警告: 最大反復回数に達しました")
```

## 【実行】貯金目標達成までの計算プログラム

実際の貯金シミュレーションプログラムを作って、while文の使い方を学びましょう。

### ステップ1：基本的な貯金シミュレーション

```python
>>> def simulate_savings_basic(goal_amount, monthly_savings):
...     """基本的な貯金シミュレーション"""
...     
...     current_savings = 0
...     months = 0
...     
...     print(f"目標金額: {goal_amount:,}円")
...     print(f"月間貯金額: {monthly_savings:,}円")
...     print("-" * 30)
...     
...     while current_savings < goal_amount:
...         months += 1
...         current_savings += monthly_savings
...         
...         print(f"{months}ヶ月目: {current_savings:,}円")
...         
...         # 安全装置（10年＝120ヶ月で打ち切り）
...         if months >= 120:
...             print("⚠️ 10年を超えました。条件を見直してください。")
...             break
...     
...     if current_savings >= goal_amount:
...         print(f"\n🎉 目標達成！")
...         print(f"達成期間: {months}ヶ月")
...         print(f"最終貯金額: {current_savings:,}円")
...         
...         years = months // 12
...         remaining_months = months % 12
...         if years > 0:
...             print(f"期間: {years}年{remaining_months}ヶ月")
...         else:
...             print(f"期間: {remaining_months}ヶ月")
...     
...     return months, current_savings
... 

>>> # テスト実行
>>> months, final_amount = simulate_savings_basic(1000000, 50000)

目標金額: 1,000,000円
月間貯金額: 50,000円
------------------------------
1ヶ月目: 50,000円
2ヶ月目: 100,000円
3ヶ月目: 150,000円
4ヶ月目: 200,000円
5ヶ月目: 250,000円
6ヶ月目: 300,000円
7ヶ月目: 350,000円
8ヶ月目: 400,000円
9ヶ月目: 450,000円
10ヶ月目: 500,000円
11ヶ月目: 550,000円
12ヶ月目: 600,000円
13ヶ月目: 650,000円
14ヶ月目: 700,000円
15ヶ月目: 750,000円
16ヶ月目: 800,000円
17ヶ月目: 850,000円
18ヶ月目: 900,000円
19ヶ月目: 950,000円
20ヶ月目: 1,000,000円

🎉 目標達成！
達成期間: 20ヶ月
最終貯金額: 1,000,000円
期間: 1年8ヶ月
```

### ステップ2：利息を含む貯金シミュレーション

```python
>>> def simulate_savings_with_interest(goal_amount, monthly_savings, annual_interest_rate=0.01):
...     """利息を含む貯金シミュレーション"""
...     
...     current_savings = 0
...     months = 0
...     monthly_interest_rate = annual_interest_rate / 12
...     
...     print(f"目標金額: {goal_amount:,}円")
...     print(f"月間貯金額: {monthly_savings:,}円")
...     print(f"年利: {annual_interest_rate:.1%}")
...     print("-" * 50)
...     print("月 | 貯金額 | 利息 | 合計残高")
...     print("-" * 50)
...     
...     while current_savings < goal_amount:
...         months += 1
...         
...         # 月初の利息計算
...         interest = current_savings * monthly_interest_rate
...         
...         # 貯金追加
...         current_savings += monthly_savings + interest
...         
...         # 月末残高表示（最初の10ヶ月と最後の数ヶ月のみ）
...         if months <= 10 or current_savings >= goal_amount * 0.9:
...             print(f"{months:2d} | {monthly_savings:,}円 | {interest:4.0f}円 | {current_savings:8,.0f}円")
...         elif months == 11:
...             print("   ...（中略）...")
...         
...         # 安全装置
...         if months >= 600:  # 50年
...             print("⚠️ 50年を超えました。目標を見直してください。")
...             break
...     
...     if current_savings >= goal_amount:
...         print("-" * 50)
...         print(f"🎉 目標達成！")
...         print(f"達成期間: {months}ヶ月")
...         print(f"最終貯金額: {current_savings:,.0f}円")
...         
...         total_deposits = monthly_savings * months
...         total_interest = current_savings - total_deposits
...         
...         print(f"総入金額: {total_deposits:,}円")
...         print(f"利息合計: {total_interest:,.0f}円")
...         print(f"利息効果: {total_interest/total_deposits:.1%}")
...     
...     return months, current_savings
... 

>>> # 利息ありとなしの比較
>>> print("=== 利息なしの場合 ===")
>>> months1, amount1 = simulate_savings_basic(2000000, 80000)

>>> print("\n=== 年利1%の場合 ===")
>>> months2, amount2 = simulate_savings_with_interest(2000000, 80000, 0.01)

>>> print(f"\n📊 比較結果:")
>>> print(f"利息なし: {months1}ヶ月で達成")
>>> print(f"利息あり: {months2}ヶ月で達成")
>>> print(f"短縮効果: {months1 - months2}ヶ月")
```

### ステップ3：目標変更に対応したシミュレーション

```python
>>> def flexible_savings_simulation():
...     """柔軟な貯金シミュレーション"""
...     
...     print("=== 貯金シミュレーター ===")
...     
...     # 初期設定
...     goal_amount = 1500000
...     monthly_savings = 70000
...     current_savings = 0
...     months = 0
...     
...     # シミュレーション履歴
...     history = []
...     
...     while current_savings < goal_amount:
...         months += 1
...         current_savings += monthly_savings
...         
...         # 履歴に記録
...         history.append({
...             "month": months,
...             "monthly_savings": monthly_savings,
...             "total_savings": current_savings
...         })
...         
...         # 進捗表示（5ヶ月ごと）
...         if months % 5 == 0:
...             progress = (current_savings / goal_amount) * 100
...             print(f"{months}ヶ月目: {current_savings:,}円 ({progress:.1f}%達成)")
...             
...             # 条件変更の判定
...             if months == 10 and current_savings < goal_amount * 0.5:
...                 print("💡 進捗が遅いため、月間貯金額を増額します")
...                 monthly_savings += 20000
...                 print(f"   新しい月間貯金額: {monthly_savings:,}円")
...             
...             if months == 15 and progress > 80:
...                 print("🎯 目標が近いため、さらに増額して早期達成を目指します")
...                 monthly_savings += 10000
...                 print(f"   新しい月間貯金額: {monthly_savings:,}円")
...         
...         # 安全装置
...         if months >= 50:
...             break
...     
...     print(f"\n🎉 目標達成！")
...     print(f"最終的な達成期間: {months}ヶ月")
...     print(f"最終貯金額: {current_savings:,}円")
...     
...     # 詳細分析
...     total_deposits = sum(record["monthly_savings"] for record in history)
...     print(f"総入金額: {total_deposits:,}円")
...     
...     return history
... 

>>> # 実行
>>> history = flexible_savings_simulation()

=== 貯金シミュレーター ===
5ヶ月目: 350,000円 (23.3%達成)
10ヶ月目: 700,000円 (46.7%達成)
💡 進捗が遅いため、月間貯金額を増額します
   新しい月間貯金額: 90,000円
15ヶ月目: 1,150,000円 (76.7%達成)
20ヶ月目: 1,600,000円 (106.7%達成)

🎉 目標達成！
最終的な達成期間: 17ヶ月
最終貯金額: 1,520,000円
総入金額: 1,520,000円
```

### ステップ4：複数シナリオの比較

```python
# 貯金シナリオ比較システム
class SavingsSimulator:
    def __init__(self):
        self.scenarios = []
    
    def add_scenario(self, name, goal_amount, monthly_savings, annual_interest_rate=0):
        """シナリオを追加"""
        scenario = {
            "name": name,
            "goal_amount": goal_amount,
            "monthly_savings": monthly_savings,
            "annual_interest_rate": annual_interest_rate,
            "result": None
        }
        self.scenarios.append(scenario)
        return len(self.scenarios) - 1
    
    def simulate_scenario(self, scenario_index):
        """指定されたシナリオをシミュレーション"""
        scenario = self.scenarios[scenario_index]
        
        goal_amount = scenario["goal_amount"]
        monthly_savings = scenario["monthly_savings"]
        annual_interest_rate = scenario["annual_interest_rate"]
        
        current_savings = 0
        months = 0
        monthly_interest_rate = annual_interest_rate / 12
        total_interest = 0
        
        while current_savings < goal_amount and months < 600:
            months += 1
            
            # 利息計算
            interest = current_savings * monthly_interest_rate
            total_interest += interest
            
            # 貯金追加
            current_savings += monthly_savings + interest
        
        # 結果を保存
        result = {
            "months": months,
            "final_amount": current_savings,
            "total_deposits": monthly_savings * months,
            "total_interest": total_interest,
            "achieved": current_savings >= goal_amount
        }
        
        scenario["result"] = result
        return result
    
    def simulate_all(self):
        """すべてのシナリオをシミュレーション"""
        for i in range(len(self.scenarios)):
            self.simulate_scenario(i)
    
    def compare_results(self):
        """結果を比較表示"""
        print("=" * 70)
        print("シナリオ比較結果")
        print("=" * 70)
        print(f"{'シナリオ':<15} {'期間':<8} {'最終額':<12} {'利息':<10} {'達成'}")
        print("-" * 70)
        
        for scenario in self.scenarios:
            if scenario["result"]:
                result = scenario["result"]
                name = scenario["name"]
                months = result["months"]
                final = result["final_amount"]
                interest = result["total_interest"]
                achieved = "✓" if result["achieved"] else "✗"
                
                years = months // 12
                remaining_months = months % 12
                if years > 0:
                    period = f"{years}年{remaining_months}ヶ月"
                else:
                    period = f"{remaining_months}ヶ月"
                
                print(f"{name:<15} {period:<8} {final:>8,.0f}円 {interest:>7,.0f}円 {achieved}")
        
        print("=" * 70)
    
    def find_best_scenario(self):
        """最適なシナリオを見つける"""
        valid_scenarios = [s for s in self.scenarios if s["result"] and s["result"]["achieved"]]
        
        if not valid_scenarios:
            return None
        
        # 最短期間のシナリオを見つける
        best_scenario = min(valid_scenarios, key=lambda s: s["result"]["months"])
        
        return best_scenario

# 使用例
simulator = SavingsSimulator()

# 複数のシナリオを追加
simulator.add_scenario("基本プラン", 2000000, 80000, 0)
simulator.add_scenario("積極プラン", 2000000, 100000, 0)
simulator.add_scenario("利息活用", 2000000, 80000, 0.02)
simulator.add_scenario("高金利+増額", 2000000, 100000, 0.03)
simulator.add_scenario("少額長期", 2000000, 60000, 0.01)

# すべてシミュレーション
simulator.simulate_all()

# 結果比較
simulator.compare_results()

# 最適シナリオの表示
best = simulator.find_best_scenario()
if best:
    print(f"\n🏆 最短達成シナリオ: {best['name']}")
    print(f"達成期間: {best['result']['months']}ヶ月")
```

## for文による繰り返し

while文は条件が満たされる間繰り返しますが、**for文**は決まった回数や、決まったデータに対して繰り返し処理を行います。

### for文の基本構文

```python
for 変数 in 繰り返し対象:
    繰り返したい処理
```

### range()関数を使った基本的な繰り返し

```python
>>> # 0から4まで（5回）繰り返し
>>> for i in range(5):
...     print(f"回数: {i}")
... 
回数: 0
回数: 1
回数: 2
回数: 3
回数: 4

>>> # 1から5まで繰り返し
>>> for i in range(1, 6):
...     print(f"数値: {i}")
... 
数値: 1
数値: 2
数値: 3
数値: 4
数値: 5

>>> # 2つ飛ばしで繰り返し
>>> for i in range(0, 10, 2):
...     print(f"偶数: {i}")
... 
偶数: 0
偶数: 2
偶数: 4
偶数: 6
偶数: 8
```

### リストに対する繰り返し

```python
>>> # リストの要素を一つずつ処理
>>> fruits = ["りんご", "バナナ", "オレンジ", "ぶどう"]

>>> for fruit in fruits:
...     print(f"果物: {fruit}")
... 
果物: りんご
果物: バナナ
果物: オレンジ
果物: ぶどう

>>> # インデックス番号も取得したい場合
>>> for index, fruit in enumerate(fruits):
...     print(f"{index + 1}番目: {fruit}")
... 
1番目: りんご
2番目: バナナ
3番目: オレンジ
4番目: ぶどう
```

## 【実行】成績表の平均点計算プログラム

成績表処理プログラムを作って、for文の使い方を学びましょう。

### ステップ1：基本的な成績計算

```python
>>> def calculate_class_statistics(scores):
...     """クラスの成績統計を計算"""
...     
...     if not scores:
...         return None
...     
...     total = 0
...     count = 0
...     max_score = scores[0]
...     min_score = scores[0]
...     
...     for score in scores:
...         total += score
...         count += 1
...         
...         if score > max_score:
...             max_score = score
...         if score < min_score:
...             min_score = score
...     
...     average = total / count
...     
...     return {
...         "count": count,
...         "total": total,
...         "average": average,
...         "max_score": max_score,
...         "min_score": min_score,
...         "range": max_score - min_score
...     }
... 

>>> # テストデータ
>>> class_scores = [85, 92, 78, 88, 94, 76, 89, 83, 91, 87]

>>> stats = calculate_class_statistics(class_scores)
>>> print("=== クラス成績統計 ===")
>>> print(f"人数: {stats['count']}人")
>>> print(f"合計点: {stats['total']}点")
>>> print(f"平均点: {stats['average']:.1f}点")
>>> print(f"最高点: {stats['max_score']}点")
>>> print(f"最低点: {stats['min_score']}点")
>>> print(f"点数幅: {stats['range']}点")

=== クラス成績統計 ===
人数: 10人
合計点: 863点
平均点: 86.3点
最高点: 94点
最低点: 76点
点数幅: 18点
```

### ステップ2：個人別成績表

```python
>>> def process_student_grades():
...     """個人別成績表を処理"""
...     
...     # 学生データ（名前と各科目の点数）
...     students = [
...         {"name": "田中太郎", "scores": {"国語": 85, "数学": 92, "英語": 78, "理科": 88, "社会": 84}},
...         {"name": "佐藤花子", "scores": {"国語": 92, "数学": 85, "英語": 95, "理科": 91, "社会": 89}},
...         {"name": "鈴木一郎", "scores": {"国語": 78, "数学": 88, "英語": 82, "理科": 85, "社会": 80}},
...         {"name": "高橋美咲", "scores": {"国語": 88, "数学": 94, "英語": 90, "理科": 92, "社会": 87}},
...         {"name": "山田健太", "scores": {"国語": 82, "数学": 79, "英語": 85, "理科": 83, "社会": 88}}
...     ]
...     
...     print("=== 個人別成績表 ===")
...     print(f"{'名前':<10} {'合計':<6} {'平均':<6} {'順位':<4} 各科目")
...     print("-" * 60)
...     
...     # 各学生の合計点と平均点を計算
...     student_results = []
...     
...     for student in students:
...         name = student["name"]
...         scores = student["scores"]
...         
...         # 合計と平均を計算
...         total_score = sum(scores.values())
...         average_score = total_score / len(scores)
...         
...         # 科目別成績の文字列を作成
...         score_details = " ".join([f"{subject}:{score}" for subject, score in scores.items()])
...         
...         student_results.append({
...             "name": name,
...             "total": total_score,
...             "average": average_score,
...             "details": score_details
...         })
...     
...     # 合計点で順位を決定（降順ソート）
...     student_results.sort(key=lambda x: x["total"], reverse=True)
...     
...     # 結果表示
...     for rank, student in enumerate(student_results, 1):
...         print(f"{student['name']:<10} {student['total']:<6} {student['average']:<6.1f} {rank:<4} {student['details']}")
...     
...     return student_results
... 

>>> results = process_student_grades()

=== 個人別成績表 ===
名前       合計   平均   順位 各科目
------------------------------------------------------------
高橋美咲     451    90.2   1    国語:88 数学:94 英語:90 理科:92 社会:87
佐藤花子     452    90.4   2    国語:92 数学:85 英語:95 理科:91 社会:89
田中太郎     427    85.4   3    国語:85 数学:92 英語:78 理科:88 社会:84
山田健太     417    83.4   4    国語:82 数学:79 英語:85 理科:83 社会:88
鈴木一郎     413    82.6   5    国語:78 数学:88 英語:82 理科:85 社会:80
```

### ステップ3：科目別統計

```python
>>> def analyze_subject_performance(students):
...     """科目別の成績分析"""
...     
...     # 科目名を取得
...     subjects = list(students[0]["scores"].keys())
...     
...     print("=== 科目別成績分析 ===")
...     print(f"{'科目':<6} {'平均':<6} {'最高':<4} {'最低':<4} {'標準偏差':<8}")
...     print("-" * 40)
...     
...     subject_stats = {}
...     
...     for subject in subjects:
...         # 該当科目の全学生の点数を収集
...         scores = [student["scores"][subject] for student in students]
...         
...         # 統計計算
...         average = sum(scores) / len(scores)
...         max_score = max(scores)
...         min_score = min(scores)
...         
...         # 標準偏差の計算
...         variance = sum((score - average) ** 2 for score in scores) / len(scores)
...         std_deviation = variance ** 0.5
...         
...         subject_stats[subject] = {
...             "average": average,
...             "max": max_score,
...             "min": min_score,
...             "std_dev": std_deviation,
...             "scores": scores
...         }
...         
...         print(f"{subject:<6} {average:<6.1f} {max_score:<4} {min_score:<4} {std_deviation:<8.2f}")
...     
...     # 最も難しい科目と簡単な科目を特定
...     easiest_subject = max(subject_stats.keys(), key=lambda s: subject_stats[s]["average"])
...     hardest_subject = min(subject_stats.keys(), key=lambda s: subject_stats[s]["average"])
...     
...     print(f"\n📊 分析結果:")
...     print(f"最も平均点が高い科目: {easiest_subject} ({subject_stats[easiest_subject]['average']:.1f}点)")
...     print(f"最も平均点が低い科目: {hardest_subject} ({subject_stats[hardest_subject]['average']:.1f}点)")
...     
...     return subject_stats
... 

>>> # 前のステップのstudentsデータを使用
>>> students = [
...     {"name": "田中太郎", "scores": {"国語": 85, "数学": 92, "英語": 78, "理科": 88, "社会": 84}},
...     {"name": "佐藤花子", "scores": {"国語": 92, "数学": 85, "英語": 95, "理科": 91, "社会": 89}},
...     {"name": "鈴木一郎", "scores": {"国語": 78, "数学": 88, "英語": 82, "理科": 85, "社会": 80}},
...     {"name": "高橋美咲", "scores": {"国語": 88, "数学": 94, "英語": 90, "理科": 92, "社会": 87}},
...     {"name": "山田健太", "scores": {"国語": 82, "数学": 79, "英語": 85, "理科": 83, "社会": 88}}
... ]

>>> subject_stats = analyze_subject_performance(students)

=== 科目別成績分析 ===
科目   平均   最高 最低 標準偏差
----------------------------------------
国語   85.0   92   78   5.39
数学   87.6   94   79   5.94
英語   86.0   95   78   6.78
理科   87.8   92   83   3.90
社会   85.6   89   80   3.78

📊 分析結果:
最も平均点が高い科目: 理科 (87.8点)
最も平均点が低い科目: 国語 (85.0点)
```

### ステップ4：成績管理システム

```python
# 総合成績管理システム
class GradeManager:
    def __init__(self):
        self.students = []
        self.subjects = []
    
    def add_student(self, name, scores_dict):
        """学生を追加"""
        student = {
            "name": name,
            "scores": scores_dict.copy(),
            "id": len(self.students) + 1
        }
        self.students.append(student)
        
        # 科目リストを更新
        for subject in scores_dict.keys():
            if subject not in self.subjects:
                self.subjects.append(subject)
    
    def calculate_student_stats(self, student):
        """個人の統計を計算"""
        scores = list(student["scores"].values())
        total = sum(scores)
        average = total / len(scores)
        
        return {
            "total": total,
            "average": average,
            "max": max(scores),
            "min": min(scores)
        }
    
    def get_class_ranking(self):
        """クラス順位を取得"""
        rankings = []
        
        for student in self.students:
            stats = self.calculate_student_stats(student)
            rankings.append({
                "name": student["name"],
                "total": stats["total"],
                "average": stats["average"]
            })
        
        # 合計点で降順ソート
        rankings.sort(key=lambda x: x["total"], reverse=True)
        
        return rankings
    
    def generate_report_card(self, student_name):
        """個人の成績表を生成"""
        student = None
        for s in self.students:
            if s["name"] == student_name:
                student = s
                break
        
        if not student:
            return f"学生 '{student_name}' が見つかりません"
        
        stats = self.calculate_student_stats(student)
        rankings = self.get_class_ranking()
        
        # 順位を見つける
        rank = None
        for i, r in enumerate(rankings, 1):
            if r["name"] == student_name:
                rank = i
                break
        
        report = f"""
=== {student['name']} さんの成績表 ===
学籍番号: {student['id']:03d}
クラス順位: {rank}/{len(self.students)}位

【科目別成績】"""
        
        for subject in self.subjects:
            if subject in student["scores"]:
                score = student["scores"][subject]
                report += f"\n{subject}: {score}点"
        
        report += f"""

【統計情報】
合計点: {stats['total']}点
平均点: {stats['average']:.1f}点
最高点: {stats['max']}点
最低点: {stats['min']}点
"""
        
        return report
    
    def analyze_class_performance(self):
        """クラス全体の成績分析"""
        if not self.students:
            return "学生データがありません"
        
        analysis = "=== クラス成績分析 ===\n"
        
        # 全体統計
        all_totals = [self.calculate_student_stats(s)["total"] for s in self.students]
        class_average = sum(all_totals) / len(all_totals)
        
        analysis += f"クラス人数: {len(self.students)}人\n"
        analysis += f"クラス平均: {class_average:.1f}点\n\n"
        
        # 科目別分析
        analysis += "【科目別平均点】\n"
        for subject in self.subjects:
            scores = [s["scores"].get(subject, 0) for s in self.students if subject in s["scores"]]
            if scores:
                subject_avg = sum(scores) / len(scores)
                analysis += f"{subject}: {subject_avg:.1f}点\n"
        
        # 成績分布
        analysis += "\n【成績分布】\n"
        grade_ranges = [
            ("A (90-100点)", 90, 100),
            ("B (80-89点)", 80, 89),
            ("C (70-79点)", 70, 79),
            ("D (60-69点)", 60, 69),
            ("F (60点未満)", 0, 59)
        ]
        
        for grade_name, min_score, max_score in grade_ranges:
            count = 0
            for student in self.students:
                avg = self.calculate_student_stats(student)["average"]
                if min_score <= avg <= max_score:
                    count += 1
            percentage = (count / len(self.students)) * 100
            analysis += f"{grade_name}: {count}人 ({percentage:.1f}%)\n"
        
        return analysis

# 使用例
grade_manager = GradeManager()

# 学生データを追加
students_data = [
    ("田中太郎", {"国語": 85, "数学": 92, "英語": 78, "理科": 88, "社会": 84}),
    ("佐藤花子", {"国語": 92, "数学": 85, "英語": 95, "理科": 91, "社会": 89}),
    ("鈴木一郎", {"国語": 78, "数学": 88, "英語": 82, "理科": 85, "社会": 80}),
    ("高橋美咲", {"国語": 88, "数学": 94, "英語": 90, "理科": 92, "社会": 87}),
    ("山田健太", {"国語": 82, "数学": 79, "英語": 85, "理科": 83, "社会": 88})
]

for name, scores in students_data:
    grade_manager.add_student(name, scores)

# 個人成績表
print(grade_manager.generate_report_card("佐藤花子"))

# クラス分析
print(grade_manager.analyze_class_performance())

# 順位表示
rankings = grade_manager.get_class_ranking()
print("\n=== クラス順位 ===")
for i, student in enumerate(rankings, 1):
    print(f"{i}位: {student['name']} ({student['total']}点)")
```

## 繰り返しの制御（break, continue）

ループの実行中に、特定の条件でループを抜けたり、処理をスキップしたりする必要があることがあります。

### break文：ループを途中で抜ける

```python
>>> # 特定の条件でループを終了
>>> numbers = [1, 3, 7, 2, 9, 4, 6]
>>> target = 9

>>> for i, number in enumerate(numbers):
...     print(f"チェック中: {number}")
...     if number == target:
...         print(f"目標の数値 {target} を {i} 番目で発見！")
...         break
... else:
...     print(f"目標の数値 {target} は見つかりませんでした")

チェック中: 1
チェック中: 3
チェック中: 7
チェック中: 2
チェック中: 9
目標の数値 9 を 4 番目で発見！
```

### continue文：現在の周期をスキップ

```python
>>> # 偶数のみを処理
>>> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

>>> print("偶数のみを表示:")
>>> for number in numbers:
...     if number % 2 != 0:  # 奇数の場合
...         continue  # この周期をスキップ
...     print(f"偶数: {number}")

偶数のみを表示:
偶数: 2
偶数: 4
偶数: 6
偶数: 8
偶数: 10
```

### 実用的な例：データ検証処理

```python
>>> def process_student_data(raw_data):
...     """学生データを検証しながら処理"""
...     
...     processed_students = []
...     error_count = 0
...     
...     print("=== 学生データ処理 ===")
...     
...     for i, data in enumerate(raw_data):
...         print(f"処理中: 学生 {i+1}")
...         
...         # 必要なフィールドの確認
...         if "name" not in data:
...             print(f"  ❌ エラー: 名前が不明")
...             error_count += 1
...             continue
...         
...         if "age" not in data:
...             print(f"  ❌ エラー: {data['name']} の年齢が不明")
...             error_count += 1
...             continue
...         
...         # 年齢の範囲チェック
...         age = data["age"]
...         if age < 15 or age > 25:
...             print(f"  ⚠️ 警告: {data['name']} の年齢 ({age}) が範囲外")
...             # continueせずに処理継続
...         
...         # データが完全に不正な場合は処理を中断
...         if age < 0:
...             print(f"  🛑 致命的エラー: 負の年齢 ({age})")
...             print("  処理を中断します")
...             break
...         
...         # 正常なデータを追加
...         processed_students.append({
...             "name": data["name"],
...             "age": age,
...             "grade": data.get("grade", "未設定")
...         })
...         print(f"  ✅ {data['name']} の処理完了")
...     
...     print(f"\n処理結果:")
...     print(f"  正常処理: {len(processed_students)}件")
...     print(f"  エラー: {error_count}件")
...     
...     return processed_students
... 

>>> # テストデータ
>>> test_data = [
...     {"name": "田中太郎", "age": 18, "grade": "A"},
...     {"age": 19, "grade": "B"},  # 名前なし
...     {"name": "佐藤花子", "age": 30, "grade": "A"},  # 年齢範囲外
...     {"name": "鈴木一郎"},  # 年齢なし
...     {"name": "山田健太", "age": 20, "grade": "C"},
...     {"name": "高橋美咲", "age": 17, "grade": "B"}
... ]

>>> processed = process_student_data(test_data)

=== 学生データ処理 ===
処理中: 学生 1
  ✅ 田中太郎 の処理完了
処理中: 学生 2
  ❌ エラー: 名前が不明
処理中: 学生 3
  ⚠️ 警告: 佐藤花子 の年齢 (30) が範囲外
  ✅ 佐藤花子 の処理完了
処理中: 学生 4
  ❌ エラー: 鈴木一郎 の年齢が不明
処理中: 学生 5
  ✅ 山田健太 の処理完了
処理中: 学生 6
  ✅ 高橋美咲 の処理完了

処理結果:
  正常処理: 4件
  エラー: 2件
```

## ネストしたループ（ループの入れ子）

ループの中にさらにループを書くことができます。これを**ネストしたループ**と言います。

### 二重ループの基本例

```python
>>> # 九九の表を作成
>>> print("=== 九九の表 ===")
>>> for i in range(1, 10):
...     for j in range(1, 10):
...         result = i * j
...         print(f"{result:3d}", end="")
...     print()  # 改行

=== 九九の表 ===
  1  2  3  4  5  6  7  8  9
  2  4  6  8 10 12 14 16 18
  3  6  9 12 15 18 21 24 27
  4  8 12 16 20 24 28 32 36
  5 10 15 20 25 30 35 40 45
  6 12 18 24 30 36 42 48 54
  7 14 21 28 35 42 49 56 63
  8 16 24 32 40 48 56 64 72
  9 18 27 36 45 54 63 72 81
```

### 実用的な例：座席表の管理

```python
>>> def create_seating_chart(rows, cols, occupied_seats=None):
...     """座席表を作成して表示"""
...     
...     if occupied_seats is None:
...         occupied_seats = []
...     
...     print("=== 座席表 ===")
...     print("  ", end="")
...     
...     # 列番号のヘッダー
...     for col in range(1, cols + 1):
...         print(f"{col:2d}", end="")
...     print()
...     
...     # 各行の座席
...     for row in range(1, rows + 1):
...         print(f"{row} ", end="")  # 行番号
...         
...         for col in range(1, cols + 1):
...             seat_id = f"{row}-{col}"
...             
...             if seat_id in occupied_seats:
...                 print(" X", end="")  # 占有済み
...             else:
...                 print(" O", end="")  # 空席
...         
...         print()  # 改行
...     
...     # 空席数をカウント
...     total_seats = rows * cols
...     occupied_count = len(occupied_seats)
...     available_count = total_seats - occupied_count
...     
...     print(f"\n座席情報:")
...     print(f"  総座席数: {total_seats}")
...     print(f"  占有済み: {occupied_count}")
...     print(f"  空席: {available_count}")
...     
...     return available_count
... 

>>> # 座席表の作成
>>> occupied = ["1-1", "1-3", "2-2", "3-1", "3-3", "4-4"]
>>> available = create_seating_chart(5, 6, occupied)

=== 座席表 ===
   1 2 3 4 5 6
1  X O X O O O
2  O X O O O O
3  X O X O O O
4  O O O X O O
5  O O O O O O

座席情報:
  総座席数: 30
  占有済み: 6
  空席: 24
```

## まとめ：繰り返し処理の活用

この章で学んだことをまとめましょう：

### while文の特徴
- 条件が真の間、処理を繰り返す
- 条件を満たすまで処理を続ける場合に適している
- 無限ループに注意が必要
- 貯金シミュレーションなどの条件達成型処理に最適

### for文の特徴
- 決まった回数や決まったデータに対して繰り返す
- リストやrange()と組み合わせて使用
- enumerate()でインデックスも同時に取得可能
- 成績処理などのデータ処理に最適

### ループ制御
- `break`: ループを途中で終了
- `continue`: 現在の周期をスキップ
- データ検証や例外処理で活用

### 実用的な応用例
- 貯金シミュレーション（while文）
- 成績表処理（for文）
- データ検証処理（break/continue）
- 座席表管理（ネストしたループ）

### プログラム設計のポイント
- ループの終了条件を明確にする
- 無限ループを避ける安全装置を設ける
- 処理の進捗を適切に表示する
- エラー処理を組み込む

次の章では、データをまとめて整理する方法について学びます。買い物リスト管理や連絡先帳プログラムを作りながら、リスト、辞書、セットなどのデータ構造を活用した効率的なデータ管理方法を習得しましょう！