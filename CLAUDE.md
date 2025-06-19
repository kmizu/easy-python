# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Preference
日本語で応答してください。

## Project Overview
Pythonの「真の文法」をBNFレベルで理解できる初心者向け入門書プロジェクト。
プログラミング初心者でも段階的に深い理解に到達できるよう設計。

## 執筆計画チェックリスト

### 第1部：プログラミングとPythonの世界へようこそ
- [ ] 第1章：プログラミングとは何か
  - [ ] コンピュータの仕組みの基礎
  - [ ] プログラミング言語の役割
  - [ ] Pythonを選ぶ理由
  - [ ] 【実行】対話型シェルで電卓として使ってみる
- [ ] 第2章：Python環境のセットアップと実行の仕組み
  - [ ] Pythonのインストール（各OS対応）
  - [ ] 対話型シェル（REPL）の使い方
  - [ ] テキストエディタ/IDEの準備
  - [ ] 【実行】はじめてのプログラムファイル作成と実行
  - [ ] Pythonインタプリタが何をしているか

### 第2部：Pythonの基本構造を理解する
- [ ] 第3章：Pythonプログラムの構造と実行
  - [ ] 字句解析の基礎（トークンとは）
  - [ ] 【実行】tokenizeモジュールでトークンを見てみる
  - [ ] インデントの重要性（INDENT/DEDENTトークン）
  - [ ] 【実行】インデントエラーを体験する
  - [ ] コメントと空白文字の扱い
  - [ ] 簡単なBNF記法の読み方入門
- [ ] 第4章：リテラルと基本的なデータ型
  - [ ] 数値リテラル（整数・浮動小数点数）のBNF
  - [ ] 【実行】様々な数値リテラルを試す（2進数、16進数、指数表記）
  - [ ] 文字列リテラルのBNF（各種クォート、エスケープシーケンス）
  - [ ] 【実行】エスケープシーケンスの実験、raw文字列
  - [ ] ブール値とNone
  - [ ] 【実行】type()関数で型を確認する

### 第3部：式と文の文法
- [ ] 第5章：式（Expression）の文法と評価
  - [ ] 基本的な式のBNF定義
  - [ ] 【実行】算術演算子と優先順位の実験
  - [ ] 【実行】比較演算子の連鎖（1 < 2 < 3）
  - [ ] 論理演算子（and, or, not）と短絡評価
  - [ ] 【実行】短絡評価の動作確認
  - [ ] 演算子の結合性
  - [ ] 【実行】eval()で式の評価過程を理解する
- [ ] 第6章：変数と代入文
  - [ ] 識別子（identifier）のBNF規則
  - [ ] 【実行】有効/無効な変数名を試す
  - [ ] 代入文（assignment_stmt）のBNF
  - [ ] 【実行】代入の右辺評価とメモリ上の動作
  - [ ] 複合代入演算子
  - [ ] 【実行】多重代入とアンパックの実験
  - [ ] 【実行】id()関数でオブジェクトの同一性を確認
- [ ] 第7章：制御構造の文法と実行フロー
  - [ ] if文のBNF定義
  - [ ] 【実行】if-elif-elseの実行フローを追跡
  - [ ] while文のBNF定義
  - [ ] 【実行】無限ループとbreak
  - [ ] for文のBNF定義とイテラブル
  - [ ] 【実行】range()とenumerate()の動作
  - [ ] 【実行】continue, passの違いを確認
  - [ ] match文（Python 3.10+）のBNF
  - [ ] 【実行】パターンマッチングの実例

### 第4部：データ構造の文法と操作
- [ ] 第8章：リスト（list）の文法と実行時動作
  - [ ] リスト表示式のBNF
  - [ ] 【実行】リストの作成とメモリ上の表現
  - [ ] リスト内包表記のBNF
  - [ ] 【実行】内包表記と通常のループの速度比較
  - [ ] インデックスとスライスの文法
  - [ ] 【実行】スライスの様々なパターンと動作
  - [ ] 【実行】リストメソッド（append, extend, insert等）の動作
  - [ ] 【実行】リストの参照とコピー（浅いコピーvs深いコピー）
- [ ] 第9章：タプル、辞書、セットの文法と特性
  - [ ] タプル表示式のBNF
  - [ ] 【実行】タプルのイミュータブル性を確認
  - [ ] 辞書表示式のBNF
  - [ ] 【実行】辞書のハッシュテーブル実装を理解する
  - [ ] 【実行】辞書内包表記とget()メソッド
  - [ ] セット（集合）の文法
  - [ ] 【実行】集合演算（和、積、差）の実行
- [ ] 第10章：文字列の高度な文法と処理
  - [ ] フォーマット文字列（f-string）のBNF
  - [ ] 【実行】f-stringの式評価とformat()との比較
  - [ ] 【実行】文字列メソッドチェーンの実行
  - [ ] 【実行】正規表現の基礎とreモジュール
  - [ ] 【実行】文字エンコーディングとバイト列

### 第5部：関数とモジュール
- [ ] 第11章：関数定義の文法と実行
  - [ ] def文のBNF定義
  - [ ] 【実行】関数オブジェクトの作成と呼び出し
  - [ ] パラメータリストの文法
  - [ ] 【実行】位置引数、キーワード引数の実験
  - [ ] 【実行】デフォルト引数の評価タイミング（ミュータブルの罠）
  - [ ] *args, **kwargsの文法
  - [ ] 【実行】可変長引数の展開と辞書展開
  - [ ] return文とyield文
  - [ ] 【実行】ジェネレータ関数の動作追跡
- [ ] 第12章：スコープとクロージャ
  - [ ] LEGB規則
  - [ ] 【実行】スコープの可視化実験
  - [ ] global文とnonlocal文のBNF
  - [ ] 【実行】クロージャの作成と変数キャプチャ
  - [ ] デコレータの文法
  - [ ] 【実行】デコレータの実行順序と引数
- [ ] 第13章：モジュールとパッケージ
  - [ ] import文のBNF定義
  - [ ] 【実行】モジュールのロードとキャッシュ
  - [ ] from...import文の文法
  - [ ] 【実行】名前空間の汚染を確認
  - [ ] 【実行】sys.pathとモジュール検索順序
  - [ ] 【実行】__init__.pyの役割とパッケージ構造
- [ ] 第14章：再帰とPythonインタプリタの実行モデル
  - [ ] 再帰関数の基礎
  - [ ] 【実行】再帰呼び出しのスタックトレース
  - [ ] 【実行】抽象構文木（AST）の再帰的な評価
  - [ ] 【実行】簡単な式評価インタプリタの実装
  - [ ] 【実行】Pythonインタプリタが構文木をたどる様子
  - [ ] 【実行】astモジュールで自作の構文木を作って評価
  - [ ] 末尾再帰最適化がない理由

### 第6部：オブジェクト指向プログラミング
- [ ] 第15章：クラス定義の文法と実行
  - [ ] class文のBNF定義
  - [ ] 【実行】クラスオブジェクトの作成過程
  - [ ] メソッドとself
  - [ ] 【実行】メソッド呼び出しの仕組み（記述子プロトコル）
  - [ ] コンストラクタ（__init__）
  - [ ] 【実行】__new__と__init__の違い
  - [ ] 【実行】インスタンス変数とクラス変数の動作
- [ ] 第16章：継承とポリモーフィズム
  - [ ] 継承の文法
  - [ ] 【実行】メソッド解決順序（MRO）の確認
  - [ ] 【実行】super()の動作原理
  - [ ] 【実行】多重継承のダイヤモンド問題
  - [ ] 【実行】抽象基底クラス（ABC）の実装
- [ ] 第17章：特殊メソッドとプロトコル
  - [ ] 【実行】__str__と__repr__の使い分け
  - [ ] 【実行】算術演算子オーバーロードの実装
  - [ ] 【実行】比較演算子とfunctools.total_ordering
  - [ ] 【実行】イテレータプロトコルの実装
  - [ ] 【実行】withステートメントとコンテキストマネージャ

### 第7部：例外処理と高度な機能
- [ ] 第18章：例外処理の文法と実行フロー
  - [ ] try文のBNF定義
  - [ ] 【実行】例外の発生と伝播の追跡
  - [ ] except節の文法
  - [ ] 【実行】例外の型階層とマッチング
  - [ ] 【実行】else節とfinally節の実行順序
  - [ ] 【実行】raise文とカスタム例外クラス
  - [ ] 【実行】例外チェーンとfrom句
- [ ] 第19章：ジェネレータと非同期処理
  - [ ] yield式のBNF
  - [ ] 【実行】ジェネレータの状態遷移
  - [ ] 【実行】send()とthrow()メソッド
  - [ ] ジェネレータ式のBNF
  - [ ] 【実行】メモリ効率の比較（リストvsジェネレータ）
  - [ ] async/awaitの文法
  - [ ] 【実行】コルーチンの実行とイベントループ
  - [ ] 【実行】非同期ジェネレータとasync for
- [ ] 第20章：型ヒントとアノテーション
  - [ ] 型アノテーションのBNF
  - [ ] 【実行】__annotations__属性の確認
  - [ ] 【実行】typing モジュールの基本型
  - [ ] 【実行】ジェネリクスとTypeVar
  - [ ] 【実行】プロトコルの定義と構造的部分型
  - [ ] 【実行】mypyによる静的型チェック

### 第8部：Pythonの内部動作
- [ ] 第21章：Pythonの実行モデル
  - [ ] 【実行】compileとdis.dis()でバイトコードを見る
  - [ ] 【実行】astモジュールで抽象構文木を可視化
  - [ ] Python仮想マシン（PVM）のスタック動作
  - [ ] 【実行】sys.getrefcount()で参照カウントを確認
  - [ ] 【実行】GILの影響をマルチスレッドで確認
  - [ ] 【実行】ガベージコレクションとweakref
- [ ] 第22章：メタプログラミング
  - [ ] 【実行】dir()、vars()、getattr()で内省
  - [ ] 【実行】exec()とeval()の動作と名前空間
  - [ ] 【実行】__build_class__とメタクラスの動作
  - [ ] 【実行】プロパティとディスクリプタの実装
  - [ ] 【実行】__getattribute__と属性アクセスのカスタマイズ

### 付録
- [ ] 付録A：Python文法の完全なBNF記法
- [ ] 付録B：標準ライブラリ重要モジュール一覧
- [ ] 付録C：PEP 8 スタイルガイド要約
- [ ] 付録D：よくあるエラーメッセージと対処法

## プロジェクト構造
```
easy-python/
├── manuscript/          # 原稿ファイル
│   ├── part1/          # 第1部
│   ├── part2/          # 第2部
│   └── ...
├── code-examples/      # サンプルコード
│   ├── chapter01/
│   ├── chapter02/
│   └── ...
├── diagrams/           # 図表
├── exercises/          # 練習問題
└── solutions/          # 練習問題の解答
```

## 執筆ガイドライン
- 各章は必ず具体的なコード例から始める
- BNF記法は段階的に導入し、最初は簡略化した形で提示
- 各章末に練習問題を配置
- 「なぜそうなるのか」を重視した説明
- エラーメッセージの読み方を積極的に解説

## 開発環境構築

### MkDocsベースの執筆環境
```bash
# Python仮想環境の作成
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# MkDocsと必要なプラグインのインストール
pip install mkdocs
pip install mkdocs-material  # マテリアルテーマ
pip install mkdocs-mermaid2-plugin  # 図表描画
pip install mkdocs-print-site-plugin  # PDF出力用
pip install pygments  # コードハイライト
```

### mkdocs.ymlの基本設定
```yaml
site_name: 'Pythonの真の文法 - BNFで学ぶPython入門'
site_author: '著者名'
site_description: 'プログラミング初心者のためのPython文法書'

theme:
  name: material
  language: ja
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - toc.integrate
    - content.code.copy  # コードコピーボタン
  palette:
    - scheme: default
      primary: blue
      accent: orange
      toggle:
        icon: material/brightness-7
        name: ダークモードに切り替え
    - scheme: slate
      primary: blue
      accent: orange
      toggle:
        icon: material/brightness-4
        name: ライトモードに切り替え

markdown_extensions:
  - admonition  # 注釈ブロック
  - pymdownx.details
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.highlight:
      anchor_linenums: true
      line_spans: __span
      pygments_lang_class: true
  - pymdownx.inlinehilite
  - pymdownx.snippets
  - pymdownx.tabbed:
      alternate_style: true
  - toc:
      permalink: true
      toc_depth: 3

plugins:
  - search:
      lang: ja
  - mermaid2
  - print-site:
      add_to_navigation: true
      print_page_title: 'PDF版'
      
extra_css:
  - stylesheets/extra.css

extra_javascript:
  - javascripts/extra.js
```

## 開発コマンド

### 基本的な執筆コマンド
```bash
# 開発サーバーの起動（ライブリロード付き）
mkdocs serve

# ビルド（静的サイト生成）
mkdocs build

# GitHubPagesへのデプロイ
mkdocs gh-deploy
```

### コード実行環境の準備
```bash
# Jupyter環境（インタラクティブな実行例用）
pip install jupyter
pip install ipykernel

# コード品質チェックツール
pip install black  # コードフォーマッター
pip install flake8  # リンター
pip install mypy  # 型チェッカー
```

### 執筆支援スクリプト
```bash
# 新しい章の作成
python scripts/new_chapter.py --part 1 --chapter 1 --title "プログラミングとは何か"

# コード例の検証
python scripts/validate_examples.py manuscript/part1/chapter01.md

# BNF記法の構文チェック
python scripts/check_bnf.py manuscript/
```