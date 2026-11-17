# html2mac

turns a folder with an `index.html` into a real mac app (own window, dock icon, menus, cmd+r reload). no electron, about 150 lines of objective-c on top of apple's webkit. the app comes out under 1 mb instead of 100+.

```sh
./build.sh "Hello" example 900 640
open build/Hello.app
```

usage: `./build.sh "<app name>" <folder> [width] [height] [icon-style]`. icon style `house` draws a house, anything else draws a tile with the first letter of the name.

needs macos 12+ and the xcode command line tools (`xcode-select --install`).

what it handles:
- window remembers size/position
- localStorage persists between launches
- normal menus + shortcuts, full screen
- alert()/confirm() become native dialogs
- external links open in your browser
- web inspector on for debugging
- icon drawn in code (`make_icon.m`) then turned into .icns

files: `WebShell.m` is the app, `make_icon.m` draws the icon, `build.sh` puts the bundle together and signs it, `example/` is a tiny test page.

i made it to run [roommies](https://github.com/sergeygruzd/roommies) as a desktop app. built with claude code.
