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
      const tagColor = tag.dataset.tagColor
      const isActive = !hasExplicitSelection || activeSelection.includes(tagId)

      if (isActive) {
        // Active state: colored background with white text
        tag.style.backgroundColor = tagColor
        tag.style.color = 'white'
        tag.style.border = 'none'
        tag.style.opacity = '1'
      } else {
        // Inactive state: light gray background with colored border
        tag.style.backgroundColor = 'rgba(229, 231, 235, 0.5)'
        tag.style.color = '#6B7280'
        tag.style.border = `2px solid ${tagColor}`
        tag.style.opacity = '0.7'
      }

      tag.setAttribute('aria-pressed', isActive)
    })
  }

  submitForm() {
    // Use submit() instead of requestSubmit() for better mobile compatibility
    // requestSubmit() is not fully supported on all mobile browsers
    this.formTarget.submit()
  }
}
