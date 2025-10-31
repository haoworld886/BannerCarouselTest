//
//  ViewController.swift
//  BannerCarousel
//
//  主要的視圖控制器，展示 Banner 輪播功能
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI 元件
    /// Banner 輪播視圖
    private let bannerCarouselView: BannerCarouselView = {
        let view = BannerCarouselView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 狀態標籤（用於顯示載入狀態或錯誤訊息）
//    private let statusLabel: UILabel = {
//        let label = UILabel()
//        label.text = "載入中..."
//        label.textColor = .systemGray
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.isHidden = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    // MARK: - 生命週期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBannerData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 當視圖即將出現時，確保輪播正在運行
        bannerCarouselView.startAutoScroll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 當視圖即將消失時，停止輪播以節省資源
        bannerCarouselView.stopAutoScroll()
    }
}

// MARK: - UI 設定
private extension ViewController {
    
    /// 設定 UI 元件和約束
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 加入子視圖
        view.addSubview(bannerCarouselView)
        //view.addSubview(statusLabel)
        
        // 設定約束
        setupConstraints()
    }
    
    /// 設定 Auto Layout 約束
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        // 創建一個可選的高度約束，優先級較低
        let heightConstraint = bannerCarouselView.heightAnchor.constraint(equalToConstant: 276)
        heightConstraint.priority = UILayoutPriority(999) // 高優先級但不是必需的
        
        NSLayoutConstraint.activate([
            // Banner 輪播視圖約束
            bannerCarouselView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            bannerCarouselView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerCarouselView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heightConstraint, // 使用優先級較低的高度約束
            
            // 狀態標籤約束
//            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
//            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - 資料載入
private extension ViewController {
    
    /// 載入 Banner 資料
    func loadBannerData() {
        //showLoadingStatus()
    
            self.bannerCarouselView.loadBannerData()
          
    }
}

// MARK: - 使用者互動
private extension ViewController {
    
    /// 重新載入按鈕點擊事件
    @objc func reloadButtonTapped() {
        // 停止當前的輪播
        bannerCarouselView.stopAutoScroll()
        
        // 提供觸覺回饋
        if #available(iOS 10.0, *) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        // 重新載入資料
        loadBannerData()
    }
}

// MARK: - 記憶體管理
extension ViewController {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // 清除圖片快取以釋放記憶體
        ImageCacheManager.shared.clearCache()
        
        print("收到記憶體警告，已清除圖片快取")
    }
}
