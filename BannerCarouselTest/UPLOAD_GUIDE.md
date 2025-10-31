# Git 上傳指南

## 📋 上傳專案到 GitHub 的完整步驟

### 步驟 1: 初始化 Git Repository

在專案根目錄開啟終端機，執行以下指令：

```bash
# 初始化 Git repository
git init

# 添加遠端 repository
git remote add origin git@github.com:haoworld886/BannerCarouselTest.git
```

### 步驟 2: 配置 Git 使用者資訊（如果還未設定）

```bash
# 設定使用者名稱和信箱
git config --global user.name "您的姓名"
git config --global user.email "您的信箱@example.com"
```

### 步驟 3: 檢查檔案狀態

```bash
# 查看目前檔案狀態
git status
```

### 步驟 4: 添加檔案到暫存區

```bash
# 添加所有檔案到暫存區
git add .

# 或者個別添加檔案
git add ViewController.swift
git add BannerCarouselView.swift
git add AsyncImageView.swift
git add DataManager.swift
git add BannerDataModel.swift
git add DataFilter.swift
git add AppDelegate.swift
git add SceneDelegate.swift
git add README.md
git add LICENSE
git add .gitignore
git add 測驗資料.json
```

### 步驟 5: 提交變更

```bash
# 提交變更並加上訊息
git commit -m "🎉 初次提交：完整的 Banner 輪播 iOS 應用程式

✨ 功能特色：
- 無限輪播功能
- 非同步圖片載入
- 智慧快取管理
- 完整生命週期處理
- MVC 架構設計

📱 技術規格：
- Swift 5.0+
- iOS 12.0+
- UIKit + Auto Layout
- JSON 資料解析"
```

### 步驟 6: 推送到 GitHub

```bash
# 首次推送，建立 main 分支並上傳
git push -u origin main

# 如果遇到錯誤，可能需要強制推送（請謹慎使用）
# git push -u origin main --force
```

### 步驟 7: 驗證上傳結果

1. 開啟瀏覽器前往：https://github.com/haoworld886/BannerCarouselTest
2. 確認所有檔案都已成功上傳
3. 檢查 README.md 是否正確顯示

## 🔄 後續更新流程

當您需要更新專案時，使用以下流程：

```bash
# 1. 查看變更狀態
git status

# 2. 添加變更的檔案
git add .

# 3. 提交變更
git commit -m "🔧 更新描述：具體說明您的變更內容"

# 4. 推送到 GitHub
git push origin main
```

## 🐛 常見問題解決

### 問題 1: Permission denied (publickey)

**解決方案：**
```bash
# 檢查 SSH key
ssh -T git@github.com

# 如果沒有 SSH key，需要生成一個
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 將 SSH key 添加到 GitHub 帳戶
cat ~/.ssh/id_rsa.pub
# 複製輸出內容到 GitHub Settings > SSH Keys
```

### 問題 2: Repository already exists

**解決方案：**
```bash
# 先拉取遠端內容
git pull origin main --allow-unrelated-histories

# 然後再推送
git push origin main
```

### 問題 3: 檔案太大無法上傳

**解決方案：**
```bash
# 檢查 .gitignore 是否正確排除大檔案
# 移除已追蹤的大檔案
git rm --cached 檔案名稱
git commit -m "移除大檔案"
```

## 📚 Git 常用指令參考

```bash
# 查看提交歷史
git log --oneline

# 查看分支
git branch -a

# 建立並切換到新分支
git checkout -b 新分支名稱

# 合併分支
git merge 分支名稱

# 查看遠端 repository 資訊
git remote -v

# 拉取最新變更
git pull origin main
```

## ✅ 上傳檢查清單

- [ ] 檔案已添加到暫存區 (`git add .`)
- [ ] 提交訊息清楚明確 (`git commit -m "..."`)
- [ ] README.md 檔案完整
- [ ] .gitignore 檔案正確設定
- [ ] LICENSE 檔案已添加
- [ ] 測試資料檔案已包含
- [ ] 所有 Swift 檔案已包含
- [ ] 遠端 repository 設定正確
- [ ] 成功推送到 GitHub (`git push origin main`)

完成以上步驟後，您的 BannerCarousel 專案就會成功上傳到 GitHub！