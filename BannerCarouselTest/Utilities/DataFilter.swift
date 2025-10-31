//
//  DataFilter.swift
//  BannerCarousel
//
//  資料過濾工具類別，提供各種資料篩選和驗證功能
//

import Foundation

// MARK: - 資料過濾器
/// 資料過濾器類別，提供靜態方法進行資料篩選
class DataFilter {
    /// 根據特定標籤識別碼過濾輪播資料
    /// - Parameters:
    ///   - draftData: 原始輪播資料陣列
    ///   - targetTagNo: 目標標籤識別碼
    /// - Returns: 符合指定標籤的輪播資料陣列
    static func filterDraftData(_ draftData: [DraftInfo], by targetTagNo: String) -> [DraftInfo] {
        return draftData.filter { draft in
            draft.tagNo == targetTagNo && draft.hasValidImageURL
        }
    }
    
}
