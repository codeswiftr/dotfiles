local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Lit component scaffold (TypeScript)
  s("litcmp", {
    t({"import { LitElement, html, css } from 'lit';", "import { customElement, property } from 'lit/decorators.js';", "", "@customElement('"}), i(1, "my-element"), t({"')", "export class ",}), i(2, "MyElement"), t({" extends LitElement {", "  static styles = css`", "    :host { display: block; }", "  `;", "", "  @property({ type: String })", "  name = '",}), i(3, "World"), t({"';", "", "  render() {", "    return html`<p>Hello, ${this.name}!</p>`;", "  }", "}", "", "declare global {", "  interface HTMLElementTagNameMap {", "    '"}), i(4, "my-element"), t({"': ",}), i(2), t({";", "  }", "}"}),
  }),
}

