import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preset", "custom", "presetSelect", "customText"]

  connect() {
    this.toggle()
  }

  toggle() {
    const isPreset = document.getElementById("scene_preset").checked

    // プリセット用フィールドの表示/非表示を切り替える
    this.presetTarget.classList.toggle("hidden", !isPreset)
    // プリセットのselectを有効化/無効化
    this.presetSelectTarget.disabled = !isPreset

    // カスタム用フィールドの表示/非表示を切り替える
    this.customTarget.classList.toggle("hidden", isPreset)
    // カスタムのtext_fieldを有効化/無効化
    this.customTextTarget.disabled = isPreset
  }
}