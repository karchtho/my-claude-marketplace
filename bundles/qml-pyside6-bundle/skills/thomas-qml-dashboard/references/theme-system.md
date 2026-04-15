# Theme System Reference

## Four Themes

`dark` | `cool_grey` | `warm_stone` | `blueprint`

---

## Singleton Declaration

```
# qmldir
singleton Theme 1.0 Themes.qml
```

```qml
// Themes.qml
pragma Singleton
import QtQuick
import Qt.labs.settings

QtObject {
    id: root

    property string current: "dark"
    readonly property var active: palette[current]

    function setTheme(name) {
        if (palette[name] !== undefined) {
            current = name
        }
    }

    readonly property var palette: ({
        "dark": darkTokens,
        "cool_grey": coolGreyTokens,
        "warm_stone": warmStoneTokens,
        "blueprint": blueprintTokens
    })

    // Token objects defined below...
}
```

---

## Token Naming Convention

All tokens use `snake_case`. Categories:

| Category | Example token |
|---|---|
| Colors | `color_surface`, `color_on_surface`, `color_primary`, `color_border` |
| Typography size | `type_body_size`, `type_label_size`, `type_heading_size` |
| Typography family | `type_family_base`, `type_family_mono` |
| Spacing | `spacing_xs`, `spacing_sm`, `spacing_md`, `spacing_lg`, `spacing_xl`, `spacing_xxl` |
| Border | `border_radius_sm`, `border_radius_md`, `border_width` |
| Opacity (states) | `opacity_disabled`, `opacity_hover` |

---

## Usage in QML

```qml
// Colors
color: Theme.active.color_surface
border.color: Theme.active.color_border

// Typography
font.family: Theme.active.type_family_base
font.pixelSize: Theme.active.type_body_size

// Spacing
padding: Theme.active.spacing_md
```

---

## Theme Persistence

```qml
// In Themes.qml
Settings {
    id: settings
    property string theme: "dark"
    Binding { target: settings; property: "theme"; value: root.current }
}

Component.onCompleted: {
    root.current = settings.theme
}
```

---

## Dark Flash Fix

The window must start hidden and become visible only after the theme is restored:

```qml
// main.qml
ApplicationWindow {
    id: root
    visible: false   // NOT true at declaration time

    Component.onCompleted: {
        Theme.setTheme(savedTheme)  // restore persisted theme
        root.visible = true         // only then show
    }
}
```

This prevents the default theme flashing briefly before the persisted one applies.

---

## Design Token Values (reference)

### Dark theme (primary)
```
color_background:   #0d0d1a
color_surface:      #1a1a2e
color_surface_alt:  #16213e
color_primary:      #4a4aba
color_on_primary:   #ffffff
color_border:       #2a2a4a
color_on_surface:   #e0e0f0
color_on_surface_muted: #8888aa
```

### Typography
```
type_family_base:   "Roboto"
type_family_mono:   "Roboto Mono"
type_heading_size:  18
type_body_size:     13
type_label_size:    11
```

### Spacing scale
```
spacing_xs:  4
spacing_sm:  8
spacing_md:  12
spacing_lg:  16
spacing_xl:  24
spacing_xxl: 32
```
