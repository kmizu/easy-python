# 付録A：Python文法の完全なBNF記法

この付録では、Python言語の文法を完全なBNF（Backus-Naur Form）記法で記述します。これはPython公式ドキュメントの文法定義を基に、本書で説明した内容を体系的にまとめたものです。

## BNF記法の読み方

- `::=` は「定義される」を意味します
- `|` は「または」を意味します（選択肢）
- `[]` は省略可能な要素を表します
- `{}` は0回以上の繰り返しを表します
- `()` はグループ化を表します
- `*` は0回以上の繰り返し
- `+` は1回以上の繰り返し

## プログラム全体の構造

```bnf
file_input ::= (NEWLINE | stmt)* ENDMARKER
interactive_input ::= [stmt_list] NEWLINE | compound_stmt NEWLINE
eval_input ::= testlist NEWLINE* ENDMARKER
```

## 文（Statement）

### 基本的な文の構造

```bnf
stmt ::= simple_stmt | compound_stmt
simple_stmt ::= small_stmt (';' small_stmt)* [';'] NEWLINE
small_stmt ::= (expr_stmt | print_stmt | del_stmt | pass_stmt | flow_stmt |
               import_stmt | global_stmt | nonlocal_stmt | assert_stmt)

compound_stmt ::= if_stmt | while_stmt | for_stmt | try_stmt | with_stmt | 
                  funcdef | classdef | decorated | async_stmt
```

### 式文と代入文

```bnf
expr_stmt ::= testlist_star_expr (annassign | augassign (yield_expr | testlist) |
              ('=' (yield_expr | testlist_star_expr))*)

annassign ::= ':' test ['=' (yield_expr | testlist)]
testlist_star_expr ::= (test | star_expr) (',' (test | star_expr))* [',']
augassign ::= ('+=' | '-=' | '*=' | '@=' | '/=' | '%=' | '&=' | '|=' | '^=' |
              '<<=' | '>>=' | '**=' | '//=')
```

### 制御構造

#### if文

```bnf
if_stmt ::= 'if' namedexpr_test ':' suite ('elif' namedexpr_test ':' suite)* ['else' ':' suite]
```

#### while文

```bnf
while_stmt ::= 'while' namedexpr_test ':' suite ['else' ':' suite]
```

#### for文

```bnf
for_stmt ::= 'for' exprlist 'in' testlist ':' suite ['else' ':' suite]
```

#### try文

```bnf
try_stmt ::= ('try' ':' suite
              ((except_clause ':' suite)+
               ['else' ':' suite]
               ['finally' ':' suite] |
               'finally' ':' suite))

except_clause ::= 'except' [test ['as' identifier]]
```

#### with文

```bnf
with_stmt ::= 'with' with_item (',' with_item)* ':' suite
with_item ::= test ['as' expr]
```

### フロー制御文

```bnf
flow_stmt ::= break_stmt | continue_stmt | return_stmt | raise_stmt | yield_stmt
break_stmt ::= 'break'
continue_stmt ::= 'continue'
return_stmt ::= 'return' [testlist]
yield_stmt ::= yield_expr
raise_stmt ::= 'raise' [test ['from' test]]
```

### その他の文

```bnf
del_stmt ::= 'del' exprlist
pass_stmt ::= 'pass'
import_stmt ::= import_name | import_from
import_name ::= 'import' dotted_as_names
import_from ::= ('from' (('.' | '...')* dotted_name | ('.' | '...')+)
               'import' ('*' | '(' import_as_names ')' | import_as_names))

global_stmt ::= 'global' identifier (',' identifier)*
nonlocal_stmt ::= 'nonlocal' identifier (',' identifier)*
assert_stmt ::= 'assert' test [',' test]
```

## 関数とクラス定義

### 関数定義

```bnf
funcdef ::= 'def' identifier parameters ['->' test] ':' suite
parameters ::= '(' [typedargslist] ')'
typedargslist ::= (tfpdef ['=' test] (',' tfpdef ['=' test])* [',' [
                   '*' [tfpdef] (',' tfpdef ['=' test])* [',' ['**' tfpdef [',']]] |
                   '**' tfpdef [',']]] |
                   '*' [tfpdef] (',' tfpdef ['=' test])* [',' ['**' tfpdef [',']]] |
                   '**' tfpdef [','])

tfpdef ::= identifier [':' test]
varargslist ::= (vfpdef ['=' test] (',' vfpdef ['=' test])* [',' [
                 '*' [vfpdef] (',' vfpdef ['=' test])* [',' ['**' vfpdef [',']]] |
                 '**' vfpdef [',']]] |
                 '*' [vfpdef] (',' vfpdef ['=' test])* [',' ['**' vfpdef [',']]] |
                 '**' vfpdef [','])

vfpdef ::= identifier
```

### クラス定義

```bnf
classdef ::= 'class' identifier ['(' [arglist] ')'] ':' suite
```

### デコレータ

```bnf
decorated ::= decorators (classdef | funcdef | async_funcdef)
decorators ::= decorator+
decorator ::= '@' dotted_name ['(' [arglist] ')'] NEWLINE
```

### 非同期文

```bnf
async_stmt ::= 'async' (funcdef | with_stmt | for_stmt)
async_funcdef ::= 'async' funcdef
```

## 式（Expression）

### 基本的な式の構造

```bnf
test ::= or_test ['if' or_test 'else' test] | lambdef
test_nocond ::= or_test | lambdef_nocond
lambdef ::= 'lambda' [varargslist] ':' test
lambdef_nocond ::= 'lambda' [varargslist] ':' test_nocond
```

### 論理演算

```bnf
or_test ::= and_test ('or' and_test)*
and_test ::= not_test ('and' not_test)*
not_test ::= 'not' not_test | comparison
```

### 比較演算

```bnf
comparison ::= expr (comp_op expr)*
comp_op ::= '<' | '>' | '==' | '>=' | '<=' | '<>' | '!=' |
            'in' | 'not' 'in' | 'is' | 'is' 'not'
```

### 算術演算

```bnf
expr ::= xor_expr ('|' xor_expr)*
xor_expr ::= and_expr ('^' and_expr)*
and_expr ::= shift_expr ('&' shift_expr)*
shift_expr ::= arith_expr (('<<' | '>>') arith_expr)*
arith_expr ::= term (('+' | '-') term)*
term ::= factor (('*' | '@' | '/' | '%' | '//') factor)*
factor ::= ('+' | '-' | '~') factor | power
power ::= atom_expr ['**' factor]
```

### アトム式

```bnf
atom_expr ::= ['await'] atom trailer*
atom ::= ('(' [yield_expr | testlist_comp] ')' |
          '[' [listmaker] ']' |
          '{' [dictorsetmaker] '}' |
          '`' testlist1 '`' |
          identifier | number | string+)

trailer ::= '(' [arglist] ')' | '[' subscriptlist ']' | '.' identifier
```

### リストと辞書の内包表記

```bnf
listmaker ::= (namedexpr_test | star_expr) ( comp_for | (',' (namedexpr_test | star_expr))* [','] )
testlist_comp ::= (namedexpr_test | star_expr) ( comp_for | (',' (namedexpr_test | star_expr))* [','] )
dictorsetmaker ::= ( ((test ':' test | '**' expr)
                     (comp_for | (',' (test ':' test | '**' expr))* [','])) |
                    ((test | star_expr)
                     (comp_for | (',' (test | star_expr))* [','])) )

comp_for ::= ['async'] 'for' exprlist 'in' or_test [comp_iter]
comp_iter ::= comp_for | comp_if
comp_if ::= 'if' test_nocond [comp_iter]
```

### 引数リスト

```bnf
arglist ::= argument (',' argument)* [',']
argument ::= ( test [comp_for] |
               test '=' test |
               '**' test |
               '*' test )
```

### その他の式要素

```bnf
subscriptlist ::= subscript (',' subscript)* [',']
subscript ::= test | [test] ':' [test] [':' [test]]
exprlist ::= (expr | star_expr) (',' (expr | star_expr))* [',']
testlist ::= test (',' test)* [',']
star_expr ::= '*' expr
```

## リテラル

### 数値リテラル

```bnf
number ::= integer | floatnumber | imagnumber
integer ::= decinteger | bininteger | octinteger | hexinteger
decinteger ::= nonzerodigit (["_"] digit)* | "0"+ (["_"] "0")*
bininteger ::= "0" ("b" | "B") (["_"] bindigit)+
octinteger ::= "0" ("o" | "O") (["_"] octdigit)+
hexinteger ::= "0" ("x" | "X") (["_"] hexdigit)+

floatnumber ::= pointfloat | exponentfloat
pointfloat ::= [digitpart] fraction | digitpart "."
exponentfloat ::= (digitpart | pointfloat) exponent
digitpart ::= digit (["_"] digit)*
fraction ::= "." digitpart
exponent ::= ("e" | "E") ["+" | "-"] digitpart

imagnumber ::= (floatnumber | digitpart) ("j" | "J")
```

### 文字列リテラル

```bnf
string ::= stringprefix? (shortstring | longstring)
stringprefix ::= "r" | "u" | "R" | "U" | "f" | "F" | "fr" | "Fr" | "fR" | "FR" | "rf" | "rF" | "Rf" | "RF"
shortstring ::= "'" shortstringitem* "'" | '"' shortstringitem* '"'
longstring ::= "'''" longstringitem* "'''" | '"""' longstringitem* '"""'
shortstringitem ::= shortstringchar | stringescapeseq
longstringitem ::= longstringchar | stringescapeseq
```

### 識別子とキーワード

```bnf
identifier ::= (letter | "_") (letter | digit | "_")*
letter ::= lowercase | uppercase
lowercase ::= "a"..."z"
uppercase ::= "A"..."Z"
digit ::= "0"..."9"
```

#### 予約語（キーワード）

```
False      await      else       import     pass
None       break      except     in         raise
True       class      finally    is         return
and        continue   for        lambda     try
as         def        from       nonlocal   while
assert     del        global     not        with
async      elif       if         or         yield
```

## 演算子優先順位（高い順）

1. `(expressions...)`, `[expressions...]`, `{key: value...}`, `{expressions...}`
2. `x[index]`, `x[index:index]`, `x(arguments...)`, `x.attribute`
3. `await x`
4. `**` (冪乗)
5. `+x`, `-x`, `~x` (単項演算子)
6. `*`, `@`, `/`, `//`, `%`
7. `+`, `-` (二項演算子)
8. `<<`, `>>`
9. `&`
10. `^`
11. `|`
12. `==`, `!=`, `<`, `<=`, `>`, `>=`, `is`, `is not`, `in`, `not in`
13. `not x`
14. `and`
15. `or`
16. `if` – `else` (条件式)
17. `lambda`
18. `:=` (セイウチ演算子)

## 特殊な構文要素

### マッチ文（Python 3.10+）

```bnf
match_stmt ::= "match" subject_expr ':' NEWLINE INDENT case_block+ DEDENT
subject_expr ::= star_named_expression (',' star_named_expressions)? [',']
case_block ::= "case" patterns [guard] ':' block
guard ::= 'if' named_expression
patterns ::= open_sequence_pattern | pattern
pattern ::= as_pattern | or_pattern
```

### 型アノテーション

```bnf
annassign ::= ':' test ['=' (yield_expr | testlist)]
```

## 字句解析要素

### トークンの種類

```bnf
NEWLINE ::= [\r\n]+
INDENT ::= 空白文字の増加
DEDENT ::= 空白文字の減少
NAME ::= identifier
NUMBER ::= number
STRING ::= string
COMMENT ::= '#' [^\r\n]*
NL ::= NEWLINE | COMMENT
```

### 演算子とデリミタ

```
+       -       *       **      /       //      %      @
<<      >>      &       |       ^       ~       :=
<       >       <=      >=      ==      !=
(       )       [       ]       {       }
,       :       .       ;       @       =       ->
+=      -=      *=      /=      //=     %=      @=
&=      |=      ^=      >>=     <<=     **=
```

## まとめ

この完全なBNF定義は、Pythonプログラムのあらゆる構文要素を網羅しています。実際のPythonインタプリタは、この文法定義に基づいて構文解析を行い、抽象構文木（AST）を構築します。

各章で学んだ個別の文法要素が、この包括的な定義の中でどのように位置づけられているかを確認することで、Python言語の体系的な理解を深めることができます。