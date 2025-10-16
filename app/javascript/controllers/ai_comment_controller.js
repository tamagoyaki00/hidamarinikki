import { Controller } from "@hotwired/stimulus"
import * as Turbo from "@hotwired/turbo"

export default class extends Controller {
  static values = { diaryId: Number, from: String }

  connect() {
    // 投稿 or 更新直後だけリクエストを飛ばす
    if (this.fromValue && this.diaryIdValue) {
      this.loadAiComment()
    }
  }

  loadAiComment() {
    fetch(`/diaries/${this.diaryIdValue}/ai_comment?from=${this.fromValue}`, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }

}