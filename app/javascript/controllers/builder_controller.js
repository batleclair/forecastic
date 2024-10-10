import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="builder"
export default class extends Controller {
  static targets = ['input', 'field', 'searchForm', 'formulaForm', 'output']

  connect() {
  }

  analyze() {
    const stringRegex = RegExp('[a-zA-Z]')
    const mathRegex = RegExp('[()+-\/\*\^\.]|[0-9]')
    if (stringRegex.test(this.fieldTarget.value)) {
      this.searchFormTarget.requestSubmit()
    }
    if (mathRegex.test(this.fieldTarget.value)) {
      this.addToFormula(this.fieldTarget.value)
    }
  }

  selectMetric() {
    this.addToFormula(`#{${event.target.dataset.id}}`)
  }

  addToFormula(input) {
    let p = Array.from(this.outputTarget.children).indexOf(this.fieldTarget)
    let a = this.inputTarget.value.split(/(\#\{\d*\})|([\(\)\*\^\+\-\/])|(\d+\.?\d*)/).filter(elm => elm)
    a.splice(p, 0, input)
    this.inputTarget.value = a.join('')
    this.formulaFormTarget.requestSubmit()
    this.fieldTarget.value = ""
    this.fieldTarget.focus()
  }

  moveLeft() {
    if (this.fieldTarget.value === "") {
      const prev = this.fieldTarget.previousElementSibling
      if (prev) {
        this.fieldTarget.after(prev)
      }
    }
  }

  moveRight() {
    if (this.fieldTarget.value === "") {
      const next = this.fieldTarget.nextElementSibling
      if (next) {
        this.fieldTarget.before(next)
      }
    }
  }

  backSpace() {
    if (this.fieldTarget.value === "") {
      let p = Array.from(this.outputTarget.children).indexOf(this.fieldTarget)
      let a = this.inputTarget.value.split(/(\#\{\d*\})|([\(\)\*\^\+\-\/])|(\d+\.?\d*)/).filter(elm => elm)
      a.splice(p-1,1)
      this.inputTarget.value = a.join('')
      this.formulaFormTarget.requestSubmit()
    } else if (this.fieldTarget.value.length === 1) {
      this.fieldTarget.value = ""
      this.searchFormTarget.requestSubmit()
    }
  }
}
