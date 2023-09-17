# WordWize  <img src="https://img.shields.io/badge/-SwiftUI4-000.svg?logo=swift&style=flat"> <img src="https://img.shields.io/badge/-CoreData-000.svg?logo=databricks&style=flat"> <img src="https://img.shields.io/badge/-CloudKit-000.svg?logo=icloud&style=flat"> <img src="https://img.shields.io/badge/-Xcode_Cloud-000.svg?logo=xcode&style=flat"> <img src="https://img.shields.io/badge/-XCTest-000.svg?logo=testcafe&style=flat"> <img src="https://img.shields.io/badge/-MVVM-000.svg?logo=instructure&style=flat"> <img src="https://img.shields.io/badge/-Test_Code_Coverage_91%25-000.svg?logo=codecov&style=flat">
<img width="1178" alt="Screenshot 2023-09-17 at 7 48 49 AM" src="https://github.com/yazuju-musa/WordWize/assets/97211329/fa474070-a782-44b2-bdc1-d6fad48b4eac">
<br><br>

アプリの全体を簡単に理解するため、こちらに[1分程度のアプリ使用動画](https://www.youtube.com/shorts/xcPiUi_p98o)をアップロードしましたので、ぜひご覧ください。

- 辞書APIや画像APIによって定義、例文、関連画像などを含んだ単語カードを自動生成
- 忘却曲線に従って効果的な間隔でカードを復習
- 英単語を英英辞典の情報で学習ができる
- 英英辞典情報をDeepLボタンによって即座にネイティブ言語に変換可能。英英辞典が理解しづらい場合でも効率的に学習が可能!
- CoreData&CloudKitを使用しデータを保持、ログインなしで端末同士の同期も可能!

  
[App Storeはこちら](https://apps.apple.com/us/app/wordwize-vocabulary-builder/id6452391290)
<br><br>

# Testability・Scalability
以下の取り組みにより、Code Coverageは91%、高い保守性を維持。

### 1. MVVM Architecture
テストを書きづらいSwiftUIファイルから最大限にビジネスロジックを切り分け、ViewModelに移動することでUnitTestを実装。

### 2. Dependency Injection
全てのDependencyをDependency Injection Containerに格納。
View同士の依存関係を無くし、一つ一つのViewを独立化。
ViewにMock用のDependency Injection Containerをセットすることで簡単にPreview・Test用の環境をセットアップすることが可能。

[Dependency Injection Container](https://github.com/yazuju-musa/WordWize/blob/main/WordWize/Injected/DIContainer.swift)


```swift
// Mock用Dependency Injection Containerの使用例。これだけの記述で簡単にMock環境出来上がり。
#Preview {
    ContentView(container: .mock())
}
```

### 3. URLSessionのMockUp
全てのNetwork処理をNetworkServiceクラスに切り分け、そこへセットするURLSessionをMock用に切り替えることで簡単にネットワーク関連のPreview・Testを行うことが可能に。
[MockURLProtocol.swift](https://github.com/yazuju-musa/WordWize/blob/main/WordWize/Helper/MockURLProtocol.swift)

```swift
// 本番用
NetworkService(session: .shared)
// Preview・Test用
NetworkService(session: .mock)
```

### 4. ViewInspector
UITestを書くことが困難なSwiftUIを[ViewInspector Library](https://github.com/nalexn/ViewInspector)によって徹底的にUnitTestを記述することに成功。

# カード自動生成ロジック

登録情報が少ない無料の辞書API(20万単語)と、登録情報が豊富な有料の辞書API(47.5万単語)をハイブリッドに活用し、API使用料金を抑えつつ幅広い単語に対応しています。
ユーザーが数百単語、数千単語を一度にカードに変換しようとした場合でもパラレル処理によって高速でカードを生成します。

<img width="824" alt="Screenshot 2023-09-13 at 10 31 37 AM" src="https://github.com/yazuju-musa/WordWize/assets/97211329/501f1af6-7d43-4bd0-9d57-1846be5e7d97">

# 復習ロジック

覚えているカードは徐々に間隔を広げて表示し、覚えていないものを集中的に勉強できる設計にしています。
覚えていた場合は徐々に習得率が上昇し、覚えていない場合は習得率がリセットされます。

<img width="618" alt="Screenshot 2023-09-13 at 10 31 54 AM" src="https://github.com/yazuju-musa/WordWize/assets/97211329/5a5cc374-732a-406e-8c26-61a5e6e676a7">

# 実行方法
リポジトリをクローンすればそのままビルドできます。
ほとんどの機能が問題なく使えますが、API Keyが空になっているためDeepLボタンが機能しない、カード生成時対応単語数減少、画像生成不能など一部の情報が動作しません。
完全な状態で使用したい場合は[App Store](https://apps.apple.com/us/app/wordwize-vocabulary-builder/id6452391290)からのダウンロードをお願いします。

```swift
struct Keys {
    static let pixabayApiKey = ""
    static let deepLApiKey = ""
    static let merriamWebsterApiKey = ""
}
```
