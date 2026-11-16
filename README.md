# html2mac

Turn a single-file web app (a folder with an `index.html`) into a **native macOS app**: its own window, Dock icon, menus and keyboard shortcuts. No Electron, no Node and no dependencies, just about 150 lines of Objective-C on Apple's built-in WebKit.

The resulting `.app` is under 1 MB (most of it is the icon), compared with 100+ MB for a typical Electron app.

## Use it

```sh
./build.sh "Hello" example 900 640
open "build/Hello.app"
```

```
./build.sh "<App Name>" <folder-with-index.html> [width] [height] [icon-style]
```

- Everything in the folder (images, CSS, JS) is bundled into the app.
- `icon-style`: `house` draws a house icon. Anything else draws a gradient tile with the app's first letter.
- Drag the result into `/Applications`.

Requires macOS 12+ and the Xcode command line tools (`xcode-select --install`).

## What the shell handles

- One resizable window that remembers its size and position, with the title and size read from `Info.plist`
- `localStorage` persists between launches, so single-file apps keep their data
- Standard menus: About, Hide, Quit, Undo/Redo, Cut/Copy/Paste, Reload (`⌘R`), Full Screen (`⌃⌘F`), Minimize, Close
- JavaScript `alert()` and `confirm()` shown as native dialogs
- External links (`target="_blank"`) open in the default browser
- Web Inspector enabled for debugging (macOS 13.3+)
- An icon drawn in code (`make_icon.m`) and converted to `.icns` with `sips` and `iconutil`
- Ad-hoc code signing so the app launches locally

## Files

| File | What it does |
|---|---|
| `WebShell.m` | The app: AppKit window plus WKWebView that loads the bundled `index.html` |
| `make_icon.m` | Draws a 1024×1024 icon PNG with Cocoa |
| `build.sh` | Compiles both, assembles the `.app` bundle, writes `Info.plist`, builds the icon set and signs |
| `example/` | A tiny demo page with a click counter that persists |

I use it to ship [Roommies](https://github.com/sergeygruzd/roommies) as a desktop app.

Built by Sergey Gruzd with Claude Code (AI pair programming).
