local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("template", {
    t({ "#include <bits/stdc++.h>", "using namespace std;", "", "int main() {", "    " }),
    i(0),
    t({ "", "    return 0;", "}" }),
  }),
}