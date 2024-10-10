import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sections"
export default class extends Controller {
  static targets = ['active']

  connect() {
  }

  update() {
    if (this.hasActiveTarget) {
      this.activeTarget.parentNode.setAttribute('src', this.element.dataset.src)
    }
    if(event.target.dataset.section) {
      const current = this.element.querySelector('[active]')
      if (current) {
        current.removeAttribute('active')
      }
      const section = document.getElementById(`section-${event.target.dataset.section}`)
      section.setAttribute('active', "")
    }
  }
}
