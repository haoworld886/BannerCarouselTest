//
//  DataManager.swift
//  BannerCarousel
//
//  資料管理器，負責載入和處理 JSON 資料
//

import Foundation

// MARK: - 資料管理器協定
/// 資料管理器協定，定義資料載入介面
protocol DataManagerProtocol {
    /// 載入 Banner 資料
    /// - Parameter completion: 完成回調，包含結果或錯誤
    func loadBannerData(completion: @escaping (Result<BannerData, DataError>) -> Void)
}

// MARK: - 資料錯誤類型
/// 資料處理相關的錯誤類型
enum DataError: Error, LocalizedError {
    /// 檔案未找到
    case fileNotFound
    /// JSON 解析失敗
    case jsonParsingFailed
    /// 資料無效
    case invalidData
    /// 網路錯誤
    case networkError
    
    /// 錯誤描述
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "找不到資料檔案"
        case .jsonParsingFailed:
            return "JSON 資料解析失敗"
        case .invalidData:
            return "資料格式無效"
        case .networkError:
            return "網路連線錯誤"
        }
    }
}

// MARK: - 資料管理器實作
/// 資料管理器實作類別
class DataManager: DataManagerProtocol {
    
    /// 單例模式
    static let shared = DataManager()
    
    /// 私有初始化，確保單例使用
    private init() {}
    
    /// 從本地 JSON 檔案載入 Banner 資料
    /// - Parameter completion: 完成回調
    func loadBannerData(completion: @escaping (Result<BannerData, DataError>) -> Void) {
        // 在背景佇列執行資料載入，避免阻塞主執行緒
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 嘗試從 Bundle 中載入 JSON 檔案
                guard let path = Bundle.main.path(forResource: "測驗資料", ofType: "json") else {
                    DispatchQueue.main.async {
                        completion(.failure(.fileNotFound))
                    }
                    return
                }
                
                // 讀取檔案內容
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                
                // 解析 JSON 資料
                let bannerData = try JSONDecoder().decode(BannerData.self, from: data)
                
                // 在主執行緒回調結果
                DispatchQueue.main.async {
                    completion(.success(bannerData))
                }
                
            } catch {
                // 處理錯誤情況
                DispatchQueue.main.async {
                    if error is DecodingError {
                        completion(.failure(.jsonParsingFailed))
                    } else {
                        completion(.failure(.invalidData))
                    }
                }
            }
        }
    }
    
    /// 從網路 URL 載入 Banner 資料（擴展功能）
    /// - Parameters:
    ///   - url: 資料來源 URL
    ///   - completion: 完成回調
    func loadBannerData(from url: URL, completion: @escaping (Result<BannerData, DataError>) -> Void) {
        // 建立網路請求任務
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 檢查網路錯誤
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.networkError))
                }
                return
            }
            
            // 檢查資料是否存在
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
                return
            }
            
            do {
                // 解析 JSON 資料
                let bannerData = try JSONDecoder().decode(BannerData.self, from: data)
                
                // 在主執行緒回調結果
                DispatchQueue.main.async {
                    completion(.success(bannerData))
                }
                
            } catch {
                // JSON 解析失敗
                DispatchQueue.main.async {
                    completion(.failure(.jsonParsingFailed))
                }
            }
        }
        
        // 開始網路請求
        task.resume()
    }
}

// MARK: - 資料過濾輔助方法
extension DataManager {
    
    /// 根據標籤資料過濾輪播項目（使用優化的過濾邏輯）
    /// - Parameters:
    ///   - bannerData: 原始 Banner 資料
    ///   - targetTagNo: 目標標籤識別碼（可選，如果為 nil 則使用優先順序最高的標籤）
    /// - Returns: 過濾後的輪播項目陣列
    func filterDraftData(from bannerData: BannerData, targetTagNo: String? = nil) -> [DraftInfo] {
        if let targetTagNo = targetTagNo {
            // 使用指定的標籤過濾
            return DataFilter.filterDraftData(bannerData.draftData, by: targetTagNo)
        } else {
            // 使用優先順序過濾，取得第一個標籤的項目
            guard let firstTag = bannerData.tagData.sorted(by: { $0.tagSort < $1.tagSort }).first else {
                return []
            }
            return DataFilter.filterDraftData(bannerData.draftData, by: firstTag.tagNo)
        }
    }
    
    
}
