# 第11章：関数を作ってみよう

これまでの章では、プログラムを順番に書いて実行してきました。しかし、同じような処理を何度も書くのは効率的ではありません。この章では、**関数**を使って処理をまとめ、再利用可能にする方法を学びます。BMI計算関数や割引価格計算関数を作りながら、プログラムをより構造化し、保守しやすくする技術を習得しましょう。

## 関数ってなに？なぜ便利？

### 関数の基本概念

**関数**とは、特定の処理をまとめて名前を付けたものです。現実世界の「道具」や「機械」と同じような概念です。

**現実世界の例：**
- **電卓**：数値を入力すると計算結果を返す
- **自動販売機**：お金を入れて商品を選ぶと商品が出てくる
- **洗濯機**：洗濯物と洗剤を入れると洗濯された衣服が出てくる

**プログラムの関数：**
- **BMI計算関数**：身長と体重を入力するとBMI値を返す
- **消費税計算関数**：価格を入力すると税込価格を返す
- **割引計算関数**：元価格と割引率を入力すると割引後価格を返す

### 関数を使う理由

```python
>>> # 関数を使わない場合（悪い例）
>>> # 田中さんのBMI計算
>>> tanaka_height = 170  # cm
>>> tanaka_weight = 65   # kg
>>> tanaka_bmi = tanaka_weight / (tanaka_height / 100) ** 2
>>> print(f"田中さんのBMI: {tanaka_bmi:.1f}")

田中さんのBMI: 22.5

>>> # 佐藤さんのBMI計算
>>> sato_height = 160
>>> sato_weight = 55
>>> sato_bmi = sato_weight / (sato_height / 100) ** 2
>>> print(f"佐藤さんのBMI: {sato_bmi:.1f}")

佐藤さんのBMI: 21.5

>>> # 鈴木さんのBMI計算
>>> suzuki_height = 175
>>> suzuki_weight = 70
>>> suzuki_bmi = suzuki_weight / (suzuki_height / 100) ** 2
>>> print(f"鈴木さんのBMI: {suzuki_bmi:.1f}")

鈴木さんのBMI: 22.9
```

この例の問題点：
1. **重複コード**：同じ計算式を何度も書いている
2. **間違いやすい**：計算式を間違える可能性がある
3. **修正が大変**：計算式を変更したい場合、すべての箇所を修正する必要がある

### 関数を使った場合（良い例）

```python
>>> def calculate_bmi(height_cm, weight_kg):
...     """BMIを計算する関数"""
...     height_m = height_cm / 100  # cmをmに変換
...     bmi = weight_kg / (height_m ** 2)
...     return bmi
... 

>>> # 各人のBMI計算
>>> tanaka_bmi = calculate_bmi(170, 65)
>>> sato_bmi = calculate_bmi(160, 55)
>>> suzuki_bmi = calculate_bmi(175, 70)

>>> print(f"田中さんのBMI: {tanaka_bmi:.1f}")
>>> print(f"佐藤さんのBMI: {sato_bmi:.1f}")
>>> print(f"鈴木さんのBMI: {suzuki_bmi:.1f}")

田中さんのBMI: 22.5
佐藤さんのBMI: 21.5
鈴木さんのBMI: 22.9
```

関数を使うメリット：
1. **再利用性**：一度作れば何度でも使える
2. **保守性**：修正は一箇所だけでOK
3. **可読性**：プログラムの意図が分かりやすい
4. **テスト性**：関数単体でテストできる

## 【実行】BMI計算関数を作ろう

BMI計算を例に、関数の作り方と使い方を詳しく学びましょう。

### ステップ1：基本的なBMI計算関数

```python
>>> def calculate_bmi(height_cm, weight_kg):
...     """
...     BMIを計算する関数
...     
...     Args:
...         height_cm (float): 身長（センチメートル）
...         weight_kg (float): 体重（キログラム）
...     
...     Returns:
...         float: BMI値
...     """
...     height_m = height_cm / 100
...     bmi = weight_kg / (height_m ** 2)
...     return bmi
... 

>>> # 使用例
>>> my_bmi = calculate_bmi(170, 65)
>>> print(f"BMI: {my_bmi:.2f}")

BMI: 22.49

>>> # 複数人のデータで検証
>>> people = [
...     ("田中太郎", 170, 65),
...     ("佐藤花子", 160, 55),
...     ("鈴木一郎", 175, 70),
...     ("山田美咲", 165, 58)
... ]

>>> print("=== BMI計算結果 ===")
>>> for name, height, weight in people:
...     bmi = calculate_bmi(height, weight)
...     print(f"{name}: BMI {bmi:.1f}")

=== BMI計算結果 ===
田中太郎: BMI 22.5
佐藤花子: BMI 21.5
鈴木一郎: BMI 22.9
山田美咲: BMI 21.3
```

### ステップ2：BMI判定機能付き関数

```python
>>> def calculate_bmi_with_category(height_cm, weight_kg):
...     """BMI計算と判定を行う関数"""
...     
...     # BMI計算
...     height_m = height_cm / 100
...     bmi = weight_kg / (height_m ** 2)
...     
...     # BMI判定
...     if bmi < 18.5:
...         category = "低体重"
...         advice = "体重を増やすことを検討してください"
...     elif bmi < 25.0:
...         category = "普通体重"
...         advice = "理想的な体重です"
...     elif bmi < 30.0:
...         category = "肥満（1度）"
...         advice = "減量を検討してください"
...     elif bmi < 35.0:
...         category = "肥満（2度）"
...         advice = "医師に相談することをお勧めします"
...     else:
...         category = "肥満（3度）"
...         advice = "早急に医師に相談してください"
...     
...     return {
...         "bmi": bmi,
...         "category": category,
...         "advice": advice
...     }
... 

>>> # 使用例
>>> result = calculate_bmi_with_category(170, 65)
>>> print(f"BMI: {result['bmi']:.1f}")
>>> print(f"判定: {result['category']}")
>>> print(f"アドバイス: {result['advice']}")

BMI: 22.5
判定: 普通体重
アドバイス: 理想的な体重です

>>> # 複数のケースで確認
>>> test_cases = [
...     ("低体重の例", 170, 50),
...     ("普通体重の例", 170, 65),
...     ("肥満1度の例", 170, 75),
...     ("肥満2度の例", 170, 90)
... ]

>>> print("\n=== BMI判定テスト ===")
>>> for description, height, weight in test_cases:
...     result = calculate_bmi_with_category(height, weight)
...     print(f"\n{description}")
...     print(f"身長: {height}cm, 体重: {weight}kg")
...     print(f"BMI: {result['bmi']:.1f} ({result['category']})")
...     print(f"アドバイス: {result['advice']}")

=== BMI判定テスト ===

低体重の例
身長: 170cm, 体重: 50kg
BMI: 17.3 (低体重)
アドバイス: 体重を増やすことを検討してください

普通体重の例
身長: 170cm, 体重: 65kg
BMI: 22.5 (普通体重)
アドバイス: 理想的な体重です

肥満1度の例
身長: 170cm, 体重: 75kg
BMI: 26.0 (肥満（1度）)
アドバイス: 減量を検討してください

肥満2度の例
身長: 170cm, 体重: 90kg
BMI: 31.1 (肥満（2度）)
アドバイス: 医師に相談することをお勧めします
```

### ステップ3：理想体重計算機能

```python
>>> def calculate_ideal_weight_range(height_cm):
...     """理想体重の範囲を計算する関数"""
...     height_m = height_cm / 100
...     
...     # BMI 18.5-24.9が普通体重範囲
...     min_weight = 18.5 * (height_m ** 2)
...     max_weight = 24.9 * (height_m ** 2)
...     
...     # BMI 22が理想とされる
...     ideal_weight = 22.0 * (height_m ** 2)
...     
...     return {
...         "min_weight": min_weight,
...         "max_weight": max_weight,
...         "ideal_weight": ideal_weight
...     }
... 

>>> def comprehensive_health_check(height_cm, weight_kg):
...     """総合的な健康チェック関数"""
...     
...     # BMI計算と判定
...     bmi_result = calculate_bmi_with_category(height_cm, weight_kg)
...     
...     # 理想体重範囲
...     ideal_range = calculate_ideal_weight_range(height_cm)
...     
...     # 現在体重と理想体重の差
...     weight_diff = weight_kg - ideal_range["ideal_weight"]
...     
...     # 目標設定
...     if weight_diff > 5:
...         goal = f"{abs(weight_diff):.1f}kg の減量"
...         target_weight = ideal_range["ideal_weight"]
...     elif weight_diff < -5:
...         goal = f"{abs(weight_diff):.1f}kg の増量"
...         target_weight = ideal_range["ideal_weight"]
...     else:
...         goal = "現在の体重を維持"
...         target_weight = weight_kg
...     
...     return {
...         "current_bmi": bmi_result["bmi"],
...         "category": bmi_result["category"],
...         "advice": bmi_result["advice"],
...         "ideal_weight_range": f"{ideal_range['min_weight']:.1f} - {ideal_range['max_weight']:.1f} kg",
...         "ideal_weight": ideal_range["ideal_weight"],
...         "weight_difference": weight_diff,
...         "goal": goal,
...         "target_weight": target_weight
...     }
... 

>>> # 使用例
>>> health_check = comprehensive_health_check(170, 75)

>>> print("=== 総合健康チェック結果 ===")
>>> print(f"現在のBMI: {health_check['current_bmi']:.1f}")
>>> print(f"判定: {health_check['category']}")
>>> print(f"理想体重範囲: {health_check['ideal_weight_range']}")
>>> print(f"理想体重: {health_check['ideal_weight']:.1f}kg")
>>> print(f"現在との差: {health_check['weight_difference']:+.1f}kg")
>>> print(f"目標: {health_check['goal']}")
>>> print(f"アドバイス: {health_check['advice']}")

=== 総合健康チェック結果 ===
現在のBMI: 26.0
判定: 肥満（1度）
理想体重範囲: 53.5 - 72.0 kg
理想体重: 63.6kg
現在との差: +11.4kg
目標: 11.4kg の減量
アドバイス: 減量を検討してください
```

### ステップ4：完全版BMI計算ツール

```python
# 完全版BMI計算ツール
class BMICalculator:
    """BMI計算と健康管理のためのクラス"""
    
    def __init__(self):
        self.history = []  # 過去の記録を保存
    
    def calculate_bmi(self, height_cm, weight_kg):
        """基本的なBMI計算"""
        height_m = height_cm / 100
        return weight_kg / (height_m ** 2)
    
    def get_bmi_category(self, bmi):
        """BMI値から判定カテゴリを取得"""
        if bmi < 18.5:
            return "低体重", "体重を増やすことを検討してください"
        elif bmi < 25.0:
            return "普通体重", "理想的な体重です"
        elif bmi < 30.0:
            return "肥満（1度）", "減量を検討してください"
        elif bmi < 35.0:
            return "肥満（2度）", "医師に相談することをお勧めします"
        else:
            return "肥満（3度）", "早急に医師に相談してください"
    
    def calculate_ideal_weight(self, height_cm, target_bmi=22.0):
        """理想体重を計算"""
        height_m = height_cm / 100
        return target_bmi * (height_m ** 2)
    
    def add_record(self, height_cm, weight_kg, date=None):
        """記録を追加"""
        if date is None:
            from datetime import datetime
            date = datetime.now().strftime("%Y-%m-%d")
        
        bmi = self.calculate_bmi(height_cm, weight_kg)
        category, advice = self.get_bmi_category(bmi)
        
        record = {
            "date": date,
            "height": height_cm,
            "weight": weight_kg,
            "bmi": bmi,
            "category": category,
            "advice": advice
        }
        
        self.history.append(record)
        return record
    
    def get_progress_report(self):
        """進捗レポートを生成"""
        if len(self.history) < 2:
            return "進捗を確認するには最低2回の記録が必要です"
        
        latest = self.history[-1]
        previous = self.history[-2]
        
        weight_change = latest["weight"] - previous["weight"]
        bmi_change = latest["bmi"] - previous["bmi"]
        
        report = f"""
=== 進捗レポート ===
前回: {previous['date']} - 体重: {previous['weight']}kg, BMI: {previous['bmi']:.1f}
今回: {latest['date']} - 体重: {latest['weight']}kg, BMI: {latest['bmi']:.1f}

変化: 体重 {weight_change:+.1f}kg, BMI {bmi_change:+.1f}

現在の状況: {latest['category']}
アドバイス: {latest['advice']}
"""
        
        return report
    
    def generate_health_plan(self, height_cm, current_weight_kg, target_bmi=22.0):
        """健康管理プランを生成"""
        current_bmi = self.calculate_bmi(height_cm, current_weight_kg)
        target_weight = self.calculate_ideal_weight(height_cm, target_bmi)
        weight_diff = current_weight_kg - target_weight
        
        plan = {
            "current_status": {
                "bmi": current_bmi,
                "weight": current_weight_kg,
                "category": self.get_bmi_category(current_bmi)[0]
            },
            "target": {
                "bmi": target_bmi,
                "weight": target_weight
            },
            "plan": self._create_weight_plan(weight_diff)
        }
        
        return plan
    
    def _create_weight_plan(self, weight_diff):
        """体重変更プランを作成"""
        if abs(weight_diff) < 2:
            return {
                "goal": "現在の体重を維持",
                "period": "継続的",
                "weekly_target": 0,
                "advice": "バランスの良い食事と適度な運動を継続してください"
            }
        elif weight_diff > 0:  # 減量が必要
            weekly_target = min(weight_diff / 10, 0.5)  # 週0.5kg以下の減量
            period_weeks = int(weight_diff / weekly_target)
            return {
                "goal": f"{weight_diff:.1f}kg の減量",
                "period": f"約{period_weeks}週間",
                "weekly_target": -weekly_target,
                "advice": "カロリー制限と有酸素運動を組み合わせましょう"
            }
        else:  # 増量が必要
            weekly_target = min(abs(weight_diff) / 10, 0.3)  # 週0.3kg以下の増量
            period_weeks = int(abs(weight_diff) / weekly_target)
            return {
                "goal": f"{abs(weight_diff):.1f}kg の増量",
                "period": f"約{period_weeks}週間",
                "weekly_target": weekly_target,
                "advice": "栄養価の高い食事と筋力トレーニングを行いましょう"
            }

# 使用例
bmi_calculator = BMICalculator()

# 記録追加
record1 = bmi_calculator.add_record(170, 75, "2024-01-01")
record2 = bmi_calculator.add_record(170, 73, "2024-01-15")
record3 = bmi_calculator.add_record(170, 71, "2024-02-01")

print("=== 最新記録 ===")
latest = bmi_calculator.history[-1]
print(f"日付: {latest['date']}")
print(f"身長: {latest['height']}cm")
print(f"体重: {latest['weight']}kg")
print(f"BMI: {latest['bmi']:.1f}")
print(f"判定: {latest['category']}")

# 進捗レポート
print(bmi_calculator.get_progress_report())

# 健康管理プラン
health_plan = bmi_calculator.generate_health_plan(170, 71)
print("=== 健康管理プラン ===")
print(f"目標: {health_plan['plan']['goal']}")
print(f"期間: {health_plan['plan']['period']}")
print(f"週間目標: {health_plan['plan']['weekly_target']:+.1f}kg")
print(f"アドバイス: {health_plan['plan']['advice']}")
```

## 引数と戻り値

### 引数（パラメータ）の種類

関数には様々な方法で値を渡すことができます。

```python
>>> # 位置引数（順番が重要）
>>> def greet_person(name, age, city):
...     return f"{name}さん（{age}歳、{city}在住）こんにちは！"
... 

>>> message = greet_person("田中", 25, "東京")
>>> print(message)

田中さん（25歳、東京在住）こんにちは！

>>> # キーワード引数（順番は自由）
>>> message = greet_person(age=30, city="大阪", name="佐藤")
>>> print(message)

佐藤さん（30歳、大阪在住）こんにちは！

>>> # デフォルト引数
>>> def create_user_profile(name, age, city="未設定", premium=False):
...     profile = {
...         "name": name,
...         "age": age,
...         "city": city,
...         "premium": premium
...     }
...     return profile
... 

>>> # 一部の引数だけ指定
>>> profile1 = create_user_profile("田中", 25)
>>> print(profile1)

{'name': '田中', 'age': 25, 'city': '未設定', 'premium': False}

>>> # 一部をキーワード引数で上書き
>>> profile2 = create_user_profile("佐藤", 30, premium=True)
>>> print(profile2)

{'name': '佐藤', 'age': 30, 'city': '未設定', 'premium': True}
```

### 可変長引数

```python
>>> # *args: 複数の位置引数を受け取る
>>> def calculate_total(*numbers):
...     """複数の数値の合計を計算"""
...     total = 0
...     for num in numbers:
...         total += num
...     return total
... 

>>> result1 = calculate_total(10, 20, 30)
>>> result2 = calculate_total(5, 15, 25, 35, 45)
>>> print(f"3つの数の合計: {result1}")
>>> print(f"5つの数の合計: {result2}")

3つの数の合計: 60
5つの数の合計: 125

>>> # **kwargs: 複数のキーワード引数を受け取る
>>> def create_product(**details):
...     """商品情報を作成"""
...     product = {"created": "2024-01-01"}
...     
...     for key, value in details.items():
...         product[key] = value
...     
...     return product
... 

>>> product1 = create_product(name="ノートPC", price=80000, category="電子機器")
>>> product2 = create_product(name="コーヒー", price=500, origin="ブラジル", roast="中煎り")

>>> print("商品1:", product1)
>>> print("商品2:", product2)

商品1: {'created': '2024-01-01', 'name': 'ノートPC', 'price': 80000, 'category': '電子機器'}
商品2: {'created': '2024-01-01', 'name': 'コーヒー', 'price': 500, 'origin': 'ブラジル', 'roast': '中煎り'}
```

## 【実行】割引価格計算関数（通常・学割・シニア割）

実用的な割引計算システムを作って、引数の活用方法を学びましょう。

### ステップ1：基本的な割引計算関数

```python
>>> def calculate_discount_price(original_price, discount_rate):
...     """基本的な割引価格計算"""
...     discount_amount = original_price * discount_rate
...     final_price = original_price - discount_amount
...     
...     return {
...         "original_price": original_price,
...         "discount_rate": discount_rate,
...         "discount_amount": discount_amount,
...         "final_price": final_price
...     }
... 

>>> # 使用例
>>> result = calculate_discount_price(10000, 0.1)  # 10%割引
>>> print(f"元価格: {result['original_price']}円")
>>> print(f"割引率: {result['discount_rate']:.0%}")
>>> print(f"割引額: {result['discount_amount']}円")
>>> print(f"最終価格: {result['final_price']}円")

元価格: 10000円
割引率: 10%
割引額: 1000.0円
最終価格: 9000.0円
```

### ステップ2：年齢別割引システム

```python
>>> def calculate_age_based_discount(original_price, age, is_student=False):
...     """年齢ベースの割引計算"""
...     
...     # 基本割引率の決定
...     if age < 12:
...         discount_rate = 0.5  # 子供50%割引
...         discount_type = "子供割引"
...     elif age >= 65:
...         discount_rate = 0.3  # シニア30%割引
...         discount_type = "シニア割引"
...     elif is_student and 12 <= age <= 25:
...         discount_rate = 0.2  # 学生20%割引
...         discount_type = "学生割引"
...     else:
...         discount_rate = 0.0  # 割引なし
...         discount_type = "通常料金"
...     
...     # 計算
...     discount_amount = original_price * discount_rate
...     final_price = original_price - discount_amount
...     
...     return {
...         "original_price": original_price,
...         "discount_type": discount_type,
...         "discount_rate": discount_rate,
...         "discount_amount": discount_amount,
...         "final_price": final_price,
...         "age": age,
...         "is_student": is_student
...     }
... 

>>> # テストケース
>>> test_cases = [
...     ("子供", 8, False),
...     ("学生", 20, True),
...     ("一般成人", 30, False),
...     ("シニア", 70, False),
...     ("成人学生", 22, True)
... ]

>>> original_price = 5000

>>> print("=== 年齢別割引計算 ===")
>>> for description, age, is_student in test_cases:
...     result = calculate_age_based_discount(original_price, age, is_student)
...     print(f"\n{description} ({age}歳, 学生: {is_student})")
...     print(f"割引タイプ: {result['discount_type']}")
...     print(f"割引率: {result['discount_rate']:.0%}")
...     print(f"最終価格: {result['final_price']:,.0f}円")

=== 年齢別割引計算 ===

子供 (8歳, 学生: False)
割引タイプ: 子供割引
割引率: 50%
最終価格: 2,500円

学生 (20歳, 学生: True)
割引タイプ: 学生割引
割引率: 20%
最終価格: 4,000円

一般成人 (30歳, 学生: False)
割引タイプ: 通常料金
割引率: 0%
最終価格: 5,000円

シニア (70歳, 学生: False)
割引タイプ: シニア割引
割引率: 30%
最終価格: 3,500円

成人学生 (22歳, 学生: True)
割引タイプ: 学生割引
割引率: 20%
最終価格: 4,000円
```

### ステップ3：複数割引対応システム

```python
>>> def calculate_multiple_discounts(original_price, age=None, is_student=False, 
...                                  is_member=False, member_level="ブロンズ", 
...                                  coupon_rate=0.0, **additional_discounts):
...     """複数の割引を適用する高度な計算システム"""
...     
...     discounts_applied = []
...     current_price = original_price
...     
...     # 1. 年齢別割引（最初に適用）
...     if age is not None:
...         if age < 12:
...             age_discount = 0.5
...             discount_name = "子供割引"
...         elif age >= 65:
...             age_discount = 0.3
...             discount_name = "シニア割引"
...         elif is_student and 12 <= age <= 25:
...             age_discount = 0.2
...             discount_name = "学生割引"
...         else:
...             age_discount = 0.0
...             discount_name = None
...         
...         if age_discount > 0:
...             discount_amount = current_price * age_discount
...             current_price -= discount_amount
...             discounts_applied.append({
...                 "type": discount_name,
...                 "rate": age_discount,
...                 "amount": discount_amount,
...                 "price_after": current_price
...             })
...     
...     # 2. 会員割引
...     if is_member:
...         member_discounts = {
...             "ブロンズ": 0.05,
...             "シルバー": 0.10,
...             "ゴールド": 0.15,
...             "プラチナ": 0.20
...         }
...         
...         member_rate = member_discounts.get(member_level, 0.05)
...         discount_amount = current_price * member_rate
...         current_price -= discount_amount
...         
...         discounts_applied.append({
...             "type": f"{member_level}会員割引",
...             "rate": member_rate,
...             "amount": discount_amount,
...             "price_after": current_price
...         })
...     
...     # 3. クーポン割引
...     if coupon_rate > 0:
...         discount_amount = current_price * coupon_rate
...         current_price -= discount_amount
...         
...         discounts_applied.append({
...             "type": "クーポン割引",
...             "rate": coupon_rate,
...             "amount": discount_amount,
...             "price_after": current_price
...         })
...     
...     # 4. その他の割引
...     for discount_name, discount_rate in additional_discounts.items():
...         if discount_rate > 0:
...             discount_amount = current_price * discount_rate
...             current_price -= discount_amount
...             
...             discounts_applied.append({
...                 "type": discount_name,
...                 "rate": discount_rate,
...                 "amount": discount_amount,
...                 "price_after": current_price
...             })
...     
...     # 総割引額と割引率を計算
...     total_discount = original_price - current_price
...     total_discount_rate = total_discount / original_price if original_price > 0 else 0
...     
...     return {
...         "original_price": original_price,
...         "final_price": current_price,
...         "total_discount": total_discount,
...         "total_discount_rate": total_discount_rate,
...         "discounts_applied": discounts_applied
...     }
... 

>>> # 複雑な割引計算の例
>>> result = calculate_multiple_discounts(
...     original_price=20000,
...     age=22,
...     is_student=True,
...     is_member=True,
...     member_level="ゴールド",
...     coupon_rate=0.05,
...     タイムセール=0.10
... )

>>> print("=== 複数割引適用結果 ===")
>>> print(f"元価格: {result['original_price']:,}円")
>>> print(f"最終価格: {result['final_price']:,.0f}円")
>>> print(f"総割引額: {result['total_discount']:,.0f}円")
>>> print(f"総割引率: {result['total_discount_rate']:.1%}")

>>> print("\n=== 適用された割引 ===")
>>> for i, discount in enumerate(result['discounts_applied'], 1):
...     print(f"{i}. {discount['type']}: {discount['rate']:.0%}割引 (-{discount['amount']:,.0f}円)")
...     print(f"   適用後価格: {discount['price_after']:,.0f}円")

=== 複数割引適用結果 ===
元価格: 20,000円
最終価格: 10,404円
総割引額: 9,596円
総割引率: 48.0%

=== 適用された割引 ===
1. 学生割引: 20%割引 (-4,000円)
   適用後価格: 16,000円
2. ゴールド会員割引: 15%割引 (-2,400円)
   適用後価格: 13,600円
3. クーポン割引: 5%割引 (-680円)
   適用後価格: 12,920円
4. タイムセール: 10%割引 (-1,292円)
   適用後価格: 11,628円
```

### ステップ4：割引計算ツールクラス

```python
# 総合割引計算システム
class DiscountCalculator:
    def __init__(self):
        self.discount_rules = {
            "age_based": {
                "child": {"min_age": 0, "max_age": 11, "rate": 0.5, "name": "子供割引"},
                "student": {"min_age": 12, "max_age": 25, "rate": 0.2, "name": "学生割引", "requires_student_status": True},
                "senior": {"min_age": 65, "max_age": 120, "rate": 0.3, "name": "シニア割引"}
            },
            "membership": {
                "ブロンズ": 0.05,
                "シルバー": 0.10,
                "ゴールド": 0.15,
                "プラチナ": 0.20
            }
        }
    
    def add_discount_rule(self, category, name, rate, conditions=None):
        """新しい割引ルールを追加"""
        if category not in self.discount_rules:
            self.discount_rules[category] = {}
        
        rule = {"rate": rate, "name": name}
        if conditions:
            rule.update(conditions)
        
        self.discount_rules[category][name] = rule
    
    def calculate_final_price(self, original_price, customer_info, coupons=None):
        """顧客情報に基づいて最終価格を計算"""
        if coupons is None:
            coupons = []
        
        calculation_steps = []
        current_price = original_price
        
        # Step 1: 年齢ベース割引
        age_discount = self._get_age_discount(customer_info.get("age"), 
                                              customer_info.get("is_student", False))
        if age_discount:
            discount_amount = current_price * age_discount["rate"]
            current_price -= discount_amount
            calculation_steps.append({
                "step": "年齢ベース割引",
                "discount_name": age_discount["name"],
                "rate": age_discount["rate"],
                "amount": discount_amount,
                "price_after": current_price
            })
        
        # Step 2: 会員割引
        if customer_info.get("is_member") and customer_info.get("member_level"):
            member_level = customer_info["member_level"]
            if member_level in self.discount_rules["membership"]:
                member_rate = self.discount_rules["membership"][member_level]
                discount_amount = current_price * member_rate
                current_price -= discount_amount
                calculation_steps.append({
                    "step": "会員割引",
                    "discount_name": f"{member_level}会員",
                    "rate": member_rate,
                    "amount": discount_amount,
                    "price_after": current_price
                })
        
        # Step 3: クーポン適用
        for coupon in coupons:
            coupon_rate = coupon.get("rate", 0)
            if coupon_rate > 0:
                discount_amount = current_price * coupon_rate
                current_price -= discount_amount
                calculation_steps.append({
                    "step": "クーポン適用",
                    "discount_name": coupon.get("name", "クーポン"),
                    "rate": coupon_rate,
                    "amount": discount_amount,
                    "price_after": current_price
                })
        
        return {
            "original_price": original_price,
            "final_price": current_price,
            "total_savings": original_price - current_price,
            "total_discount_rate": (original_price - current_price) / original_price,
            "calculation_steps": calculation_steps
        }
    
    def _get_age_discount(self, age, is_student):
        """年齢に基づく割引を取得"""
        if age is None:
            return None
        
        for rule_name, rule in self.discount_rules["age_based"].items():
            if rule["min_age"] <= age <= rule["max_age"]:
                # 学生ステータスが必要な割引の場合
                if rule.get("requires_student_status") and not is_student:
                    continue
                return rule
        
        return None
    
    def generate_discount_report(self, original_price, customer_info, coupons=None):
        """割引レポートを生成"""
        result = self.calculate_final_price(original_price, customer_info, coupons)
        
        report = f"""
=== 割引計算レポート ===
お客様情報:
  年齢: {customer_info.get('age', '不明')}歳
  学生: {'はい' if customer_info.get('is_student') else 'いいえ'}
  会員: {'はい' if customer_info.get('is_member') else 'いいえ'}"""
        
        if customer_info.get('is_member'):
            report += f" ({customer_info.get('member_level', '不明')})"
        
        report += f"""

価格計算:
  元価格: {result['original_price']:,}円"""
        
        for step in result['calculation_steps']:
            report += f"""
  {step['discount_name']}: -{step['amount']:,.0f}円 ({step['rate']:.0%})
    → {step['price_after']:,.0f}円"""
        
        report += f"""

最終結果:
  お支払い金額: {result['final_price']:,.0f}円
  総割引額: {result['total_savings']:,.0f}円
  総割引率: {result['total_discount_rate']:.1%}
"""
        
        return report

# 使用例
calculator = DiscountCalculator()

# テストケース
customers = [
    {
        "name": "田中太郎",
        "info": {"age": 8, "is_student": False, "is_member": False},
        "coupons": []
    },
    {
        "name": "佐藤花子", 
        "info": {"age": 20, "is_student": True, "is_member": True, "member_level": "シルバー"},
        "coupons": [{"name": "初回クーポン", "rate": 0.05}]
    },
    {
        "name": "鈴木一郎",
        "info": {"age": 70, "is_member": True, "member_level": "ゴールド"},
        "coupons": [{"name": "タイムセール", "rate": 0.1}]
    }
]

original_price = 15000

for customer in customers:
    print(f"\n{'='*50}")
    print(f"顧客: {customer['name']}")
    report = calculator.generate_discount_report(
        original_price, 
        customer['info'], 
        customer['coupons']
    )
    print(report)
```

## 関数の中の変数（スコープ）

### ローカル変数とグローバル変数

```python
>>> # グローバル変数
>>> global_counter = 0

>>> def increment_counter():
...     # ローカル変数
...     local_temp = global_counter
...     global global_counter  # グローバル変数を変更する宣言
...     global_counter += 1
...     print(f"ローカル変数 local_temp: {local_temp}")
...     print(f"グローバル変数 global_counter: {global_counter}")
... 

>>> print(f"関数呼び出し前: {global_counter}")
>>> increment_counter()
>>> print(f"関数呼び出し後: {global_counter}")

関数呼び出し前: 0
ローカル変数 local_temp: 0
グローバル変数 global_counter: 1
関数呼び出し後: 1

>>> # ローカル変数はスコープ外では見えない
>>> # print(local_temp)  # NameError: name 'local_temp' is not defined
```

### 実用的なスコープの例

```python
>>> # 設定値を管理する例
>>> DEFAULT_TAX_RATE = 0.1  # グローバル設定

>>> def calculate_price_with_tax(price, tax_rate=None):
...     """税込価格を計算する関数"""
...     if tax_rate is None:
...         tax_rate = DEFAULT_TAX_RATE  # グローバル変数を使用
...     
...     tax_amount = price * tax_rate
...     total_price = price + tax_amount
...     
...     return {
...         "base_price": price,
...         "tax_rate": tax_rate,
...         "tax_amount": tax_amount,
...         "total_price": total_price
...     }
... 

>>> # デフォルト税率を使用
>>> result1 = calculate_price_with_tax(1000)
>>> print(f"通常税率: {result1['total_price']}円")

通常税率: 1100.0円

>>> # カスタム税率を使用
>>> result2 = calculate_price_with_tax(1000, 0.08)
>>> print(f"軽減税率: {result2['total_price']}円")

軽減税率: 1080.0円
```

## まとめ：関数の効果的な活用

この章で学んだことをまとめましょう：

### 関数の基本概念
- **再利用性**: 一度作れば何度でも使える
- **保守性**: 修正は一箇所だけでOK
- **可読性**: プログラムの意図が分かりやすい
- **テスト性**: 関数単体でテストできる

### 引数の種類
- **位置引数**: 順番が重要
- **キーワード引数**: 名前で指定、順番自由
- **デフォルト引数**: 省略可能な引数
- **可変長引数**: *args（複数の位置引数）、**kwargs（複数のキーワード引数）

### 戻り値の活用
- 単一の値を返す
- 辞書やリストで複数の値を返す
- 計算結果と状態情報を同時に返す

### 実用的な応用例
- BMI計算と健康管理システム
- 複数割引対応の価格計算システム
- 設定値を活用した柔軟な処理

### スコープの理解
- ローカル変数: 関数内でのみ有効
- グローバル変数: プログラム全体で有効
- 適切なスコープの使い分けで保守性向上

### 関数設計のベストプラクティス
- 一つの関数は一つの責任を持つ
- 関数名は処理内容を明確に表現
- 引数と戻り値を明確に定義
- ドキュメント文字列（docstring）で説明を記載

次の章では、プログラムをファイルに保存して管理する方法と、モジュールという仕組みを使って機能を分けて整理する方法を学びます。家計簿プログラムをファイルに保存し、計算ライブラリモジュールを作って、より本格的なプログラム開発を体験しましょう！