/** UI adapter only: all poses, validation and transactions belong to MoonBit. */
export function createExpressionPanel({
  container,
  element,
  button,
  send,
  snapshot,
  focusFace,
}) {
  container.classList.add("modeling-expressions");
  const header = element("div", "modeling-expression-header");
  header.append(
    element("h2", "", "表情 / Expressions"),
    button("通常の顔", "Neutral expression", () =>
      send({ op: "expression.preview", weights: {} }),
    ),
    button("顔を拡大", "Frame expression face", focusFace),
  );
  const body = element("div", "modeling-expression-body");
  const list = element("div", "modeling-expression-list");
  const author = element("div", "modeling-expression-author");
  const select = document.createElement("select");
  select.setAttribute("aria-label", "Expression to edit");
  const name = document.createElement("input");
  name.setAttribute("aria-label", "Expression name");
  name.placeholder = "新しい表情の名前";
  name.maxLength = 120;
  let selected = "",
    signature = "";
  const rows = new Map();
  const status = element("p", "modeling-expression-status");
  status.setAttribute("role", "status");
  select.addEventListener("change", () => {
    selected = select.value;
    name.value =
      snapshot().document.expressions.find((e) => e.id === selected)?.name ??
      "";
  });
  const controls = element("div", "modeling-actions");
  const add = button("新規差分", "New expression", () => {
    const expressions = snapshot().document.expressions;
    let serial = 1;
    while (expressions.some((e) => e.id === `custom.${serial}`)) serial++;
    const id = `custom.${serial}`;
    send({
      op: "expression.begin",
      id,
      name: name.value.trim() || `表情 ${serial}`,
    });
  });
  const edit = button("差分を編集", "Edit expression", () =>
    send({
      op: "expression.begin",
      id: selected,
      name: name.value.trim() || selected,
    }),
  );
  const remove = button("削除", "Delete expression", () =>
    send({ op: "expression.remove", id: selected }),
  );
  const save = button("差分を確定", "Save expression", () =>
    send({ op: "expression.save" }),
  );
  const cancel = button("取り消す", "Cancel expression", () =>
    send({ op: "expression.cancel" }),
  );
  controls.append(add, edit, remove, save, cancel);
  author.append(select, name, controls, status);
  body.append(list, author);
  container.append(header, body);
  function sync(state) {
    const expressions = state.document.expressions;
    const next = JSON.stringify(expressions.map((e) => [e.id, e.name]));
    if (next !== signature) {
      signature = next;
      if (!expressions.some((e) => e.id === selected))
        selected = expressions[0]?.id ?? "";
      select.replaceChildren(
        ...expressions.map((e) => new Option(e.name, e.id)),
      );
      select.value = selected;
      name.value = expressions.find((e) => e.id === selected)?.name ?? "";
      list.replaceChildren();
      rows.clear();
      for (const expression of expressions) {
        const row = element("div", "modeling-expression-row");
        const preset = button(
          expression.name.split(" / ")[0],
          "Preview expression " + expression.id,
          () => {
            selected = expression.id;
            select.value = selected;
            name.value = expression.name;
            send({ op: "expression.preview", weights: { [selected]: 1 } });
          },
        );
        const weight = document.createElement("input");
        weight.type = "range";
        weight.min = "0";
        weight.max = "1";
        weight.step = "0.01";
        weight.setAttribute("aria-label", "Expression weight " + expression.id);
        weight.addEventListener("input", () =>
          send({
            op: "expression.preview",
            weights: {
              ...snapshot().weights,
              [expression.id]: Number(weight.value),
            },
          }),
        );
        const output = element("output");
        row.append(preset, weight, output);
        list.append(row);
        rows.set(expression.id, { weight, output, preset });
      }
      if (!expressions.length)
        list.append(
          element(
            "p",
            "modeling-muted",
            "新規差分を作り、顔の部品や頂点を動かして表情を登録できます。",
          ),
        );
    }
    const drafting = !!state.expressionEdit,
      busy = !!state.modal;
    for (const [id, row] of rows) {
      const value = state.weights[id] ?? 0;
      row.weight.value = String(value);
      row.output.textContent = Math.round(value * 100) + "%";
      row.preset.setAttribute("aria-pressed", String(value > 0));
      row.weight.disabled = row.preset.disabled = drafting || busy;
    }
    header.querySelector("button").disabled = drafting || busy;
    select.disabled = name.disabled = drafting || busy;
    add.disabled = drafting || busy || expressions.length >= 32;
    edit.disabled = remove.disabled = drafting || busy || !selected;
    save.hidden = cancel.hidden = !drafting;
    save.disabled = cancel.disabled = busy;
    add.hidden = edit.hidden = remove.hidden = drafting;
    status.textContent = drafting
      ? `編集中: ${state.expressionEdit.name}。G / R / S、Tab → 頂点編集で顔を変形し、差分を確定してください。`
      : "強さを混ぜてプレビュー。編集後は Save model で全ての差分を保存できます。";
  }
  return { sync };
}
