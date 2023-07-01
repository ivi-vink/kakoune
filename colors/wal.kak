# wal theme
evaluate-commands %sh{
    nu -c '
let tbl = [[scope name colors];

[global  value               {fg:  colors.color1}       ]
[global  type                {fg:  colors.color3}       ]
[global  variable            {fg:  colors.color4}       ]
[global  module              {fg:  colors.color2}       ]
[global  function            {fg:  special.foreground}  ]
[global  string              {fg:  colors.color5}       ]
[global  keyword             {fg:  colors.color2}       ]
[global  operator            {fg:  special.foreground}  ]
[global  attribute           {fg:  colors.color3}       ]
[global  comment             {fg:  colors.color8        attr:  i}                   ]
[global  documentation       {fg:  comment}             ]
[global  meta                {fg:  colors.color6}       ]
[global  builtin             {fg:  special.foreground   attr:  b}                   ]
[global  title               {fg:  colors.color2        attr:  b}                   ]
[global  header              {fg:  colors.color3}       ]
[global  mono                {fg:  special.foreground}  ]
[global  block               {fg:  colors.color6}       ]
[global  link                {fg:  colors.color4        attr:  u}                   ]
[global  bullet              {fg:  colors.color3}       ]
[global  list                {fg:  special.foreground}  ]
[global  Default             {fg:  special.foreground   bg:    special.background}  ]
[global  PrimarySelection    {fg:  special.foreground   bg:    colors.color1       attr:  g}   ]
[global  SecondarySelection  {fg:  colors.color0        bg:    colors.color4       attr:  g}   ]
[global  PrimaryCursor       {fg:  special.background   bg:    special.foreground   attr:  fg}  ]
[global  SecondaryCursor     {fg:  special.background   bg:    colors.color4        attr:  fg}  ]
[global  PrimaryCursorEol    {fg:  special.background   bg:    special.foreground   attr:  fg}  ]
[global  SecondaryCursorEol  {fg:  special.background   bg:    colors.color0        attr:  fg}  ]
[global  LineNumbers         {fg:  colors.color8}       ]
[global  LineNumberCursor    {fg:  colors.color3        bg:    colors.color5}       ]
[global  LineNumbersWrapped  {fg:  colors.color5}       ]
[global  MenuForeground      {fg:  colors.color0        bg:    colors.color4}      ]
[global  MenuBackground      {fg:  special.foreground   bg:    colors.color5}       ]
[global  MenuInfo            {fg:  special.background}  ]
[global  Information         {fg:  special.background   bg:    special.foreground}  ]
[global  Error               {fg:  special.background   bg:    colors.color1}       ]
[global  DiagnosticError     {fg:  colors.color1}       ]
[global  DiagnosticWarning   {fg:  colors.color3}       ]
[global  StatusLine          {fg:  special.foreground   bg:    special.background}  ]
[global  StatusLineMode      {fg:  colors.color3        attr:  b}                   ]
[global  StatusLineInfo      {fg:  colors.color5}      ]
[global  StatusLineValue     {fg:  colors.color1}       ]
[global  StatusCursor        {fg:  special.background   bg:    special.foreground}  ]
[global  Prompt              {fg:  colors.color3}       ]
[global  MatchingChar        {fg:  special.foreground   bg:    colors.color0        attr:  b}   ]
[global  BufferPadding       {fg:  colors.color0        bg:    special.background}  ]
[global  Whitespace          {fg:  colors.color0        attr:  f}                   ]

]

let get_color_records  = { |tbl keys|
    ($keys |
     each { |key| ($tbl | get $key | transpose key value | each { {key: ($key + '.' + $in.key), value: ($in.value | str replace "#" "rgb:") } }) } |
     flatten |
     reduce -f {} { |kv acc| $acc | insert $kv.key $kv.value })
}
let wal = (
    do $get_color_records (open ~/.cache/wal/colors.json) [colors special]
)

let get_or_return = { |cell|
    try { $wal | get $cell } catch { $cell }
}
let color2string = { |color|
    let col = ($color | match $in {
        {fg: $fg, bg: $bg, ul: $ul} => { $"(do $get_or_return $fg),(do $get_or_return $bg),(do $get_or_return $ul)" },
        {fg: $fg, bg: $bg} => { $"(do $get_or_return $fg),(do $get_or_return $bg)" },
        {fg: $fg} => (do $get_or_return $fg)
    })
    let col = ($color | match $in {
        {attr: $attr} => $"($col)+($attr)"
        _ => $col
    })
    $col
}
$tbl | each {|face| $"face ($face.scope) ($face.name) (do $color2string $face.colors)" } | to text
'
}
