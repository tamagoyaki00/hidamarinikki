import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  select(event) {
    const clickedDiv = event.currentTarget;
    if (!clickedDiv) return;

    this.element.querySelectorAll('div[data-action]').forEach(div => {
      div.querySelector('button').classList.remove('btn-secondary', 'btn-active');
      div.querySelector('button').classList.add('btn-outline');
    });

    const clickedButton = clickedDiv.querySelector('button');
    if (clickedButton) {
      clickedButton.classList.add('btn-secondary', 'btn-active');
      clickedButton.classList.remove('btn-outline');

      const selectedValue = clickedDiv.dataset.value;
      const radioButton = this.element.querySelector(`input[type="radio"][value="${selectedValue}"]`);
      if (radioButton) {
        radioButton.checked = true;
      }
    }
  }
}