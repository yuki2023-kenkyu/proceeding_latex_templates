% proceedings.cls  (COMPLETE / FIXED v2)
% LuaLaTeX + bxjsarticle
% - Two-column body throughout
% - Full-width title/author/summary via \twocolumn[ ... ]
% - Delay figures/tables and print immediately after \printbibliography (no forced page break)
% - Figure: "Figure 1."  / Table: "Table I."
% - No List of Figures/Tables
% - Paragraph indent = 1 zw
% - Section spacing: 1 blank line between sections; no extra blank line between subsections
% - Advisor footnote in lighter color
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{proceedings}[2026/02/02 Proceedings class (LuaLaTeX + bxjsarticle)]
\ClassInfo{proceedings}{*** proceedings.cls LOADED ***}

% --- Pass unknown options to bxjsarticle ---
\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{bxjsarticle}%
}
\ProcessOptions\relax

% --- Base class ---
\LoadClass[a4paper,ja=minimal,lualatex]{bxjsarticle}

% ========= Fonts (LuaLaTeX) =========
\RequirePackage{fontspec}
\RequirePackage{luatexja-fontspec}

% HaranoAji if available
\IfFontExistsTF{HaranoAjiMincho}{%
  \setmainjfont{HaranoAjiMincho}
  \setsansjfont{HaranoAjiGothic}
}{%
  % fallback: TeX Live defaults
}

\setmainfont{Latin Modern Roman}
\setsansfont{Latin Modern Sans}
\setmonofont{Latin Modern Mono}

% ========= Page geometry (A4, margins) =========
\RequirePackage[a4paper]{geometry}
\geometry{
  top=25mm,
  bottom=22mm,
  left=20mm,
  right=20mm
}

% ========= Two-column layout =========
\setlength{\columnsep}{10mm}

% ========= No page numbers =========
\pagestyle{empty}

% ========= Basic typography =========
\AtBeginDocument{\fontsize{9pt}{14pt}\selectfont}

% Paragraph indent: 1 fullwidth space (zw)
\setlength{\parindent}{1\zw}
\setlength{\parskip}{0pt}

% \section 直後の段落も字下げする（\parindent=1\zw が効く）
\RequirePackage{indentfirst}

% Justification
\RequirePackage{ragged2e}

% ========= Section headings =========
\RequirePackage{titlesec}

% section: centered; 1 blank line between sections
\titleformat{\section}[block]
  {\bfseries\fontsize{10.5pt}{14pt}\selectfont\filcenter}
  {\thesection}{1\zw}{}
\titlespacing*{\section}
  {0pt}{1.0\baselineskip}{0.4\baselineskip}

% subsection: run-in; no extra blank line between subsections
\titleformat{\subsection}[runin]
{\bfseries\fontsize{9pt}{14pt}\selectfont}
{\thesubsection}{1\zw}{}[\hspace*{1\zw}]
\titlespacing*{\subsection}
{0pt}{0pt}{0.4em}

% ========= Graphics / Captions =========
\RequirePackage{graphicx}
\RequirePackage{caption}

% Caption label format: "Figure 1." / "Table I."
\renewcommand{\figurename}{Fig.}
\renewcommand{\tablename}{Table}
\renewcommand{\thetable}{\Roman{table}}

\captionsetup{
  font=small,
  labelfont=bf,
  labelformat=simple,
  labelsep=period
}

% ========= No List of Figures/Tables =========
\providecommand{\listoffigures}{}
\providecommand{\listoftables}{}

% ========= Hyperref (avoid misaligned link rectangles) =========
\RequirePackage[unicode,psdextra]{hyperref}
\hypersetup{
  hidelinks,
  pdfborder={0 0 0},
  pdfhighlight=/N
}

% ========= Bibliography (biblatex-phys: keep phys) =========
\RequirePackage[
  backend=biber,
  style=phys,
  biblabel=brackets,
  sorting=none
]{biblatex}

% If biblatex.cfg exists, read it
% \InputIfFileExists{biblatex.cfg}{}{}

\setlength{\biblabelsep}{0.6em}

% IMPORTANT: biblatex-phys fixes heading internally, so override it here.
% This makes the bibliography heading always Japanese ("参考文献"),
% regardless of \printbibliography[title=...].
\defbibheading{bibliography}[\refname]{%
  \section*{参考文献}%
}

% ========= Colors =========
\RequirePackage{xcolor}

% ========= Title block macros =========
\newcommand{\PaperTitle}[1]{%
  \par\centering{\fontsize{15pt}{18pt}\selectfont #1\par}%
  \vspace{0.4\baselineskip}%
}
\newcommand{\PaperAuthor}[1]{%
  \par\centering{\fontsize{11pt}{14pt}\selectfont #1\par}%
  \vspace{1.0\baselineskip}%
}
\newcommand{\PaperSummary}[1]{%
  \par\noindent
  \begin{minipage}{\textwidth}
    \justifying
    {\fontsize{9pt}{14pt}\selectfont #1\par}%
  \end{minipage}%
  \vspace{1.0\baselineskip}%
}

% Advisor footnote (no mark), lighter color
\newcommand{\AdvisorFootnote}[1]{%
  \begingroup
  \renewcommand{\thefootnote}{}%
  \footnotetext{\textcolor{black!60}{指導教員：#1}}%
  \endgroup
}

% ============================================================
% Delayed figures/tables:
% - Collect figure/table bodies where they appear
% - Print them immediately after \printbibliography (no forced page break)
%
% Key fix (v2):
% - DO NOT rewrite \caption to \captionof (causes recursion with caption package)
% - Instead, set \@captype = figure/table when typesetting the stored body,
%   so the original \caption{...} works outside floats.
% ============================================================
\RequirePackage{xparse}
\RequirePackage{etoolbox}

\makeatletter
\gdef\proceedings@stored@figures{}
\gdef\proceedings@stored@tables{}

% Typeset a stored block with a given caption type.
\newcommand{\proceedings@typeset@stored}[2]{%
  \par\medskip\noindent
  \begingroup
  \def\@captype{#1}%
  \begin{minipage}{\linewidth}
    #2%
  \end{minipage}%
  \endgroup
  \par\medskip
}

% Store figure body and suppress output at original position
\RenewDocumentEnvironment{figure}{O{tbp} +b}{%
  \typeout{[proceedings] storing a figure}%
  \g@addto@macro\proceedings@stored@figures{%
    \proceedings@typeset@stored{figure}{#2}%
  }%
}{}

% Store figure* similarly
\RenewDocumentEnvironment{figure*}{O{tbp} +b}{%
  \typeout{[proceedings] storing a figure*}%
  \g@addto@macro\proceedings@stored@figures{%
    \proceedings@typeset@stored{figure}{#2}%
  }%
}{}

% Store table body and suppress output at original position
\RenewDocumentEnvironment{table}{O{tbp} +b}{%
  \typeout{[proceedings] storing a table}%
  \g@addto@macro\proceedings@stored@tables{%
    \proceedings@typeset@stored{table}{#2}%
  }%
}{}

% Store table* similarly
\RenewDocumentEnvironment{table*}{O{tbp} +b}{%
  \typeout{[proceedings] storing a table*}%
  \g@addto@macro\proceedings@stored@tables{%
    \proceedings@typeset@stored{table}{#2}%
  }%
}{}

\newif\ifproceedings@floatsprinted
\proceedings@floatsprintedfalse
\newif\ifproceedings@patchok
\proceedings@patchokfalse

\newcommand{\proceedings@printdelayedfloats}{%
  \ifproceedings@floatsprinted\else
  \proceedings@floatsprintedtrue
  \typeout{[proceedings] printing delayed floats}%
  \par\noindent
  \proceedings@stored@figures
  \proceedings@stored@tables
  \fi
}

% Patch \printbibliography
\AtBeginDocument{%
  \apptocmd{\printbibliography}{\proceedings@printdelayedfloats}{%
    \proceedings@patchoktrue
  }{%
    \ClassWarning{proceedings}{Failed to patch \string\printbibliography}%
  }%
}

% Safety net: only if patch failed
\AtEndDocument{%
  \ifproceedings@patchok\else
  \proceedings@printdelayedfloats
  \fi
}
\makeatother

\endinput
