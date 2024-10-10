import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modals"
export default class extends Controller {
  connect() {
  }

  redirect(event) {
    if (event.detail.success) {
      const fetchResponse = event.detail.fetchResponse
      history.pushState(
        { turbo_frame_history: true },
        "",
        fetchResponse.response.url
      )
      Turbo.visit(fetchResponse.response.url)
    }
  }

  close() {
    event.preventDefault()
    this.element.innerHTML = ""
  }
}
