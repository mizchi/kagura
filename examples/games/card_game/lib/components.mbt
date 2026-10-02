///|
let ink : Int = 0xF0EEE5

///|
let muted_ink : Int = 0xBCC7D5

///|
let gold : Int = 0xFFD080

///|
let cyan : Int = 0x7FE0D4

///|
fn ui_text(
  key : String,
  x : Double,
  y : Double,
  text : String,
  scale? : Double = 0.75,
  color? : Int = ink,
) -> @scene.SceneNode {
  @scene.label(key~, x~, y~, content=text.to_upper(), scale~, color~)
}

///|
fn fit_text(
  key : String,
  x : Double,
  y : Double,
  text : String,
  width : Double,
  scale? : Double = 0.75,
  color? : Int = ink,
) -> @scene.SceneNode {
  let fitted = ui_min(
    scale,
    width / ui_max(1.0, text.length().to_double() * 12.0 - 3.0),
  )
  ui_text(key, x, y, text, scale=fitted, color~)
}

///|
fn wrap_copy(text : String, max_chars : Int) -> Array[String] {
  let lines : Array[String] = []
  let mut current = ""
  for word in text.to_upper().split(" ") {
    if current != "" && current.length() + word.length() + 1 > max_chars {
      lines.push(current)
      current = ""
    }
    current = if current == "" {
      word.to_string()
    } else {
      current + " " + word.to_string()
    }
  }
  if current != "" {
    lines.push(current)
  }
  lines
}

///|
fn copy_lines(
  key : String,
  text : String,
  x : Double,
  y : Double,
  width : Double,
  scale : Double,
  color : Int,
) -> @scene.SceneNode {
  let lines = wrap_copy(text, ui_max(4, (width / (12.0 * scale)).to_int()))
  let nodes : Array[@scene.SceneNode] = []
  for i = 0; i < lines.length(); i = i + 1 {
    nodes.push(
      fit_text(
        key + i.to_string(),
        x,
        y + i.to_double() * (15.0 * scale + 4.0),
        lines[i],
        width,
        scale~,
        color~,
      ),
    )
  }
  @scene.fragment(nodes)
}

///|
fn ui_panel(
  key : String,
  rect : UiRect,
  fill : Int,
  border : Int,
  children : Array[@scene.SceneNode],
) -> @scene.SceneNode {
  @scene.rect(
    key~,
    x=rect.x,
    y=rect.y,
    w=rect.w,
    h=rect.h,
    fill~,
    children=[
      @scene.rect_outline(
        x=1.0,
        y=1.0,
        w=rect.w - 2.0,
        h=rect.h - 2.0,
        color=border,
      ),
      ..children,
    ],
  )
}

///|
fn ui_button(
  key : String,
  rect : UiRect,
  text : String,
  accent? : Int = gold,
) -> @scene.SceneNode {
  ui_panel(key, rect, 0x253044, accent, [
    fit_text(
      "text",
      rect.w / 2.0,
      rect.h / 2.0,
      text,
      rect.w - 16.0,
      scale=0.85,
      color=accent,
    ),
  ])
}

///|
fn ui_meter(
  key : String,
  x : Double,
  y : Double,
  width : Double,
  value : Int,
  maximum : Int,
  color : Int,
) -> @scene.SceneNode {
  let ratio = ui_max(
    0.0,
    ui_min(1.0, value.to_double() / ui_max(1, maximum).to_double()),
  )
  @scene.rect(key~, x~, y~, w=width, h=12.0, fill=0x10151C, children=[
    @scene.rect(x=1.0, y=1.0, w=(width - 2.0) * ratio, h=10.0, fill=color),
    fit_text(
      "value",
      width / 2.0,
      6.0,
      value.to_string() + "/" + maximum.to_string(),
      width - 6.0,
      scale=0.55,
    ),
  ])
}

///|
fn card_accent(id : CardId) -> Int {
  match card_def(id).card_type {
    Attack => 0xFFA082
    Skill => cyan
    Power => 0xCAB2FF
  }
}

///|
fn card_type_text(id : CardId) -> String {
  match card_def(id).card_type {
    Attack => "ATTACK"
    Skill => "SKILL"
    Power => "POWER"
  }
}

///|
fn card_icon(
  card : CardId,
  x : Double,
  y : Double,
  size : Double,
  accent : Int,
) -> @scene.SceneNode {
  let px = size / 7.0
  let pattern = match card_def(card).card_type {
    Attack =>
      [
        "0000010", "0000110", "0101100", "0011000", "0110100", "1100000", "1000000",
      ]
    Skill =>
      [
        "1111111", "1000001", "1011101", "1011101", "0100010", "0111110", "0011100",
      ]
    Power =>
      [
        "0001000", "0011100", "0111110", "1101011", "0111110", "0011100", "0001000",
      ]
  }
  let nodes : Array[@scene.SceneNode] = []
  for row = 0; row < 7; row = row + 1 {
    for col = 0; col < 7; col = col + 1 {
      if pattern[row][col] == '1' {
        nodes.push(
          @scene.rect(
            x=x + col.to_double() * px,
            y=y + row.to_double() * px,
            w=px,
            h=px,
            fill=accent,
          ),
        )
      }
    }
  }
  @scene.fragment(nodes)
}

///|
fn ui_card(
  key : String,
  rect : UiRect,
  id : CardId,
  cost : Int,
  enabled : Bool,
  selected : Bool,
  spine? : Bool = false,
  detailed? : Bool = false,
) -> @scene.SceneNode {
  let def = card_def(id)
  let accent = card_accent(id)
  let border = if selected { gold } else if enabled { accent } else { 0xA0ADBF }
  let text_color = if enabled { ink } else { muted_ink }
  let children : Array[@scene.SceneNode] = [
    @scene.rect(x=4.0, y=4.0, w=22.0, h=22.0, fill=0x10151C),
    ui_text(
      "cost",
      15.0,
      15.0,
      if id == Whirlwind {
        "X"
      } else {
        cost.to_string()
      },
      scale=0.9,
      color=border,
    ),
  ]
  if !spine {
    let title_scale = if rect.w < 85.0 { 0.55 } else { 0.7 }
    children.push(
      copy_lines(
        "name_",
        def.name,
        rect.w / 2.0,
        36.0,
        rect.w - 12.0,
        title_scale,
        text_color,
      ),
    )
    let icon_size = if rect.h < 120.0 { 18.0 } else { 30.0 }
    let icon_y = if rect.h < 120.0 { 53.0 } else { 65.0 }
    if !detailed {
      children.push(
        card_icon(id, (rect.w - icon_size) / 2.0, icon_y, icon_size, border),
      )
    }
    let desc_y = if detailed {
      68.0
    } else if rect.h < 120.0 {
      rect.h - 22.0
    } else {
      111.0
    }
    let desc_scale = if rect.w < 85.0 { 0.4 } else { 0.5 }
    children.push(
      copy_lines(
        "effect_",
        if detailed {
          render_copy(def.description)
        } else {
          short_desc(def)
        },
        rect.w / 2.0,
        desc_y,
        rect.w - 10.0,
        desc_scale,
        text_color,
      ),
    )
    if rect.h >= 120.0 {
      children.push(
        fit_text(
          "type",
          rect.w / 2.0,
          rect.h - 10.0,
          card_type_text(id) + (if def.exhaust { " EXH" } else { "" }),
          rect.w - 10.0,
          scale=0.45,
          color=border,
        ),
      )
    }
  }
  ui_panel(
    key,
    rect,
    if enabled {
      0x222C3B
    } else {
      0x1C2430
    },
    border,
    children,
  )
}

///|
fn short_desc(def : CardDef) -> String {
  match def.id {
    Strike => "6 DAMAGE"
    Defend => def.base_block.to_string() + " BLOCK"
    Bash => "8 DMG VUL 2"
    Cleave => "8 DMG ALL"
    Pommel_Strike => "9 DMG DRAW 1"
    Twin_Strike => "5 DMG X2"
    Iron_Wave =>
      def.base_damage.to_string() +
      " DMG " +
      def.base_block.to_string() +
      " BLK"
    Anger => "6 DMG COPY"
    Headbutt => "9 DMG RECUR"
    Shrug_It_Off => "8 BLK DRAW 1"
    Armaments => "5 BLOCK"
    True_Grit => "7 BLK EXH 1"
    Flex => "2 TEMP STR"
    Clothesline => "12 DMG WK 2"
    Uppercut => "13 DMG WK VUL"
    Body_Slam => "DMG FROM BLK"
    Sword_Boomerang => "3 DMG X3 RNG"
    Rampage => "8 DMG GROW 5"
    Bloodletting => "-3 HP +2 E"
    Offering => "-6 HP +2 E DRAW 3"
    Seeing_Red => "+2 ENERGY"
    Battle_Trance => "DRAW 3"
    Shockwave => "WK VUL 3 ALL"
    Disarm => "ENEMY STR -2"
    Inflame => "+2 STRENGTH"
    Metallicize => "3 BLK PER TURN"
    Bludgeon => "32 DAMAGE"
    Impervious => "30 BLOCK"
    Demon_Form => "2 STR PER TURN"
    Barricade => "KEEP BLOCK"
    Feel_No_Pain => "3 BLK PER EXH"
    Corruption => "FREE SKILLS EXH"
    Heavy_Blade => "14 DMG STR X3"
    Whirlwind => "5 DMG X E ALL"
    Feed => "10 DMG +3 MAX HP"
    Fiend_Fire => "7 DMG PER EXH"
    Limit_Break => "DOUBLE STR"
    Carnage => "20 DMG ETHEREAL"
    Immolate => "21 DMG ALL"
    Reaper => "4 DMG ALL HEAL"
    Entrench => "DOUBLE BLOCK"
    Pummel => "2 DMG X4"
  }
}

///|
/// The scene font supports uppercase ASCII; convert punctuation to word breaks.
fn render_copy(text : String) -> String {
  let mut out = ""
  for ch in text.to_upper() {
    let n = ch.to_int()
    out += if (n >= 65 && n <= 90) ||
      (n >= 48 && n <= 57) ||
      ch == ' ' ||
      ch == '+' ||
      ch == '-' ||
      ch == '/' ||
      ch == ':' ||
      ch == '>' ||
      ch == '%' {
      ch.to_string()
    } else {
      " "
    }
  }
  out
}

///|
fn view_card_detail(id : CardId, r : UiRect) -> @scene.SceneNode {
  let def = card_def(id)
  ui_panel("card_detail", r, 0x222C3B, card_accent(id), [
    fit_text(
      "name",
      r.w / 2.0,
      24.0,
      def.name + " / " + def.cost.to_string() + " ENERGY",
      r.w - 24.0,
      scale=0.85,
      color=card_accent(id),
    ),
    copy_lines(
      "description_",
      render_copy(def.description),
      r.w / 2.0,
      52.0,
      r.w - 32.0,
      0.65,
      ink,
    ),
  ])
}
