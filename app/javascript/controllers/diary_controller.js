import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  
  addItem() {
    const container = this.containerTarget
    const itemCount = container.children.length + 1
    
    const template = document.getElementById('diary-item-template')
    const clone = template.content.cloneNode(true)
    
    const labelSpan = clone.querySelector('.label-text')
    const textarea = clone.querySelector('textarea')
    
    labelSpan.textContent = itemCount
    textarea.id = `item_${itemCount}`
    textarea.placeholder = `${itemCount}. 日記の内容`
    
    container.appendChild(clone)
  }
  
  removeItem(event) {
    const item = event.target.closest('.form-control')
    item.remove()

    this.updateItemNumbers()
  }
  
  updateItemNumbers() {
    const items = this.containerTarget.children
    Array.from(items).forEach((item, index) => {
      const labelSpan = item.querySelector('.label-text')
      const textarea = item.querySelector('textarea')
      const itemNumber = index + 1
      
      labelSpan.textContent = itemNumber
      textarea.placeholder = `${itemNumber}. 日記の内容`
    })
  }
}

