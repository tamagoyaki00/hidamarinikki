import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.lastScrollY = window.scrollY;
    this.toggle();
  }

  toggle() {
    window.addEventListener('scroll', this.handleScroll.bind(this));
  }

  handleScroll() {
    if (window.scrollY > this.lastScrollY) {
      this.element.classList.add("translate-y-20", "opacity-0");
    } else {
      this.element.classList.remove("translate-y-20", "opacity-0");
    }
    this.lastScrollY = window.scrollY;
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll);
  }
}