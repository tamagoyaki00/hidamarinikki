// controllers/password_visibility_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "iconOpen", "iconClose"]

  toggle() {
    const type = this.inputTarget.type === "password" ? "text" : "password"
    this.inputTarget.type = type

    this.iconOpenTarget.classList.toggle("hidden")
    this.iconCloseTarget.classList.toggle("hidden")
  }
}
