# SEC Document Preparation & Presentation Software

![Course](https://img.shields.io/badge/Course-SEC-blue.svg?style=for-the-badge)

Welcome to the collection of practical assignments for the **Document Preparation & Presentation Software** course. This repository contains LaTeX solutions for various **document formatting and typesetting** problems.

---
## 📅 List of Practicals

1. [Hello World! — Basic Document Structure](./1.tex)
- **Objective**: Create a simple LaTeX document with title, author, and mathematical expressions.
Steps:
    1) Define document class `article` with font size and paper size.
    2) Set `\title`, `\author`, and `\date` in the preamble.
    3) Use `\maketitle` inside `\begin{document}`.
    4) Write inline math using `$...$` and display math using `$$...$$`.

2. [Calculus & Series — Mathematical Notation](./2.tex)
- **Objective**: Typeset integrals, summations, products, and limits using LaTeX math mode.
Steps:
    1) Use `\int_{a}^{b}` for definite integrals.
    2) Use `\sum_{n=1}^{\infty}` for series notation.
    3) Use `\prod_{i=a}^{b}` for product notation.
    4) Use `\lim_{x\to\infty}` for limits.

3. [Equations & Matrices](./3.tex)
- **Objective**: Write aligned multi-line equations and matrix notation.
Steps:
    1) Use `\begin{align}` for numbered, aligned equations.
    2) Add cross-reference labels with `\label{}` and reference them with `\ref{}`.
    3) Use `pmatrix` (round brackets) or `bmatrix` (square brackets) environments for matrices.

4. [Nested Lists — Structured Documentation](./4.tex)
- **Objective**: Create structured nested lists for organized content.
Steps:
    1) Use `\begin{itemize}` for unordered lists.
    2) Nest a second `\begin{itemize}` inside a list item.
    3) Customize bullet style with `\item[-]` for sub-items.

5. [Algorithms — Pseudocode with algorithm2e](./5.tex)
- **Objective**: Write clear algorithm pseudocode using the `algorithm2e` package.
Steps:
    1) Add `\usepackage[ruled,vlined]{algorithm2e}` to the preamble.
    2) Define input/output using `\KwInput`, `\KwOutput`.
    3) Use `\If`, `\ElseIf`, `\Else`, `\For`, and `\While` for control flow.
    4) Add comments using `\tcp{}` (inline) and `\tcc{}` (block).

6. [Tables — Row Merging with multirow](./6.tex)
- **Objective**: Create tables where a single cell spans multiple rows.
Steps:
    1) Add `\usepackage{multirow}` to the preamble.
    2) Use `\multirow{n}{*}{text}` to span `n` rows.
    3) Leave subsequent rows' merged cell position empty with `&`.

7. [Tables — Column Merging with multicolumn](./7.tex)
- **Objective**: Create tables with headers spanning multiple columns.
Steps:
    1) Use `\multicolumn{n}{|c|}{text}` to span `n` columns.
    2) Specify column alignment and borders inside `\multicolumn`.
    3) Add `\hline` before and after the header row.

8. [Subfigures — Multiple Images with Captions](./8.tex)
- **Objective**: Arrange multiple images in a 2x2 grid with individual captions.
Steps:
    1) Add `\usepackage{graphicx}` and `\usepackage{subcaption}`.
    2) Use `\begin{subfigure}[b]{0.45\textwidth}` for each image slot.
    3) Add `\caption{}` and `\label{}` to each subfigure.
    4) Reference subfigures in text using `\ref{fig:sub1}`.

9. [Automated Front Matter — TOC, LOF, LOT](./9.tex)
- **Objective**: Automatically generate a Table of Contents, List of Figures, and List of Tables.
Steps:
    1) Place `\tableofcontents`, `\listoffigures`, `\listoftables` after `\maketitle`.
    2) Use `\section{}` and `\subsection{}` to populate the TOC.
    3) Add captions to `table` and `figure` environments.
    4) Compile **twice** for all references to resolve correctly.

10. [Bibliography — Reference Management with natbib](./10.tex)
- **Objective**: Manage and cite references using the `natbib` package.
Steps:
    1) Add `\usepackage[numbers]{natbib}` and `\usepackage{url}` to the preamble.
    2) Cite sources in text using `\citep{key}`.
    3) Define references inside `\begin{thebibliography}{9}` using `\bibitem{key}`.
    4) Set the style using `\bibliographystyle{plain}`.

---
<p align="right">
  <i>Developed with ❤️ by <a href="https://github.com/16ratneshkumar">16ratneshkumar</a></i>
</p>