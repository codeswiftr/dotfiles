local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- SwiftUI View skeleton
  s("sview", {
    t({"import SwiftUI", "", "struct "}), i(1, "MyView"), t({": View {", "    var body: some View {", "        ",}), i(2, "Text(\"Hello\")"), t({"", "    }", "}", "", "#Preview {", "    ",}), i(1), t({"()", "}"}),
  }),
}

