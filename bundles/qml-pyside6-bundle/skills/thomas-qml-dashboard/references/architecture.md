# Architecture Reference

## Layer Overview

```
QML UI (pure presentation)
    ↓ signals / properties
Python Backend (PySide6)
    ↓ @Slot / @Property / Signal
Business logic & data
```

UI never touches business logic directly. All cross-boundary communication goes through the Python bridge layer.

---

## Main Window Structure

```
ApplicationWindow
└── ColumnLayout (fills window)
    ├── TabBar (fixed height, row 1)
    └── RowLayout (fills remaining, row 2)
        ├── Sidebar (animated width)
        └── StageArea (fills remaining width)
```

---

## WidgetContent Interface

Every widget content component must expose these properties and signals:

```qml
// Interface contract — implement in each WidgetContent component
property string widgetTitle       // displayed in header
property color  accentColor       // header accent / border
property int    badgeStatus       // 0=none, 1=info, 2=warn, 3=error
property list<QtObject> footerActions  // ActionDescriptor instances
property int    minWidth
property int    maxWidth
property int    minHeight
property int    maxHeight

signal requestClose()
signal requestCollapse()
```

The shell reads these via property aliases — it does **not** know the widget type.

---

## WidgetShell

Owns the visual chrome (header + footer + content slot). The `content` property accepts any `WidgetContent` implementor.

```qml
WidgetShell {
    content: ConnectionWidget { }  // injected
}
```

**Shell responsibilities:**
- Render `WidgetHeader` with title, status badge, collapse/close buttons
- Render `WidgetFooter` with action buttons from `content.footerActions`
- Proxy `requestClose` / `requestCollapse` signals from content
- Register/unregister self with `WorkspaceStore` on creation/destruction

**Shell does NOT:**
- Know widget business logic
- Hold widget state (state lives in `WorkspaceStore` child instances)

---

## Widget Modes

```qml
// BaseWidget has:
property string mode: "floating"   // or "snapped"
```

- `"floating"` — free positioning in StageArea
- `"snapped"` — docked to sidebar or grid

---

## WorkspaceStore Singleton

Owns all widget instances so state survives shell destruction.

```qml
// Registration (in WidgetShell)
Component.onCompleted: WorkspaceStore.registerWidget(widgetId, this)
Component.onDestruction: WorkspaceStore.unregisterWidget(widgetId)

// Broadcast
WorkspaceStore.broadcastEvent("themeChanged", { theme: "dark" })
```

---

## State Ownership: Python, not QML

All persistent or shareable state lives in Python and is injected into QML.
QML binds reactively; it never owns the source of truth for workspace data.

**Typical Python-side responsibilities:**
- Tab list and active tab tracking
- Per-widget state: coordinates, snap/unsnap, collapsed, active tool and its state
- Sidebar collapsed state
- Workspace serialization for save/export/share

**Python model exposure** — exact class structure depends on the existing codebase,
but injection follows the patterns in `references/python-bridge.md`.

QML consumes these via `required property var modelName` or context properties,
and calls `@Slot` methods to request mutations — never writes to Python properties directly.

---

## Tab System

- Tabs are keyed by stable incrementing integer IDs
- ID increments monotonically — never reuse an ID after tab close
- Active tab tracking lives in the Python workspace model
- QML `StackLayout` (or equivalent) switches view by reading the active ID from the model

---

## File Association (planned)

Custom `.mws` extension for workspace export. OS-level registration planned — not yet implemented.
Register via Python at app startup using platform-specific mechanisms.
