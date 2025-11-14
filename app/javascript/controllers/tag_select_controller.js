import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tag-select"
export default class extends Controller {
  static values = {
    createNew: { type: Boolean, default: true },
    placeholder: { type: String, default: "Select or create tags..." }
  }

  connect() {
    this.initializeSelect()
  }

  initializeSelect() {
    // TomSelect is loaded from CDN and available as a global
    if (typeof TomSelect === 'undefined') {
      console.error('TomSelect is not loaded. Make sure the CDN script is included.')
      return
    }

    const options = {
      plugins: {
        remove_button: {
          title: 'Remove this tag'
        }
      },
      create: this.createNewValue,
      maxItems: null,
      valueField: 'value',
      labelField: 'text',
      searchField: 'text',
      placeholder: this.placeholderValue,
      hidePlaceholder: true,
      render: {
        option: this.renderOption.bind(this),
        item: this.renderItem.bind(this)
      }
    }

    // Add creation function if enabled
    if (this.createNewValue) {
      options.create = (input) => {
        return {
          value: input.toLowerCase(),
          text: input.toLowerCase(),
          color: this.getRandomColor()
        }
      }
    }

    this.select = new TomSelect(this.element, options)
  }

  renderOption(data, escape) {
    const color = data.color || '#6B7280'
    return `
      <div class="flex items-center gap-2 py-1">
        <span class="w-3 h-3 rounded-full flex-shrink-0" style="background-color: ${escape(color)}"></span>
        <span class="flex-1">${escape(data.text)}</span>
      </div>
    `
  }

  renderItem(data, escape) {
    const color = data.color || '#6B7280'
    const bgColor = this.hexToRGBA(color, 0.2)
    return `
      <div class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-sm font-medium" style="background-color: ${bgColor}; color: ${escape(color)}">
        <span class="w-2 h-2 rounded-full" style="background-color: ${escape(color)}"></span>
        <span>${escape(data.text)}</span>
      </div>
    `
  }

  hexToRGBA(hex, alpha) {
    const r = parseInt(hex.slice(1, 3), 16)
    const g = parseInt(hex.slice(3, 5), 16)
    const b = parseInt(hex.slice(5, 7), 16)
    return `rgba(${r}, ${g}, ${b}, ${alpha})`
  }

  getRandomColor() {
    const colors = [
      '#EF4444', // red
      '#F59E0B', // amber
      '#10B981', // emerald
      '#3B82F6', // blue
      '#8B5CF6', // violet
      '#EC4899', // pink
      '#06B6D4', // cyan
      '#84CC16'  // lime
    ]
    return colors[Math.floor(Math.random() * colors.length)]
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
    }
  }
}
