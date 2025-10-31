# BannerCarousel iOS App

## 📖 專案概述

BannerCarousel 是一個採用 **Swift 5**、**UIKit** 和 **MVC 架構**開發的 Banner 輪播元件。

**開發環境**: iOS 12.0+ | Swift 5.0+ | Xcode 12.0+

---

### 🏗️ 架構設計

```
┌─────────────────────────────────────────────────────────┐
│                    ViewController                        │  ← 主控制器
│  - 整合 BannerCarouselView                               │
│  - 處理生命週期                                          │
└────────────────┬────────────────────────────────────────┘
                 │
        ┌────────▼───────────────────────────────────┐
        │      BannerCarouselView (主視圖)            │
        │  - titleLabel                               │
        │  - scrollView (UIScrollView)                │
        │  - pageControl                              │
        │  - autoScrollTimer                          │
        └─────┬──────────┬────────────┬──────────────┘
              │          │            │
       ┌──────▼──┐  ┌───▼─────┐ ┌───▼──────────┐
       │DataManager │ImageCache│  │ AsyncImageView │ (多個)
       │(單例)     ││ Manager  │  │- 非同步載入     │
       │- JSON載入 ││(單例)    │  │- 顯示狀態       │
       └──┬────────┘└──────────┘  └────────────────┘
          │
    ┌─────▼──────────────────────┐
    │  BannerDataModel           │
    │  - BannerData (Codable)    │
    │  - TagInfo                 │
    │  - DraftInfo               │
    └────────────────────────────┘
```

### 🔧 設計模式應用

| 模式 | 應用場景 | 檔案位置 |
|-----|---------|---------|
| **Singleton** | DataManager、ImageCacheManager | DataManager.swift:50, AsyncImageView.swift:288 |
| **MVC** | 視圖/控制器/模型分離 | 整體架構 |
| **Delegate** | UIScrollViewDelegate 處理滾動事件 | BannerCarouselView.swift:561-600 |
| **Observer** | NotificationCenter 監聽生命週期 | BannerCarouselView.swift:116-176 |

---


### 資料流程

```
JSON 檔案 (測驗資料.json)
    ↓
DataManager.loadBannerData()           [背景執行緒載入]
    ↓
JSONDecoder.decode(BannerData.self)    [主執行緒解析]
    ↓
DataFilter.filterDraftData()           [依 TagNo 篩選]
    ↓
BannerCarouselView.configureBanner()   [建立 UI]
    ↓
AsyncImageView.loadImage()             [非同步載入圖片]
    ↓
ImageCacheManager.setImage()           [快取管理]
```




#### 三頁面無限滾動 (BannerCarouselView.swift:426-450)

**核心概念**：
```swift
// 原始資料: [A, B, C, D]
// 擴展資料: [D] + [A, B, C, D] + [A]
//           ↑    ←實際內容→    ↑
//        前置複製             後置複製
```

**實作邏輯** (`setupInfiniteScrollItems()`):
```swift
if bannerItems.count == 1 {
    extendedBannerItems = bannerItems  // 單項不需要無限滾動
} else {
    extendedBannerItems = []
    extendedBannerItems.append(bannerItems.last!)   // 前置
    extendedBannerItems.append(contentsOf: bannerItems)  // 內容
    extendedBannerItems.append(bannerItems.first!)  // 後置
}
```

**邊界處理** (`handleInfiniteScrollBoundary()`):
- 滾動到索引 0（前置複製）→ 無動畫跳轉到實際最後項
- 滾動到索引 N+1（後置複製）→ 無動畫跳轉到實際第一項

---


## 👨‍💻 作者

**Howard Lee** - [GitHub](https://github.com/haoworld886)

---


