# LuaLaTeX-CAS

A computer algebra system written purely in Lua for embedding into LaTeX using the LuaLaTeX compiler. Includes symbolic root-finding, factoring, expansion, differentiation, and integration, as well as some number-theoretic and ring-theoretic functionality. Can even run in Overleaf if you upload all the files (or wait for this to be uploaded as a CTAN package).

Performance is necessarily not extremely fast, given Lua is an interpreted language. Do not expect to be able to factor large-degree polynomials or large integers in a reasonable time (this is not the point of this CAS).

Full documentation for both the Lua end and LaTeX macros is currently WIP.
