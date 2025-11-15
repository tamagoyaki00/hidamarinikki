import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    showDelay: { type: Number, default: 100 },
    hideDelay: { type: Number, default: 5000 },
    type: String,
    env: String
  }

  connect() {
    const isTestEnv = this.envValue === "test"

    // ai_comment の場合だけ20秒後に消える(テスト環境では2秒後)
    let delay
    if (isTestEnv) {
      delay = 2000
    } else {
      delay = this.typeValue === "ai_comment" ? 20000 : this.hideDelayValue
    }

    setTimeout(() => {
      this.show()
    }, this.showDelayValue)

    this.timer = setTimeout(() => {
      this.hide()
    }, delay)
  }

  show() {
    this.containerTarget.classList.remove("translate-y-0", "opacity-0");
    this.containerTarget.classList.add("translate-y-[30px]", "opacity-100");
  }

  hide() {
    clearTimeout(this.timer);
    this.containerTarget.classList.remove("translate-y-[30px]", "opacity-100");
    this.containerTarget.classList.add("translate-y-0", "opacity-0");
  }

  remove(event) {
    if (event.propertyName === 'transform' || event.propertyName === 'opacity') {
        this.element.remove();
    }
  }

  disconnect() {
    clearTimeout(this.timer);
  }
}