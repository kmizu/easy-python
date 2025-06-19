# 第14章：再帰とPythonインタプリタの実行モデル

## この章で学ぶこと

- 再帰関数の基礎
- 再帰呼び出しのスタックトレース
- 抽象構文木（AST）の再帰的な評価
- 簡単な式評価インタプリタの実装
- Pythonインタプリタが構文木をたどる様子
- 末尾再帰最適化がない理由

## 14.1 再帰関数の基礎

### 再帰の基本概念

```python
# recursion_basics.py

# 基本的な再帰関数
print("=== 階乗の計算 ===")
def factorial(n):
    """n! を再帰的に計算"""
    print(f"  factorial({n})が呼ばれました")
    
    # ベースケース（終了条件）
    if n <= 1:
        print(f"  -> ベースケース: {n}! = 1")
        return 1
    
    # 再帰ケース
    result = n * factorial(n - 1)
    print(f"  -> {n}! = {n} * {n-1}! = {result}")
    return result

result = factorial(5)
print(f"\n結果: 5! = {result}")

# フィボナッチ数列
print("\n=== フィボナッチ数列 ===")
def fibonacci(n, depth=0):
    """n番目のフィボナッチ数を計算（視覚化付き）"""
    indent = "  " * depth
    print(f"{indent}fib({n})")
    
    if n <= 1:
        print(f"{indent}-> {n}")
        return n
    
    result = fibonacci(n-1, depth+1) + fibonacci(n-2, depth+1)
    print(f"{indent}-> {result}")
    return result

fib_result = fibonacci(5)
print(f"\n結果: fib(5) = {fib_result}")

# 再帰の深さ制限
print("\n=== 再帰の深さ制限 ===")
import sys
print(f"デフォルトの再帰制限: {sys.getrecursionlimit()}")

def deep_recursion(n):
    """深い再帰のテスト"""
    if n == 0:
        return 0
    return 1 + deep_recursion(n - 1)

try:
    result = deep_recursion(5000)
except RecursionError as e:
    print(f"RecursionError: {e}")

# 再帰制限の変更（注意が必要）
sys.setrecursionlimit(10000)
print(f"新しい再帰制限: {sys.getrecursionlimit()}")
```

## 14.2 【実行】再帰呼び出しのスタックトレース

```python
# recursion_stack_trace.py
import traceback
import inspect

# スタックフレームの可視化
print("=== スタックフレームの可視化 ===")

def print_stack():
    """現在のスタックを表示"""
    frames = inspect.stack()
    print(f"\n現在のスタック深さ: {len(frames)}")
    for i, frame in enumerate(frames[:5]):  # 上位5フレームのみ
        print(f"  {i}: {frame.function} ({frame.filename}:{frame.lineno})")

def recursive_function(n):
    """スタックを表示する再帰関数"""
    print(f"\n--- recursive_function({n}) ---")
    print_stack()
    
    if n > 0:
        recursive_function(n - 1)
    
    print(f"\n--- returning from recursive_function({n}) ---")

recursive_function(3)

# スタックフレームの詳細情報
print("\n=== スタックフレームの詳細 ===")

def examine_frame(n):
    """フレームの詳細を調査"""
    if n == 0:
        frame = inspect.currentframe()
        print("\nフレーム情報:")
        print(f"  関数名: {frame.f_code.co_name}")
        print(f"  ファイル名: {frame.f_code.co_filename}")
        print(f"  行番号: {frame.f_lineno}")
        print(f"  ローカル変数: {frame.f_locals}")
        
        # 呼び出し元の情報
        caller_frame = frame.f_back
        if caller_frame:
            print(f"\n呼び出し元:")
            print(f"  関数名: {caller_frame.f_code.co_name}")
            print(f"  行番号: {caller_frame.f_lineno}")
        
        return
    
    examine_frame(n - 1)

examine_frame(3)

# 例外発生時のトレースバック
print("\n=== 例外時のトレースバック ===")

def buggy_recursion(n):
    """エラーを含む再帰関数"""
    if n == 0:
        raise ValueError("意図的なエラー")
    return buggy_recursion(n - 1)

try:
    buggy_recursion(5)
except ValueError:
    print("トレースバック:")
    traceback.print_exc()

# メモリ使用量の観察
print("\n=== 再帰とメモリ使用量 ===")
import psutil
import os

def memory_intensive_recursion(n, data_size=1000):
    """メモリを消費する再帰"""
    # 各フレームでデータを保持
    local_data = list(range(data_size))
    
    if n == 0:
        process = psutil.Process(os.getpid())
        memory_mb = process.memory_info().rss / 1024 / 1024
        print(f"メモリ使用量: {memory_mb:.2f} MB")
        return
    
    memory_intensive_recursion(n - 1, data_size)

print("浅い再帰:")
memory_intensive_recursion(10)

print("\n深い再帰:")
memory_intensive_recursion(100)
```

## 14.3 【実行】抽象構文木（AST）の再帰的な評価

```python
# ast_recursive_evaluation.py
import ast
import operator

# ASTの可視化
print("=== 抽象構文木（AST）の構造 ===")

def visualize_ast(node, level=0):
    """ASTノードを再帰的に表示"""
    indent = "  " * level
    node_name = node.__class__.__name__
    
    if isinstance(node, ast.BinOp):
        op_name = node.op.__class__.__name__
        print(f"{indent}{node_name} ({op_name})")
        visualize_ast(node.left, level + 1)
        visualize_ast(node.right, level + 1)
    elif isinstance(node, ast.UnaryOp):
        op_name = node.op.__class__.__name__
        print(f"{indent}{node_name} ({op_name})")
        visualize_ast(node.operand, level + 1)
    elif isinstance(node, ast.Constant):
        print(f"{indent}{node_name}: {node.value}")
    elif isinstance(node, ast.Name):
        print(f"{indent}{node_name}: {node.id}")
    else:
        print(f"{indent}{node_name}")
        for child in ast.iter_child_nodes(node):
            visualize_ast(child, level + 1)

# 式をASTに変換
expression = "2 + 3 * 4"
tree = ast.parse(expression, mode='eval')
print(f"式: {expression}")
visualize_ast(tree.body)

# より複雑な式
print("\n\n複雑な式のAST:")
complex_expr = "(2 + 3) * (4 - 1)"
tree = ast.parse(complex_expr, mode='eval')
print(f"式: {complex_expr}")
visualize_ast(tree.body)
```

## 14.4 【実行】簡単な式評価インタプリタの実装

```python
# simple_interpreter.py
import ast
import operator

class SimpleEvaluator(ast.NodeVisitor):
    """簡単な式評価器"""
    
    def __init__(self):
        self.operators = {
            ast.Add: operator.add,
            ast.Sub: operator.sub,
            ast.Mult: operator.mul,
            ast.Div: operator.truediv,
            ast.Pow: operator.pow,
            ast.USub: operator.neg,
        }
        self.depth = 0
    
    def evaluate(self, expression):
        """式を評価"""
        tree = ast.parse(expression, mode='eval')
        return self.visit(tree.body)
    
    def visit(self, node):
        """ノードを訪問（デバッグ情報付き）"""
        indent = "  " * self.depth
        node_name = node.__class__.__name__
        print(f"{indent}訪問: {node_name}")
        
        self.depth += 1
        result = super().visit(node)
        self.depth -= 1
        
        print(f"{indent}結果: {result}")
        return result
    
    def visit_Constant(self, node):
        """定数ノード"""
        return node.value
    
    def visit_BinOp(self, node):
        """二項演算子ノード"""
        left = self.visit(node.left)
        right = self.visit(node.right)
        op_func = self.operators[type(node.op)]
        return op_func(left, right)
    
    def visit_UnaryOp(self, node):
        """単項演算子ノード"""
        operand = self.visit(node.operand)
        op_func = self.operators[type(node.op)]
        return op_func(operand)

# 評価器のテスト
print("=== 式評価インタプリタ ===")
evaluator = SimpleEvaluator()

expressions = [
    "42",
    "2 + 3",
    "2 + 3 * 4",
    "(2 + 3) * 4",
    "-5 + 10",
    "2 ** 3",
]

for expr in expressions:
    print(f"\n式: {expr}")
    result = evaluator.evaluate(expr)
    print(f"最終結果: {result}")
```

## 14.5 【実行】Pythonインタプリタが構文木をたどる様子

```python
# interpreter_tree_walk.py
import ast
import dis

# Pythonの実際のバイトコード生成
print("=== Pythonのバイトコード生成 ===")

def show_bytecode(expression):
    """式のバイトコードを表示"""
    print(f"\n式: {expression}")
    code = compile(expression, '<string>', 'eval')
    dis.dis(code)

expressions = [
    "2 + 3",
    "2 + 3 * 4",
    "x if x > 0 else -x",
]

for expr in expressions:
    show_bytecode(expr)

# カスタムインタプリタの拡張
class AdvancedEvaluator(ast.NodeVisitor):
    """変数と関数呼び出しをサポートする評価器"""
    
    def __init__(self, namespace=None):
        self.namespace = namespace or {}
        self.call_stack = []
    
    def evaluate(self, expression, **variables):
        """式を評価"""
        self.namespace.update(variables)
        tree = ast.parse(expression, mode='eval')
        return self.visit(tree.body)
    
    def visit_Name(self, node):
        """変数参照"""
        if node.id in self.namespace:
            return self.namespace[node.id]
        raise NameError(f"名前 '{node.id}' が定義されていません")
    
    def visit_Call(self, node):
        """関数呼び出し"""
        func = self.visit(node.func)
        args = [self.visit(arg) for arg in node.args]
        
        # 呼び出しスタックに追加
        self.call_stack.append(f"{node.func.id}({args})")
        print(f"呼び出しスタック: {' -> '.join(self.call_stack)}")
        
        result = func(*args)
        self.call_stack.pop()
        return result
    
    def visit_BinOp(self, node):
        """二項演算"""
        left = self.visit(node.left)
        right = self.visit(node.right)
        
        ops = {
            ast.Add: lambda a, b: a + b,
            ast.Sub: lambda a, b: a - b,
            ast.Mult: lambda a, b: a * b,
            ast.Div: lambda a, b: a / b,
        }
        
        return ops[type(node.op)](left, right)
    
    def visit_Compare(self, node):
        """比較演算"""
        left = self.visit(node.left)
        comparisons = []
        
        for op, right in zip(node.ops, node.comparators):
            right_val = self.visit(right)
            
            if isinstance(op, ast.Gt):
                result = left > right_val
            elif isinstance(op, ast.Lt):
                result = left < right_val
            elif isinstance(op, ast.Eq):
                result = left == right_val
            else:
                raise NotImplementedError(f"演算子 {op} は未実装")
            
            comparisons.append(result)
            left = right_val
        
        return all(comparisons)
    
    def visit_IfExp(self, node):
        """条件式（三項演算子）"""
        test = self.visit(node.test)
        if test:
            return self.visit(node.body)
        else:
            return self.visit(node.orelse)

# 高度な評価器のテスト
print("\n=== 高度な式評価 ===")
evaluator = AdvancedEvaluator({
    'abs': abs,
    'max': max,
    'min': min,
})

test_cases = [
    ("x + y", {"x": 10, "y": 20}),
    ("x * 2 + y", {"x": 5, "y": 3}),
    ("max(x, y)", {"x": 10, "y": 20}),
    ("x if x > 0 else -x", {"x": -5}),
    ("abs(x) + abs(y)", {"x": -5, "y": 10}),
]

for expr, vars in test_cases:
    print(f"\n式: {expr}")
    print(f"変数: {vars}")
    result = evaluator.evaluate(expr, **vars)
    print(f"結果: {result}")
```

## 14.6 【実行】astモジュールで自作の構文木を作って評価

```python
# custom_ast_creation.py
import ast

print("=== カスタムASTの作成と評価 ===")

# 手動でASTを構築
def create_custom_ast():
    """(2 + 3) * 4 のASTを手動で作成"""
    # 定数ノード
    two = ast.Constant(value=2)
    three = ast.Constant(value=3)
    four = ast.Constant(value=4)
    
    # 2 + 3
    add_op = ast.Add()
    addition = ast.BinOp(left=two, op=add_op, right=three)
    
    # (2 + 3) * 4
    mult_op = ast.Mult()
    multiplication = ast.BinOp(left=addition, op=mult_op, right=four)
    
    # Expression文でラップ
    expr = ast.Expression(body=multiplication)
    
    # 行番号を設定（必須）
    ast.fix_missing_locations(expr)
    
    return expr

# カスタムASTを作成
custom_tree = create_custom_ast()
print("カスタムAST構造:")
print(ast.dump(custom_tree, indent=2))

# コンパイルして実行
code = compile(custom_tree, '<custom>', 'eval')
result = eval(code)
print(f"\n実行結果: {result}")

# より複雑なAST：関数定義
print("\n=== 関数定義のAST作成 ===")

def create_function_ast():
    """
    def square(x):
        return x * x
    """
    # パラメータ
    x_arg = ast.arg(arg='x', annotation=None)
    arguments = ast.arguments(
        posonlyargs=[],
        args=[x_arg],
        kwonlyargs=[],
        kw_defaults=[],
        defaults=[]
    )
    
    # x * x
    x_name1 = ast.Name(id='x', ctx=ast.Load())
    x_name2 = ast.Name(id='x', ctx=ast.Load())
    multiply = ast.BinOp(left=x_name1, op=ast.Mult(), right=x_name2)
    
    # return文
    return_stmt = ast.Return(value=multiply)
    
    # 関数定義
    func_def = ast.FunctionDef(
        name='square',
        args=arguments,
        body=[return_stmt],
        decorator_list=[],
        returns=None
    )
    
    # モジュール
    module = ast.Module(body=[func_def], type_ignores=[])
    ast.fix_missing_locations(module)
    
    return module

# 関数ASTを作成してコンパイル
func_tree = create_function_ast()
print("関数定義のAST:")
print(ast.dump(func_tree, indent=2))

# 実行
code = compile(func_tree, '<custom_function>', 'exec')
namespace = {}
exec(code, namespace)

# 作成された関数を使用
square = namespace['square']
print(f"\nsquare(5) = {square(5)}")

# ASTの変換
print("\n=== ASTの変換 ===")

class DoubleConstants(ast.NodeTransformer):
    """すべての数値定数を2倍にする"""
    
    def visit_Constant(self, node):
        if isinstance(node.value, (int, float)):
            return ast.Constant(value=node.value * 2)
        return node

# 元の式
original_expr = "3 + 4 * 5"
tree = ast.parse(original_expr, mode='eval')

print(f"元の式: {original_expr}")
print(f"元の結果: {eval(original_expr)}")

# 変換
transformer = DoubleConstants()
new_tree = transformer.visit(tree)
ast.fix_missing_locations(new_tree)

# 新しい式を評価
code = compile(new_tree, '<transformed>', 'eval')
result = eval(code)
print(f"変換後の結果: {result}")  # 6 + 8 * 10 = 86
```

## 14.7 末尾再帰最適化がない理由

```python
# tail_recursion.py

print("=== 末尾再帰とPython ===")

# 末尾再帰の例
def factorial_tail(n, acc=1):
    """末尾再帰版の階乗"""
    if n == 0:
        return acc
    return factorial_tail(n - 1, n * acc)  # 末尾位置での再帰

# 通常の再帰
def factorial_normal(n):
    """通常の再帰版の階乗"""
    if n == 0:
        return 1
    return n * factorial_normal(n - 1)  # 再帰の後に掛け算

print(f"factorial_tail(5) = {factorial_tail(5)}")
print(f"factorial_normal(5) = {factorial_normal(5)}")

# スタックフレームの確認
import sys

def count_frames_tail(n, acc=1, depth=0):
    """末尾再帰でフレーム数を数える"""
    if depth == 0:
        print(f"\n末尾再帰（n={n}）:")
    
    frame_count = len(sys._getframe().f_back.__dict__)
    print(f"  深さ{depth}: フレーム数≈{frame_count}")
    
    if n == 0:
        return acc
    return count_frames_tail(n - 1, n * acc, depth + 1)

def count_frames_normal(n, depth=0):
    """通常の再帰でフレーム数を数える"""
    if depth == 0:
        print(f"\n通常の再帰（n={n}）:")
    
    frame_count = len(sys._getframe().f_back.__dict__)
    print(f"  深さ{depth}: フレーム数≈{frame_count}")
    
    if n == 0:
        return 1
    return n * count_frames_normal(n - 1, depth + 1)

# 小さい値でテスト
count_frames_tail(5)
count_frames_normal(5)

print("\n=== Pythonが末尾再帰最適化をしない理由 ===")
reasons = """
1. **デバッグの困難さ**
   - スタックトレースが失われる
   - エラー発生時の原因特定が困難

2. **Pythonの設計思想**
   - 明示的は暗黙的よりも良い
   - デバッグ可能性を重視

3. **代替手段の存在**
   - ループへの書き換え
   - ジェネレータの使用
   - trampolineパターン

4. **実装の複雑さ**
   - 動的な性質との相性
   - 例外処理との統合
"""
print(reasons)

# 代替案：ループへの書き換え
print("\n=== ループへの書き換え ===")

def factorial_loop(n):
    """ループ版の階乗"""
    result = 1
    for i in range(1, n + 1):
        result *= i
    return result

print(f"factorial_loop(5) = {factorial_loop(5)}")

# Trampolineパターン
print("\n=== Trampolineパターン ===")

def trampoline(func):
    """末尾再帰をループに変換"""
    while callable(func):
        func = func()
    return func

def factorial_trampoline(n, acc=1):
    """Trampolineを使った階乗"""
    if n == 0:
        return acc
    return lambda: factorial_trampoline(n - 1, n * acc)

result = trampoline(factorial_trampoline(5))
print(f"factorial_trampoline(5) = {result}")
```

## 14.8 この章のまとめ

- 再帰は関数が自分自身を呼び出すプログラミング手法
- Pythonは各関数呼び出しでスタックフレームを作成する
- ASTは構文木を表現し、再帰的に評価される
- Pythonインタプリタは構文木を再帰的に辿って実行する
- Pythonは末尾再帰最適化を行わない（デバッグ容易性のため）
- 深い再帰はループやジェネレータに書き換えることを推奨

## 練習問題

1. **再帰パーサー**
   簡単な算術式（括弧付き）をパースする再帰下降パーサーを実装してください。

2. **木構造の走査**
   二分木を表すクラスを作成し、前順・中順・後順で走査する再帰関数を実装してください。

3. **AST変換器**
   すべての変数名を大文字に変換するAST変換器を作成してください。

4. **メモ化デコレータ**
   再帰関数用のメモ化デコレータを作成し、フィボナッチ数列で性能を比較してください。

5. **ミニインタプリタ**
   変数代入、算術演算、if文をサポートする簡単なインタプリタを実装してください。

---

次章では、クラス定義の文法と実行について学びます。

[第15章 クラス定義の文法と実行 →](../part6/chapter15.md)