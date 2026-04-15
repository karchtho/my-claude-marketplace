---
name: thomas-qml-dashboard
description: >
  QML + PySide6 guidance for Thomas's widget-based desktop dashboard application.
  Use this skill whenever working on QML components, the theme system, sidebar,
  tab management, widget shell/content architecture, workspace state, Flickable
  scrolling, or the Python-to-QML bridge. Trigger on any mention of: QML,
  WidgetShell, WidgetContent, WorkspaceStore, Theme singleton, BaseWidget, sidebar,
  collapsible, accordion, snapped/floating mode, design tokens, qmldir,
  Qt.labs.settings, injected Python model, QAbstractListModel, app_settings,
  workspace_model, or PySide6 @Slot/@Property patterns. Also trigger when
  generating new QML components, writing signal/slot connections, binding to
  injected Python objects, or debugging property binding issues in this project.
---

# Thomas QML Dashboard Skill

Desktop dashboard — Qt 6 / QML front-end, Python (PySide6) back-end.
No C++. No CMake. Pure QML + Python.

Read this file first. Reference files are in `references/` — load them on demand.

---

## Project Overview

Widget-based dashboard with:
- Animated collapsible sidebar
- Tabbed workspace (tabs keyed by stable incrementing integer IDs)
- Stage area hosting `WidgetShell` instances
- Two widget modes: `"floating"` and `"snapped"`
- Four themes: `dark`, `cool_grey`, `warm_stone`, `blueprint`

**Architecture document**: see `references/architecture.md`  
**Theme system**: see `references/theme-system.md`  
**Python bridge patterns**: see `references/python-bridge.md`

---

## QML Property Ordering Convention

Always follow this order inside any QML component:

```
id
geometry (width, height, anchors, Layout.*)
custom properties
aliases
signals
functions
child items / visual tree
Connections {}
Component.onCompleted {}
```

---

## Code Style Rules

- `snake_case` for token names, `camelCase` for QML properties and IDs, `PascalCase` for component file names
- No alignment spacing (don't pad `=` signs to line up columns)
- Prefer declarative bindings over imperative assignments in `Component.onCompleted`
- Use explicit types, not `var`, for all property declarations
- Ternary for conditional values on a single line: `width: collapsed ? 40 : 220`

---

## Component Generation

When generating a new QML component:

1. Determine the type: `Item` (visual), `QtObject` (logic/state), or `Control` (interactive)
2. Apply the property ordering convention above
3. For widgets: implement the `WidgetContent` interface (see `references/architecture.md`)
4. For singletons: declare in `qmldir` as `singleton Name 1.0 Name.qml`
5. No C++ registration — Python bridge via `@QmlElement` or `setContextProperty`

### Component type cheat sheet

| Use case | Base type |
|---|---|
| Visual container, layout | `Item` |
| Clickable control | `Rectangle` + `MouseArea` (custom) or `Control` |
| Shared state / store | `QtObject` (singleton) |
| Widget content | `Item` implementing `WidgetContent` interface |
| Widget shell | `Item` owning header + footer + content slot |
| Action descriptor | `QtObject` (not plain JS object) |

---

## Singleton Pattern

```qml
// MySingleton.qml
pragma Singleton
import QtQuick

QtObject {
    id: root
    // ...
}
```

```
# qmldir
singleton MySingleton 1.0 MySingleton.qml
```

Access everywhere as `MySingleton.propertyName` — no import alias needed if in the same module.

---

## Common Binding Patterns

**Animated width (sidebar collapse):**
```qml
property bool collapsed: false

width: collapsed ? 40 : 220
Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
```

**Dynamic padding from collapse state:**
```qml
width: contentRow.implicitWidth + (collapsed ? Theme.active.spacing_xs : Theme.active.spacing_xl)
```

**Mirrored icon (collapse arrow):**
```qml
Image {
    mirror: !sidebar.collapsed
    source: "qrc:/icons/arrow_left.svg"
}
```

**Accordion height toggle:**
```qml
property bool expanded: false
height: expanded ? contentCol.implicitHeight : 0
clip: true
Behavior on height { NumberAnimation { duration: 150 } }
```

---

## Scrollable Content

Always use `Flickable` directly — not `ScrollView` — so scrollbar behavior stays explicit.

```qml
Flickable {
    anchors.fill: parent
    contentHeight: innerColumn.implicitHeight
    clip: true

    Column {
        id: innerColumn
        width: parent.width
        // items here
    }

    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
}
```

**Do not** set a hardcoded `implicitHeight` on the `contentItem`. Drive `contentHeight` from the layout's `implicitHeight`.

---

## Theme System (quick ref)

Full detail: `references/theme-system.md`

```qml
// Access tokens
color: Theme.active.color_surface
font.pixelSize: Theme.active.type_body_size

// Switch theme
Theme.setTheme("dark")  // validated before applying
```

```qml
// Avoid dark flash on launch (main.qml)
ApplicationWindow {
    id: root
    visible: false  // hidden until theme is restored

    Component.onCompleted: {
        Theme.setTheme(settings.theme)
        root.visible = true
    }
}
```

---

## State: Python Models Injected into QML

State is **not** managed by QML singletons. It lives in Python and gets injected.
QML is a pure presentation layer — it binds to what Python exposes.

The exact object structure depends on the existing Python codebase (TBD), but the
binding pattern is always the same:

```qml
// QML root receives injected objects
ApplicationWindow {
    required property var appSettings    // e.g. theme, window prefs
    required property var workspaceModel // e.g. tabs, widgets, drag state
}
```

```qml
// Bind to injected model properties reactively
Text { text: workspaceModel.activeTabName }
Rectangle { color: workspaceModel.sidebarCollapsed ? "#111" : "#222" }

// Call slots to mutate state — never write to Python properties directly from QML
Button { onClicked: workspaceModel.closeTab(tabId) }
```

**What typically lives in Python state (not QML):**
- Tab list and active tab
- Per-widget: coordinates, snap state, collapsed, active tool, tool state
- Sidebar collapsed state (needs persistence)
- Workspace export / share data

**What can stay local in QML:**
- Hover/focus/pressed visual states
- Animation intermediate values
- Ephemeral UI-only toggles with no persistence requirement

Full injection patterns: `references/python-bridge.md`  
Workspace state responsibilities: `references/architecture.md`

---

## Signals & Connections

```qml
// Define in child
signal requestClose()

// Handle in parent with Connections
Connections {
    target: someChild
    function onRequestClose() { /* ... */ }
}
```

`ActionDescriptor` must be `QtObject`, not a plain JS object, to support reactive bindings:

```qml
property list<QtObject> footerActions: [
    QtObject {
        property string label: "Save"
        property bool enabled: true
        signal triggered()
    }
]
```

---

## Anti-Patterns to Avoid

| Anti-pattern | Fix |
|---|---|
| `anchors.*` on direct `Layout` children | Use `Layout.*` attached properties |
| `ScrollView` when scrollbar control matters | Use `Flickable` + explicit `ScrollBar` |
| Plain JS object for `ActionDescriptor` | Use `QtObject` |
| Hardcoded `implicitHeight` on `contentItem` | Drive from layout's `implicitHeight` |
| `Component.onCompleted: someBinding = value` | Use declarative binding |
| `var` for property type | Use explicit type (`int`, `string`, `color`, etc.) |
| C++ `QML_ELEMENT` registration | Use PySide6 `@QmlElement` or `setContextProperty` |

---

## Reference Files

Load these on demand — don't load all at once:

- `references/architecture.md` — Widget architecture, WidgetShell/WidgetContent interface, WorkspaceStore, tab system, widget modes
- `references/theme-system.md` — Full token system, four themes, persistence, dark-flash fix
- `references/python-bridge.md` — PySide6 `@Slot`, `@Property`, `@QmlElement`, signal/slot wiring from Python to QML
