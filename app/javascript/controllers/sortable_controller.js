import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs"
import { FetchRequest } from "@rails/request.js";

// Connects to data-controller="sortable"
export default class extends Controller {
  static values = {url: String, handle: Boolean}

  connect() {
    this.sortable = Sortable.create(this.element, {
      onEnd: this.persist.bind(this),
      handle: this.handleValue ? ".handle" : this.handleValue
    });
  }

  persist(event) {
    const data = new FormData()
    data.append("position", event.newIndex + 1)
    const url = this.urlValue.replace(":id", event.item.dataset.id)
    const request = new FetchRequest('patch', url, {body: data})
    request.perform()
  }
}
