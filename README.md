# LuaLaTeX-CAS

A computer algebra system written purely in Lua for embedding into LaTeX using the LuaLaTeX compiler. Includes symbolic root-finding, factoring, expansion, differentiation, and integration, as well as some number-theoretic and ring-theoretic functionality. Can even run in Overleaf.

Performance is necessarily not extremely fast, given Lua is an interpreted language. Do not expect to be able to factor large-degree polynomials or large integers in a reasonable time (but this is not the point of this CAS).

Permission is granted to copy, distribute and/or modify this
software under the terms of the LaTeX Project Public License
(LPPL), version 1.3c or any later version.
