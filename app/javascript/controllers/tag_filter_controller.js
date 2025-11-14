import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tag", "form", "hiddenInput"]
  static values = {
    selectedTags: Array
  }

  connect() {
    const initialSelection = this.hasSelectedTagsValue ? this.selectedTagsValue.map(String) : []
    this.selectedTagsValue = initialSelection

    this.updateHiddenInputs()
    this.updateTagStyles()
  }

  toggleTag(event) {
    const tagId = event.currentTarget.dataset.tagId
    let selections = [...this.selectedTagsValue.map(String)]
    const index = selections.indexOf(tagId)

    if (index === -1) {
      selections.push(tagId)
    } else {
      selections.splice(index, 1)
    }

    selections = selections.filter(Boolean)
    this.selectedTagsValue = selections

    this.updateHiddenInputs()
    this.updateTagStyles()
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

  updateTagStyles() {
    const activeSelection = this.selectedTagsValue.map(String)
    const hasExplicitSelection = activeSelection.length > 0

    this.tagTargets.forEach(tag => {
      const tagId = tag.dataset.tagId
      const isActive = !hasExplicitSelection || activeSelection.includes(tagId)

      tag.classList.toggle('opacity-50', !isActive)
      tag.classList.toggle('ring-2', hasExplicitSelection && !isActive)
      tag.classList.toggle('ring-offset-2', hasExplicitSelection && !isActive)
      tag.setAttribute('aria-pressed', isActive)
    })
  }

  submitForm() {
    this.formTarget.requestSubmit()
  }
}
