# pip-exercise

Some examples for iOS Picture-in-Picture.

| pip-basic | pip-custom | pip-camera | pip-performance |
|:---:|:---:|:---:|:---:|
| <kbd><img src="https://user-images.githubusercontent.com/5572875/185188288-109215dd-b2b0-486c-bdff-808e17ec5cfd.gif" width="250"></kbd> | <kbd><img src="https://user-images.githubusercontent.com/5572875/185188620-e38b4cbb-a8e8-408e-a24b-e057156d16ae.gif" width="250"></kbd> | <kbd><img src="https://user-images.githubusercontent.com/5572875/187035872-6b8e9167-4bcf-4e24-b857-088c9354aa10.gif" width="250"></kbd> | <kbd><img src="https://user-images.githubusercontent.com/5572875/185191996-08f7bf12-c45c-4799-9f4f-906a5c60d979.gif" width="250"></kbd> |

## Examples

- [pip-basic](https://github.com/naru-jpn/pip-exercise/examples/pip-basic)
   - `AVPlayerLayer` を使ったシンプルな PiP の実装
- [pip-custom](https://github.com/naru-jpn/pip-exercise/examples/pip-custom)
   - `AVSampleBufferDisplayLayer` を使った pip-basic よりも自由度の高い PiP の実装
- [pip-camera](https://github.com/naru-jpn/pip-exercise/examples/pip-camera)
   - `AVSampleBufferDisplayLayer` を使ったカメラからの入力を使用した PiP の実装
   - _カメラからの入力はアプリがバックグラウンド状態の期間は停止します_
- [pip-performance](https://github.com/naru-jpn/pip-exercise/examples/pip-performance)
   - `CMSampleBuffer` を使ったレンダリングに関係する処理のパフォーマンス計測

## Links

- [iOSDC Japan 2022 PiPを応用した配信コメントバー機能の開発秘話と技術の詳解](https://fortee.jp/iosdc-japan-2022/proposal/f9ec6cc3-bc06-4749-a6b4-a472b9234684)
