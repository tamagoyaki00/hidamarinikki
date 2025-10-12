import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "slide", "counter", "previousButton", "nextButton", "modalSpinner"]
  static values = {
    images: Array,
    index: Number
  }

  indexValueChanged() {
    this.showSlide()
  }

  // サムネイルクリック時にモーダルを開き、表示開始インデックスを設定する
  open(event) {
    this.indexValue = Number(event.params.index)
    this.modalTarget.showModal()

    // スピナーを表示
    this.modalSpinnerTarget.classList.remove("hidden")

    // 画像を差し替え
    const url = this.imagesValue[this.indexValue]
    this.slideTarget.src = url
  }

  // モーダルを閉じる
  close() {
    this.modalTarget.close()
  }

  // 次の画像に切り替える（インデックスを増やす）
  next() {
    this.indexValue = (this.indexValue + 1) % this.imagesValue.length
  }

  // 前の画像に切り替える（インデックスを減らす）
  previous() {
    this.indexValue = (this.indexValue - 1 + this.imagesValue.length) % this.imagesValue.length
  }

  // スライドの画像とカウンターを更新する
  showSlide() {
    const imageUrl = this.imagesValue[this.indexValue]
    this.slideTarget.src = imageUrl
    this.counterTarget.textContent = `${this.indexValue + 1} / ${this.imagesValue.length}`

    // 画像が1枚以下の場合、ナビゲーションボタンを非表示にする
    if (this.imagesValue.length <= 1) {
      this.previousButtonTarget.classList.add("hidden")
      this.nextButtonTarget.classList.add("hidden")
    } else {
      this.previousButtonTarget.classList.remove("hidden")
      this.nextButtonTarget.classList.remove("hidden")
    }
  }

  // キーボード操作
  keyPress(event) {
    if (!this.modalTarget.open) return;

    switch (event.code) {
      case "ArrowRight":
        this.next();
        event.preventDefault();
        break;
      case "ArrowLeft":
        this.previous();
        event.preventDefault();
        break;
      case "Escape":
        this.close();
        event.preventDefault();
        break;
    }
  }

  // モーダルの背景（backdrop）をクリックしたときに閉じる
  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  hideSpinner() {
    if (this.hasModalSpinnerTarget) {
      this.modalSpinnerTarget.classList.add("hidden")
    }
  }
}