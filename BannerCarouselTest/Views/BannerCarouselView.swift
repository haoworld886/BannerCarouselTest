//
//  BannerCarouselView.swift
//  BannerCarousel
//
//  主要的 Banner 輪播視圖元件
//

import UIKit

// MARK: - Banner 輪播視圖
/// 主要的 Banner 輪播視圖元件，提供自動輪播和手勢互動功能
class BannerCarouselView: UIView {
    
    // MARK: - UI 元件
    /// 標題標籤
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 主要滾動視圖
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    /// 頁面指示器
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - 屬性
    /// 輪播項目資料
    private var bannerItems: [DraftInfo] = []
    
    /// 自動滾動計時器
    private var autoScrollTimer: Timer?
    
    /// 當前頁面索引（實際資料索引）
    private var currentIndex: Int = 0
    
    /// 自動滾動間隔（秒）
    private let autoScrollInterval: TimeInterval = 5.0
    
    /// 無限滾動相關屬性
    /// 擴展後的輪播項目（用於無限滾動）
    private var extendedBannerItems: [DraftInfo] = []
    
    /// 是否正在程式化滾動（避免在自動滾動時觸發手動滾動邏輯）
    private var isProgrammaticScrolling: Bool = false
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupNotifications()
    }
    
    // MARK: - 生命週期
    override func layoutSubviews() {
        super.layoutSubviews()
        // 當佈局改變時，重新設定滾動視圖內容
        updateScrollViewLayout()
    }
    
    deinit {
        // 清理計時器和通知
        stopAutoScroll()
        removeNotifications()
    }
}

// MARK: - UI 設定
private extension BannerCarouselView {
    
    /// 設定 UI 元件和約束
    func setupUI() {
        backgroundColor = .white
        
        // 加入子視圖
        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(pageControl)
        
        // 設定滾動視圖委託
        scrollView.delegate = self
        
        // 設定頁面指示器點擊事件
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        
        // 設定約束
        setupConstraints()
    }
    
    /// 設定應用程式生命週期通知
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    /// 移除通知觀察者
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 設定 Auto Layout 約束
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // 標題標籤約束
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // 滾動視圖約束
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: 180),
            
            // 頁面指示器約束
            pageControl.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    /// 更新滾動視圖佈局
    func updateScrollViewLayout() {
        guard !extendedBannerItems.isEmpty else { return }
        
        // 設定滾動視圖內容大小（使用擴展後的項目數量）
        let contentWidth = scrollView.frame.width * CGFloat(extendedBannerItems.count)
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
        
        // 設定初始位置到第一個實際項目（索引 1，因為索引 0 是最後一個項目的複製）
        if bannerItems.count > 1 {
            let initialOffsetX = scrollView.frame.width
            scrollView.setContentOffset(CGPoint(x: initialOffsetX, y: 0), animated: false)
        }
    }
}

// MARK: - 應用程式生命週期處理
private extension BannerCarouselView {
    
    /// 應用程式即將進入非活躍狀態
    @objc func applicationWillResignActive() {
        stopAutoScroll()
    }
    
    /// 應用程式變為活躍狀態
    @objc func applicationDidBecomeActive() {
        // 延遲一點時間再啟動，確保 UI 已經準備好
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.startAutoScroll()
        }
    }
    
    /// 應用程式進入背景
    @objc func applicationDidEnterBackground() {
        stopAutoScroll()
    }
    
    /// 應用程式即將進入前景
    @objc func applicationWillEnterForeground() {
        // 在 applicationDidBecomeActive 中處理啟動
    }
}

// MARK: - 公開方法
extension BannerCarouselView {
    
    /// 載入 Banner 資料並開始輪播
    func loadBannerData() {
        DataManager.shared.loadBannerData { [weak self] result in
            switch result {
            case .success(let bannerData):
                self?.configureBanner(with: bannerData)
            case .failure(let error):
                print("載入 Banner 資料失敗: \(error.localizedDescription)")
                // 這裡可以顯示錯誤狀態或預設內容
            }
        }
    }
    
    /// 開始自動輪播
    func startAutoScroll() {
        stopAutoScroll() // 先停止現有計時器
        
        guard bannerItems.count > 1 else { return } // 只有一個項目時不需要自動輪播
        
        // 確保在主執行緒上建立計時器
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.autoScrollTimer = Timer.scheduledTimer(withTimeInterval: self.autoScrollInterval, repeats: true) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.scrollToNextPage()
                }
            }
            
            // 將計時器加入到 RunLoop 中，確保在滾動時也能正常運作
            if let timer = self.autoScrollTimer {
                RunLoop.current.add(timer, forMode: .common)
            }
        }
    }
    
    /// 停止自動輪播
    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    /// 重新啟動自動輪播（用於使用者互動後）
    func restartAutoScroll() {
        // 延遲一點時間再重新啟動，避免與使用者互動衝突
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startAutoScroll()
        }
    }
    
    /// 檢查自動輪播是否正在運行
    var isAutoScrolling: Bool {
        return autoScrollTimer != nil && autoScrollTimer!.isValid
    }
    
    /// 滾動到指定頁面
    /// - Parameters:
    ///   - index: 目標頁面索引
    ///   - animated: 是否使用動畫
    func scrollToPage(_ index: Int, animated: Bool = true) {
        guard index >= 0 && index < bannerItems.count else { return }
        
        stopAutoScroll()
        isProgrammaticScrolling = true
        
        // 計算目標位置（在擴展陣列中的位置）
        let targetScrollIndex = bannerItems.count > 1 ? index + 1 : index
        let offsetX = scrollView.frame.width * CGFloat(targetScrollIndex)
        
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
        
        // 更新當前索引和頁面指示器
        currentIndex = index
        pageControl.currentPage = index
        
        // 如果沒有動畫，立即重新啟動自動滾動
        if !animated {
            isProgrammaticScrolling = false
            restartAutoScroll()
        }
    }
    
    /// 頁面指示器點擊事件處理
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let targetPage = sender.currentPage
        scrollToPage(targetPage, animated: true)
        
        // 提供觸覺回饋（iOS 10+）
        if #available(iOS 10.0, *) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    /// 手動滾動到上一頁
    func scrollToPreviousPage() {
        let previousIndex = currentIndex > 0 ? currentIndex - 1 : bannerItems.count - 1
        scrollToPage(previousIndex, animated: true)
    }
    
    /// 手動滾動到下一頁（公開方法）
    func scrollToNextPageManually() {
        let nextIndex = (currentIndex + 1) % bannerItems.count
        scrollToPage(nextIndex, animated: true)
    }
}

// MARK: - 私有方法
private extension BannerCarouselView {
    
    /// 使用 Banner 資料配置視圖
    func configureBanner(with bannerData: BannerData) {
        // 設定標題
        titleLabel.text = bannerData.headTitle
        
        // 過濾並設定輪播項目
        bannerItems = DataManager.shared.filterDraftData(from: bannerData)
        
        // 設定頁面指示器
        pageControl.numberOfPages = bannerItems.count
        pageControl.currentPage = 0
        
        // 建立輪播項目視圖
        createBannerItemViews()
        
        // 開始自動輪播
        startAutoScroll()
    }
    
    /// 建立輪播項目視圖
    func createBannerItemViews() {
        // 清除現有的子視圖
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        // 準備無限滾動的擴展項目
        setupInfiniteScrollItems()
        
        // 為每個擴展項目建立視圖
        for (index, item) in extendedBannerItems.enumerated() {
            let itemView = createBannerItemView(for: item, at: index)
            scrollView.addSubview(itemView)
        }
        
        // 更新佈局
        updateScrollViewLayout()
    }
    
    /// 設定無限滾動項目
    func setupInfiniteScrollItems() {
        guard !bannerItems.isEmpty else {
            extendedBannerItems = []
            return
        }
        
        if bannerItems.count == 1 {
            // 只有一個項目時，不需要無限滾動
            extendedBannerItems = bannerItems
        } else {
            // 多個項目時，使用「三頁面」策略
            // 結構：[最後一個項目] + [所有原始項目] + [第一個項目]
            extendedBannerItems = []
            
            // 加入最後一個項目的複製（用於從第一個項目向前滾動）
            extendedBannerItems.append(bannerItems.last!)
            
            // 加入所有原始項目
            extendedBannerItems.append(contentsOf: bannerItems)
            
            // 加入第一個項目的複製（用於從最後一個項目向後滾動）
            extendedBannerItems.append(bannerItems.first!)
        }
    }
    
    /// 建立單個輪播項目視圖
    func createBannerItemView(for item: DraftInfo, at index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        // 設定框架（考慮邊距）
        let margin: CGFloat = 8
        let x = scrollView.frame.width * CGFloat(index) + margin
        let width = scrollView.frame.width - (margin * 2)
        containerView.frame = CGRect(x: x, y: 0, width: width, height: scrollView.frame.height)
        
        // 建立非同步圖片視圖
        let asyncImageView = AsyncImageView()
        asyncImageView.cornerRadius = 12
        asyncImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        containerView.addSubview(asyncImageView)
        
        // 設定約束
        NSLayoutConstraint.activate([
            // 圖片視圖約束
            asyncImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            asyncImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            asyncImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            asyncImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
        ])
        
        // 載入圖片
        asyncImageView.loadImage(from: item.imageURL) { result in
            switch result {
            case .success(_):
                // 圖片載入成功，可以在這裡加入額外的處理
                break
            case .failure(let error):
                print("圖片載入失敗: \(error.localizedDescription)")
            }
        }
        
        return containerView
    }
    
    /// 滾動到下一頁
    func scrollToNextPage() {
        guard !bannerItems.isEmpty else { return }
        
        if bannerItems.count == 1 {
            // 只有一個項目時不需要滾動
            return
        }
        
        isProgrammaticScrolling = true
        
        // 計算下一個位置（在擴展陣列中的位置）
        let currentScrollIndex = getCurrentScrollIndex()
        let nextScrollIndex = currentScrollIndex + 1
        let offsetX = scrollView.frame.width * CGFloat(nextScrollIndex)
        
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    /// 取得當前滾動位置對應的索引
    func getCurrentScrollIndex() -> Int {
        let pageWidth = scrollView.frame.width
        return Int(round(scrollView.contentOffset.x / pageWidth))
    }
    
    /// 處理無限滾動的邊界情況
    func handleInfiniteScrollBoundary() {
        guard bannerItems.count > 1 else { return }
        
        let currentScrollIndex = getCurrentScrollIndex()
        let pageWidth = scrollView.frame.width
        
        if currentScrollIndex == 0 {
            // 滾動到了第一個位置（最後一個項目的複製），跳轉到實際的最後一個項目
            let targetIndex = bannerItems.count // 實際最後一個項目在擴展陣列中的位置
            let offsetX = pageWidth * CGFloat(targetIndex)
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
            currentIndex = bannerItems.count - 1
            
        } else if currentScrollIndex == extendedBannerItems.count - 1 {
            // 滾動到了最後一個位置（第一個項目的複製），跳轉到實際的第一個項目
            let targetIndex = 1 // 實際第一個項目在擴展陣列中的位置
            let offsetX = pageWidth * CGFloat(targetIndex)
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
            currentIndex = 0
            
        } else {
            // 正常範圍內，更新當前索引
            currentIndex = currentScrollIndex - 1 // 減 1 是因為擴展陣列的第一個元素是複製的
        }
        
        // 更新頁面指示器
        pageControl.currentPage = currentIndex
    }
}

// MARK: - UIScrollViewDelegate
extension BannerCarouselView: UIScrollViewDelegate {
    
    /// 滾動結束時更新當前頁面
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleInfiniteScrollBoundary()
        // 重新啟動自動滾動計時器
        restartAutoScroll()
    }
    
    /// 程式化滾動結束時更新當前頁面
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isProgrammaticScrolling {
            isProgrammaticScrolling = false
            handleInfiniteScrollBoundary()
            // 重新啟動自動滾動
            restartAutoScroll()
        }
    }
    
    /// 開始拖拽時停止自動滾動
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    /// 滾動過程中更新頁面指示器（僅用於視覺反饋）
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isProgrammaticScrolling && bannerItems.count > 1 else { return }
        
        // 計算當前顯示的實際頁面（用於頁面指示器）
        let currentScrollIndex = getCurrentScrollIndex()
        
        // 將擴展陣列的索引轉換為實際項目索引
        if currentScrollIndex >= 1 && currentScrollIndex <= bannerItems.count {
            let actualIndex = currentScrollIndex - 1
            if actualIndex != pageControl.currentPage {
                pageControl.currentPage = actualIndex
            }
        }
    }
}
