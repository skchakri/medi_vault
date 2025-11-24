import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "toolbar", "count", "modal", "credentialIds", "selectAll"]

  connect() {
    this.selectedIds = new Set()
  }

  toggleAll(event) {
    const isChecked = event.target.checked

    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = isChecked
      const credentialId = checkbox.dataset.credentialId

      if (isChecked) {
        this.selectedIds.add(credentialId)
      } else {
        this.selectedIds.delete(credentialId)
      }
    })

    this.updateUI()
  }

  toggleCredential(event) {
    const credentialId = event.target.dataset.credentialId

    if (event.target.checked) {
      this.selectedIds.add(credentialId)
    } else {
      this.selectedIds.delete(credentialId)
    }

    this.updateSelectAllCheckbox()
    this.updateUI()
  }

  updateSelectAllCheckbox() {
    if (this.hasSelectAllTarget) {
      const allChecked = this.checkboxTargets.length > 0 &&
                        this.checkboxTargets.every(cb => cb.checked)
      const someChecked = this.checkboxTargets.some(cb => cb.checked)

      this.selectAllTarget.checked = allChecked
      this.selectAllTarget.indeterminate = someChecked && !allChecked
    }
  }

  clearSelection() {
    this.selectedIds.clear()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = false
    })
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = false
      this.selectAllTarget.indeterminate = false
    }
    this.updateUI()
  }

  updateUI() {
    const count = this.selectedIds.size

    if (count > 0) {
      this.toolbarTarget.classList.remove("hidden")
      this.countTarget.textContent = count
    } else {
      this.toolbarTarget.classList.add("hidden")
    }

    this.updateSelectAllCheckbox()
  }

  showShareModal() {
    if (this.selectedIds.size === 0) {
      alert("Please select at least one credential to share")
      return
    }

    // Clear previous hidden inputs
    this.credentialIdsTarget.innerHTML = ""

    // Add hidden inputs for each selected credential
    this.selectedIds.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "credential_ids[]"
      input.value = id
      this.credentialIdsTarget.appendChild(input)
    })

    this.modalTarget.classList.remove("hidden")
    this.modalTarget.style.display = "block"
  }

  hideShareModal() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.style.display = "none"
  }
}
