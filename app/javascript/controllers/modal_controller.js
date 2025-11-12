import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    document.addEventListener("turbo:before-visit", this.closeIfOpen)
  }

  disconnect() {
    document.removeEventListener("turbo:before-visit", this.closeIfOpen)
  }

  open() {
    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  closeIfOpen = () => {
    if (this.hasModalTarget && this.modalTarget.open) {
      this.close()
    }
  }
}
