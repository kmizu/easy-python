# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Preference
日本語で応答してください。

## Project Overview
Pythonの「真の文法」をBNFレベルで理解できる初心者向け入門書プロジェクト。
プログラミング初心者でも段階的に深い理解に到達できるよう設計。

## 執筆計画チェックリスト

### 第1段階：コンピュータの世界を知る

- [x] 第1章：コンピュータってなに？
  - [ ] 身の回りのコンピュータを探してみよう（スマホ、家電、車など）
  - [ ] コンピュータが理解できる言葉（0と1の世界）
  - [ ] 【実行】スマホの容量計算で単位を理解する（GB→MB→KB→バイト）
  - [ ] なぜプログラムが必要なのか
  - [ ] 【実行】電卓アプリと計算プログラムの違いを体験

- [x] 第2章：データの正体 - 数字と文字の表現
  - [ ] ビット（0と1）からバイトへ
  - [ ] 【実行】年齢や体重を2進数で表現してみよう
  - [ ] コンピュータは文字をどう覚えているか
  - [ ] 【実行】自分の名前の文字コードを調べてみよう
  - [ ] メモリという名前の記憶装置

- [x] 第3章：プログラムとの出会い
  - [ ] プログラムって何だろう？
  - [ ] なぜPythonを選ぶのか（他の言語との違い）
  - [ ] 【実行】Pythonをインストールしてみよう
  - [ ] 【実行】自分の名前で挨拶するプログラム

### 第2段階：Pythonで計算してみよう

- [x] 第4章：Pythonと友達になろう
  - [ ] Pythonとの対話（対話型シェル）
  - [ ] 【実行】消費税計算プログラムを作ろう
  - [ ] エラーメッセージは怖くない
  - [ ] 【実行】計算ミスでエラーを体験してみよう

- [x] 第5章：数の世界で遊ぼう
  - [ ] 整数と小数の違い
  - [ ] 【実行】家計簿の計算（収入・支出・残高）
  - [ ] 大きな数、小さな数
  - [ ] 【実行】日本の人口や国土面積をいろんな進数で表現
  - [ ] 計算の順番（優先順位）

- [x] 第6章：文字と文章を扱おう
  - [ ] 文字列ってなに？
  - [ ] 【実行】メールの件名を組み立てるプログラム
  - [ ] 特殊な文字（改行、タブなど）
  - [ ] 【実行】住所の整形プログラム
  - [ ] 文字列の中身を調べよう

### 第3段階：プログラムらしくしよう

- [x] 第7章：変数という魔法の箱
  - [ ] 変数ってなに？なぜ必要？
  - [ ] 【実行】ユーザー情報を管理するプログラム（名前、年齢、住所）
  - [ ] いい変数名、だめな変数名
  - [ ] 【実行】商品管理システムの変数名を考えよう
  - [ ] 【実行】メモリの使用量を確認してみよう

- [x] 第8章：コンピュータに判断させよう
  - [ ] もしも〜だったら（if文）
  - [ ] 【実行】年齢による映画料金計算プログラム
  - [ ] 真偽値（TrueとFalse）
  - [ ] 【実行】パスワード強度チェックプログラム
  - [ ] 複雑な条件（and, or, not）

- [x] 第9章：同じことを繰り返そう
  - [ ] 繰り返しの力（while文）
  - [ ] 【実行】貯金目標達成までの計算プログラム
  - [ ] for文による繰り返し
  - [ ] 【実行】成績表の平均点計算プログラム
  - [ ] 繰り返しの制御（break, continue）

- [x] 第10章：データをまとめて整理しよう
  - [ ] リスト - データの集まり
  - [ ] 【実行】買い物リスト管理プログラム
  - [ ] 辞書 - 名前をつけて整理
  - [ ] 【実行】連絡先帳プログラム（名前→電話番号）
  - [ ] セット - 重複のない集合

### 第4段階：プログラムを構造化しよう

- [x] 第11章：関数を作ってみよう
  - [ ] 関数ってなに？なぜ便利？
  - [ ] 【実行】BMI計算関数を作ろう
  - [ ] 引数と戻り値
  - [ ] 【実行】割引価格計算関数（通常・学割・シニア割）
  - [ ] 関数の中の変数（スコープ）

- [x] 第12章：プログラムをファイルに保存しよう
  - [ ] .pyファイルとは
  - [ ] 【実行】家計簿プログラムをファイルに保存
  - [ ] モジュール - 機能を分けて整理
  - [ ] 【実行】計算ライブラリモジュールを作ろう
  - [ ] パッケージ - モジュールをまとめる

- [x] 第13章：エラーと上手に付き合おう
  - [ ] エラーは敵じゃない
  - [ ] 【実行】入力ミスでよくあるエラーを体験
  - [ ] try-except文でエラーを捕まえる
  - [ ] 【実行】安全な数値入力プログラムを作ろう
  - [ ] デバッグの基本テクニック

### 第5段階：オブジェクトという考え方

- [x] 第14章：オブジェクトってなに？
  - [ ] 現実世界とプログラムの世界
  - [ ] 【実行】銀行口座をオブジェクトで考えてみよう
  - [ ] クラスとインスタンス
  - [ ] 【実行】個人情報管理クラスを作ってみよう
  - [ ] メソッド - オブジェクトができること

- [x] 第15章：クラスを作ってみよう
  - [ ] クラスの設計
  - [ ] 【実行】図書クラスを作ってみよう（タイトル、著者、貸出状況）
  - [ ] __init__メソッド（コンストラクタ）
  - [ ] 【実行】商品クラスで在庫管理システム
  - [ ] プライベートな属性

- [x] 第16章：クラスの継承
  - [ ] 継承ってなに？
  - [ ] 【実行】乗り物→自動車→電気自動車のクラス継承
  - [ ] メソッドのオーバーライド
  - [ ] 【実行】従業員→正社員→契約社員のクラス設計
  - [ ] 多重継承の基礎

### 第6段階：Pythonをもっと深く知ろう

- [x] 第17章：Pythonの内部構造を覗いてみよう
  - [ ] Pythonインタプリタの仕組み
  - [ ] 【実行】プログラムサイズとバイトコードサイズを比較
  - [ ] メモリ管理と参照カウント
  - [ ] 【実行】大量データ処理時のメモリ使用量を観察
  - [ ] ガベージコレクション

- [x] 第18章：文法の正体を知ろう
  - [ ] プログラミング言語の文法とは
  - [ ] BNF記法入門 - 文法を書く文法
  - [ ] 【実行】自作の簡単な計算式パーサーを作ろう
  - [ ] トークンと構文解析
  - [ ] 【実行】プログラムコードをトークンに分解してみよう

- [x] 第19章：高度な機能を使ってみよう
  - [ ] ジェネレータ - メモリ効率の良い繰り返し
  - [ ] 【実行】大量のログファイル処理プログラム
  - [ ] デコレータ - 関数を装飾する
  - [ ] 【実行】実行時間測定デコレータを作ろう
  - [ ] 内包表記 - スマートなリスト作成

- [x] 第20章：型ヒントで安全なプログラム
  - [ ] 型ヒントってなに？
  - [ ] 【実行】ユーザー管理システムに型ヒントを追加
  - [ ] typingモジュールの基礎
  - [ ] 【実行】型チェックでバグを予防しよう
  - [ ] より安全なプログラムのために

### 付録
- [ ] 付録A：Python文法の完全なBNF記法
- [ ] 付録B：標準ライブラリ重要モジュール一覧
- [ ] 付録C：PEP 8 スタイルガイド要約
- [ ] 付録D：よくあるエラーメッセージと対処法

## プロジェクト構造
```
easy-python/
├── docs/              # MkDocsで管理する原稿ファイル
│   ├── index.md       # トップページ
│   ├── chapter01.md   # 第1章
│   ├── chapter02.md   # 第2章
│   └── ...
├── code-examples/     # サンプルコード
│   ├── chapter01/
│   ├── chapter02/
│   └── ...
├── diagrams/          # 図表
├── exercises/         # 練習問題
└── solutions/         # 練習問題の解答
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