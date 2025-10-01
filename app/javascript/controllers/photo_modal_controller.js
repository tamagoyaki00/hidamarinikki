import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "slide", "counter", "previousButton", "nextButton"]
  static values = {
    images: Array,
    index: Number
  }

  connect() {

  }

  indexValueChanged() {
    this.showSlide()
  }

  open(event) {
    this.indexValue = Number(event.params.index)
    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }

  next() {
    this.indexValue = (this.indexValue + 1) % this.imagesValue.length
  }

  previous() {
    this.indexValue = (this.indexValue - 1 + this.imagesValue.length) % this.imagesValue.length
  }

  showSlide() {
    const imageUrl = this.imagesValue[this.indexValue]
    this.slideTarget.src = imageUrl
    this.counterTarget.textContent = `${this.indexValue + 1} / ${this.imagesValue.length}`

    if (this.imagesValue.length <= 1) {
      this.previousButtonTarget.classList.add("hidden")
      this.nextButtonTarget.classList.add("hidden")
    } else {
      this.previousButtonTarget.classList.remove("hidden")
      this.nextButtonTarget.classList.remove("hidden")
    }
  }

  keyPress(event) {
    if (event.key === "ArrowRight") {
      this.next()
    }
    if (event.key === "ArrowLeft") {
      this.previous()
    }
    if (event.key === "Escape") {
      this.close()
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}