import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menus"
export default class extends Controller {
  static targets = ['item', 'back']

  connect() {
  }

  setActive() {
    if (this.hasBackTarget) {
      this.backTarget.click()
    }
    this.itemTargets.forEach(item => {
      item.removeAttribute("active")
    });
    event.target.parentNode.setAttribute("active", "")
  }

}
