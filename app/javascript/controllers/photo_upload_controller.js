import { Controller } from "@hotwired/stimulus"
import imageCompression from "browser-image-compression"

export default class extends Controller {
  static targets = ["submitButton", "overlay"] // 送信ボタンをターゲットに追加

async compressAndSubmit(event) {
  event.preventDefault()

  this.submitButtonTarget.disabled = true
  const originalButtonText = this.submitButtonTarget.textContent
  this.submitButtonTarget.textContent = "画像を処理中..."
  this.overlayTarget.classList.remove("hidden")

  const form = event.currentTarget
  const fileInputs = form.querySelectorAll("input[type='file'][multiple]")

  const options = {
    maxSizeMB: 1, // 最大1M
    maxWidthOrHeight: 1920, // 最大縦横1920px
    useWebWorker: true
  }
  

  try {
    for (const input of fileInputs) {
      const files = Array.from(input.files)
      if (files.length === 0) continue

      const dataTransfer = new DataTransfer()

      const compressedFiles = await Promise.all(
        files.map(async (file) => {
          try {
            const compressed = await imageCompression(file, options)
            // Blob の場合は File に変換
            return new File([compressed], file.name, { type: file.type })
          } catch (error) {
            console.error("圧縮エラー:", error)
            return file // 元の File を返す
          }
        })
      )

      compressedFiles.forEach(file => dataTransfer.items.add(file))
      input.files = dataTransfer.files

    }

      form.submit()

    } catch (error) {
      console.error("予期せぬエラー:", error)
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = originalButtonText
      alert("ファイルの処理中にエラーが発生しました。もう一度お試しください。")
    }
  }
}