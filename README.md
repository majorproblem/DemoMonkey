# DemoMonkey

## Description

DemoMonkey is a document-based macOS application that acts as a "typing
assistant". Each document holds an ordered collection of text snippets; a macOS
Service pulls the "next line" from the frontmost document onto the pasteboard, so
you can feed canned commands or text into any other application without switching
windows.

It demonstrates the pasteboard and Services APIs, and uses Cocoa Bindings
together with an `NSArrayController` subclass for drag-and-drop reordering.

Originally an Apple sample (circa 2009–2010, targeting "Mac OS X v10.6 and
later"); this copy has been manually retargeted to build and run on current
Xcode and macOS.

## Build Requirements

- A current version of Xcode. A full Xcode install is required — the standalone
  Command Line Tools are not enough, because the `.xib` files are compiled with
  `ibtool` at build time.
- **No package manager.** There are no CocoaPods, Swift Package Manager, or
  Carthage dependencies; the only frameworks used are Cocoa / AppKit /
  Foundation.
- The project builds against whichever macOS SDK is installed locally.
  `MACOSX_DEPLOYMENT_TARGET` is set to `14.6` in
  `DemoMonkey.xcodeproj/project.pbxproj`; adjust it to match the systems you
  need to support.
- The code uses **manual reference counting (MRC)**, not ARC — `retain` /
  `release` / `dealloc` are explicit throughout. Do not enable ARC.
- Interface files are Interface Builder **`.xib`** source files under
  `English.lproj/` (`Display`, `Edit`, `MainMenu`, `Preferences`). The original
  compiled `.nib` bundles have been removed; edit the `.xib` files in Xcode's
  Interface Builder.

Build in Xcode (open `DemoMonkey.xcodeproj`, then **Product ▸ Build**), or from
the command line:

```sh
xcodebuild -project DemoMonkey.xcodeproj -target DemoMonkey -configuration Debug build
```

There is no test target and no continuous-integration configuration, so there is
nothing to run for `test` or `lint`.

## Runtime Requirements

macOS 14.6 or later, matching the project's deployment target. To run on an
earlier macOS, lower `MACOSX_DEPLOYMENT_TARGET` and rebuild.

## Packaging List

### Model

- **`Step.{h,m}`** — one text snippet (`body`, `tableSummary`, `tooltip`).
  Conforms to `NSCoding`, `NSPasteboardReading`, and `NSPasteboardWriting` so
  instances can be archived and copied / dragged to and from other apps.

### Document and controllers

- **`MyDocument.{h,m}`** — `NSDocument` subclass. Owns the `steps` array,
  exposes KVC/KVO-compliant array accessors for the bound array controllers, and
  provides the Service entry points, which it forwards to the display
  controller. Manages a `DisplayController` and, lazily, an `EditController`.
- **`DisplayController.{h,m}`** — the read-only presentation window; a table
  view bound to an `NSArrayController`, tracking a "current row" for the
  Services flow.
- **`EditController.{h,m}`** — the editable window for adding, removing,
  reordering, editing, and pasting snippets.
- **`DMKArrayController.{h,m}`** — `NSArrayController` subclass backing the Edit
  table; implements table-view drag-and-drop reordering.
- **`AppDelegate.{h,m}`** — registers the app as the Services provider and
  routes Service requests to the current main document; also manages the
  application's preferences and the Preferences window.

### Resources

- **`English.lproj/{Display,Edit,MainMenu,Preferences}.xib`** — Interface
  Builder files.
- **`DemoMonkey.icns`** — application icon (referenced by `CFBundleIconFile`).
- **`Info.plist`** — bundle info, document type, and the `NSServices`
  declarations.

## Revision History

- **1.1-fork.1** — Fork. Retargeted for current Xcode / macOS (deployment
  target 14.6); `.nib` → `.xib`; added app icon; main-window list column now
  tracks the window width.
- **1.1** — Cleaned up comments and log statements; revised initializers.
  *(Apple)*
- **1.0** — First version. *(Apple)*

---

Portions Copyright © 2009–2010 Apple Inc. All rights reserved. Later
modifications for modern toolchains by the repository maintainer.
