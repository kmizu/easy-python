# 第3章：Pythonプログラムの構造と実行

## この章で学ぶこと

- Pythonプログラムがどのように解析されるか
- トークン（字句）とは何か
- インデントの重要性とINDENT/DEDENTトークン
- コメントと空白文字の扱い
- BNF記法の基礎

## 3.1 プログラムの解析プロセス

前章で少し触れましたが、Pythonがプログラムを実行する際、まず**字句解析**（Lexical Analysis）という処理を行います。

### 料理に例えると...

プログラムの解析は料理の準備に似ています：

1. **字句解析**: 材料を切り分ける（トマト、玉ねぎ、にんじん...）
2. **構文解析**: レシピの手順を理解する（炒める→煮る→味付け）
3. **実行**: 実際に料理する

今回は最初のステップ、「材料を切り分ける」部分を学びます。

## 3.2 トークン（字句）とは

### トークンの基本概念

**トークン**とは、プログラムを構成する最小の意味のある単位です。

```python
price = 100 + 20
```

このコードは以下のトークンに分解されます：

1. `price` - 名前（NAME）
2. `=` - 代入演算子（EQUAL）
3. `100` - 数値（NUMBER）
4. `+` - 加算演算子（PLUS）
5. `20` - 数値（NUMBER）

### 【実行】tokenizeモジュールでトークンを見てみる

実際にPythonがどのようにトークンを認識するか見てみましょう：

```python
# tokenize_example.py
import tokenize
import io

# 解析したいコード
code = """
price = 100 + 20
print(price)
"""

# トークンを表示
tokens = tokenize.tokenize(io.BytesIO(code.encode()).readline)
for token in tokens:
    print(f"{token.type:2d} {tokenize.tok_name[token.type]:10s} {repr(token.string):15s}")
```

実行結果：

```
$ python3 tokenize_example.py
 0 ENCODING    'utf-8'        
61 NL          '\n'           
 1 NAME        'price'        
53 EQUAL       '='            
 2 NUMBER      '100'          
14 PLUS        '+'            
 2 NUMBER      '20'           
61 NL          '\n'           
 1 NAME        'print'        
54 LPAR        '('            
 1 NAME        'price'        
55 RPAR        ')'            
61 NL          '\n'           
 0 ENDMARKER   ''             
```

各行の意味：
- 最初の数字: トークンタイプの番号
- 次の文字列: トークンタイプの名前
- 最後の文字列: 実際のトークンの内容

### 主要なトークンタイプ

| トークンタイプ | 説明 | 例 |
|--------------|------|-----|
| NAME | 識別子（変数名、関数名など） | `price`, `print` |
| NUMBER | 数値リテラル | `100`, `3.14` |
| STRING | 文字列リテラル | `"Hello"`, `'World'` |
| EQUAL | 代入演算子 | `=` |
| PLUS, MINUS | 算術演算子 | `+`, `-` |
| LPAR, RPAR | 括弧 | `(`, `)` |
| COLON | コロン | `:` |
| NEWLINE | 改行（文の終了） | （改行文字） |
| INDENT/DEDENT | インデント/デデント | （後述） |

## 3.3 インデントの重要性

### Pythonの最大の特徴

多くのプログラミング言語は`{}`でブロックを表現しますが、Pythonは**インデント**（字下げ）でブロックを表現します。

```python
# 他の言語（例：JavaScript）
if (condition) {
    doSomething();
    doAnother();
}

# Python
if condition:
    do_something()
    do_another()
```

### INDENT/DEDENTトークン

Pythonはインデントの変化を特別なトークンとして扱います：

```python
# indent_example.py
import tokenize
import io

code = """
if True:
    print("インデントされた行")
    print("同じレベル")
print("元のレベルに戻った")
"""

tokens = tokenize.tokenize(io.BytesIO(code.encode()).readline)
for token in tokens:
    if token.type in [tokenize.INDENT, tokenize.DEDENT, tokenize.NAME, tokenize.NEWLINE]:
        print(f"{tokenize.tok_name[token.type]:10s} 行{token.start[0]}")
```

実行結果：

```
NEWLINE     行1
NAME        行2
NAME        行2
NEWLINE     行2
INDENT      行3
NAME        行3
...
DEDENT      行5
NAME        行5
```

!!! warning "インデントのルール"
    - 同じブロック内では同じ数のスペース（またはタブ）を使う
    - スペースとタブを混在させない（推奨：スペース4つ）
    - インデントレベルは一貫性を保つ

### 【実行】インデントエラーを体験する

わざとインデントエラーを起こしてみましょう：

```python
# indent_error.py
if True:
    print("最初の行")
   print("インデントが違う！")  # スペース3つ
```

実行結果：

```
$ python3 indent_error.py
  File "indent_error.py", line 3
    print("インデントが違う！")
    ^
IndentationError: unindent does not match any outer indentation level
```

## 3.4 コメントと空白文字

### コメントの扱い

コメントは字句解析の段階で取り除かれます：

```python
# これはコメントです
price = 100  # 行末コメント
"""
複数行の
文字列コメント
"""
```

### 空白文字の役割

```python
# これらは同じ意味
x=1+2
x = 1 + 2
x   =   1   +   2

# ただし、文字列内の空白は保持される
message = "Hello   World"  # スペース3つ
```

## 3.5 簡単なBNF記法の読み方入門

### BNFとは

**BNF（Backus-Naur Form）**は、プログラミング言語の文法を正確に記述するための記法です。

料理のレシピが「材料」と「手順」を定義するように、BNFは言語の「構成要素」と「組み合わせ方」を定義します。

### 基本的な記号

| 記号 | 意味 | 例 |
|------|------|-----|
| `::=` | 「～として定義される」 | `数字 ::= 0|1|2|3|4|5|6|7|8|9` |
| `|` | 「または」 | `符号 ::= + | -` |
| `[ ]` | 「省略可能」 | `整数 ::= [符号] 数字列` |
| `{ }` または `*` | 「0回以上の繰り返し」 | `数字列 ::= 数字 {数字}` |
| `< >` | 「非終端記号」（さらに定義が必要） | `<式>` |

### 簡単な例：整数の定義

```bnf
<整数> ::= [<符号>] <数字列>
<符号> ::= + | -
<数字列> ::= <数字> {<数字>}
<数字> ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
```

これを読むと：
- 整数は、省略可能な符号の後に数字列が続く
- 符号は、+または-
- 数字列は、1つ以上の数字の並び
- 数字は、0から9のいずれか

有効な整数の例：`123`, `-456`, `+789`, `0`

### Pythonの簡単な文のBNF

```bnf
<代入文> ::= <識別子> = <式>
<識別子> ::= <文字> {<文字> | <数字> | _}
<文字> ::= a | b | c | ... | z | A | B | ... | Z
```

これにより`price = 100`のような代入文が定義されます。

!!! note "なぜBNFを学ぶのか"
    BNFを理解すると：
    - エラーメッセージがより理解しやすくなる
    - 言語の制限や可能性が明確になる
    - 新しい言語を学ぶ際の理解が早くなる

## 3.6 実践：簡単なパーサーを作ってみる

### 数式パーサーの実装

BNFの理解を深めるため、簡単な数式パーサーを作ってみましょう：

```python
# simple_parser.py

def parse_number(text, pos):
    """数字を解析する"""
    start = pos
    while pos < len(text) and text[pos].isdigit():
        pos += 1
    if pos > start:
        return int(text[start:pos]), pos
    return None, pos

def parse_expression(text):
    """簡単な加算式を解析する
    <式> ::= <数> { + <数> }
    """
    pos = 0
    result, pos = parse_number(text, pos)
    
    if result is None:
        return None
    
    while pos < len(text):
        # 空白をスキップ
        while pos < len(text) and text[pos] == ' ':
            pos += 1
            
        if pos >= len(text) or text[pos] != '+':
            break
            
        pos += 1  # '+' をスキップ
        
        # 空白をスキップ
        while pos < len(text) and text[pos] == ' ':
            pos += 1
            
        num, pos = parse_number(text, pos)
        if num is None:
            return None
            
        result += num
    
    return result

# テスト
expressions = [
    "123",
    "10 + 20",
    "1 + 2 + 3",
    "100+200+300"
]

for expr in expressions:
    result = parse_expression(expr)
    print(f"{expr} = {result}")
```

実行結果：

```
$ python3 simple_parser.py
123 = 123
10 + 20 = 30
1 + 2 + 3 = 6
100+200+300 = 600
```

## 3.7 この章のまとめ

- Pythonプログラムは最初に**トークン**に分解される
- トークンには様々な種類がある（NAME、NUMBER、演算子など）
- インデントは特別なトークン（INDENT/DEDENT）として扱われる
- BNF記法は言語の文法を正確に記述する方法
- 文法を理解することで、より深いレベルでPythonを理解できる

## 練習問題

1. **トークン分解**
   以下のコードがどのようなトークンに分解されるか、予想してから`tokenize`モジュールで確認してください：
   ```python
   name = "Python"
   version = 3.11
   print(f"{name} {version}")
   ```

2. **インデントの練習**
   以下のコードのインデントを修正してください：
   ```python
   for i in range(3):
   print(i)
   if i == 1:
   print("one")
   ```

3. **BNFの読解**
   以下のBNFが表す文法で、有効な文字列を3つ書いてください：
   ```bnf
   <挨拶> ::= <時間帯> <敬称>
   <時間帯> ::= おはよう | こんにちは | こんばんは
   <敬称> ::= さん | 様 | 君
   ```

4. **簡単なパーサーの拡張**
   `simple_parser.py`を改造して、引き算（-）にも対応させてください。

---

次章では、Pythonの様々なリテラル（数値、文字列など）の正確な文法を学びます。

[第4章 リテラルと基本的なデータ型 →](chapter04.md)