import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.itemCounter = this.containerTarget.querySelectorAll('.form-control').length;
  }

  addItem() {
    this.itemCounter++;
    const newItemHtml = `
      <div class="form-control">
        <div class="label">
          <span class="label-text">${this.itemCounter}. 日記の内容</span>
        </div>
        <textarea
          name="diary[items][]"
          id="item_${this.itemCounter}"
          rows="2"
          class="textarea textarea-bordered textarea-accent w-full"
          placeholder="${this.itemCounter}. 日記の内容"
        ></textarea>
      </div>
    `;
    this.containerTarget.insertAdjacentHTML('beforeend', newItemHtml);
  }
}
