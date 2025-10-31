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
    
    // MARK: - 現代 async/await API
    
    /// 異步載入 Banner 資料（現代 API）
    /// - Returns: Banner 資料
    /// - Throws: DataError
    func loadBannerData() async throws -> BannerData {
        return try await loadBannerDataAsync()
    }
        
    /// 從本地 JSON 檔案載入 Banner 資料
    /// - Parameter completion: 完成回調
    func loadBannerData(completion: @escaping (Result<BannerData, DataError>) -> Void) {
        // 使用 Task 來處理異步操作，符合 Swift 6 並發模型
        Task {
            do {
                let bannerData = try await loadBannerDataAsync()
                await MainActor.run {
                    completion(.success(bannerData))
                }
            } catch let error as DataError {
                await MainActor.run {
                    completion(.failure(error))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(.invalidData))
                }
            }
        }
    }
    
    /// 異步載入 Banner 資料的私有方法
    /// - Returns: 解析後的 BannerData
    /// - Throws: DataError
    private func loadBannerDataAsync() async throws -> BannerData {
        // 嘗試從 Bundle 中載入 JSON 檔案
        guard let path = Bundle.main.path(forResource: "測驗資料", ofType: "json") else {
            throw DataError.fileNotFound
        }
        
        // 讀取檔案內容
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        
        // 解析 JSON 資料
        // 使用 withCheckedThrowingContinuation 確保在 nonisolated 上下文中執行
        // 這樣 JSON 解析操作不會被限制在特定的 actor（如 MainActor）上，
        // 可以在後台線程執行，提高效能
        return try await withCheckedThrowingContinuation { continuation in
            do {
                // JSONDecoder 的解析操作是 CPU 密集型任務
                // 在 nonisolated 上下文中執行可以避免阻塞主線程
                let bannerData = try JSONDecoder().decode(BannerData.self, from: data)
                continuation.resume(returning: bannerData)
            } catch {
                if error is DecodingError {
                    continuation.resume(throwing: DataError.jsonParsingFailed)
                } else {
                    continuation.resume(throwing: DataError.invalidData)
                }
            }
        }
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
