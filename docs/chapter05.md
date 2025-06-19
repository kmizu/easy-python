# 第5章：数の世界で遊ぼう

前の章で基本的な計算ができるようになりました。この章では、数の世界をもっと深く探検してみましょう。整数と小数の違い、大きな数や小さな数の扱い方、そして私たちが普段使う10進数以外の数値表現について学んでいきます。実際に家計簿の計算や、日本の人口のような大きな数を扱いながら、Pythonの数値処理能力を体験してみましょう。

## 整数と小数の違い

### コンピュータの中での数の表現

人間にとって「数」は「数」ですが、コンピュータの中では整数と小数は全く違う方法で保存されています。

**整数（int）の特徴：**
- 小数点がない数（..., -2, -1, 0, 1, 2, ...）
- 正確な値として保存される
- メモリ使用量が比較的少ない
- 計算が高速

**浮動小数点数（float）の特徴：**
- 小数点がある数（3.14, -2.5, 0.0 など）
- 近似値として保存される（重要！）
- メモリ使用量が多い
- 計算に時間がかかる

### 実際に試してみよう

```python
>>> # 整数の例
>>> students = 30
>>> print(type(students))
<class 'int'>

>>> # 浮動小数点数の例
>>> average_score = 85.5
>>> print(type(average_score))
<class 'float'>

>>> # 整数でも割り算すると浮動小数点数になる
>>> result = 10 / 2
>>> print(result, type(result))
5.0 <class 'float'>

>>> # 整数除算を使うと整数のまま
>>> result = 10 // 2
>>> print(result, type(result))
5 <class 'int'>
```

### 浮動小数点数の落とし穴

浮動小数点数は近似値として保存されるため、時々予想外の結果になることがあります：

```python
>>> 0.1 + 0.2
0.30000000000000004

>>> # これは浮動小数点数の仕様です！
>>> # 正確な小数計算が必要な場合は...
>>> from decimal import Decimal
>>> result = Decimal('0.1') + Decimal('0.2')
>>> print(result)
0.3
```

**お金の計算では要注意：**
```python
>>> # 危険な例
>>> price = 0.1  # 10円
>>> quantity = 3
>>> total = price * quantity
>>> print(total)
0.30000000000000004

>>> # 安全な方法
>>> price_yen = 10  # 円単位で整数として扱う
>>> quantity = 3
>>> total_yen = price_yen * quantity
>>> print(f"{total_yen}円")
30円
```

## 【実行】家計簿の計算（収入・支出・残高）

実用的な家計簿計算プログラムを作って、整数と小数の扱いを練習してみましょう。

### ステップ1：基本的な家計簿

```python
>>> # 月の収入と支出
>>> salary = 250000      # 給料
>>> part_time = 50000    # アルバイト
>>> total_income = salary + part_time

>>> # 支出
>>> rent = 80000         # 家賃
>>> food = 45000         # 食費
>>> utilities = 15000    # 光熱費
>>> transport = 12000    # 交通費
>>> others = 25000       # その他

>>> total_expenses = rent + food + utilities + transport + others
>>> balance = total_income - total_expenses

>>> print(f"収入合計: {total_income:,}円")
収入合計: 300,000円
>>> print(f"支出合計: {total_expenses:,}円")
支出合計: 177,000円
>>> print(f"残高: {balance:,}円")
残高: 123,000円
```

### ステップ2：複数月の管理

```python
>>> # 3ヶ月分の家計簿データ
>>> monthly_data = [
...     {"month": "1月", "income": 300000, "expenses": 177000},
...     {"month": "2月", "income": 285000, "expenses": 190000},
...     {"month": "3月", "income": 320000, "expenses": 165000}
... ]

>>> total_income = 0
>>> total_expenses = 0
>>> 
>>> print("=== 月別家計簿 ===")
>>> for data in monthly_data:
...     month = data["month"]
...     income = data["income"]
...     expenses = data["expenses"]
...     balance = income - expenses
...     
...     total_income += income
...     total_expenses += expenses
...     
...     print(f"{month}: 収入{income:,}円, 支出{expenses:,}円, 残高{balance:,}円")
... 
=== 月別家計簿 ===
1月: 収入300,000円, 支出177,000円, 残高123,000円
2月: 収入285,000円, 支出190,000円, 残高95,000円
3月: 収入320,000円, 支出165,000円, 残高155,000円

>>> total_balance = total_income - total_expenses
>>> average_income = total_income / len(monthly_data)
>>> average_expenses = total_expenses / len(monthly_data)

>>> print(f"\n=== 3ヶ月間の合計 ===")
>>> print(f"総収入: {total_income:,}円")
>>> print(f"総支出: {total_expenses:,}円")
>>> print(f"総残高: {total_balance:,}円")
>>> print(f"月平均収入: {average_income:,.0f}円")
>>> print(f"月平均支出: {average_expenses:,.0f}円")
```

### ステップ3：貯金目標の計算

```python
>>> # 貯金目標の設定
>>> savings_goal = 1000000  # 100万円
>>> monthly_savings = 50000  # 月5万円

>>> months_needed = savings_goal / monthly_savings
>>> years_needed = months_needed / 12

>>> print(f"貯金目標: {savings_goal:,}円")
>>> print(f"月間貯金額: {monthly_savings:,}円")
>>> print(f"達成まで: {months_needed:.1f}ヶ月 ({years_needed:.1f}年)")
貯金目標: 1,000,000円
月間貯金額: 50,000円
達成まで: 20.0ヶ月 (1.7年)

>>> # 実際の貯金シミュレーション
>>> current_savings = 0
>>> month = 0

>>> print("\n=== 貯金シミュレーション ===")
>>> while current_savings < savings_goal:
...     month += 1
...     current_savings += monthly_savings
...     print(f"{month}ヶ月目: {current_savings:,}円")
...     if month >= 24:  # 2年で打ち切り
...         break
... 
=== 貯金シミュレーション ===
1ヶ月目: 50,000円
2ヶ月目: 100,000円
3ヶ月目: 150,000円
...（中略）...
20ヶ月目: 1,000,000円
```

### ステップ4：完全版家計簿プログラム

ファイルに保存できる完全版を作ってみましょう：

```python
# 家計簿管理プログラム
class HouseholdBudget:
    def __init__(self):
        self.monthly_data = []
    
    def add_month(self, month, income, expenses):
        """月のデータを追加"""
        data = {
            "month": month,
            "income": income,
            "expenses": expenses,
            "balance": income - expenses
        }
        self.monthly_data.append(data)
    
    def calculate_totals(self):
        """合計値を計算"""
        if not self.monthly_data:
            return 0, 0, 0
        
        total_income = sum(data["income"] for data in self.monthly_data)
        total_expenses = sum(data["expenses"] for data in self.monthly_data)
        total_balance = total_income - total_expenses
        
        return total_income, total_expenses, total_balance
    
    def calculate_averages(self):
        """平均値を計算"""
        if not self.monthly_data:
            return 0, 0
        
        total_income, total_expenses, _ = self.calculate_totals()
        count = len(self.monthly_data)
        
        return total_income / count, total_expenses / count
    
    def print_summary(self):
        """サマリーを表示"""
        print("=== 家計簿サマリー ===")
        
        for data in self.monthly_data:
            print(f"{data['month']}: 収入{data['income']:,}円, "
                  f"支出{data['expenses']:,}円, "
                  f"残高{data['balance']:,}円")
        
        total_income, total_expenses, total_balance = self.calculate_totals()
        avg_income, avg_expenses = self.calculate_averages()
        
        print(f"\n=== 合計 ===")
        print(f"総収入: {total_income:,}円")
        print(f"総支出: {total_expenses:,}円")
        print(f"総残高: {total_balance:,}円")
        print(f"月平均収入: {avg_income:,.0f}円")
        print(f"月平均支出: {avg_expenses:,.0f}円")

# 使用例
budget = HouseholdBudget()
budget.add_month("1月", 300000, 177000)
budget.add_month("2月", 285000, 190000)
budget.add_month("3月", 320000, 165000)
budget.print_summary()
```

## 大きな数、小さな数

### Pythonの数値の範囲

**整数（int）：**
```python
>>> # Pythonの整数は任意精度！
>>> big_number = 2 ** 100
>>> print(big_number)
1267650600228229401496703205376

>>> # さらに大きな数
>>> huge_number = 2 ** 1000
>>> print(len(str(huge_number)))  # 桁数
302
```

**浮動小数点数（float）：**
```python
>>> import sys
>>> print(f"最大値: {sys.float_info.max}")
最大値: 1.7976931348623157e+308

>>> print(f"最小値: {sys.float_info.min}")
最小値: 2.2250738585072014e-308

>>> # オーバーフローの例
>>> big_float = 1e308 * 10
>>> print(big_float)
inf

>>> # アンダーフローの例
>>> small_float = 1e-324 / 10
>>> print(small_float)
0.0
```

### 科学的記法（指数表記）

大きな数や小さな数は、科学的記法で表現できます：

```python
>>> # 科学的記法の例
>>> speed_of_light = 3e8  # 3 × 10^8 m/s
>>> print(speed_of_light)
300000000.0

>>> # 非常に小さな数
>>> planck_constant = 6.626e-34  # プランク定数
>>> print(planck_constant)
6.626e-34

>>> # 計算例
>>> distance_to_sun = 1.5e11  # 地球-太陽間距離（メートル）
>>> time_for_light = distance_to_sun / speed_of_light
>>> print(f"太陽の光が地球に届くまで: {time_for_light:.1f}秒")
太陽の光が地球に届くまで: 500.0秒
```

### 数値フォーマットのテクニック

```python
>>> number = 1234567.89

>>> # 基本的なフォーマット
>>> print(f"{number:,}")        # 3桁区切り
1,234,567.89

>>> print(f"{number:.2f}")      # 小数点以下2桁
1234567.89

>>> print(f"{number:,.2f}")     # 3桁区切り + 小数点以下2桁
1,234,567.89

>>> print(f"{number:.2e}")      # 科学的記法
1.23e+06

>>> # パーセント表示
>>> ratio = 0.1234
>>> print(f"{ratio:.1%}")
12.3%
```

## 【実行】日本の人口や国土面積をいろんな進数で表現

身近で大きな数を使って、異なる進数表現を学んでみましょう。

### 日本の基本データ

```python
>>> # 日本の基本データ（2023年推定）
>>> population = 125000000      # 人口（約1億2500万人）
>>> area_km2 = 377975          # 国土面積（平方キロメートル）
>>> gdp_trillion = 4.2         # GDP（兆ドル）

>>> print(f"日本の人口: {population:,}人")
日本の人口: 125,000,000人
>>> print(f"日本の国土面積: {area_km2:,}平方キロメートル")
日本の国土面積: 377,975平方キロメートル
>>> print(f"日本のGDP: {gdp_trillion}兆ドル")
日本のGDP: 4.2兆ドル
```

### 10進数から他の進数への変換

Python には進数変換の便利な関数があります：

```python
>>> number = 255

>>> # 2進数表現
>>> binary = bin(number)
>>> print(f"10進数 {number} は 2進数で {binary}")
10進数 255 は 2進数で 0b11111111

>>> # 8進数表現  
>>> octal = oct(number)
>>> print(f"10進数 {number} は 8進数で {octal}")
10進数 255 は 8進数で 0o377

>>> # 16進数表現
>>> hexadecimal = hex(number)
>>> print(f"10進数 {number} は 16進数で {hexadecimal}")
10進数 255 は 16進数で 0xff
```

### 日本の人口を各進数で表現

```python
>>> population = 125000000

>>> print(f"日本の人口: {population:,}人")
>>> print(f"2進数: {bin(population)}")
>>> print(f"8進数: {oct(population)}")
>>> print(f"16進数: {hex(population)}")

日本の人口: 125,000,000人
2進数: 0b111011101011111010000000000
8進数: 0o735372000
16進数: 0x7735f400

>>> # 2進数の桁数を確認
>>> binary_str = bin(population)[2:]  # 0bを除去
>>> print(f"2進数の桁数: {len(binary_str)}桁")
2進数の桁数: 27桁
```

### 各進数での計算例

```python
>>> # 16進数で色を表現（RGB）
>>> red = 0xFF     # 255
>>> green = 0x80   # 128  
>>> blue = 0x00    # 0

>>> color = (red << 16) + (green << 8) + blue
>>> print(f"色コード: #{color:06X}")
色コード: #FF8000

>>> # 2進数でファイルサイズを計算
>>> # 1KB = 1024バイト = 2^10バイト
>>> file_size_kb = 1500
>>> file_size_bytes = file_size_kb * 1024
>>> print(f"{file_size_kb}KB = {file_size_bytes:,}バイト")
>>> print(f"2進数: {bin(file_size_bytes)}")
1500KB = 1,536,000バイト
2進数: 0b101110111000000000000
```

### 進数変換の仕組みを理解しよう

```python
>>> def decimal_to_binary(n):
...     """10進数を2進数に変換（仕組みを表示）"""
...     if n == 0:
...         return "0"
...     
...     binary_digits = []
...     original_n = n
...     
...     print(f"{n}を2進数に変換:")
...     while n > 0:
...         remainder = n % 2
...         quotient = n // 2
...         print(f"{n} ÷ 2 = {quotient} 余り {remainder}")
...         binary_digits.append(str(remainder))
...         n = quotient
...     
...     binary_str = ''.join(reversed(binary_digits))
...     print(f"答え: {original_n} = {binary_str}(2進数)")
...     return binary_str
... 

>>> # 実際に使ってみよう
>>> decimal_to_binary(25)
25を2進数に変換:
25 ÷ 2 = 12 余り 1
12 ÷ 2 = 6 余り 0
6 ÷ 2 = 3 余り 0
3 ÷ 2 = 1 余り 1
1 ÷ 2 = 0 余り 1
答え: 25 = 11001(2進数)
'11001'
```

## 計算の順番（優先順位）

### 演算子の優先順位

数学と同じように、Pythonでも計算の順番（優先順位）があります：

| 優先順位 | 演算子 | 説明 | 例 |
|----------|--------|------|-----|
| 1（高） | `()` | 括弧 | `(2 + 3) * 4` |
| 2 | `**` | 累乗 | `2 ** 3` |
| 3 | `+x`, `-x` | 単項演算子 | `-5`, `+3` |
| 4 | `*`, `/`, `//`, `%` | 乗除算 | `6 * 7 / 2` |
| 5（低） | `+`, `-` | 加減算 | `5 + 3 - 1` |

### 優先順位の例

```python
>>> # 例1: 基本的な優先順位
>>> result = 2 + 3 * 4
>>> print(result)  # 2 + (3 * 4) = 2 + 12 = 14
14

>>> # 例2: 累乗の優先順位
>>> result = 2 + 3 ** 2 * 4
>>> print(result)  # 2 + (3^2) * 4 = 2 + 9 * 4 = 2 + 36 = 38
38

>>> # 例3: 括弧で順序を変更
>>> result = (2 + 3) ** 2 * 4
>>> print(result)  # (2 + 3)^2 * 4 = 5^2 * 4 = 25 * 4 = 100
100
```

### 複雑な計算の例

```python
>>> # 複利計算の例
>>> principal = 1000000    # 元本（100万円）
>>> rate = 0.02           # 年利2%
>>> years = 10            # 10年

>>> # 複利計算式: A = P(1 + r)^n
>>> amount = principal * (1 + rate) ** years
>>> print(f"元本: {principal:,}円")
>>> print(f"年利: {rate:.1%}")
>>> print(f"期間: {years}年")
>>> print(f"最終金額: {amount:,.0f}円")
>>> print(f"利息: {amount - principal:,.0f}円")

元本: 1,000,000円
年利: 2.0%
期間: 10年
最終金額: 1,218,994円
利息: 218,994円

>>> # 計算式を分解して確認
>>> print(f"(1 + {rate}) = {1 + rate}")
>>> print(f"(1 + {rate})^{years} = {(1 + rate) ** years}")
>>> print(f"{principal} × {(1 + rate) ** years:.6f} = {amount:.0f}")
```

### 実際の計算での注意点

```python
>>> # 注意1: 整数除算と浮動小数点除算
>>> print(f"10 / 3 = {10 / 3}")        # 浮動小数点除算
>>> print(f"10 // 3 = {10 // 3}")       # 整数除算
>>> print(f"10 % 3 = {10 % 3}")         # 余り

10 / 3 = 3.3333333333333335
10 // 3 = 3
10 % 3 = 1

>>> # 注意2: 累乗の結合性（右から計算される）
>>> print(f"2 ** 3 ** 2 = {2 ** 3 ** 2}")  # 2^(3^2) = 2^9 = 512
>>> print(f"(2 ** 3) ** 2 = {(2 ** 3) ** 2}")  # (2^3)^2 = 8^2 = 64

2 ** 3 ** 2 = 512
(2 ** 3) ** 2 = 64

>>> # 注意3: 負数の累乗
>>> print(f"-2 ** 2 = {-2 ** 2}")      # -(2^2) = -4
>>> print(f"(-2) ** 2 = {(-2) ** 2}")  # (-2)^2 = 4

-2 ** 2 = -4
(-2) ** 2 = 4
```

## 数学関数の利用

### mathモジュール

Pythonには数学計算のための豊富な関数が用意されています：

```python
>>> import math

>>> # 三角関数
>>> angle = math.pi / 4  # 45度
>>> print(f"sin(45°) = {math.sin(angle):.3f}")
>>> print(f"cos(45°) = {math.cos(angle):.3f}")

sin(45°) = 0.707
cos(45°) = 0.707

>>> # 対数・指数
>>> print(f"log(10) = {math.log10(100)}")  # 常用対数
>>> print(f"ln(e) = {math.log(math.e)}")    # 自然対数
>>> print(f"e^2 = {math.exp(2):.3f}")       # 指数関数

log(10) = 2.0
ln(e) = 1.0
e^2 = 7.389

>>> # その他の関数
>>> print(f"√16 = {math.sqrt(16)}")
>>> print(f"|-5| = {math.fabs(-5)}")
>>> print(f"⌈3.2⌉ = {math.ceil(3.2)}")    # 天井関数
>>> print(f"⌊3.8⌋ = {math.floor(3.8)}")   # 床関数

√16 = 4.0
|-5| = 5.0
⌈3.2⌉ = 4
⌊3.8⌋ = 3
```

### 実用的な計算例

```python
>>> import math

>>> # 住宅ローンの計算
>>> loan_amount = 30000000    # 借入額（3000万円）
>>> annual_rate = 0.015       # 年利1.5%
>>> years = 35               # 返済期間35年

>>> monthly_rate = annual_rate / 12
>>> total_months = years * 12

>>> # 月々の返済額計算（元利均等）
>>> monthly_payment = (loan_amount * monthly_rate * 
...                    (1 + monthly_rate) ** total_months) / \
...                   ((1 + monthly_rate) ** total_months - 1)

>>> total_payment = monthly_payment * total_months
>>> total_interest = total_payment - loan_amount

>>> print(f"借入額: {loan_amount:,}円")
>>> print(f"年利: {annual_rate:.1%}")
>>> print(f"返済期間: {years}年")
>>> print(f"月々の返済額: {monthly_payment:,.0f}円")
>>> print(f"総返済額: {total_payment:,.0f}円")
>>> print(f"利息合計: {total_interest:,.0f}円")

借入額: 30,000,000円
年利: 1.5%
返済期間: 35年
月々の返済額: 91,856円
総返済額: 38,579,424円
利息合計: 8,579,424円
```

## まとめ：Pythonでの数値処理

この章で学んだことをまとめましょう：

### 整数と浮動小数点数
- 整数は正確、浮動小数点数は近似値
- お金の計算では整数を使うことを推奨
- 科学的記法で大きな数・小さな数を表現

### 進数の変換
- bin(), oct(), hex()で進数変換
- コンピュータは内部で2進数を使用
- 16進数は色やメモリアドレスでよく使用

### 計算の優先順位
- 括弧 → 累乗 → 乗除算 → 加減算
- 複雑な式では括弧を使って明確に
- 整数除算（//）と浮動小数点除算（/）の違い

### 実用的な計算
- 家計簿管理
- 複利計算
- 住宅ローン計算
- mathモジュールの活用

### 数値フォーマット
- 3桁区切り表示（:,）
- 小数点以下の桁数指定（:.2f）
- パーセント表示（:.1%）
- 科学的記法（:.2e）

次の章では、数値だけでなく文字列の処理について学んでいきます。メールの件名作成や住所の整形など、実際の文字列操作を通じて、Pythonの文字列処理能力を体験してみましょう！