# mizchi/kagura_platform

各プラットフォーム実装が従う共通 contract。`platform/` 直下を独立した
MoonBit module として配布します。OS・DOM・GPU API を直接呼びません。

- `PlatformDriver`: 初期化、イベント、入力、ウィンドウ状態の契約。
  `pub(open)` とし、別 module でも実装できるようにします。
- `WindowOptions` / `MonitorInfo` / cursor・fullscreen の状態: 共通 API の型。
- `WebCanvasHooks` / `DesktopNativeHooks`: host を注入する型付き境界。
- `WebCanvasPlatform` / `DesktopGlfwPlatform`: hook を呼ぶ既存の shell。
  ともに `PlatformDriver` と `mizchi/gfx.SurfaceProvider` を実装します。
  未注入時の決定的な fallback はテスト・headless 用です。

## 依存方向

```text
platform_web ──→ platform ──→ kagura_core / gfx
                    ↑
                  engine
```

実装は `platform_<target>/`、配布名は `mizchi/kagura_platform_<target>` とします。
現在の JS 実装は `platform_web/`。contract は実装を import せず、実装同士も
依存させません。新しい実装はこの contract と共有のライフサイクル検証に従います。
型の変更は先に contract で定義し、実装で独自の入力・ウィンドウ型を増やしません。

`platform_web/runtime_hooks/` とトップレベルの `platform_native/` は独立した既存 module です。
描画・音声・フォントと host を結線するため engine に依存する起動時の統合層で、
この contract の配布内容には含めません。JS の platform hook は `platform_web` の
公開 API を通し、native は `DesktopNativeHooks` に従って注入します。
native の既存 import 名は `mizchi/native_runtime_hooks` です。

`just platform-test` で共通契約と JS adapter、配布の分離、依存方向を検証します。
`just check-release` は全 release module の境界を検査します。
