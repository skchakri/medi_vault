import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    if (this.hasDelayValue && this.delayValue > 0) {
      this.timeout = setTimeout(() => {
        this.dismiss()
      }, this.delayValue)
    }
  }

  dismiss() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.element.classList.add("transition", "transform", "opacity-0", "translate-x-full")

    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}
