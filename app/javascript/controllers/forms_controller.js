import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="forms"
export default class extends Controller {
  static targets = ['input', 'resizer']

  connect() {
    if (this.hasResizerTarget) {
      this.resize()
    }
  }

  resize() {
    const width = this.resizerTarget.offsetWidth
    this.resizerTarget.innerHTML = this.inputTarget.value
    this.inputTarget.style = `width: ${this.resizerTarget.offsetWidth}px`
  }

  submit() {
    this.element.requestSubmit()
  }
}
