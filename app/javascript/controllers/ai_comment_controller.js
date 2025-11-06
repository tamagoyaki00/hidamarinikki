import { Controller } from "@hotwired/stimulus"
import * as Turbo from "@hotwired/turbo"

export default class extends Controller {
  static values = { diaryId: Number, from: String }

  connect() {
    if (this.fromValue && this.diaryIdValue) {
      this.loadAiComment()
    }
  }

  loadAiComment() {
    fetch(`/diaries/${this.diaryIdValue}/ai_comment?from=${this.fromValue}`, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
        const url = new URL(window.location)
        url.searchParams.delete("from")
        url.searchParams.delete("diary_id")
        window.history.replaceState({}, "", url)
      })
  }


}