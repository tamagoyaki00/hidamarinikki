import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "existingPhoto"]
  
  connect() {
    this.selectedFiles = []
    this.setupExistingPhotos()
  }

  // 既存写真に削除ボタンを追加
  setupExistingPhotos() {
    this.existingPhotoTargets.forEach((photoDiv, index) => {
      // 既に削除ボタンがある場合はスキップ
      if (photoDiv.querySelector('.delete-existing-btn')) return
      
      const deleteButton = document.createElement('button')
      deleteButton.type = 'button'
      deleteButton.className = 'absolute top-2 right-2 bg-red-500 hover:bg-red-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold shadow-lg delete-existing-btn'
      deleteButton.innerHTML = '×'
      deleteButton.dataset.action = 'click->photo-preview#removeExisting'
      // 🔥 ボタンにはphoto-idを付けない！親要素から取得する
      deleteButton.dataset.photoId = photoDiv.dataset.photoId
      
      photoDiv.appendChild(deleteButton)
    })
  }

  // 🎯 既存画像の削除（完全修正版）
  removeExisting(event) {
    const button = event.currentTarget
    const photoId = button.dataset.photoId
    
    // 🔥 削除ボタンの親要素（画像のdiv）を直接取得
    const photoDiv = button.parentElement
    
    // 削除用の隠しフィールドを追加
    this.addDeleteField(photoId)
    
    // 🔥 画面から完全に削除（アニメーション付き）
    this.animateRemove(photoDiv)
  }

  // 新規ファイルのプレビュー
  preview() {
    const newPhotoContainer = this.previewTarget.querySelector('.new-photos')
    if (newPhotoContainer) {
      newPhotoContainer.innerHTML = ''
    } else {
      const container = document.createElement('div')
      container.className = 'new-photos contents'
      this.previewTarget.appendChild(container)
    }
    
    this.selectedFiles = []
    const files = Array.from(this.inputTarget.files)
    
    files.forEach((file, index) => {
      if (file.type.startsWith('image/')) {
        this.selectedFiles.push(file)
        this.createNewPreview(file, index)
      }
    })
  }

  // 新規画像のプレビュー作成
  createNewPreview(file, index) {
    const reader = new FileReader()
    
    reader.onload = (e) => {
      const div = document.createElement('div')
      // 🎯 レスポンシブ対応の高さ設定
      div.className = 'relative w-full h-32 sm:h-40 md:h-48 lg:h-56'
      div.innerHTML = `
        <img src="${e.target.result}" 
            class="w-full h-32 sm:h-40 md:h-48 lg:h-56 object-cover rounded-lg shadow-sm hover:shadow-md transition-all duration-200">
        <button type="button" 
                class="absolute top-1 right-1 sm:top-2 sm:right-2 bg-red-500 hover:bg-red-600 text-white rounded-full w-5 h-5 sm:w-6 sm:h-6 flex items-center justify-center text-xs sm:text-sm font-bold shadow-lg transition-all duration-200 z-10"
                data-action="click->photo-preview#removeNew"
                data-index="${index}">
          ×
        </button>
      `
      
      const newPhotoContainer = this.previewTarget.querySelector('.new-photos')
      newPhotoContainer.appendChild(div)
    }
    
    reader.readAsDataURL(file)
  }

  // 新規画像の削除
  removeNew(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    
    // ファイル配列から削除
    this.selectedFiles.splice(index, 1)
    
    // DataTransferで新しいFileListを作成
    const dt = new DataTransfer()
    this.selectedFiles.forEach(file => dt.items.add(file))
    this.inputTarget.files = dt.files
    
    // プレビューを再描画
    this.preview()
  }

  // 🎪 アニメーション付きで要素を削除
  animateRemove(element) {
    console.log('削除開始:', element)
    console.log('要素のタグ名:', element.tagName)
    console.log('要素の内容（最初の100文字）:', element.innerHTML.substring(0, 100))
    
    // フェードアウトアニメーション
    element.style.transition = 'all 0.3s ease-out'
    element.style.transform = 'scale(0.8)'
    element.style.opacity = '0'
    
    // アニメーション完了後に要素を削除
    setTimeout(() => {
      console.log('要素を削除:', element)
      element.remove() // 🔥 ここで画像要素全体を完全に削除
      
      // グリッドが空になった場合の処理
      this.checkEmptyGrid()
    }, 300)
  }

  // グリッドが空かどうかをチェック
  checkEmptyGrid() {
    const hasExistingPhotos = this.previewTarget.querySelectorAll('[data-photo-id]').length > 0
    const hasNewPhotos = this.previewTarget.querySelector('.new-photos')?.children.length > 0
    
    // 画像が一つもない場合はグリッドを非表示
    if (!hasExistingPhotos && !hasNewPhotos) {
      this.previewTarget.style.display = 'none'
    } else {
      this.previewTarget.style.display = 'grid'
    }
  }

  // 削除用の隠しフィールドを追加
  addDeleteField(photoId) {
    // 既に削除フィールドがある場合はスキップ
    if (this.element.querySelector(`input[name="diary_form[delete_photo_ids][]"][value="${photoId}"]`)) {
      return
    }
    
    const hiddenField = document.createElement('input')
    hiddenField.type = 'hidden'
    hiddenField.name = 'diary_form[delete_photo_ids][]'
    hiddenField.value = photoId
    
    this.element.appendChild(hiddenField)
 }
}