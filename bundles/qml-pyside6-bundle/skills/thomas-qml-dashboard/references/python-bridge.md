# Python Bridge Reference (PySide6 → QML)

No C++. All backend exposure uses PySide6 mechanisms.

---

## Exposing a Python Object to QML

### Method 1: Required Property (preferred for new code)

```python
# Python
from PySide6.QtCore import QObject, Signal, Property, Slot

class Backend(QObject):
    countChanged = Signal()

    def __init__(self):
        super().__init__()
        self._count = 0

    @Property(int, notify=countChanged)
    def count(self):
        return self._count

    @Slot()
    def increment(self):
        self._count += 1
        self.countChanged.emit()

backend = Backend()
engine.setInitialProperties({"backend": backend})
engine.load("qrc:/ui/main.qml")
```

```qml
// QML root
ApplicationWindow {
    required property Backend backend

    Label { text: "Count: " + backend.count }
    Button { onClicked: backend.increment() }
}
```

### Method 2: Context Property (fine for existing code)

```python
engine.rootContext().setContextProperty("backend", backend)
```

```qml
// Available globally — no required property declaration needed
Label { text: backend.count }
```

---

## @Slot Rules

**`@Slot` is mandatory for any Python method callable from QML.**
Missing it causes `TypeError` at runtime — no other error clue is given.

```python
@Slot()                          # no args, no return
def reset(self): ...

@Slot(str)                       # one arg
def setName(self, name: str): ...

@Slot(str, result=str)           # arg + return type
def greet(self, name: str) -> str:
    return f"Hello, {name}!"

@Slot(int, bool)                 # multiple args
def setItem(self, index: int, enabled: bool): ...
```

---

## @Property Rules

Properties exposed to QML must have a `notify` signal for QML to react to changes.

```python
nameChanged = Signal()

@Property(str, notify=nameChanged)
def name(self):
    return self._name

@name.setter
def name(self, value):
    if self._value != value:
        self._name = value
        self.nameChanged.emit()
```

Without `notify`, QML reads the value once at binding time and never updates.

---

## Registering a Python Class as a QML Type

Use `@QmlElement` when QML should instantiate the class directly:

```python
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "com.myapp.backend"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class ConnectionModel(QObject):
    ...
```

```qml
import com.myapp.backend 1.0

ConnectionModel { id: connModel }
```

---

## Connecting QML Signals to Python Slots

```python
# After engine.load()
root = engine.rootObjects()[0]
root.someSignal.connect(backend.on_some_signal)
```

---

## Threading Rules

- Emit signals only from the main thread (or use `QMetaObject.invokeMethod` with `Qt.QueuedConnection` from worker threads)
- Never block the main thread — use `QThread` or `asyncio` integration for heavy work
- No blocking IO in `@Slot` handlers

---

## Common Errors

| Symptom | Cause | Fix |
|---|---|---|
| `TypeError` calling Python from QML | Missing `@Slot` | Add `@Slot(...)` decorator |
| Property not updating in QML | Missing `notify` signal | Add `notify=xyzChanged` to `@Property` |
| `engine.rootObjects()` is empty | QML load failure | Check console for QML parse error |
| Signal fires but QML doesn't update | Wrong thread | Emit from main thread |

---

## Entry Point Bootstrap

```python
# __main__.py
import sys
from pathlib import Path
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    engine.setInitialProperties({"backend": backend})

    qml_file = Path(__file__).parent / "ui" / "main.qml"
    engine.load(str(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
```
