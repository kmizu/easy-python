# 第17章：デコレータとメタプログラミング

## この章で学ぶこと

- 高度なデコレータパターン
- メタクラスの基礎
- ディスクリプタプロトコル
- 動的なクラス生成
- 抽象基底クラス（ABC）
- \_\_new\_\_, \_\_init\_subclass\_\_の活用

## 17.1 高度なデコレータパターン

### 【実行】クラスベースのデコレータ

```python
# advanced_decorators.py

# クラスベースのデコレータ
print("=== クラスベースのデコレータ ===")
class CountCalls:
    """関数の呼び出し回数をカウントするデコレータ"""
    
    def __init__(self, func):
        self.func = func
        self.count = 0
        # 元の関数の情報を保持
        self.__name__ = func.__name__
        self.__doc__ = func.__doc__
    
    def __call__(self, *args, **kwargs):
        self.count += 1
        print(f"  {self.func.__name__}が{self.count}回目の呼び出し")
        return self.func(*args, **kwargs)
    
    def reset_count(self):
        """カウンターをリセット"""
        self.count = 0

@CountCalls
def greet(name):
    """挨拶する関数"""
    return f"Hello, {name}!"

print(greet("Alice"))
print(greet("Bob"))
print(f"現在のカウント: {greet.count}")
greet.reset_count()
print(f"リセット後: {greet.count}")

# パラメータ付きクラスデコレータ
print("\n=== パラメータ付きクラスデコレータ ===")
class RateLimit:
    """レート制限デコレータ"""
    
    def __init__(self, max_calls, period):
        self.max_calls = max_calls
        self.period = period
        self.calls = []
    
    def __call__(self, func):
        def wrapper(*args, **kwargs):
            import time
            now = time.time()
            
            # 期間外の呼び出しを削除
            self.calls = [call_time for call_time in self.calls 
                         if now - call_time < self.period]
            
            # レート制限チェック
            if len(self.calls) >= self.max_calls:
                raise RuntimeError(
                    f"レート制限: {self.period}秒間に{self.max_calls}回まで"
                )
            
            self.calls.append(now)
            return func(*args, **kwargs)
        
        wrapper.reset_limit = lambda: self.calls.clear()
        return wrapper

@RateLimit(max_calls=3, period=5.0)
def send_email(to):
    print(f"メール送信: {to}")
    return "送信完了"

# テスト
for i in range(4):
    try:
        send_email(f"user{i}@example.com")
    except RuntimeError as e:
        print(f"エラー: {e}")

# メソッドデコレータ
print("\n=== メソッドデコレータ ===")
class Timer:
    """メソッドの実行時間を測定"""
    
    def __init__(self, func):
        self.func = func
        
    def __get__(self, obj, objtype):
        """ディスクリプタプロトコル"""
        if obj is None:
            return self
        import functools
        return functools.partial(self.__call__, obj)
    
    def __call__(self, *args, **kwargs):
        import time
        start = time.time()
        result = self.func(*args, **kwargs)
        end = time.time()
        print(f"{self.func.__name__}: {end - start:.4f}秒")
        return result

class Calculator:
    @Timer
    def slow_calculation(self, n):
        """時間のかかる計算"""
        import time
        time.sleep(0.1)
        return sum(range(n))

calc = Calculator()
result = calc.slow_calculation(1000)
print(f"結果: {result}")

# デコレータの合成
print("\n=== デコレータの合成 ===")
def validate_types(**expected_types):
    """型チェックデコレータ"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            import inspect
            sig = inspect.signature(func)
            bound = sig.bind(*args, **kwargs)
            bound.apply_defaults()
            
            for name, expected_type in expected_types.items():
                if name in bound.arguments:
                    value = bound.arguments[name]
                    if not isinstance(value, expected_type):
                        raise TypeError(
                            f"{name}は{expected_type.__name__}型が必要"
                        )
            
            return func(*args, **kwargs)
        return wrapper
    return decorator

def cache_result(func):
    """結果をキャッシュするデコレータ"""
    cache = {}
    def wrapper(*args, **kwargs):
        key = str(args) + str(kwargs)
        if key in cache:
            print(f"  キャッシュヒット: {key}")
            return cache[key]
        
        result = func(*args, **kwargs)
        cache[key] = result
        print(f"  結果をキャッシュ: {key}")
        return result
    
    wrapper.clear_cache = lambda: cache.clear()
    return wrapper

# 複数のデコレータを適用
@cache_result
@validate_types(x=int, y=int)
@CountCalls
def add(x, y):
    print(f"    実際の計算: {x} + {y}")
    return x + y

print(add(1, 2))
print(add(1, 2))  # キャッシュされる
print(add(3, 4))
```

### 【実行】デコレータファクトリー

```python
# decorator_factory.py

# 高度なデコレータファクトリー
print("=== デコレータファクトリー ===")

def with_timeout(timeout_seconds):
    """タイムアウト機能付きデコレータ"""
    def decorator(func):
        import signal
        import functools
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            def timeout_handler(signum, frame):
                raise TimeoutError(f"{func.__name__}が{timeout_seconds}秒でタイムアウト")
            
            # シグナルハンドラーを設定
            old_handler = signal.signal(signal.SIGALRM, timeout_handler)
            signal.alarm(timeout_seconds)
            
            try:
                result = func(*args, **kwargs)
                return result
            finally:
                signal.alarm(0)  # タイマーをリセット
                signal.signal(signal.SIGALRM, old_handler)
        
        return wrapper
    return decorator

@with_timeout(2)
def slow_function():
    import time
    time.sleep(1)
    return "完了"

try:
    result = slow_function()
    print(f"結果: {result}")
except TimeoutError as e:
    print(f"タイムアウト: {e}")

# 条件付きデコレータ
print("\n=== 条件付きデコレータ ===")
def conditional_decorator(condition):
    """条件が真の場合のみデコレートする"""
    def decorator(decorator_func):
        def wrapper(func):
            if condition:
                return decorator_func(func)
            return func
        return wrapper
    return decorator

def debug_decorator(func):
    """デバッグ情報を出力"""
    def wrapper(*args, **kwargs):
        print(f"DEBUG: {func.__name__}({args}, {kwargs})")
        result = func(*args, **kwargs)
        print(f"DEBUG: -> {result}")
        return result
    return wrapper

# デバッグモードの設定
DEBUG_MODE = True

@conditional_decorator(DEBUG_MODE)(debug_decorator)
def calculate(x, y):
    return x * y

print(calculate(3, 4))

# 環境に基づくデコレータ
print("\n=== 環境に基づくデコレータ ===")
import os

def env_specific(env_name, default_env='development'):
    """環境に基づいてデコレータを適用"""
    current_env = os.environ.get('PYTHON_ENV', default_env)
    
    def decorator(decorators_dict):
        def wrapper(func):
            if current_env in decorators_dict:
                return decorators_dict[current_env](func)
            return func
        return wrapper
    return decorator

def production_logging(func):
    """本番環境用ログ"""
    def wrapper(*args, **kwargs):
        print(f"PROD: 実行中 {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

def development_debug(func):
    """開発環境用デバッグ"""
    def wrapper(*args, **kwargs):
        print(f"DEV: デバッグ {func.__name__} with {args}")
        return func(*args, **kwargs)
    return wrapper

@env_specific('development')({
    'production': production_logging,
    'development': development_debug
})
def process_data(data):
    return f"処理済み: {data}"

print(process_data("テストデータ"))
```

## 17.2 【実行】メタクラスの基礎

```python
# metaclass_basics.py

# メタクラスの基本概念
print("=== メタクラスの基本概念 ===")

# クラスもオブジェクト
class MyClass:
    pass

print(f"MyClass: {MyClass}")
print(f"type(MyClass): {type(MyClass)}")
print(f"MyClass.__class__: {MyClass.__class__}")

# 動的なクラス作成
print("\n=== 動的なクラス作成 ===")

# type()を使ったクラス作成
def init_method(self, value):
    self.value = value

def str_method(self):
    return f"DynamicClass(value={self.value})"

# type(name, bases, dict)でクラスを作成
DynamicClass = type(
    'DynamicClass',
    (object,),
    {
        '__init__': init_method,
        '__str__': str_method,
        'class_variable': 'dynamically created'
    }
)

obj = DynamicClass(42)
print(f"obj: {obj}")
print(f"obj.class_variable: {obj.class_variable}")

# 基本的なメタクラス
print("\n=== 基本的なメタクラス ===")

class SingletonMeta(type):
    """シングルトンパターンを実装するメタクラス"""
    _instances = {}
    
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]

class DatabaseConnection(metaclass=SingletonMeta):
    def __init__(self):
        print("データベース接続を作成")
        self.connection_id = id(self)

# シングルトンの確認
db1 = DatabaseConnection()
db2 = DatabaseConnection()
print(f"db1 is db2: {db1 is db2}")
print(f"db1.connection_id: {db1.connection_id}")
print(f"db2.connection_id: {db2.connection_id}")

# メタクラスでクラス作成をカスタマイズ
print("\n=== クラス作成のカスタマイズ ===")

class AutoPropertyMeta(type):
    """属性を自動的にプロパティに変換するメタクラス"""
    
    def __new__(mcs, name, bases, attrs):
        # _で始まる属性をプロパティに変換
        for key, value in list(attrs.items()):
            if key.startswith('_') and not key.startswith('__'):
                prop_name = key[1:]  # _を除去
                
                def make_property(attr_name):
                    def getter(self):
                        return getattr(self, attr_name)
                    
                    def setter(self, value):
                        print(f"  {attr_name}を{value}に設定")
                        setattr(self, attr_name, value)
                    
                    return property(getter, setter)
                
                if prop_name not in attrs:
                    attrs[prop_name] = make_property(key)
        
        return super().__new__(mcs, name, bases, attrs)

class Person(metaclass=AutoPropertyMeta):
    def __init__(self, name, age):
        self._name = name
        self._age = age

person = Person("Alice", 30)
print(f"person.name: {person.name}")
person.age = 31  # setter が呼ばれる

# メタクラスの継承
print("\n=== メタクラスの継承 ===")

class LoggingMeta(type):
    """メソッド呼び出しをログに記録するメタクラス"""
    
    def __new__(mcs, name, bases, attrs):
        # すべてのメソッドをラップ
        for key, value in attrs.items():
            if callable(value) and not key.startswith('__'):
                attrs[key] = mcs.wrap_method(value, key)
        
        return super().__new__(mcs, name, bases, attrs)
    
    @staticmethod
    def wrap_method(method, method_name):
        def wrapper(self, *args, **kwargs):
            print(f"LOG: {method_name}が呼ばれました")
            result = method(self, *args, **kwargs)
            print(f"LOG: {method_name}が完了しました")
            return result
        return wrapper

class Calculator(metaclass=LoggingMeta):
    def add(self, a, b):
        return a + b
    
    def multiply(self, a, b):
        return a * b

calc = Calculator()
result1 = calc.add(3, 5)
result2 = calc.multiply(4, 6)
print(f"add結果: {result1}, multiply結果: {result2}")
```

## 17.3 【実行】ディスクリプタプロトコル

```python
# descriptor_protocol.py

# 基本的なディスクリプタ
print("=== 基本的なディスクリプタ ===")

class Descriptor:
    """基本的なディスクリプタの例"""
    
    def __init__(self, name):
        self.name = name
    
    def __get__(self, obj, objtype=None):
        print(f"  __get__: {self.name}, obj={obj}, type={objtype}")
        if obj is None:
            return self
        return obj.__dict__.get(self.name, None)
    
    def __set__(self, obj, value):
        print(f"  __set__: {self.name} = {value}")
        obj.__dict__[self.name] = value
    
    def __delete__(self, obj):
        print(f"  __delete__: {self.name}")
        del obj.__dict__[self.name]

class MyClass:
    attr = Descriptor('attr')

obj = MyClass()
print("obj.attr = 'hello'")
obj.attr = 'hello'
print(f"obj.attr: {obj.attr}")
print("del obj.attr")
del obj.attr

# 型チェックディスクリプタ
print("\n=== 型チェックディスクリプタ ===")

class TypedAttribute:
    """型チェック付き属性"""
    
    def __init__(self, expected_type, name=None):
        self.expected_type = expected_type
        self.name = name
    
    def __set_name__(self, owner, name):
        """Python 3.6+で自動的に呼ばれる"""
        self.name = name
    
    def __get__(self, obj, objtype=None):
        if obj is None:
            return self
        return obj.__dict__.get(self.name)
    
    def __set__(self, obj, value):
        if not isinstance(value, self.expected_type):
            raise TypeError(
                f"{self.name}は{self.expected_type.__name__}型である必要があります"
            )
        obj.__dict__[self.name] = value

class Person:
    name = TypedAttribute(str)
    age = TypedAttribute(int)
    
    def __init__(self, name, age):
        self.name = name
        self.age = age

person = Person("Alice", 30)
print(f"person.name: {person.name}")
print(f"person.age: {person.age}")

try:
    person.age = "thirty"
except TypeError as e:
    print(f"エラー: {e}")

# 計算プロパティディスクリプタ
print("\n=== 計算プロパティディスクリプタ ===")

class ComputedProperty:
    """計算されるプロパティ"""
    
    def __init__(self, func):
        self.func = func
        self.name = func.__name__
    
    def __get__(self, obj, objtype=None):
        if obj is None:
            return self
        # 毎回計算（キャッシュしない）
        return self.func(obj)
    
    def __set__(self, obj, value):
        raise AttributeError(f"{self.name}は読み取り専用です")

class Rectangle:
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    @ComputedProperty
    def area(self):
        print(f"  面積を計算中: {self.width} * {self.height}")
        return self.width * self.height
    
    @ComputedProperty
    def perimeter(self):
        return 2 * (self.width + self.height)

rect = Rectangle(5, 3)
print(f"面積: {rect.area}")
print(f"面積（再計算）: {rect.area}")
print(f"周囲: {rect.perimeter}")

try:
    rect.area = 100
except AttributeError as e:
    print(f"エラー: {e}")

# キャッシュディスクリプタ
print("\n=== キャッシュディスクリプタ ===")

class CachedProperty:
    """計算結果をキャッシュするプロパティ"""
    
    def __init__(self, func):
        self.func = func
        self.name = func.__name__
    
    def __get__(self, obj, objtype=None):
        if obj is None:
            return self
        
        # キャッシュをチェック
        cache_name = f'_cached_{self.name}'
        if hasattr(obj, cache_name):
            print(f"  キャッシュから取得: {self.name}")
            return getattr(obj, cache_name)
        
        # 計算してキャッシュ
        print(f"  計算してキャッシュ: {self.name}")
        value = self.func(obj)
        setattr(obj, cache_name, value)
        return value
    
    def __delete__(self, obj):
        # キャッシュをクリア
        cache_name = f'_cached_{self.name}'
        if hasattr(obj, cache_name):
            delattr(obj, cache_name)

class ExpensiveCalculation:
    def __init__(self, base_value):
        self.base_value = base_value
    
    @CachedProperty
    def expensive_result(self):
        """時間のかかる計算"""
        import time
        time.sleep(0.1)
        return self.base_value ** 2

calc = ExpensiveCalculation(10)
print(f"1回目: {calc.expensive_result}")
print(f"2回目: {calc.expensive_result}")

# キャッシュをクリア
del calc.expensive_result
print(f"クリア後: {calc.expensive_result}")
```

## 17.4 【実行】動的なクラス生成とナメームドタプル

```python
# dynamic_class_generation.py

# 基本的な動的クラス生成
print("=== 基本的な動的クラス生成 ===")

def create_class(class_name, attributes):
    """属性を持つクラスを動的に作成"""
    
    def __init__(self, **kwargs):
        for attr in attributes:
            value = kwargs.get(attr, None)
            setattr(self, attr, value)
    
    def __repr__(self):
        values = [f"{attr}={getattr(self, attr)}" for attr in attributes]
        return f"{class_name}({', '.join(values)})"
    
    # クラス辞書を構築
    class_dict = {
        '__init__': __init__,
        '__repr__': __repr__,
        '__slots__': attributes  # メモリ最適化
    }
    
    return type(class_name, (object,), class_dict)

# 動的にPersonクラスを作成
Person = create_class('Person', ['name', 'age', 'city'])
person = Person(name="Alice", age=30, city="Tokyo")
print(f"person: {person}")

# ナメッドタプルのような機能
print("\n=== ナメッドタプル風の実装 ===")

def namedtuple_like(typename, field_names):
    """namedtupleのような機能を実装"""
    
    if isinstance(field_names, str):
        field_names = field_names.split()
    
    def __new__(cls, *args):
        if len(args) != len(field_names):
            raise TypeError(f"{typename}には{len(field_names)}個の引数が必要")
        
        instance = object.__new__(cls)
        for name, value in zip(field_names, args):
            object.__setattr__(instance, name, value)
        return instance
    
    def __repr__(self):
        values = [f"{name}={getattr(self, name)!r}" for name in field_names]
        return f"{typename}({', '.join(values)})"
    
    def __eq__(self, other):
        if not isinstance(other, self.__class__):
            return False
        return all(getattr(self, name) == getattr(other, name) 
                  for name in field_names)
    
    def __setattr__(self, name, value):
        raise AttributeError(f"{typename}は不変です")
    
    def __delattr__(self, name):
        raise AttributeError(f"{typename}は不変です")
    
    # クラス辞書
    class_dict = {
        '__new__': __new__,
        '__repr__': __repr__,
        '__eq__': __eq__,
        '__setattr__': __setattr__,
        '__delattr__': __delattr__,
        '__slots__': field_names,
        '_fields': field_names
    }
    
    return type(typename, (object,), class_dict)

Point = namedtuple_like('Point', 'x y')
p1 = Point(1, 2)
p2 = Point(1, 2)
p3 = Point(3, 4)

print(f"p1: {p1}")
print(f"p1.x: {p1.x}")
print(f"p1 == p2: {p1 == p2}")
print(f"p1 == p3: {p1 == p3}")

try:
    p1.x = 10
except AttributeError as e:
    print(f"エラー: {e}")

# データクラス風の実装
print("\n=== データクラス風の実装 ===")

def dataclass_like(cls):
    """dataclassのような機能を提供するデコレータ"""
    
    # 型ヒントから属性を取得
    annotations = getattr(cls, '__annotations__', {})
    
    def __init__(self, **kwargs):
        for name in annotations:
            if name in kwargs:
                setattr(self, name, kwargs[name])
            elif hasattr(cls, name):
                setattr(self, name, getattr(cls, name))
            else:
                raise TypeError(f"必須引数 {name} が指定されていません")
    
    def __repr__(self):
        values = [f"{name}={getattr(self, name)!r}" 
                 for name in annotations]
        return f"{cls.__name__}({', '.join(values)})"
    
    def __eq__(self, other):
        if not isinstance(other, cls):
            return False
        return all(getattr(self, name) == getattr(other, name) 
                  for name in annotations)
    
    # メソッドを追加
    cls.__init__ = __init__
    cls.__repr__ = __repr__
    cls.__eq__ = __eq__
    
    return cls

@dataclass_like
class Book:
    title: str
    author: str
    year: int = 2023

book1 = Book(title="Python入門", author="田中太郎", year=2023)
book2 = Book(title="Python入門", author="田中太郎")
print(f"book1: {book1}")
print(f"book2: {book2}")
print(f"book1 == book2: {book1 == book2}")

# ファクトリーパターン
print("\n=== ファクトリーパターン ===")

class ClassFactory:
    """クラスを動的に作成するファクトリー"""
    
    @staticmethod
    def create_model(name, **fields):
        """モデルクラスを作成"""
        
        def __init__(self, **kwargs):
            for field_name, field_type in fields.items():
                value = kwargs.get(field_name)
                if value is not None and not isinstance(value, field_type):
                    raise TypeError(
                        f"{field_name}は{field_type.__name__}型が必要"
                    )
                setattr(self, field_name, value)
        
        def validate(self):
            """バリデーション"""
            for field_name, field_type in fields.items():
                value = getattr(self, field_name, None)
                if value is None:
                    raise ValueError(f"{field_name}は必須です")
        
        def to_dict(self):
            """辞書に変換"""
            return {name: getattr(self, name, None) for name in fields}
        
        # クラス辞書
        class_dict = {
            '__init__': __init__,
            'validate': validate,
            'to_dict': to_dict,
            '_fields': fields
        }
        
        return type(name, (object,), class_dict)

# ユーザーモデルを作成
User = ClassFactory.create_model(
    'User',
    id=int,
    name=str,
    email=str
)

user = User(id=1, name="Alice", email="alice@example.com")
user.validate()
print(f"user.to_dict(): {user.to_dict()}")

try:
    invalid_user = User(id="not_int", name="Bob")
except TypeError as e:
    print(f"型エラー: {e}")
```

## 17.5 【実行】抽象基底クラス（ABC）

```python
# abstract_base_classes.py

# 基本的なABC
print("=== 基本的なABC ===")
from abc import ABC, abstractmethod

class Animal(ABC):
    """動物の抽象基底クラス"""
    
    @abstractmethod
    def make_sound(self):
        """動物の鳴き声（サブクラスで実装必須）"""
        pass
    
    @abstractmethod
    def move(self):
        """動物の移動方法（サブクラスで実装必須）"""
        pass
    
    def info(self):
        """共通の情報表示（具象メソッド）"""
        return f"{self.__class__.__name__}: {self.make_sound()}"

# 抽象クラスはインスタンス化できない
try:
    animal = Animal()
except TypeError as e:
    print(f"エラー: {e}")

# 具象クラスの実装
class Dog(Animal):
    def make_sound(self):
        return "ワンワン"
    
    def move(self):
        return "走る"

class Bird(Animal):
    def make_sound(self):
        return "チュンチュン"
    
    def move(self):
        return "飛ぶ"

dog = Dog()
bird = Bird()
print(f"dog.info(): {dog.info()}")
print(f"bird.move(): {bird.move()}")

# 抽象プロパティ
print("\n=== 抽象プロパティ ===")

class Shape(ABC):
    """図形の抽象基底クラス"""
    
    @property
    @abstractmethod
    def area(self):
        """面積（抽象プロパティ）"""
        pass
    
    @property
    @abstractmethod
    def perimeter(self):
        """周囲長（抽象プロパティ）"""
        pass

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    @property
    def area(self):
        return self.width * self.height
    
    @property
    def perimeter(self):
        return 2 * (self.width + self.height)

rect = Rectangle(5, 3)
print(f"長方形の面積: {rect.area}")
print(f"長方形の周囲: {rect.perimeter}")

# クラスメソッドの抽象化
print("\n=== 抽象クラスメソッド ===")

class DatabaseConnection(ABC):
    """データベース接続の抽象基底クラス"""
    
    @classmethod
    @abstractmethod
    def connect(cls, connection_string):
        """接続を確立（抽象クラスメソッド）"""
        pass
    
    @abstractmethod
    def execute(self, query):
        """クエリを実行（抽象インスタンスメソッド）"""
        pass

class MySQLConnection(DatabaseConnection):
    def __init__(self, connection_string):
        self.connection_string = connection_string
        print(f"MySQL接続: {connection_string}")
    
    @classmethod
    def connect(cls, connection_string):
        return cls(connection_string)
    
    def execute(self, query):
        return f"MySQL実行: {query}"

mysql = MySQLConnection.connect("mysql://localhost:3306/test")
result = mysql.execute("SELECT * FROM users")
print(result)

# 仮想サブクラス
print("\n=== 仮想サブクラス ===")

class Drawable(ABC):
    """描画可能オブジェクトのABC"""
    
    @abstractmethod
    def draw(self):
        pass

# 既存のクラスを仮想サブクラスとして登録
class Circle:
    def __init__(self, radius):
        self.radius = radius
    
    def draw(self):
        return f"半径{self.radius}の円を描画"

# 仮想サブクラスとして登録
Drawable.register(Circle)

circle = Circle(5)
print(f"isinstance(circle, Drawable): {isinstance(circle, Drawable)}")
print(f"issubclass(Circle, Drawable): {issubclass(Circle, Drawable)}")
print(f"circle.draw(): {circle.draw()}")

# プロトコルチェック
print("\n=== プロトコルチェック ===")

class Sized(ABC):
    """サイズを持つオブジェクトのABC"""
    
    @abstractmethod
    def __len__(self):
        pass

# 組み込み型も自動的にサブクラスになる
print(f"issubclass(list, Sized): {issubclass(list, Sized)}")
print(f"issubclass(str, Sized): {issubclass(str, Sized)}")
print(f"issubclass(int, Sized): {issubclass(int, Sized)}")

my_list = [1, 2, 3]
print(f"isinstance(my_list, Sized): {isinstance(my_list, Sized)}")

# 複数の抽象基底クラス
print("\n=== 複数のABC ===")

class Readable(ABC):
    @abstractmethod
    def read(self):
        pass

class Writable(ABC):
    @abstractmethod
    def write(self, data):
        pass

class ReadWritable(Readable, Writable):
    """読み書き可能な抽象基底クラス"""
    pass

class File(ReadWritable):
    def __init__(self, filename):
        self.filename = filename
        self.content = ""
    
    def read(self):
        return self.content
    
    def write(self, data):
        self.content += data

file = File("test.txt")
file.write("Hello, ")
file.write("World!")
print(f"file.read(): {file.read()}")
```

## 17.6 \_\_new\_\_と\_\_init\_subclass\_\_の活用

```python
# new_and_init_subclass.py

# __new__の活用
print("=== __new__の活用 ===")

class ImmutablePoint:
    """不変なポイントクラス"""
    
    def __new__(cls, x, y):
        # __new__でインスタンスを作成
        instance = super().__new__(cls)
        # 属性を直接設定（__init__前）
        instance._x = x
        instance._y = y
        return instance
    
    def __init__(self, x, y):
        # __init__では何もしない（すでに初期化済み）
        pass
    
    @property
    def x(self):
        return self._x
    
    @property
    def y(self):
        return self._y
    
    def __setattr__(self, name, value):
        if hasattr(self, '_x'):  # 初期化後
            raise AttributeError("ImmutablePointは不変です")
        super().__setattr__(name, value)
    
    def __repr__(self):
        return f"ImmutablePoint({self.x}, {self.y})"

point = ImmutablePoint(3, 4)
print(f"point: {point}")
try:
    point.x = 10
except AttributeError as e:
    print(f"エラー: {e}")

# __init_subclass__の活用
print("\n=== __init_subclass__の活用 ===")

class PluginBase:
    """プラグインの基底クラス"""
    _plugins = {}
    
    def __init_subclass__(cls, plugin_name=None, **kwargs):
        super().__init_subclass__(**kwargs)
        if plugin_name:
            cls._plugins[plugin_name] = cls
            print(f"プラグイン '{plugin_name}' を登録: {cls.__name__}")
    
    @classmethod
    def get_plugin(cls, name):
        return cls._plugins.get(name)
    
    @classmethod
    def list_plugins(cls):
        return list(cls._plugins.keys())

# プラグインを作成（自動登録される）
class TextProcessor(PluginBase, plugin_name='text'):
    def process(self, data):
        return data.upper()

class ImageProcessor(PluginBase, plugin_name='image'):
    def process(self, data):
        return f"処理済み画像: {data}"

class VideoProcessor(PluginBase, plugin_name='video'):
    def process(self, data):
        return f"処理済み動画: {data}"

# プラグインの使用
print(f"利用可能なプラグイン: {PluginBase.list_plugins()}")

text_plugin = PluginBase.get_plugin('text')()
result = text_plugin.process("hello world")
print(f"テキスト処理結果: {result}")

# 検証機能付きサブクラス
print("\n=== 検証機能付きサブクラス ===")

class ValidatedModel:
    """検証機能付きモデルの基底クラス"""
    
    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        
        # 型ヒントから必須フィールドを取得
        annotations = getattr(cls, '__annotations__', {})
        cls._fields = annotations
        
        # バリデーションメソッドを自動生成
        cls._setup_validation()
    
    @classmethod
    def _setup_validation(cls):
        """バリデーションメソッドをセットアップ"""
        original_init = cls.__init__
        
        def validated_init(self, **kwargs):
            # 型チェック
            for field_name, field_type in cls._fields.items():
                if field_name in kwargs:
                    value = kwargs[field_name]
                    if not isinstance(value, field_type):
                        raise TypeError(
                            f"{field_name}は{field_type.__name__}型が必要"
                        )
                    setattr(self, field_name, value)
            
            # カスタムバリデーション
            if hasattr(cls, 'validate'):
                cls.validate(self)
        
        cls.__init__ = validated_init

class User(ValidatedModel):
    name: str
    age: int
    email: str
    
    def validate(self):
        """カスタムバリデーション"""
        if self.age < 0:
            raise ValueError("年齢は0以上である必要があります")
        if '@' not in self.email:
            raise ValueError("無効なメールアドレスです")

# 正常なケース
user = User(name="Alice", age=30, email="alice@example.com")
print(f"ユーザー作成成功: {user.name}")

# エラーケース
try:
    invalid_user = User(name="Bob", age=-5, email="bob@example.com")
except ValueError as e:
    print(f"バリデーションエラー: {e}")

# Singleton with __new__
print("\n=== Singletonの実装 ===")

class SingletonMeta(type):
    _instances = {}
    
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]

class Config(metaclass=SingletonMeta):
    def __init__(self):
        if not hasattr(self, 'initialized'):
            self.settings = {}
            self.initialized = True
    
    def set(self, key, value):
        self.settings[key] = value
    
    def get(self, key):
        return self.settings.get(key)

config1 = Config()
config2 = Config()

config1.set('debug', True)
print(f"config1 is config2: {config1 is config2}")
print(f"config2.get('debug'): {config2.get('debug')}")
```

## 17.7 この章のまとめ

- デコレータはクラスベースでも実装でき、状態を保持できる
- メタクラスでクラス作成プロセスをカスタマイズできる
- ディスクリプタでプロパティアクセスを制御できる
- 動的なクラス生成でコードを自動化できる
- ABCで明確なインターフェースを定義できる
- `__new__`と`__init_subclass__`で高度なカスタマイズが可能

## 練習問題

1. **ORM風ライブラリ**
   メタクラスとディスクリプタを使って簡単なORM風ライブラリを作成してください。

2. **バリデーションライブラリ**
   デコレータとABCを組み合わせたバリデーションライブラリを実装してください。

3. **プラグインシステム**
   `__init_subclass__`を使った拡張可能なプラグインシステムを作成してください。

4. **型安全なBuilder**
   ディスクリプタを使って型安全なBuilderパターンを実装してください。

5. **メタクラスによるAPI生成**
   クラス定義からREST APIのエンドポイントを自動生成するメタクラスを作成してください。

---

次章では、Pythonの内部動作について詳しく学びます。

[第18章 Pythonの内部動作と最適化 →](../part7/chapter18.md)