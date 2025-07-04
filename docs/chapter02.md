# 第2章：データの正体 - 数字と文字の表現

前の章で、コンピュータが0と1だけで動いていることを学びました。でも、「0と1だけで、どうやって私たちの名前や写真を表現できるの？」と疑問に思いませんでしたか？この章では、その仕組みを詳しく見ていきましょう。

## ビット（0と1）からバイトへ

### ビットだけでは足りない

1つのビット（0または1）では、2つの状態しか表現できません。でも、私たちが表現したいものはもっとたくさんあります：

- アルファベットは26文字（A〜Z）
- 日本語のひらがなは46文字（あ〜ん）
- 数字は10種類（0〜9）
- 記号もたくさん（!@#$%など）

### ビットを組み合わせてパワーアップ

ビットを複数組み合わせると、表現できる種類が飛躍的に増えます：

| ビット数 | 組み合わせ数 | 例 |
|----------|-------------|-----|
| 1ビット | 2種類 | 0, 1 |
| 2ビット | 4種類 | 00, 01, 10, 11 |
| 3ビット | 8種類 | 000, 001, 010, 011, 100, 101, 110, 111 |
| 4ビット | 16種類 | 0000〜1111 |
| 8ビット | 256種類 | 00000000〜11111111 |

### バイトの誕生

コンピュータの世界では、**8ビットをまとめて1バイト**と呼びます。1バイトで256種類の異なる値を表現できるので、これがデータの基本単位として使われています。

```
1バイト = 8ビット = 256通りの組み合わせ
```

## 【実行】年齢や体重を2進数で表現してみよう

実際に身近な数字を2進数で表現してみましょう。

### ステップ1：10進数から2進数への変換方法

10進数を2進数に変換するには、2で割り続けて余りを記録します。

**例：年齢25歳を2進数にしてみよう**

```
25 ÷ 2 = 12 余り 1
12 ÷ 2 = 6  余り 0
6  ÷ 2 = 3  余り 0
3  ÷ 2 = 1  余り 1
1  ÷ 2 = 0  余り 1
```

余りを下から読むと：**11001**

確認してみましょう：
```
1×2⁴ + 1×2³ + 0×2² + 0×2¹ + 1×2⁰
= 1×16 + 1×8 + 0×4 + 0×2 + 1×1
= 16 + 8 + 0 + 0 + 1
= 25 ✓
```

### ステップ2：あなたの年齢を2進数にしてみよう

**練習問題：**
あなたの年齢を2進数で表現してください。

**ヒント：よく使われる年齢の2進数**
- 10歳 → 1010
- 15歳 → 1111
- 20歳 → 10100
- 30歳 → 11110
- 40歳 → 101000

### ステップ3：体重を2進数にしてみよう

**例：体重60kgの場合**

```
60 ÷ 2 = 30 余り 0
30 ÷ 2 = 15 余り 0
15 ÷ 2 = 7  余り 1
7  ÷ 2 = 3  余り 1
3  ÷ 2 = 1  余り 1
1  ÷ 2 = 0  余り 1
```

答え：**111100**

### ステップ4：コンピュータでの実際の保存方法

実際のコンピュータでは、数値は決まったビット数で保存されます：

**8ビット（1バイト）で保存する場合：**
- 25歳 → 00011001
- 60kg → 00111100

左側に0を追加して、8ビットにそろえています。これを**ゼロパディング**と言います。

## コンピュータは文字をどう覚えているか

数字の次は、文字がどう保存されているかを見てみましょう。

### 文字コードの仕組み

コンピュータは文字を直接理解できません。そこで、**文字と数字を対応させる表**を作って、文字を数字として保存しています。この対応表を**文字コード**と言います。

### ASCII コード（アスキーコード）

最も基本的な文字コードが**ASCII**です。英語のアルファベット、数字、記号に番号を割り当てています。

**主要なASCII文字コード：**

| 文字 | 10進数 | 2進数 | 説明 |
|------|--------|-------|------|
| A    | 65     | 01000001 | 大文字のA |
| B    | 66     | 01000010 | 大文字のB |
| a    | 97     | 01100001 | 小文字のa |
| b    | 98     | 01100010 | 小文字のb |
| 0    | 48     | 00110000 | 数字のゼロ |
| 1    | 49     | 00110001 | 数字のイチ |
| !    | 33     | 00100001 | 感嘆符 |
| ?    | 63     | 00111111 | 疑問符 |

### 日本語の文字コード

日本語には、ひらがな、カタカナ、漢字があり、ASCII だけでは足りません。そこで、より多くの文字を表現できる文字コードが作られました。

**主要な日本語文字コード：**

1. **Shift-JIS**：日本で広く使われた
2. **EUC-JP**：UNIX系で使われた
3. **UTF-8**：現在の標準（世界中の文字を表現可能）

**UTF-8での例：**
- 「あ」→ 11100011 10000001 10000010（3バイト）
- 「漢」→ 11100110 10100100 10100010（3バイト）

日本語は1文字で複数バイトを使うため、英語より容量が大きくなります。

## 【実行】自分の名前の文字コードを調べてみよう

実際にあなたの名前がどんな数字として保存されているか調べてみましょう。

### ステップ1：オンライン文字コード変換ツールを使う

以下のような無料のウェブサイトで文字コードを調べることができます：

1. ブラウザで「文字コード変換 オンライン」と検索
2. 文字コード変換サイトを開く
3. あなたの名前を入力欄に入力
4. UTF-8やShift-JISなどの文字コードを選択
5. 変換結果を確認

### ステップ2：結果を理解してみよう

**例：「田中」という名前の場合（UTF-8）**

```
「田」→ E7 94 B0 (16進数) → 11100111 10010100 10110000 (2進数)
「中」→ E4 B8 AD (16進数) → 11100100 10111000 10101101 (2進数)
```

つまり、「田中」という2文字は、コンピュータの中では6バイト（48ビット）の0と1の組み合わせとして保存されています。

### ステップ3：英語名と比較してみよう

**例：「TARO」という名前の場合（ASCII）**

```
「T」→ 54 (16進数) → 01010100 (2進数) → 1バイト
「A」→ 41 (16進数) → 01000001 (2進数) → 1バイト
「R」→ 52 (16進数) → 01010010 (2進数) → 1バイト
「O」→ 4F (16進数) → 01001111 (2進数) → 1バイト
```

「TARO」は4バイトで表現できます。日本語の「田中」（6バイト）より少ない容量で済みます。

### ステップ4：文字化けの原因を理解しよう

時々、メールやウェブサイトで文字が変に表示される「文字化け」を見たことがありませんか？

**文字化けの原因：**
1. 送信側：UTF-8で「こんにちは」を送信
2. 受信側：Shift-JISとして解釈してしまう
3. 結果：意味不明な文字が表示される

これは、同じ数字の組み合わせを異なる文字コード表で解釈してしまうために起こります。

## メモリという名前の記憶装置

コンピュータがこれらのデータをどこに保存しているかを理解しましょう。

### メモリの仕組み

**メモリ**は、コンピュータの一時的な記憶装置です。本棚のように、たくさんの「住所」があり、それぞれの住所に1バイトのデータを保存できます。

```
メモリのイメージ：
住所     | データ（1バイト）
---------|------------------
0x1000   | 01001000  (H)
0x1001   | 01100101  (e)
0x1002   | 01101100  (l)
0x1003   | 01101100  (l)
0x1004   | 01101111  (o)
```

この例では、「Hello」という文字列が住所0x1000から0x1004まで保存されています。

### メモリの種類

コンピュータには複数種類のメモリがあります：

1. **RAM（ランダムアクセスメモリ）**
   - 一時的な作業場所
   - 電源を切ると内容が消える
   - 高速だが容量は少なめ

2. **ストレージ（HDD/SSD）**
   - 長期的な保存場所
   - 電源を切っても内容が残る
   - 低速だが大容量

3. **CPU内のレジスタ**
   - 最も高速な記憶装置
   - 容量は極めて少ない
   - CPUが計算に使う

### データの流れ

プログラムを実行するときのデータの流れ：

1. **ストレージからRAMへ**：プログラムとデータを読み込み
2. **RAMからCPUへ**：処理するデータを転送
3. **CPU内で処理**：計算や判断を実行
4. **CPUからRAMへ**：結果を保存
5. **RAMからストレージへ**：必要に応じて長期保存

## データ型の基本概念

プログラミングでは、データの種類を**データ型**として分類します。

### 主要なデータ型

1. **整数型（Integer）**
   - 例：25, -10, 0
   - 小数点のない数値
   - 計算が高速

2. **浮動小数点型（Float）**
   - 例：3.14, -2.5, 0.0
   - 小数点のある数値
   - 近似値として保存

3. **文字列型（String）**
   - 例：「こんにちは」, "Hello"
   - 文字の集まり
   - 文字コードで保存

4. **論理型（Boolean）**
   - True（真）またはFalse（偽）
   - 条件判断に使用
   - 1ビットで表現可能だが、通常1バイト使用

### データ型が重要な理由

1. **メモリ効率**：適切な型を選ぶことで無駄な容量を使わない
2. **処理速度**：型に応じた最適な処理方法を選択
3. **エラー防止**：意図しない操作を防ぐ

**例：年齢の保存**
- 不適切：文字列として「25歳」で保存 → 計算できない
- 適切：整数として25で保存 → 計算可能

## 実際のデータサイズを体感してみよう

身の回りのデータがどのくらいのサイズかを理解しましょう。

### テキストデータ

```
「こんにちは」（5文字）
= 5文字 × 3バイト（UTF-8での日本語1文字）
= 15バイト

短いメール（200文字程度）
= 200文字 × 3バイト
= 600バイト
```

### 画像データ

```
スマホ写真（1200万画素）
= 1200万ピクセル × 3色（RGB） × 1バイト
= 約36MB（圧縮前）

実際のJPEG写真
= 約3-5MB（圧縮後）
```

### 音楽データ

```
CD音質の音楽（1分間）
= 44,100サンプル/秒 × 60秒 × 2チャンネル × 2バイト
= 約10MB

MP3音楽（1分間）
= 約1MB（圧縮後）
```

### 動画データ

```
フルHD動画（1分間、圧縮前）
= 1920×1080ピクセル × 30フレーム/秒 × 60秒 × 3色 × 1バイト
= 約11GB

実際のMP4動画（1分間）
= 約50-100MB（圧縮後）
```

## まとめ：データ表現の仕組み

この章で学んだことをまとめましょう：

### 数字の表現
- コンピュータは2進数（0と1）ですべての数を表現
- 8ビット = 1バイトが基本単位
- 大きな数は複数バイトを組み合わせて表現

### 文字の表現
- 文字は文字コードによって数字に変換
- ASCIIは英語の基本文字セット
- UTF-8は世界中の文字を表現可能
- 日本語は1文字で複数バイト必要

### メモリの仕組み
- データは住所付きの記憶場所に保存
- RAMは一時的、ストレージは永続的
- データ型によって保存方法が変わる

### サイズの感覚
- テキスト：軽い（数バイト〜数KB）
- 画像：中程度（数MB）
- 音楽：中程度（数MB）
- 動画：重い（数十〜数百MB）

次の章では、いよいよプログラムというものに実際に触れてみます。これまで学んだ「0と1の世界」と「データの表現」を基礎として、実際にコンピュータに指示を出してみましょう！