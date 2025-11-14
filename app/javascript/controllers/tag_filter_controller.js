import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tag", "form", "hiddenInput"]
  static values = {
    selectedTags: Array
  }

  connect() {
    // Initialize with no tags selected (all active by default)
    this.selectedTagsValue = []
    this.updateHiddenInputs()
  }

  toggleTag(event) {
    const tagId = event.currentTarget.dataset.tagId
    const index = this.selectedTagsValue.indexOf(tagId)

    if (index === -1) {
      // Tag was not selected, add it
      this.selectedTagsValue.push(tagId)
      event.currentTarget.classList.remove('opacity-50')
      event.currentTarget.classList.add('ring-2', 'ring-offset-2')
    } else {
      // Tag was selected, remove it
      this.selectedTagsValue.splice(index, 1)
      event.currentTarget.classList.add('opacity-50')
      event.currentTarget.classList.remove('ring-2', 'ring-offset-2')
    }

    this.updateHiddenInputs()
    this.submitForm()
  }

  updateHiddenInputs() {
    // Remove existing hidden inputs
    this.hiddenInputTargets.forEach(input => input.remove())

    // Add hidden inputs for selected tags (empty array = all tags selected)
    if (this.selectedTagsValue.length > 0) {
      this.selectedTagsValue.forEach(tagId => {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'tag_ids[]'
        input.value = tagId
        input.dataset.tagFilterTarget = 'hiddenInput'
        this.formTarget.appendChild(input)
      })
    }
  }

  submitForm() {
    this.formTarget.requestSubmit()
  }
}
