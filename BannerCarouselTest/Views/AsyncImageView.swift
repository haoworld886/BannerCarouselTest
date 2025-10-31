//
//  AsyncImageView.swift
//  BannerCarousel
//
//  非同步圖片載入視圖元件，支援快取和載入狀態顯示
//

import UIKit

// MARK: - 非同步圖片視圖
/// 非同步圖片載入視圖，提供網路圖片載入、快取和錯誤處理功能
class AsyncImageView: UIView {
    
    // MARK: - UI 元件
    /// 主要圖片視圖
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// 載入指示器
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .systemGray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    /// 錯誤狀態標籤
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "圖片載入失敗"
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - 屬性
    /// 當前載入的圖片 URL
    private var currentURL: URL?
    
    /// 載入任務
    private var loadingTask: URLSessionDataTask?
    
    /// 圖片快取管理器
    private static let imageCache = ImageCacheManager.shared
    
    /// 預設佔位圖片
    var placeholderImage: UIImage? {
        didSet {
            if imageView.image == nil {
                imageView.image = placeholderImage
            }
        }
    }
    
    /// 圓角半徑
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0
        }
    }
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - 生命週期
    deinit {
        // 取消進行中的載入任務
        cancelLoading()
    }
}

// MARK: - UI 設定
private extension AsyncImageView {
    
    /// 設定 UI 元件和約束
    func setupUI() {
        backgroundColor = .systemGray6
        
        // 加入子視圖
        addSubview(imageView)
        addSubview(loadingIndicator)
        addSubview(errorLabel)
        
        // 設定約束
        setupConstraints()
    }
    
    /// 設定 Auto Layout 約束
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // 圖片視圖約束
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 載入指示器約束
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // 錯誤標籤約束
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - 公開方法
extension AsyncImageView {
    
    /// 載入圖片
    /// - Parameters:
    ///   - url: 圖片 URL
    ///   - placeholder: 佔位圖片（可選）
    ///   - completion: 載入完成回調（可選）
    func loadImage(from url: URL?, placeholder: UIImage? = nil, completion: ((Result<UIImage, Error>) -> Void)? = nil) {
        // 取消之前的載入任務
        cancelLoading()
        
        // 重置 UI 狀態
        resetUI()
        
        // 設定佔位圖片
        if let placeholder = placeholder {
            imageView.image = placeholder
        } else if let defaultPlaceholder = placeholderImage {
            imageView.image = defaultPlaceholder
        }
        
        // 檢查 URL 有效性
        guard let url = url else {
            showError()
            completion?(.failure(ImageLoadError.invalidURL))
            return
        }
        
        currentURL = url
        
        // 檢查快取
        if let cachedImage = Self.imageCache.getImage(for: url) {
            displayImage(cachedImage)
            completion?(.success(cachedImage))
            return
        }
        
        // 開始載入
        startLoading()
        
        // 建立載入任務
        loadingTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleLoadingResult(data: data, response: response, error: error, url: url, completion: completion)
            }
        }
        
        loadingTask?.resume()
    }
    
    /// 取消載入
    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
        currentURL = nil
        stopLoading()
    }
    
    /// 清除圖片
    func clearImage() {
        cancelLoading()
        imageView.image = placeholderImage
        resetUI()
    }
}

// MARK: - 私有方法
private extension AsyncImageView {
    
    /// 處理載入結果
    func handleLoadingResult(data: Data?, response: URLResponse?, error: Error?, url: URL, completion: ((Result<UIImage, Error>) -> Void)?) {
        // 停止載入指示器
        stopLoading()
        
        // 檢查是否為當前請求
        guard url == currentURL else { return }
        
        // 檢查錯誤
        if let error = error {
            showError()
            completion?(.failure(error))
            return
        }
        
        // 檢查資料
        guard let data = data, let image = UIImage(data: data) else {
            showError()
            completion?(.failure(ImageLoadError.invalidData))
            return
        }
        
        // 快取圖片
        Self.imageCache.setImage(image, for: url)
        
        // 顯示圖片
        displayImage(image)
        completion?(.success(image))
    }
    
    /// 重置 UI 狀態
    func resetUI() {
        errorLabel.isHidden = true
        loadingIndicator.stopAnimating()
    }
    
    /// 開始載入狀態
    func startLoading() {
        errorLabel.isHidden = true
        loadingIndicator.startAnimating()
    }
    
    /// 停止載入狀態
    func stopLoading() {
        loadingIndicator.stopAnimating()
    }
    
    /// 顯示圖片
    func displayImage(_ image: UIImage) {
        imageView.image = image
        errorLabel.isHidden = true
    }
    
    /// 顯示錯誤狀態
    func showError() {
        imageView.image = placeholderImage
        errorLabel.isHidden = false
    }
}

// MARK: - 圖片載入錯誤類型
/// 圖片載入相關的錯誤類型
enum ImageLoadError: Error, LocalizedError {
    /// 無效的 URL
    case invalidURL
    /// 無效的資料
    case invalidData
    /// 網路錯誤
    case networkError
    
    /// 錯誤描述
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無效的圖片 URL"
        case .invalidData:
            return "無效的圖片資料"
        case .networkError:
            return "網路連線錯誤"
        }
    }
}

// MARK: - 圖片快取管理器
/// 圖片快取管理器，使用 LRU 策略管理記憶體快取
class ImageCacheManager {
    
    /// 單例
    static let shared = ImageCacheManager()
    
    /// 快取容器
    private let cache = NSCache<NSString, UIImage>()
    
    /// 最大快取數量
    private let maxCacheCount = 50
    
    /// 最大記憶體使用量（MB）
    private let maxMemoryUsage = 50 * 1024 * 1024 // 50MB
    
    /// 私有初始化
    private init() {
        setupCache()
    }
    
    /// 設定快取參數
    private func setupCache() {
        cache.countLimit = maxCacheCount
        cache.totalCostLimit = maxMemoryUsage
        
        // 監聽記憶體警告
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    /// 處理記憶體警告
    @objc private func handleMemoryWarning() {
        cache.removeAllObjects()
    }
    
    /// 取得快取圖片
    /// - Parameter url: 圖片 URL
    /// - Returns: 快取的圖片（如果存在）
    func getImage(for url: URL) -> UIImage? {
        let key = NSString(string: url.absoluteString)
        return cache.object(forKey: key)
    }
    
    /// 設定快取圖片
    /// - Parameters:
    ///   - image: 要快取的圖片
    ///   - url: 圖片 URL
    func setImage(_ image: UIImage, for url: URL) {
        let key = NSString(string: url.absoluteString)
        
        // 估算圖片記憶體大小
        let cost = estimateImageMemorySize(image)
        
        cache.setObject(image, forKey: key, cost: cost)
    }
    
    /// 移除快取圖片
    /// - Parameter url: 圖片 URL
    func removeImage(for url: URL) {
        let key = NSString(string: url.absoluteString)
        cache.removeObject(forKey: key)
    }
    
    /// 清除所有快取
    func clearCache() {
        cache.removeAllObjects()
    }
    
    /// 估算圖片記憶體大小
    /// - Parameter image: 圖片
    /// - Returns: 估算的記憶體大小（位元組）
    private func estimateImageMemorySize(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}