import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    showDelay: { type: Number, default: 10 },
    hideDelay: { type: Number, default: 8000 },
    type: String
  }

  connect() {
    // ai_comment の場合だけ消える時間を25秒後に変更
    const delay = this.typeValue === "ai_comment" ? 25000 : this.hideDelayValue

    setTimeout(() => {
      this.show()
    }, this.showDelayValue);


    this.timer = setTimeout(() => {
      this.hide()
    }, delay);
  }

  show() {
    this.containerTarget.classList.remove("translate-y-0", "opacity-0");
    this.containerTarget.classList.add("translate-y-full", "opacity-100");
    this.containerTarget.classList.remove("pointer-events-none");
    this.containerTarget.classList.add("pointer-events-auto");
  }

  hide() {
    clearTimeout(this.timer);
    this.containerTarget.classList.remove("translate-y-full", "opacity-100");
    this.containerTarget.classList.add("translate-y-0", "opacity-0");
    this.containerTarget.classList.remove("pointer-events-auto");
    this.containerTarget.classList.add("pointer-events-none");
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