# Graph Report - Closet_mobile  (2026-07-18)

## Corpus Check
- 47 files · ~16,990 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 314 nodes · 399 edges · 24 communities (17 shown, 7 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `44b2c6cb`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- closet_header.dart
- sourceur_inscription_screen.dart
- labeled_field.dart
- FlutterMacOS
- my_application.cc
- closet_text_styles.dart
- AppDelegate
- closet_colors.dart
- wWinMain
- manifest.json
- widget_test.dart
- RegisterPlugins
- MainActivity
- closet
- README.md
- flutter_export_environment.sh
- Package.swift
- String?

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `MessageHandler` - 12 edges
3. `FlutterWindow` - 10 edges
4. `Create` - 10 edges
5. `WndProc` - 10 edges
6. `MessageHandler` - 9 edges
7. `_MyApplication` - 7 edges
8. `OnCreate` - 7 edges
9. `WindowClassRegistrar` - 7 edges
10. `Destroy` - 7 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.h → windows/flutter/generated_plugin_registrant.cc
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc

## Import Cycles
- None detected.

## Communities (24 total, 7 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.07
Nodes (51): Point, RECT, Size, unique_ptr, DartProject, HWND, LPARAM, LRESULT (+43 more)

### Community 1 - "closet_header.dart"
Cohesion: 0.06
Nodes (35): Color, build, ClosetBottomNav, indexActif, _items, onTap, build, ClosetOutlineButton (+27 more)

### Community 2 - "sourceur_inscription_screen.dart"
Cohesion: 0.06
Nodes (36): bool get, ../../../core/widgets/closet_bottom_nav.dart, ../../../core/widgets/closet_buttons.dart, ../../../core/widgets/closet_header.dart, _atelierController, build, _buildBoutons, _buildEtapeAtelier (+28 more)

### Community 3 - "labeled_field.dart"
Cohesion: 0.07
Nodes (29): core/theme/closet_colors.dart, ../../../../core/theme/closet_text_styles.dart, features/sourceur/inscription/sourceur_inscription_screen.dart, IconData, build, controller, hint, icone (+21 more)

### Community 4 - "FlutterMacOS"
Cohesion: 0.09
Nodes (17): Cocoa, Flutter, FlutterMacOS, FlutterPluginRegistry, FlutterSceneDelegate, FlutterViewController, Foundation, SceneDelegate (+9 more)

### Community 5 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 6 - "closet_text_styles.dart"
Cohesion: 0.12
Nodes (16): closet_colors.dart, badgePill, bouton, ClosetTextStyles, corps, corpsSurVert, labelChamp, labelEtape (+8 more)

### Community 7 - "AppDelegate"
Cohesion: 0.16
Nodes (10): Any, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, AppDelegate, Bool (+2 more)

### Community 8 - "closet_colors.dart"
Cohesion: 0.14
Nodes (13): bordure, ClosetColors, creme, dore, doreDesactive, ivoire, noir, rougeBadge (+5 more)

### Community 9 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 10 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 11 - "widget_test.dart"
Cohesion: 0.50
Nodes (3): package:closet/main.dart, package:flutter_test/flutter_test.dart, main

## Knowledge Gaps
- **113 isolated node(s):** `ClosetColors`, `noir`, `vert`, `dore`, `ivoire` (+108 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FlutterWindow` connect `Win32Window` to `FlutterMacOS`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `MessageHandler` (e.g. with `Destroy` and `GetClientArea`) actually correct?**
  _`MessageHandler` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `ClosetColors`, `noir`, `vert` to the rest of the system?**
  _113 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.06594071385359952 - nodes in this community are weakly interconnected._
- **Should `closet_header.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06258890469416785 - nodes in this community are weakly interconnected._
- **Should `sourceur_inscription_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05555555555555555 - nodes in this community are weakly interconnected._
- **Should `labeled_field.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07007575757575757 - nodes in this community are weakly interconnected._