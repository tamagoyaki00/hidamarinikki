import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTarget.addEventListener("change", this.roundTo15Minutes.bind(this))
  }

  roundTo15Minutes(event) {
    const [hour, minute] = event.target.value.split(":").map(Number)
    const rounded = [0, 15, 30, 45].reduce((prev, curr) => Math.abs(curr - minute) < Math.abs(prev - minute) ? curr : prev)
    event.target.value = `${hour.toString().padStart(2,'0')}:${rounded.toString().padStart(2,'0')}`
  }
}
