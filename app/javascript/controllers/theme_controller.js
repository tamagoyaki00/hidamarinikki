import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  static values = {
    light: { type: String, default: "hidamarinikki" },
    dark: { type: String, default: "sunset" },
  }

  connect() {
    const savedTheme = localStorage.getItem("theme")

    // 保存されたテーマがあれば適用、なければOSの設定を確認
    if (savedTheme) {
      this.applyTheme(savedTheme)
    } else {
      // OSがダークモードを優先しているかチェック
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
      this.applyTheme(prefersDark ? this.darkValue : this.lightValue)
    }
  }

  toggle(event) {
    const theme = event.target.checked ? this.darkValue : this.lightValue
    this.applyTheme(theme)
    localStorage.setItem("theme", theme) // 選択したテーマをlocalStorageに保存
  }

  // テーマを適用し、トグルの状態を更新するヘルパーメソッド
  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)

    // トグル（チェックボックス）の状態を現在のテーマに合わせる
    // ページ読み込み時に正しい表示にするために必要
    this.toggleTarget.checked = (theme === this.darkValue)

    // 
    window.dispatchEvent(new CustomEvent("theme:changed", { detail: { theme } }))

  }
}