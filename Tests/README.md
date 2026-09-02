# Manual Service harnesses

There is no XCTest target. These are small command-line tools for exercising
DemoMonkey's macOS Services without driving iTerm by hand, plus fixtures for the
two document file formats.

```sh
Tests/build.sh                  # compiles into Tests/build/
Tests/run-service-checks.sh     # end-to-end checks against the built app
```

`run-service-checks.sh` drives the real application: it needs a GUI session,
quits and relaunches DemoMonkey several times, and temporarily writes the
`defaultLineEnding` preference. It exits non-zero on failure.

## Tools

- **`svc`** — invoke a Service by name and print what came back, with `<CR>` and
  `<LF>` made visible. Without input text it leaves the pasteboard empty first,
  so anything read back demonstrably came from the app. Getting this wrong is
  easy: seeding the pasteboard and then reading it back looks like success.
- **`gendoc`** — fixture in the current format (dictionary root: `Steps`,
  `LineEnding`). Includes a step whose body already contains CRLF, which must
  not come back out as CR CR LF.
- **`genlegacy`** — fixture in the original format (bare array root, no
  settings), for the backward-compatibility branch in `-readFromData:`.

## What the checks cover

- The `defaultLineEnding` preference seeds a new document, and text captured by
  **Create New Step** comes back out through **Get Next Line** with that
  terminator — for all three settings.
- A document saved in the current format keeps its own `LineEnding` and the
  preference does *not* override it; a legacy file, which specifies none, takes
  the preference.

## Gotchas

`Get Next Line` needs a document with steps **and a selection**; an empty
untitled document yields no data and the Service reports an error rather than
returning an empty string. Run exactly one copy of the app — two copies fight
over the same `NSPortName` and the Service goes to whichever won registration.
