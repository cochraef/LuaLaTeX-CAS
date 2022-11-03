# LuaLaTeX-CAS

A computer algebra system written purely in Lua for embedding into LaTeX using the LuaLaTeX compiler. Includes symbolic root-finding, factoring, expansion, differentiation, and integration, as well as some number-theoretic and ring-theoretic functionality. Can even run in Overleaf.

Performance is necessarily not extremely fast, given Lua is an interpreted language. Do not expect to be able to factor large-degree polynomials or large integers in a reasonable time (but this is not the point of this CAS).

The Lua CAS itself can be downloaded or cloned from [https://github.com/cochraef/LuaCAS](https://github.com/cochraef/LuaCAS).

# Installation

The package manager for your local TeX distribution ought to work just fine. Alternatively, download luacas.tds.zip and unzip the file in the root of one of your TDS trees. You may need to update some filename database after this (this may vary depending on your TeX distribution).

# Authors

This package is authored and maintained by Evan Cochrane and Timothy All.

# License

Permission is granted to copy, distribute and/or modify this
software under the terms of the LaTeX Project Public License
(LPPL), version 1.3c or any later version.

![poweredbylua](http://www.lua.org/images/powered-by-lua.gif)
