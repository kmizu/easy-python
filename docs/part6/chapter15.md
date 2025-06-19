# 第15章：クラス定義の文法と実行

## この章で学ぶこと

- class文のBNF定義
- インスタンスの作成と初期化
- メソッドとself引数
- 継承の文法と動作
- 特殊メソッド（マジックメソッド）
- クラス変数とインスタンス変数

## 15.1 class文のBNF定義

### クラス定義の構文

```bnf
<クラス定義> ::= "class" <識別子> ["(" [<継承リスト>] ")"] ":" <スイート>
<継承リスト> ::= <式> ("," <式>)*
```

### 基本的なクラス定義

```python
# class_basics.py

# 最も簡単なクラス
class Empty:
    pass

# インスタンスの作成
obj = Empty()
print(f"obj: {obj}")
print(f"type(obj): {type(obj)}")
print(f"obj.__class__: {obj.__class__}")

# 基本的なクラス
print("\n=== 基本的なクラス ===")
class Dog:
    """犬を表すクラス"""
    
    # クラス変数
    species = "Canis familiaris"
    
    def __init__(self, name, age):
        """コンストラクタ（初期化メソッド）"""
        self.name = name  # インスタンス変数
        self.age = age
    
    def bark(self):
        """吠える"""
        return f"{self.name}がワンワン吠えています！"
    
    def describe(self):
        """自己紹介"""
        return f"{self.name}は{self.age}歳の{self.species}です。"

# インスタンスの作成
dog1 = Dog("ポチ", 3)
dog2 = Dog("タロウ", 5)

print(f"dog1: {dog1.describe()}")
print(f"dog1.bark(): {dog1.bark()}")
print(f"dog2: {dog2.describe()}")

# クラス変数へのアクセス
print(f"\nDog.species: {Dog.species}")
print(f"dog1.species: {dog1.species}")
print(f"dog1.__class__.species: {dog1.__class__.species}")
```

## 15.2 【実行】インスタンスの作成と初期化プロセス

```python
# instance_creation.py

# インスタンス作成プロセスの詳細
print("=== インスタンス作成プロセス ===")

class MyClass:
    def __new__(cls, *args, **kwargs):
        """インスタンスの作成"""
        print(f"1. __new__が呼ばれました: cls={cls}")
        instance = super().__new__(cls)
        print(f"   作成されたインスタンス: {instance}")
        return instance
    
    def __init__(self, value):
        """インスタンスの初期化"""
        print(f"2. __init__が呼ばれました: self={self}")
        self.value = value
        print(f"   初期化完了: value={self.value}")

# インスタンス作成
print("MyClass(42)を実行:")
obj = MyClass(42)
print(f"結果: {obj}")

# 属性へのアクセス
print("\n=== 属性アクセスの仕組み ===")
class AttributeDemo:
    class_var = "クラス変数"
    
    def __init__(self):
        self.instance_var = "インスタンス変数"
    
    def __getattr__(self, name):
        """属性が見つからない場合に呼ばれる"""
        print(f"__getattr__: {name}が見つかりません")
        return f"動的に生成された{name}"
    
    def __setattr__(self, name, value):
        """属性の設定時に呼ばれる"""
        print(f"__setattr__: {name} = {value}")
        super().__setattr__(name, value)
    
    def __delattr__(self, name):
        """属性の削除時に呼ばれる"""
        print(f"__delattr__: {name}を削除")
        super().__delattr__(name)

demo = AttributeDemo()
print(f"demo.instance_var: {demo.instance_var}")
print(f"demo.unknown_attr: {demo.unknown_attr}")

demo.new_attr = "新しい属性"
del demo.new_attr

# __dict__の確認
print("\n=== インスタンスの__dict__ ===")
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    def greet(self):
        return f"Hello, I'm {self.name}"

person = Person("Alice", 30)
print(f"person.__dict__: {person.__dict__}")
print(f"Person.__dict__.keys(): {list(Person.__dict__.keys())}")

# 動的な属性の追加
person.city = "Tokyo"
print(f"\n属性追加後のperson.__dict__: {person.__dict__}")

# __slots__の使用
print("\n=== __slots__ ===")
class OptimizedPerson:
    __slots__ = ['name', 'age']
    
    def __init__(self, name, age):
        self.name = name
        self.age = age

opt_person = OptimizedPerson("Bob", 25)
print(f"opt_person.name: {opt_person.name}")

try:
    opt_person.city = "Osaka"  # エラー
except AttributeError as e:
    print(f"エラー: {e}")

# メモリ使用量の比較
import sys
regular_person = Person("Charlie", 35)
optimized_person = OptimizedPerson("David", 40)

print(f"\n通常のクラス: {sys.getsizeof(regular_person.__dict__)} bytes")
print(f"__slots__使用: {sys.getsizeof(optimized_person)} bytes")
```

## 15.3 【実行】メソッドとself引数の仕組み

```python
# methods_and_self.py

# メソッドの種類
print("=== メソッドの種類 ===")

class MethodTypes:
    class_var = 0
    
    def __init__(self, value):
        self.instance_var = value
    
    # インスタンスメソッド
    def instance_method(self):
        """通常のメソッド"""
        return f"インスタンスメソッド: self={self}, value={self.instance_var}"
    
    # クラスメソッド
    @classmethod
    def class_method(cls):
        """クラスメソッド"""
        cls.class_var += 1
        return f"クラスメソッド: cls={cls}, class_var={cls.class_var}"
    
    # スタティックメソッド
    @staticmethod
    def static_method(x, y):
        """スタティックメソッド"""
        return f"スタティックメソッド: {x} + {y} = {x + y}"

# 使用例
obj = MethodTypes(42)
print(obj.instance_method())
print(MethodTypes.class_method())
print(obj.class_method())  # インスタンスからも呼べる
print(MethodTypes.static_method(10, 20))
print(obj.static_method(5, 7))

# selfの仕組み
print("\n=== selfの仕組み ===")

class SelfDemo:
    def method(self, arg):
        print(f"self: {self}")
        print(f"arg: {arg}")
        return f"{self}.method({arg})"

demo = SelfDemo()

# 通常の呼び出し
print("\n通常の呼び出し:")
result1 = demo.method("hello")
print(f"結果: {result1}")

# 明示的な呼び出し
print("\n明示的な呼び出し:")
result2 = SelfDemo.method(demo, "world")
print(f"結果: {result2}")

# メソッドオブジェクト
print("\n=== メソッドオブジェクト ===")
method_obj = demo.method
print(f"method_obj: {method_obj}")
print(f"method_obj.__self__: {method_obj.__self__}")
print(f"method_obj.__func__: {method_obj.__func__}")
print(f"method_obj('test'): {method_obj('test')}")

# バインドされていないメソッド
unbound_method = SelfDemo.method
print(f"\nunbound_method: {unbound_method}")
print(f"unbound_method(demo, 'test'): {unbound_method(demo, 'test')}")

# プロパティ
print("\n=== プロパティ ===")
class Temperature:
    def __init__(self, celsius=0):
        self._celsius = celsius
    
    @property
    def celsius(self):
        """摂氏温度のゲッター"""
        print("  celsius getter呼び出し")
        return self._celsius
    
    @celsius.setter
    def celsius(self, value):
        """摂氏温度のセッター"""
        print(f"  celsius setter呼び出し: {value}")
        if value < -273.15:
            raise ValueError("絶対零度以下にはできません")
        self._celsius = value
    
    @property
    def fahrenheit(self):
        """華氏温度（読み取り専用）"""
        return self._celsius * 9/5 + 32
    
    @fahrenheit.setter
    def fahrenheit(self, value):
        """華氏温度のセッター"""
        self.celsius = (value - 32) * 5/9

# プロパティの使用
temp = Temperature()
print(f"初期温度: {temp.celsius}°C")
temp.celsius = 25
print(f"摂氏: {temp.celsius}°C")
print(f"華氏: {temp.fahrenheit}°F")

temp.fahrenheit = 86
print(f"華氏86°F = 摂氏{temp.celsius}°C")
```

## 15.4 【実行】継承とMRO（メソッド解決順序）

```python
# inheritance_mro.py

# 単純な継承
print("=== 単純な継承 ===")
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        return f"{self.name}が何か言っています"
    
    def move(self):
        return f"{self.name}が動いています"

class Dog(Animal):
    def speak(self):
        """メソッドのオーバーライド"""
        return f"{self.name}がワンワン吠えています"
    
    def fetch(self):
        """新しいメソッドの追加"""
        return f"{self.name}がボールを取ってきました"

class Cat(Animal):
    def speak(self):
        return f"{self.name}がニャーと鳴いています"
    
    def scratch(self):
        return f"{self.name}が爪を研いでいます"

# 使用例
dog = Dog("ポチ")
cat = Cat("タマ")

print(f"dog.speak(): {dog.speak()}")
print(f"dog.move(): {dog.move()}")
print(f"dog.fetch(): {dog.fetch()}")

print(f"\ncat.speak(): {cat.speak()}")
print(f"cat.scratch(): {cat.scratch()}")

# isinstance と issubclass
print(f"\nisinstance(dog, Dog): {isinstance(dog, Dog)}")
print(f"isinstance(dog, Animal): {isinstance(dog, Animal)}")
print(f"isinstance(dog, Cat): {isinstance(dog, Cat)}")
print(f"issubclass(Dog, Animal): {issubclass(Dog, Animal)}")

# 多重継承とMRO
print("\n=== 多重継承とMRO ===")
class A:
    def method(self):
        print("A.method")
        return "A"

class B(A):
    def method(self):
        print("B.method")
        return "B"

class C(A):
    def method(self):
        print("C.method")
        return "C"

class D(B, C):
    pass

# MROの確認
print(f"D.__mro__: {D.__mro__}")
print(f"D.mro(): {D.mro()}")

# メソッド呼び出し
d = D()
result = d.method()
print(f"d.method()の結果: {result}")

# ダイヤモンド継承問題
print("\n=== ダイヤモンド継承 ===")
class Base:
    def __init__(self):
        print("Base.__init__")
    
    def method(self):
        return "Base.method"

class Left(Base):
    def __init__(self):
        super().__init__()
        print("Left.__init__")
    
    def method(self):
        return f"Left.method -> {super().method()}"

class Right(Base):
    def __init__(self):
        super().__init__()
        print("Right.__init__")
    
    def method(self):
        return f"Right.method -> {super().method()}"

class Child(Left, Right):
    def __init__(self):
        super().__init__()
        print("Child.__init__")

print("Child()を作成:")
child = Child()
print(f"\nChild.__mro__: {[cls.__name__ for cls in Child.__mro__]}")
print(f"child.method(): {child.method()}")

# super()の動作
print("\n=== super()の動作 ===")
class Parent:
    def __init__(self, name):
        self.name = name
        print(f"Parent.__init__({name})")

class Child(Parent):
    def __init__(self, name, age):
        super().__init__(name)  # 親クラスの初期化
        self.age = age
        print(f"Child.__init__({name}, {age})")

child = Child("太郎", 10)

# 協調的な継承
print("\n=== 協調的な継承 ===")
class Loggable:
    def __init__(self, **kwargs):
        print(f"Loggable.__init__")
        super().__init__(**kwargs)

class Serializable:
    def __init__(self, **kwargs):
        print(f"Serializable.__init__")
        super().__init__(**kwargs)

class MyClass(Loggable, Serializable):
    def __init__(self, value):
        print(f"MyClass.__init__({value})")
        super().__init__(value=value)
        self.value = value

print("協調的な多重継承:")
obj = MyClass(42)
print(f"MRO: {[cls.__name__ for cls in MyClass.__mro__]}")
```

## 15.5 【実行】特殊メソッド（マジックメソッド）

```python
# special_methods.py

# 基本的な特殊メソッド
print("=== 基本的な特殊メソッド ===")
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __str__(self):
        """文字列表現（人間向け）"""
        return f"Point({self.x}, {self.y})"
    
    def __repr__(self):
        """文字列表現（開発者向け）"""
        return f"Point(x={self.x}, y={self.y})"
    
    def __eq__(self, other):
        """等価性の判定"""
        if not isinstance(other, Point):
            return NotImplemented
        return self.x == other.x and self.y == other.y
    
    def __hash__(self):
        """ハッシュ値の計算"""
        return hash((self.x, self.y))

p1 = Point(1, 2)
p2 = Point(1, 2)
p3 = Point(3, 4)

print(f"str(p1): {str(p1)}")
print(f"repr(p1): {repr(p1)}")
print(f"p1 == p2: {p1 == p2}")
print(f"p1 == p3: {p1 == p3}")
print(f"hash(p1): {hash(p1)}")

# 算術演算子のオーバーロード
print("\n=== 算術演算子 ===")
class Vector:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __add__(self, other):
        """ベクトルの加算"""
        if isinstance(other, Vector):
            return Vector(self.x + other.x, self.y + other.y)
        return NotImplemented
    
    def __sub__(self, other):
        """ベクトルの減算"""
        if isinstance(other, Vector):
            return Vector(self.x - other.x, self.y - other.y)
        return NotImplemented
    
    def __mul__(self, scalar):
        """スカラー倍"""
        return Vector(self.x * scalar, self.y * scalar)
    
    def __rmul__(self, scalar):
        """右側からのスカラー倍"""
        return self.__mul__(scalar)
    
    def __abs__(self):
        """絶対値（長さ）"""
        return (self.x ** 2 + self.y ** 2) ** 0.5
    
    def __str__(self):
        return f"Vector({self.x}, {self.y})"

v1 = Vector(3, 4)
v2 = Vector(1, 2)

print(f"v1 + v2 = {v1 + v2}")
print(f"v1 - v2 = {v1 - v2}")
print(f"v1 * 2 = {v1 * 2}")
print(f"3 * v2 = {3 * v2}")
print(f"abs(v1) = {abs(v1)}")

# コンテナプロトコル
print("\n=== コンテナプロトコル ===")
class Matrix:
    def __init__(self, data):
        self.data = data
    
    def __len__(self):
        """長さ（行数）"""
        return len(self.data)
    
    def __getitem__(self, key):
        """要素へのアクセス"""
        if isinstance(key, tuple):
            row, col = key
            return self.data[row][col]
        return self.data[key]
    
    def __setitem__(self, key, value):
        """要素の設定"""
        if isinstance(key, tuple):
            row, col = key
            self.data[row][col] = value
        else:
            self.data[key] = value
    
    def __contains__(self, value):
        """包含判定"""
        return any(value in row for row in self.data)
    
    def __iter__(self):
        """イテレータプロトコル"""
        return iter(self.data)

matrix = Matrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

print(f"len(matrix): {len(matrix)}")
print(f"matrix[1]: {matrix[1]}")
print(f"matrix[1, 2]: {matrix[1, 2]}")
print(f"5 in matrix: {5 in matrix}")
print(f"10 in matrix: {10 in matrix}")

matrix[0, 0] = 100
print(f"matrix[0, 0] = {matrix[0, 0]}")

# コンテキストマネージャ
print("\n=== コンテキストマネージャ ===")
class Timer:
    def __init__(self, name):
        self.name = name
    
    def __enter__(self):
        """withブロックの開始"""
        import time
        self.start = time.time()
        print(f"{self.name}: 計測開始")
        return self
    
    def __exit__(self, exc_type, exc_value, traceback):
        """withブロックの終了"""
        import time
        elapsed = time.time() - self.start
        print(f"{self.name}: {elapsed:.4f}秒")
        # 例外を再発生させる（Falseを返す）
        return False

with Timer("処理時間"):
    import time
    time.sleep(0.1)
    print("  何か処理をしています...")

# 呼び出し可能オブジェクト
print("\n=== 呼び出し可能オブジェクト ===")
class Multiplier:
    def __init__(self, factor):
        self.factor = factor
    
    def __call__(self, value):
        """オブジェクトを関数のように呼び出す"""
        return value * self.factor

times3 = Multiplier(3)
print(f"times3(10): {times3(10)}")
print(f"times3(7): {times3(7)}")
print(f"callable(times3): {callable(times3)}")
```

## 15.6 【実行】クラス変数とインスタンス変数の違い

```python
# class_vs_instance_vars.py

# 基本的な違い
print("=== クラス変数とインスタンス変数 ===")
class Counter:
    count = 0  # クラス変数
    
    def __init__(self, name):
        self.name = name  # インスタンス変数
        Counter.count += 1
        self.id = Counter.count
    
    def __str__(self):
        return f"{self.name} (ID: {self.id})"

# インスタンスの作成
c1 = Counter("First")
c2 = Counter("Second")
c3 = Counter("Third")

print(f"c1: {c1}")
print(f"c2: {c2}")
print(f"c3: {c3}")
print(f"Counter.count: {Counter.count}")

# 名前空間の確認
print("\n=== 名前空間 ===")
print(f"Counter.__dict__: {Counter.__dict__}")
print(f"c1.__dict__: {c1.__dict__}")

# 属性の解決順序
print("\n=== 属性の解決順序 ===")
class Demo:
    class_attr = "クラス属性"
    
    def __init__(self):
        # インスタンス属性はまだない
        pass

d = Demo()
print(f"d.class_attr: {d.class_attr}")  # クラス属性を参照
d.class_attr = "インスタンス属性"  # インスタンス属性を作成
print(f"d.class_attr: {d.class_attr}")  # インスタンス属性を参照
print(f"Demo.class_attr: {Demo.class_attr}")  # クラス属性は変更されていない

# ミュータブルなクラス変数の罠
print("\n=== ミュータブルなクラス変数の罠 ===")
class ListContainer:
    shared_list = []  # 危険！全インスタンスで共有される
    
    def add(self, item):
        self.shared_list.append(item)

container1 = ListContainer()
container2 = ListContainer()

container1.add("item1")
container2.add("item2")

print(f"container1.shared_list: {container1.shared_list}")
print(f"container2.shared_list: {container2.shared_list}")
print(f"同じオブジェクト？ {container1.shared_list is container2.shared_list}")

# 正しい実装
print("\n=== 正しい実装 ===")
class SafeListContainer:
    def __init__(self):
        self.items = []  # インスタンスごとに作成
    
    def add(self, item):
        self.items.append(item)

safe1 = SafeListContainer()
safe2 = SafeListContainer()

safe1.add("item1")
safe2.add("item2")

print(f"safe1.items: {safe1.items}")
print(f"safe2.items: {safe2.items}")

# クラスメソッドとクラス変数
print("\n=== クラスメソッドとクラス変数 ===")
class Configuration:
    _settings = {}
    
    @classmethod
    def set(cls, key, value):
        """設定値を保存"""
        cls._settings[key] = value
    
    @classmethod
    def get(cls, key, default=None):
        """設定値を取得"""
        return cls._settings.get(key, default)
    
    @classmethod
    def get_all(cls):
        """全設定を取得"""
        return cls._settings.copy()

# 使用例
Configuration.set("debug", True)
Configuration.set("timeout", 30)

print(f"debug: {Configuration.get('debug')}")
print(f"all settings: {Configuration.get_all()}")

# サブクラスでの挙動
class AppConfig(Configuration):
    pass

AppConfig.set("app_name", "MyApp")
print(f"\nAppConfig settings: {AppConfig.get_all()}")
print(f"Configuration settings: {Configuration.get_all()}")
print("注意: _settingsは共有されている！")

# 独立したクラス変数を持つサブクラス
class IndependentConfig:
    _settings = {}
    
    def __init_subclass__(cls):
        """サブクラス作成時に呼ばれる"""
        super().__init_subclass__()
        cls._settings = {}  # 各サブクラスに独自の辞書
    
    @classmethod
    def set(cls, key, value):
        cls._settings[key] = value
    
    @classmethod
    def get_all(cls):
        return cls._settings.copy()

class ServiceAConfig(IndependentConfig):
    pass

class ServiceBConfig(IndependentConfig):
    pass

ServiceAConfig.set("port", 8080)
ServiceBConfig.set("port", 9090)

print(f"\nServiceA: {ServiceAConfig.get_all()}")
print(f"ServiceB: {ServiceBConfig.get_all()}")
```

## 15.7 この章のまとめ

- クラスはclass文で定義され、テンプレートとして機能する
- インスタンスは`__new__`で作成され、`__init__`で初期化される
- メソッドの第一引数selfは自動的にインスタンスが渡される
- 継承によってコードの再利用と拡張が可能
- MROによってメソッドの解決順序が決まる
- 特殊メソッドで演算子のオーバーロードやプロトコルを実装できる
- クラス変数とインスタンス変数は異なる名前空間に存在する

## 練習問題

1. **カスタムリストクラス**
   Pythonの組み込みリストを継承して、要素の追加時に自動的にソートされるSortedListクラスを実装してください。

2. **デコレータクラス**
   関数の実行時間を計測するデコレータをクラスとして実装してください（`__call__`を使用）。

3. **抽象基底クラス**
   図形を表す抽象基底クラスShapeを作成し、Circle、Rectangle、Triangleクラスを実装してください。

4. **ディスクリプタ**
   型チェックを行うディスクリプタクラスを作成し、属性の型を強制してください。

5. **メタクラス入門**
   すべてのメソッド呼び出しをログに記録するメタクラスを作成してください。

---

次章では、例外処理の文法について学びます。

[第16章 例外処理の文法 →](chapter16.md)