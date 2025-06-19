# 第12章：プログラムをファイルに保存しよう

これまでの章では、Pythonの対話型シェルでプログラムを実行してきました。しかし、長いプログラムを毎回手で入力するのは非効率的です。この章では、プログラムを**ファイル**に保存し、再利用可能な**モジュール**として整理する方法を学びます。家計簿管理プログラムをファイルに保存し、計算ライブラリを作りながら、実際のプログラム開発の流れを体験しましょう。

## Pythonファイル（.py）とは

### プログラムをファイルに保存する理由

対話型シェルは学習や実験には便利ですが、実際の開発では以下の理由でファイルが必要になります：

**対話型シェルの限界：**
- 長いプログラムを毎回手で入力する必要がある
- コンピュータを再起動すると消えてしまう
- 他の人と共有するのが難しい
- 修正や改良が困難

**ファイルに保存するメリット：**
- 一度書けば何度でも実行できる
- 修正や改良が簡単
- 他の人と簡単に共有できる
- バックアップが取れる
- 部品として再利用できる

### はじめてのPythonファイルを作ろう

```python
# calculator.py
"""
簡単な電卓プログラム
"""

def add(a, b):
    """二つの数を足す"""
    return a + b

def subtract(a, b):
    """二つの数を引く"""
    return a - b

def multiply(a, b):
    """二つの数を掛ける"""
    return a * b

def divide(a, b):
    """二つの数を割る"""
    if b == 0:
        return "エラー: ゼロで割ることはできません"
    return a / b

# プログラムが直接実行された場合のテスト
if __name__ == "__main__":
    print("=== 簡単な電卓 ===")
    
    # 計算例
    num1 = 10
    num2 = 3
    
    print(f"{num1} + {num2} = {add(num1, num2)}")
    print(f"{num1} - {num2} = {subtract(num1, num2)}")
    print(f"{num1} × {num2} = {multiply(num1, num2)}")
    print(f"{num1} ÷ {num2} = {divide(num1, num2):.2f}")
    
    # ゼロ除算のテスト
    print(f"{num1} ÷ 0 = {divide(num1, 0)}")
```

### ファイルの実行方法

```bash
# コマンドラインから実行
python calculator.py

# 出力：
=== 簡単な電卓 ===
10 + 3 = 13
10 - 3 = 7
10 × 3 = 30
10 ÷ 3 = 3.33
10 ÷ 0 = エラー: ゼロで割ることはできません
```

## 【実行】家計簿管理プログラムをファイルに保存しよう

実用的な家計簿管理プログラムを作って、ファイルの使い方を学びましょう。

### ステップ1：基本的な家計簿ファイル

```python
# household_budget.py
"""
家計簿管理プログラム
毎月の収入と支出を管理する
"""

import datetime

class HouseholdBudget:
    def __init__(self, initial_balance=0):
        """家計簿の初期化"""
        self.balance = initial_balance
        self.transactions = []
        self.monthly_budget = {}
        self.categories = {
            "income": ["給料", "副業", "その他収入"],
            "expense": ["食費", "交通費", "光熱費", "家賃", "娯楽", "その他支出"]
        }
    
    def add_transaction(self, amount, category, description=""):
        """取引を追加"""
        if category in self.categories["income"]:
            transaction_type = "収入"
            self.balance += amount
        elif category in self.categories["expense"]:
            transaction_type = "支出"
            self.balance -= amount
        else:
            return False, f"不明なカテゴリ: {category}"
        
        transaction = {
            "date": datetime.datetime.now(),
            "type": transaction_type,
            "amount": amount,
            "category": category,
            "description": description,
            "balance_after": self.balance
        }
        
        self.transactions.append(transaction)
        return True, f"{transaction_type}を記録しました: {amount:,}円"
    
    def get_monthly_summary(self, year=None, month=None):
        """月次サマリーを取得"""
        if year is None:
            year = datetime.datetime.now().year
        if month is None:
            month = datetime.datetime.now().month
        
        monthly_income = 0
        monthly_expense = 0
        monthly_transactions = []
        
        for transaction in self.transactions:
            if (transaction["date"].year == year and 
                transaction["date"].month == month):
                monthly_transactions.append(transaction)
                
                if transaction["type"] == "収入":
                    monthly_income += transaction["amount"]
                else:
                    monthly_expense += transaction["amount"]
        
        return {
            "year": year,
            "month": month,
            "income": monthly_income,
            "expense": monthly_expense,
            "net": monthly_income - monthly_expense,
            "transactions": monthly_transactions
        }
    
    def set_monthly_budget(self, category, amount):
        """月間予算を設定"""
        self.monthly_budget[category] = amount
        return f"{category}の月間予算を{amount:,}円に設定しました"
    
    def check_budget_status(self):
        """予算の使用状況をチェック"""
        current_month = self.get_monthly_summary()
        status = {}
        
        for category, budget_amount in self.monthly_budget.items():
            spent = 0
            for transaction in current_month["transactions"]:
                if transaction["category"] == category and transaction["type"] == "支出":
                    spent += transaction["amount"]
            
            remaining = budget_amount - spent
            percentage = (spent / budget_amount) * 100 if budget_amount > 0 else 0
            
            status[category] = {
                "budget": budget_amount,
                "spent": spent,
                "remaining": remaining,
                "percentage": percentage,
                "over_budget": spent > budget_amount
            }
        
        return status
    
    def generate_report(self):
        """レポートを生成"""
        summary = self.get_monthly_summary()
        budget_status = self.check_budget_status()
        
        report = f"""
=== 家計簿レポート ({summary['year']}年{summary['month']}月) ===
現在の残高: {self.balance:,}円

【今月の収支】
収入: {summary['income']:,}円
支出: {summary['expense']:,}円
差額: {summary['net']:,}円

【予算使用状況】
"""
        
        for category, status in budget_status.items():
            over_text = " ⚠️ 予算超過" if status["over_budget"] else ""
            report += f"{category}: {status['spent']:,}円 / {status['budget']:,}円 ({status['percentage']:.1f}%){over_text}\n"
        
        report += f"\n【最近の取引履歴】\n"
        recent_transactions = sorted(self.transactions, 
                                   key=lambda x: x["date"], 
                                   reverse=True)[:5]
        
        for transaction in recent_transactions:
            date_str = transaction["date"].strftime("%m/%d")
            report += f"{date_str} {transaction['type']} {transaction['amount']:,}円 ({transaction['category']})\n"
        
        return report

# プログラムが直接実行された場合のテスト
if __name__ == "__main__":
    # 家計簿の作成
    budget = HouseholdBudget(50000)  # 初期残高5万円
    
    # 月間予算の設定
    budget.set_monthly_budget("食費", 30000)
    budget.set_monthly_budget("交通費", 10000)
    budget.set_monthly_budget("娯楽", 15000)
    
    # 取引の追加
    budget.add_transaction(250000, "給料", "12月分給料")
    budget.add_transaction(3500, "食費", "スーパーで買い物")
    budget.add_transaction(580, "交通費", "電車代")
    budget.add_transaction(1200, "食費", "昼食")
    budget.add_transaction(8000, "娯楽", "映画鑑賞")
    budget.add_transaction(25000, "副業", "フリーランス収入")
    budget.add_transaction(2800, "食費", "夕食の材料")
    
    # レポート表示
    print(budget.generate_report())
```

### ステップ2：データをファイルに保存する機能

```python
# budget_with_file.py
"""
ファイル保存機能付き家計簿管理プログラム
"""

import datetime
import json
import os

class FileBudgetManager:
    def __init__(self, filename="budget_data.json", initial_balance=0):
        """ファイル付き家計簿の初期化"""
        self.filename = filename
        self.balance = initial_balance
        self.transactions = []
        self.monthly_budget = {}
        self.categories = {
            "income": ["給料", "副業", "その他収入"],
            "expense": ["食費", "交通費", "光熱費", "家賃", "娯楽", "その他支出"]
        }
        
        # ファイルから既存データを読み込み
        self.load_from_file()
    
    def save_to_file(self):
        """データをファイルに保存"""
        # 日付データをJSON対応形式に変換
        transactions_for_json = []
        for transaction in self.transactions:
            transaction_copy = transaction.copy()
            transaction_copy["date"] = transaction["date"].isoformat()
            transactions_for_json.append(transaction_copy)
        
        data = {
            "balance": self.balance,
            "transactions": transactions_for_json,
            "monthly_budget": self.monthly_budget,
            "categories": self.categories,
            "last_updated": datetime.datetime.now().isoformat()
        }
        
        try:
            with open(self.filename, 'w', encoding='utf-8') as file:
                json.dump(data, file, ensure_ascii=False, indent=2)
            return True, f"データを{self.filename}に保存しました"
        except Exception as e:
            return False, f"保存エラー: {e}"
    
    def load_from_file(self):
        """ファイルからデータを読み込み"""
        if not os.path.exists(self.filename):
            return False, "ファイルが存在しません"
        
        try:
            with open(self.filename, 'r', encoding='utf-8') as file:
                data = json.load(file)
            
            self.balance = data.get("balance", 0)
            self.monthly_budget = data.get("monthly_budget", {})
            self.categories = data.get("categories", self.categories)
            
            # 取引データの復元（日付を正しい形式に戻す）
            self.transactions = []
            for transaction in data.get("transactions", []):
                transaction_copy = transaction.copy()
                transaction_copy["date"] = datetime.datetime.fromisoformat(transaction["date"])
                self.transactions.append(transaction_copy)
            
            return True, f"{self.filename}からデータを読み込みました"
        except Exception as e:
            return False, f"読み込みエラー: {e}"
    
    def add_transaction(self, amount, category, description=""):
        """取引を追加してファイルに保存"""
        if category in self.categories["income"]:
            transaction_type = "収入"
            self.balance += amount
        elif category in self.categories["expense"]:
            transaction_type = "支出"
            self.balance -= amount
        else:
            return False, f"不明なカテゴリ: {category}"
        
        transaction = {
            "date": datetime.datetime.now(),
            "type": transaction_type,
            "amount": amount,
            "category": category,
            "description": description,
            "balance_after": self.balance
        }
        
        self.transactions.append(transaction)
        
        # ファイルに自動保存
        save_success, save_message = self.save_to_file()
        if save_success:
            return True, f"{transaction_type}を記録しました: {amount:,}円"
        else:
            return False, f"取引は記録されましたが、保存に失敗: {save_message}"
    
    def export_to_csv(self, output_filename=None):
        """取引データをCSVファイルにエクスポート"""
        if output_filename is None:
            current_date = datetime.datetime.now().strftime("%Y%m%d")
            output_filename = f"budget_export_{current_date}.csv"
        
        try:
            with open(output_filename, 'w', encoding='utf-8') as file:
                # ヘッダー行
                file.write("日付,種別,金額,カテゴリ,説明,残高\n")
                
                # データ行
                for transaction in self.transactions:
                    date_str = transaction["date"].strftime("%Y-%m-%d %H:%M:%S")
                    line = f"{date_str},{transaction['type']},{transaction['amount']},{transaction['category']},{transaction['description']},{transaction['balance_after']}\n"
                    file.write(line)
            
            return True, f"CSVファイル '{output_filename}' にエクスポートしました"
        except Exception as e:
            return False, f"エクスポートエラー: {e}"
    
    def backup_data(self, backup_filename=None):
        """データのバックアップを作成"""
        if backup_filename is None:
            current_date = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_filename = f"budget_backup_{current_date}.json"
        
        # 元のファイル名を一時的に変更してバックアップ
        original_filename = self.filename
        self.filename = backup_filename
        success, message = self.save_to_file()
        self.filename = original_filename
        
        return success, message

# 使用例とテスト
if __name__ == "__main__":
    # ファイル付き家計簿の作成
    budget = FileBudgetManager("my_budget.json", 50000)
    
    print("=== ファイル付き家計簿システム ===")
    
    # 月間予算の設定
    budget.monthly_budget["食費"] = 30000
    budget.monthly_budget["交通費"] = 10000
    budget.monthly_budget["娯楽"] = 15000
    
    # 取引の追加（自動でファイルに保存される）
    transactions_to_add = [
        (250000, "給料", "12月分給料"),
        (3500, "食費", "スーパーで買い物"),
        (580, "交通費", "電車代"),
        (1200, "食費", "昼食"),
        (8000, "娯楽", "映画鑑賞"),
        (25000, "副業", "フリーランス収入"),
        (2800, "食費", "夕食の材料")
    ]
    
    for amount, category, description in transactions_to_add:
        success, message = budget.add_transaction(amount, category, description)
        print(message)
    
    # データの保存確認
    save_success, save_message = budget.save_to_file()
    print(f"\n{save_message}")
    
    # CSVエクスポート
    csv_success, csv_message = budget.export_to_csv()
    print(csv_message)
    
    # バックアップ作成
    backup_success, backup_message = budget.backup_data()
    print(backup_message)
    
    print(f"\n現在の残高: {budget.balance:,}円")
    print(f"取引履歴件数: {len(budget.transactions)}件")
```

## モジュールとして整理しよう

### ステップ3：計算ライブラリモジュールの作成

```python
# math_utils.py
"""
数学計算ユーティリティモジュール
家計簿で使用する計算機能をまとめたライブラリ
"""

import math
from typing import List, Tuple, Dict

def calculate_tax(amount: float, tax_rate: float = 0.1) -> float:
    """消費税を計算"""
    return amount * tax_rate

def calculate_total_with_tax(amount: float, tax_rate: float = 0.1) -> float:
    """税込み金額を計算"""
    return amount + calculate_tax(amount, tax_rate)

def calculate_percentage(part: float, whole: float) -> float:
    """パーセンテージを計算"""
    if whole == 0:
        return 0
    return (part / whole) * 100

def calculate_average(numbers: List[float]) -> float:
    """平均値を計算"""
    if not numbers:
        return 0
    return sum(numbers) / len(numbers)

def calculate_median(numbers: List[float]) -> float:
    """中央値を計算"""
    if not numbers:
        return 0
    
    sorted_numbers = sorted(numbers)
    n = len(sorted_numbers)
    
    if n % 2 == 0:
        # 偶数個の場合は中央2つの平均
        return (sorted_numbers[n//2 - 1] + sorted_numbers[n//2]) / 2
    else:
        # 奇数個の場合は中央値
        return sorted_numbers[n//2]

def calculate_standard_deviation(numbers: List[float]) -> float:
    """標準偏差を計算"""
    if len(numbers) < 2:
        return 0
    
    average = calculate_average(numbers)
    variance = sum((x - average) ** 2 for x in numbers) / (len(numbers) - 1)
    return math.sqrt(variance)

def calculate_compound_interest(principal: float, rate: float, years: int) -> float:
    """複利計算"""
    return principal * (1 + rate) ** years

def calculate_loan_payment(principal: float, annual_rate: float, years: int) -> float:
    """ローンの月額返済額を計算"""
    monthly_rate = annual_rate / 12
    num_payments = years * 12
    
    if monthly_rate == 0:
        return principal / num_payments
    
    return principal * (monthly_rate * (1 + monthly_rate) ** num_payments) / \
           ((1 + monthly_rate) ** num_payments - 1)

class BudgetCalculator:
    """家計簿計算専用クラス"""
    
    @staticmethod
    def calculate_savings_goal(current_amount: float, target_amount: float, 
                             monthly_savings: float) -> Dict:
        """貯金目標の計算"""
        if monthly_savings <= 0:
            return {"error": "月間貯金額は正の数である必要があります"}
        
        remaining = target_amount - current_amount
        if remaining <= 0:
            return {
                "months_needed": 0,
                "already_achieved": True,
                "excess_amount": abs(remaining)
            }
        
        months_needed = math.ceil(remaining / monthly_savings)
        return {
            "months_needed": months_needed,
            "years_and_months": (months_needed // 12, months_needed % 12),
            "total_savings_needed": remaining,
            "already_achieved": False
        }
    
    @staticmethod
    def calculate_budget_allocation(income: float, allocation_ratios: Dict[str, float]) -> Dict:
        """予算配分の計算"""
        if sum(allocation_ratios.values()) != 1.0:
            return {"error": "配分比率の合計は1.0である必要があります"}
        
        allocation = {}
        for category, ratio in allocation_ratios.items():
            allocation[category] = income * ratio
        
        return allocation
    
    @staticmethod
    def analyze_spending_pattern(transactions: List[Dict]) -> Dict:
        """支出パターンの分析"""
        if not transactions:
            return {"error": "取引データがありません"}
        
        # カテゴリ別集計
        category_totals = {}
        monthly_totals = {}
        
        for transaction in transactions:
            if transaction["type"] == "支出":
                category = transaction["category"]
                amount = transaction["amount"]
                date = transaction["date"]
                month_key = f"{date.year}-{date.month:02d}"
                
                # カテゴリ別集計
                category_totals[category] = category_totals.get(category, 0) + amount
                
                # 月別集計
                monthly_totals[month_key] = monthly_totals.get(month_key, 0) + amount
        
        total_spending = sum(category_totals.values())
        
        # パーセンテージ計算
        category_percentages = {}
        for category, amount in category_totals.items():
            category_percentages[category] = calculate_percentage(amount, total_spending)
        
        return {
            "total_spending": total_spending,
            "category_totals": category_totals,
            "category_percentages": category_percentages,
            "monthly_totals": monthly_totals,
            "average_monthly_spending": calculate_average(list(monthly_totals.values()))
        }

# モジュールテスト
if __name__ == "__main__":
    print("=== 数学計算ユーティリティのテスト ===")
    
    # 基本計算のテスト
    price = 1000
    tax = calculate_tax(price)
    total = calculate_total_with_tax(price)
    print(f"価格: {price}円, 消費税: {tax}円, 税込み: {total}円")
    
    # 統計計算のテスト
    test_numbers = [100, 200, 150, 300, 250]
    print(f"\\n数値: {test_numbers}")
    print(f"平均: {calculate_average(test_numbers):.2f}")
    print(f"中央値: {calculate_median(test_numbers):.2f}")
    print(f"標準偏差: {calculate_standard_deviation(test_numbers):.2f}")
    
    # 複利計算のテスト
    principal = 100000
    rate = 0.03
    years = 5
    future_value = calculate_compound_interest(principal, rate, years)
    print(f"\\n複利計算: {principal:,}円を年利{rate:.1%}で{years}年運用 → {future_value:,.0f}円")
    
    # 家計簿計算のテスト
    print("\\n=== 家計簿計算のテスト ===")
    
    # 貯金目標
    goal_result = BudgetCalculator.calculate_savings_goal(50000, 500000, 30000)
    print(f"貯金目標: {goal_result}")
    
    # 予算配分
    allocation_ratios = {
        "生活費": 0.6,
        "貯金": 0.2,
        "娯楽": 0.1,
        "投資": 0.1
    }
    allocation = BudgetCalculator.calculate_budget_allocation(300000, allocation_ratios)
    print(f"予算配分: {allocation}")
```

### ステップ4：メインプログラムでモジュールを使用

```python
# main_budget_app.py
"""
メイン家計簿アプリケーション
作成したモジュールを組み合わせて完全な家計簿システムを構築
"""

# 自作モジュールのインポート
from budget_with_file import FileBudgetManager
from math_utils import BudgetCalculator, calculate_percentage, calculate_average

import datetime
from typing import Dict, List

class AdvancedBudgetApp:
    def __init__(self, data_filename="advanced_budget.json"):
        """高度な家計簿アプリの初期化"""
        self.budget_manager = FileBudgetManager(data_filename)
        self.calculator = BudgetCalculator()
    
    def setup_recommended_budget(self, monthly_income: float) -> Dict:
        """推奨予算配分の設定（50/30/20ルール）"""
        recommended_allocation = {
            "必需品": 0.50,  # 家賃、食費、光熱費など
            "娯楽": 0.30,    # 外食、趣味など
            "貯金": 0.20     # 貯金、投資など
        }
        
        allocation = self.calculator.calculate_budget_allocation(
            monthly_income, recommended_allocation
        )
        
        if "error" in allocation:
            return allocation
        
        # 詳細なカテゴリ別予算設定
        detailed_budget = {
            # 必需品カテゴリ
            "家賃": allocation["必需品"] * 0.4,
            "食費": allocation["必需品"] * 0.3,
            "光熱費": allocation["必需品"] * 0.15,
            "交通費": allocation["必需品"] * 0.15,
            
            # 娯楽カテゴリ
            "娯楽": allocation["娯楽"],
            
            # 貯金カテゴリ
            "貯金": allocation["貯金"]
        }
        
        # 予算をシステムに設定
        for category, amount in detailed_budget.items():
            if category != "貯金":  # 貯金は支出カテゴリではない
                self.budget_manager.monthly_budget[category] = amount
        
        return {
            "monthly_income": monthly_income,
            "allocation": allocation,
            "detailed_budget": detailed_budget,
            "setup_complete": True
        }
    
    def analyze_financial_health(self) -> Dict:
        """家計の健康状態を分析"""
        current_summary = self.budget_manager.get_monthly_summary()
        spending_analysis = self.calculator.analyze_spending_pattern(
            self.budget_manager.transactions
        )
        
        # 収支バランスの評価
        income = current_summary["income"]
        expense = current_summary["expense"]
        savings_rate = (current_summary["net"] / income * 100) if income > 0 else 0
        
        # 健康度の判定
        if savings_rate >= 20:
            health_status = "優秀"
            health_color = "🟢"
        elif savings_rate >= 10:
            health_status = "良好"
            health_color = "🟡"
        elif savings_rate >= 0:
            health_status = "要注意"
            health_color = "🟠"
        else:
            health_status = "危険"
            health_color = "🔴"
        
        return {
            "health_status": health_status,
            "health_color": health_color,
            "savings_rate": savings_rate,
            "monthly_summary": current_summary,
            "spending_analysis": spending_analysis,
            "recommendations": self._generate_recommendations(savings_rate, spending_analysis)
        }
    
    def _generate_recommendations(self, savings_rate: float, spending_analysis: Dict) -> List[str]:
        """家計改善の推奨事項を生成"""
        recommendations = []
        
        if savings_rate < 10:
            recommendations.append("貯金率が低いです。支出を見直して最低でも収入の10%は貯金しましょう。")
        
        if "category_percentages" in spending_analysis:
            percentages = spending_analysis["category_percentages"]
            
            if percentages.get("食費", 0) > 30:
                recommendations.append("食費の割合が高いです。外食を控えて自炊を増やすことをお勧めします。")
            
            if percentages.get("娯楽", 0) > 20:
                recommendations.append("娯楽費の割合が高いです。月間予算を設定して管理しましょう。")
        
        if not recommendations:
            recommendations.append("家計管理が良好です！この調子で継続しましょう。")
        
        return recommendations
    
    def plan_savings_goal(self, target_amount: float, target_months: int = None) -> Dict:
        """貯金目標の計画"""
        current_balance = self.budget_manager.balance
        
        if target_months:
            # 期限指定の場合
            monthly_savings_needed = (target_amount - current_balance) / target_months
            result = {
                "target_amount": target_amount,
                "current_balance": current_balance,
                "target_months": target_months,
                "monthly_savings_needed": monthly_savings_needed,
                "plan_type": "期限指定"
            }
        else:
            # 現在の収支から推定
            recent_summary = self.budget_manager.get_monthly_summary()
            estimated_monthly_savings = recent_summary["net"]
            
            if estimated_monthly_savings <= 0:
                return {"error": "現在の収支では貯金できません。支出を見直してください。"}
            
            result = self.calculator.calculate_savings_goal(
                current_balance, target_amount, estimated_monthly_savings
            )
            result.update({
                "target_amount": target_amount,
                "current_balance": current_balance,
                "estimated_monthly_savings": estimated_monthly_savings,
                "plan_type": "現在の収支ベース"
            })
        
        return result
    
    def generate_comprehensive_report(self) -> str:
        """総合レポートの生成"""
        health_analysis = self.analyze_financial_health()
        budget_status = self.budget_manager.check_budget_status()
        
        report = f"""
=== 総合家計レポート ===
生成日時: {datetime.datetime.now().strftime('%Y年%m月%d日 %H:%M')}

【家計健康度】 {health_analysis['health_color']} {health_analysis['health_status']}
貯金率: {health_analysis['savings_rate']:.1f}%
現在の残高: {self.budget_manager.balance:,}円

【今月の収支】
収入: {health_analysis['monthly_summary']['income']:,}円
支出: {health_analysis['monthly_summary']['expense']:,}円
収支: {health_analysis['monthly_summary']['net']:,}円

【カテゴリ別支出分析】
"""
        
        if "category_percentages" in health_analysis['spending_analysis']:
            for category, percentage in health_analysis['spending_analysis']['category_percentages'].items():
                amount = health_analysis['spending_analysis']['category_totals'][category]
                report += f"{category}: {amount:,}円 ({percentage:.1f}%)\n"
        
        report += "\n【予算使用状況】\n"
        for category, status in budget_status.items():
            over_text = " ⚠️ 予算超過" if status["over_budget"] else ""
            report += f"{category}: {status['spent']:,}円 / {status['budget']:,}円 ({status['percentage']:.1f}%){over_text}\n"
        
        report += "\n【改善推奨事項】\n"
        for i, recommendation in enumerate(health_analysis['recommendations'], 1):
            report += f"{i}. {recommendation}\n"
        
        return report

# 使用例とデモンストレーション
if __name__ == "__main__":
    print("=== 高度な家計簿アプリケーション ===")
    
    # アプリケーションの初期化
    app = AdvancedBudgetApp("demo_budget.json")
    
    # 推奨予算の設定（月収30万円の場合）
    monthly_income = 300000
    budget_setup = app.setup_recommended_budget(monthly_income)
    print(f"月収 {monthly_income:,}円での推奨予算設定完了")
    
    # サンプル取引データの追加
    sample_transactions = [
        (300000, "給料", "12月分給料"),
        (80000, "家賃", "12月分家賃"),
        (25000, "食費", "食材費"),
        (15000, "食費", "外食費"),
        (8000, "光熱費", "電気代"),
        (5000, "交通費", "定期券"),
        (12000, "娯楽", "映画・本"),
        (30000, "副業", "フリーランス"),
        (3500, "食費", "コンビニ"),
        (6000, "娯楽", "友人との食事")
    ]
    
    print("\nサンプル取引を追加中...")
    for amount, category, description in sample_transactions:
        success, message = app.budget_manager.add_transaction(amount, category, description)
        if not success:
            print(f"エラー: {message}")
    
    # 家計健康度の分析
    health_analysis = app.analyze_financial_health()
    print(f"\n家計健康度: {health_analysis['health_color']} {health_analysis['health_status']}")
    print(f"貯金率: {health_analysis['savings_rate']:.1f}%")
    
    # 貯金目標の計画
    savings_goal = app.plan_savings_goal(1000000)  # 100万円目標
    if "error" not in savings_goal:
        print(f"\n貯金目標: {savings_goal['months_needed']}ヶ月で達成予定")
    
    # 総合レポートの生成
    comprehensive_report = app.generate_comprehensive_report()
    print(comprehensive_report)
    
    # データの保存とバックアップ
    app.budget_manager.save_to_file()
    app.budget_manager.backup_data()
    app.budget_manager.export_to_csv()
    
    print("\nデータの保存、バックアップ、CSVエクスポートが完了しました。")
```

## パッケージの概念

### ステップ5：パッケージとして整理

```
budget_system/
├── __init__.py              # パッケージの初期化ファイル
├── core/
│   ├── __init__.py
│   ├── budget_manager.py    # 基本的な家計簿管理機能
│   └── file_operations.py   # ファイル操作機能
├── utils/
│   ├── __init__.py
│   ├── math_utils.py       # 数学計算ユーティリティ
│   └── date_utils.py       # 日付操作ユーティリティ
└── apps/
    ├── __init__.py
    ├── cli_app.py          # コマンドライン版アプリ
    └── gui_app.py          # GUI版アプリ（将来用）
```

```python
# budget_system/__init__.py
"""
家計簿管理システムパッケージ
"""

from .core.budget_manager import BudgetManager
from .core.file_operations import FileOperations
from .utils.math_utils import BudgetCalculator
from .apps.cli_app import BudgetApp

__version__ = "1.0.0"
__author__ = "Python学習者"

# パッケージレベルで簡単にアクセスできるクラス
Budget = BudgetManager
Calculator = BudgetCalculator
App = BudgetApp

# 使いやすい関数のエイリアス
def create_budget(filename=None):
    """新しい家計簿を作成"""
    return BudgetManager(filename)

def load_budget(filename):
    """既存の家計簿を読み込み"""
    budget = BudgetManager(filename)
    budget.load_from_file()
    return budget
```

```python
# budget_system/utils/date_utils.py
"""
日付操作ユーティリティ
"""

import datetime
from typing import List, Tuple

def get_month_range(year: int, month: int) -> Tuple[datetime.datetime, datetime.datetime]:
    """指定した月の開始日と終了日を取得"""
    start_date = datetime.datetime(year, month, 1)
    
    if month == 12:
        end_date = datetime.datetime(year + 1, 1, 1) - datetime.timedelta(days=1)
    else:
        end_date = datetime.datetime(year, month + 1, 1) - datetime.timedelta(days=1)
    
    return start_date, end_date

def get_weekday_name(date: datetime.datetime) -> str:
    """曜日名を取得（日本語）"""
    weekdays = ["月", "火", "水", "木", "金", "土", "日"]
    return weekdays[date.weekday()]

def format_date_japanese(date: datetime.datetime) -> str:
    """日本語形式で日付をフォーマット"""
    weekday = get_weekday_name(date)
    return f"{date.year}年{date.month}月{date.day}日({weekday})"

def get_business_days_in_month(year: int, month: int) -> int:
    """指定した月の営業日数を取得"""
    start_date, end_date = get_month_range(year, month)
    
    business_days = 0
    current_date = start_date
    
    while current_date <= end_date:
        # 月曜日=0, 日曜日=6
        if current_date.weekday() < 5:  # 平日
            business_days += 1
        current_date += datetime.timedelta(days=1)
    
    return business_days

def get_payday_dates(year: int, payday: int = 25) -> List[datetime.datetime]:
    """年間の給料日一覧を取得"""
    paydays = []
    
    for month in range(1, 13):
        try:
            payday_date = datetime.datetime(year, month, payday)
            
            # 土日の場合は前営業日に調整
            while payday_date.weekday() >= 5:  # 土日
                payday_date -= datetime.timedelta(days=1)
            
            paydays.append(payday_date)
        except ValueError:
            # 月に該当日がない場合（2月30日など）は月末
            if month == 2:
                last_day = 28 if year % 4 != 0 else 29
            elif month in [4, 6, 9, 11]:
                last_day = 30
            else:
                last_day = 31
            
            payday_date = datetime.datetime(year, month, last_day)
            paydays.append(payday_date)
    
    return paydays

# 使用例
if __name__ == "__main__":
    print("=== 日付ユーティリティのテスト ===")
    
    # 今月の範囲
    now = datetime.datetime.now()
    start, end = get_month_range(now.year, now.month)
    print(f"今月の範囲: {format_date_japanese(start)} ～ {format_date_japanese(end)}")
    
    # 営業日数
    business_days = get_business_days_in_month(now.year, now.month)
    print(f"今月の営業日数: {business_days}日")
    
    # 今年の給料日
    paydays = get_payday_dates(now.year)
    print(f"今年の給料日（最初の3回）:")
    for payday in paydays[:3]:
        print(f"  {format_date_japanese(payday)}")
```

## まとめ：ファイルとモジュールの活用

この章で学んだことをまとめましょう：

### ファイルに保存する利点
- **永続性**：プログラムを終了してもデータが残る
- **再利用性**：何度でも実行できる
- **共有性**：他の人と簡単に共有できる
- **バックアップ**：データを安全に保管できる

### モジュールの利点
- **分離**：機能ごとにファイルを分けて整理
- **再利用**：他のプログラムからも使える
- **保守性**：修正や改良が簡単
- **協業**：チームでの開発がしやすい

### パッケージの利点
- **整理**：関連するモジュールをまとめて管理
- **名前空間**：名前の衝突を避けられる
- **配布**：システム全体を一つの単位として配布

### 実用的な応用
- 家計簿管理システムの完全版
- 計算ライブラリの作成
- ファイル操作とデータ永続化
- モジュール化による保守性向上
- パッケージ化による再利用性向上

### ファイル操作のベストプラクティス
```python
# 良い例：エラーハンドリング付きファイル操作
try:
    with open(filename, 'r', encoding='utf-8') as file:
        data = json.load(file)
except FileNotFoundError:
    print(f"ファイル {filename} が見つかりません")
except json.JSONDecodeError:
    print("ファイルの形式が正しくありません")
except Exception as e:
    print(f"予期しないエラー: {e}")
```

次の章では、**例外処理**について詳しく学びます。エラーが発生したときにプログラムがクラッシュしないよう適切に対処する方法を、実践的な例を通じて習得しましょう！

---

**第12章執筆完了ログ:**
第12章ではPythonファイル（.py）の概念から始まり、実用的な家計簿管理プログラムをファイルに保存する方法を学習。モジュール化による機能分離、パッケージによる整理まで段階的に構築。計算ライブラリ、ファイル操作、日付ユーティリティなど実用的なモジュールを作成し、最終的に総合的な家計簿システムとして統合。次は第13章の例外処理に進みます。