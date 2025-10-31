# BannerCarousel iOS App

## 📖 專案概述

BannerCarousel 是一個採用 **Swift 5**、**UIKit** 和 **MVC 架構**開發的 Banner 輪播元件。這個專案展示了現代 iOS 開發的最佳實踐，包含無限輪播、圖片快取、非同步載入等功能。

**開發環境**: iOS 12.0+ | Swift 5.0+ | Xcode 12.0+

## ✨ 主要功能

- 🔄 **無限輪播**: 實現流暢的三頁面無限滾動效果
- 🖼️ **智慧圖片載入**: 非同步載入圖片，支援快取機制
- ⏰ **自動輪播**: 支援自動定時切換，並可手動控制
- 🎯 **生命週期管理**: 完整處理應用程式前景/背景切換
- 📱 **響應式設計**: 支援不同螢幕尺寸和方向
- 🔍 **資料過濾**: 根據標籤動態過濾顯示內容

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

## 🚀 快速開始

### 安裝步驟

1. **Clone 專案**
   ```bash
   git clone https://github.com/haoworld886/BannerCarouselTest.git
   cd BannerCarouselTest
   ```

2. **開啟專案**
   ```bash
   open BannerCarousel.xcodeproj
   ```

3. **選擇目標裝置並執行**
   - 選擇模擬器或實體裝置
   - 按 `Cmd + R` 執行專案

### 基本使用

```swift
// 建立 BannerCarouselView
let bannerView = BannerCarouselView()
view.addSubview(bannerView)

// 載入資料並開始輪播
bannerView.loadBannerData()

// 控制輪播
bannerView.startAutoScroll()  // 開始自動輪播
bannerView.stopAutoScroll()   // 停止自動輪播
```

---



## 👨‍💻 作者

**Howard Lee** - [GitHub](https://github.com/haoworld886)

---


