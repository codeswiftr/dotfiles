local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- FastAPI router endpoint
  s("fa_ep", {
    t({"from fastapi import APIRouter", "", "router = APIRouter()", "", "@router.get("}), i(1, "/items"), t({")", "async def ",}), i(2, "list_items"), t({"():", "    return {\"status\": \"ok\"}"}),
  }),

  -- Pydantic model template
  s("model", {
    t({"from pydantic import BaseModel", "", "class ",}), i(1, "Item"), t({"(BaseModel):", "    ",}), i(2, "name: str"), t({"", "    ",}), i(3, "value: int = 0"),
  }),
}

