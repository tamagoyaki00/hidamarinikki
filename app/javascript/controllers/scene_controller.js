import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preset", "custom"]

  connect() {
    this.toggle() // 初期状態を反映
  }

  toggle() {
    const selected = this.element.querySelector(
      "input[name='notification_setting[scene_type]']:checked"
    )?.value

    this.presetTarget.classList.toggle("hidden", selected !== "preset")
    this.customTarget.classList.toggle("hidden", selected !== "custom")
  }
}
