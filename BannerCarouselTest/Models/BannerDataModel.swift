//
//  BannerDataModel.swift
//  BannerCarousel
//
//  資料模型定義，用於解析 JSON 資料和管理輪播內容
//

import Foundation

// MARK: - 主要資料結構
/// 主要的 Banner 資料結構，對應 JSON 根物件
struct BannerData: Codable {
    /// 主標題，顯示在輪播上方
    let headTitle: String
    /// 標籤資料陣列，用於過濾輪播內容
    let tagData: [TagInfo]
    /// 草稿資料陣列，包含所有輪播項目
    let draftData: [DraftInfo]
    
    // JSON 欄位映射
    enum CodingKeys: String, CodingKey {
        case headTitle = "HeadTitle"
        case tagData = "TagData"
        case draftData = "DraftData"
    }
}

// MARK: - 標籤資訊結構
/// 標籤資訊結構，用於分類和過濾輪播內容
struct TagInfo: Codable {
    /// 標籤唯一識別碼
    let tagNo: String
    /// 標籤標題
    let tagTitle: String
    /// 標籤排序順序
    let tagSort: Int
    
    // JSON 欄位映射
    enum CodingKeys: String, CodingKey {
        case tagNo = "TagNo"
        case tagTitle = "TagTitle"
        case tagSort = "TagSort"
    }
}

// MARK: - 輪播項目結構
/// 輪播項目資訊結構，包含顯示所需的所有資料
struct DraftInfo: Codable {
    /// 關聯的標籤識別碼，用於過濾
    let tagNo: String
    /// 主標題
    let draftTitle: String
    /// 副標題
    let draftSubTitle: String
    /// 圖片 URL 字串
    let draftPic: String
    
    // JSON 欄位映射
    enum CodingKeys: String, CodingKey {
        case tagNo = "TagNo"
        case draftTitle = "DraftTitle"
        case draftSubTitle = "DraftSubTitle"
        case draftPic = "DraftPic"
    }
}

// MARK: - 輔助擴展
extension DraftInfo {
    /// 取得圖片 URL 物件
    var imageURL: URL? {
        return URL(string: draftPic)
    }
    
    /// 檢查是否有有效的圖片 URL
    var hasValidImageURL: Bool {
        return imageURL != nil
    }
}

extension BannerData {
    /// 根據指定的 TagNo 過濾出相關的輪播項目
    /// - Parameter targetTagNo: 目標標籤識別碼
    /// - Returns: 過濾後的輪播項目陣列
    func filteredDraftData(for targetTagNo: String) -> [DraftInfo] {
        return draftData.filter { $0.tagNo == targetTagNo }
    }
}
