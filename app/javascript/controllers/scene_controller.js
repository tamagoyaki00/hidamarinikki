import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preset", "custom"]

  connect() {
    this.toggle() // 初期状態を反映
  }

  toggle() {
    const selected = this.element.querySelector("input[name='notification_setting[scene_type]']:checked")?.value

    if (selected === "preset") {
      this.presetTarget.classList.remove("hidden")
      this.customTarget.classList.add("hidden")
    } else if (selected === "custom") {
      this.customTarget.classList.remove("hidden")
      this.presetTarget.classList.add("hidden")
    }
  }
}
