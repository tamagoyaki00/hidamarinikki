import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner"]

  connect() {
    const img = this.element.querySelector("img")
    if (img && img.complete) {
      this.hide()
    }
  }

  hide() {
    this.spinnerTarget.classList.add("opacity-0", "transition-opacity", "duration-300")
    setTimeout(() => {
      this.spinnerTarget.remove()
    }, 300)
  }

}

