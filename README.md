# proceeding_latex_templates

LuaLaTeX（LuaHBTeX）で「卒業研究発表会 予稿（A4・2段組）」を作成するための最小テンプレートです。  
本文は `main.tex` を編集し、クラス定義は `proceedings.cls` に集約しています。

---

## ディレクトリ構造と各ファイルの役割

```
proceeding_latex_templates-main/
├── main.tex                      # 予稿の本文（編集対象）
├── proceedings.cls               # クラス定義（2段組レイアウト、タイトルブロック、フッター等）
├── packages_lualatex.sty         # 追加パッケージ束（数式・単位・参照などを集約）
├── zcref_settings.sty            # zref-clever（\zlabel/\zcref）の設定
├── biblatex.cfg                  # biblatex（physスタイル）設定：日本語/非日本語の出力調整
├── biblatex-journal-style.sty    # 雑誌名（journaltitle 等）の体裁調整用（biblatex補助）
├── reference.bib                 # 参考文献データベース（BibTeX形式）
├── figures/
│   └── diagram.jpg               # 図のサンプル
├── out/                          # ビルド生成物の出力先（PDF/aux/bcf/bbl等）
├── .vscode/
│   └── settings.json             # VS Code + LaTeX Workshop 用設定（outDir/biber/recipe）
└── LICENSE                       # ライセンス（MIT）
```

---

## 実行環境

### 必須
- **TeX Live 2025** 以降（ログ上は LuaHBTeX 1.22.0 / LaTeX2e 2025-06-01）
- **LuaLaTeX（lualatex）**
- **biber**（biblatex のバックエンド）

### 推奨（開発・ビルド）
- **VS Code**
- 拡張 **LaTeX Workshop**
  - 本リポジトリの `.vscode/settings.json` は、出力先を `out/` に固定し、
    `lualatex → biber → lualatex → lualatex` のレシピでビルドする想定です。

---

## 使用方法

### 1) VS Code（LaTeX Workshop）でビルドする
1. このフォルダを VS Code で開く
2. `main.tex` を編集
3. LaTeX Workshop の Recipe で **`lualatex (biblatex+biber)`** を選択してビルド  
   - 出力は `out/main.pdf`（または設定により `main.pdf`）になります

> 参考文献が空になる場合は、**biber が走っていない**か、`out/` を見ていない可能性が高いです（後述）。

### 2) コマンドラインでビルドする（out/ を使用）
```bash
lualatex -synctex=1 -interaction=nonstopmode -file-line-error -halt-on-error -output-directory=out main.tex
biber --input-directory=out --output-directory=out --bblencoding=utf8 -u -U --output_safechars main
lualatex -synctex=1 -interaction=nonstopmode -file-line-error -halt-on-error -output-directory=out main.tex
lualatex -synctex=1 -interaction=nonstopmode -file-line-error -halt-on-error -output-directory=out main.tex
```

---

## テンプレートの書き方（最低限）

### タイトル・著者・要旨
`main.tex` 冒頭の `\twocolumn[ ... ]` 内で指定します（クラス側マクロ）。
- `\PaperTitle{...}`
- `\PaperAuthor{...}`
- `\PaperSummary{...}`

### 指導教員名（フッター）
`main.tex` の `\AdvisorFootnote{...}` で指定します（表示方法は `proceedings.cls` 側）。

### 単位（siunitx）
`packages_lualatex.sty` で `siunitx` を読み込んでいるので、本文では例えば：
- `\SI{297}{\milli\metre}`
- `\SI{2}{\mega\byte}`

### 箇条書き（(1), (2), ...）
`packages_lualatex.sty` で `enumitem` を設定済みなので、通常の `enumerate` で `(1)` 形式になります。

### 参照（zref-clever）
本文では `\label` ではなく **`\zlabel`** を使う運用に寄せています（例：`\zlabel{eq:euler}`）。  
参照は `\zcref{eq:euler}`。

### 参考文献（biblatex）
- `main.tex` で `\addbibresource{reference.bib}` を指定
- 本文で `\cite{...}` を使用
- 末尾で `\printbibliography`

---

## 注意事項・トラブルシュート

### 参考文献が出ない（Empty bibliography / No file main.bbl）
原因のほとんどは次のどれかです：

1. **biber を実行していない**  
   - LaTeX のログに `Please (re)run Biber` と出る場合はこれです。
2. **outDir を使っているのに biber が out/ を見ていない**  
   - `main.bcf` は `out/` に生成されるので、biber も `--input-directory=out` が必要です。
   - `.vscode/settings.json` の biber ツールはこの前提で設定されています。
3. `\addbibresource{reference.bib}` を削除している／`reference.bib` が見つからない  
   - `\addbibresource` を消すと警告は減りますが、当然 bibliography は生成されません。

まず `out/` に `main.bcf` があるか、次に `out/main.bbl` が生成されているかを確認してください。

### `autonum` を使いたい場合
`packages_lualatex.sty` では、過去に **biblatex と衝突したため** `autonum` をデフォルトで無効化しています。  
必要なら、衝突が出ないことを確認した上で自己責任で有効化してください。

### out/ の扱い
`out/` は補助ファイルが多く生成されます。Git 管理する場合は `.gitignore` で除外する運用を推奨します。

---

## ライセンス
MIT License（`LICENSE` を参照）
