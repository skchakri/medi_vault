import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bulk-upload"
export default class extends Controller {
  static targets = ["dropzone", "input", "fileList", "fileCount", "submitButton", "clearButton"]

  connect() {
    console.log("Bulk upload controller connected")
    this.selectedFiles = []
    // Prevent default drag behaviors on the entire dropzone
    this.dropzoneTarget.addEventListener('dragenter', this.preventDefaults.bind(this))
    this.dropzoneTarget.addEventListener('dragover', this.preventDefaults.bind(this))
    this.dropzoneTarget.addEventListener('dragleave', this.preventDefaults.bind(this))
    this.dropzoneTarget.addEventListener('drop', this.preventDefaults.bind(this))
  }

  preventDefaults(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  openFilePicker(event) {
    event.preventDefault()
    console.log("Opening file picker...")
    this.inputTarget.click()
  }

  handleDragOver(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.add("border-purple-500", "bg-purple-100")
    this.dropzoneTarget.classList.remove("border-gray-300", "bg-gray-50")
  }

  handleDragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.remove("border-purple-500", "bg-purple-100")
    this.dropzoneTarget.classList.add("border-gray-300", "bg-gray-50")
  }

  handleDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    console.log("Files dropped:", event.dataTransfer.files)
    this.dropzoneTarget.classList.remove("border-purple-500", "bg-purple-100")
    this.dropzoneTarget.classList.add("border-gray-300", "bg-gray-50")

    const files = Array.from(event.dataTransfer.files)
    this.addFiles(files)
  }

  handleFileSelect(event) {
    console.log("Files selected:", event.target.files)
    const files = Array.from(event.target.files)
    this.addFiles(files)
  }

  addFiles(files) {
    console.log("Adding files:", files)

    // Filter valid file types
    const validFiles = files.filter(file => {
      const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
      const validExtensions = ['.pdf', '.jpg', '.jpeg', '.png', '.gif', '.doc', '.docx']
      const extension = '.' + file.name.split('.').pop().toLowerCase()

      return validTypes.includes(file.type) || validExtensions.includes(extension)
    })

    console.log("Valid files after filtering:", validFiles)

    // Filter out files that are too large (10MB)
    const maxSize = 10 * 1024 * 1024 // 10MB
    const sizedFiles = validFiles.filter(file => {
      if (file.size > maxSize) {
        alert(`${file.name} is too large. Maximum file size is 10MB.`)
        return false
      }
      return true
    })

    console.log("Files after size filtering:", sizedFiles)

    // Add to selected files
    this.selectedFiles = [...this.selectedFiles, ...sizedFiles]
    console.log("Total selected files:", this.selectedFiles)

    this.updateFileInput()
    this.updateFileList()
    this.updateSubmitButton()
  }

  updateFileInput() {
    // Use DataTransfer to update the file input with selected files
    const dt = new DataTransfer()
    this.selectedFiles.forEach(file => {
      dt.items.add(file)
    })
    this.inputTarget.files = dt.files
    console.log("File input updated. File count:", this.inputTarget.files.length)
  }

  updateFileList() {
    if (this.selectedFiles.length === 0) {
      this.fileListTarget.classList.add("hidden")
      return
    }

    this.fileListTarget.classList.remove("hidden")
    this.fileCountTarget.textContent = this.selectedFiles.length

    const listHTML = this.selectedFiles.map((file, index) => {
      const fileSize = this.formatFileSize(file.size)
      const fileIcon = this.getFileIcon(file)

      return `
        <div class="p-4 flex items-center justify-between hover:bg-gray-100 transition" data-file-index="${index}">
          <div class="flex items-center flex-1 min-w-0">
            <div class="flex-shrink-0 mr-3">
              ${fileIcon}
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 truncate">${file.name}</p>
              <p class="text-xs text-gray-500">${fileSize}</p>
            </div>
          </div>
          <button
            type="button"
            data-action="click->bulk-upload#removeFile"
            data-index="${index}"
            class="ml-4 flex-shrink-0 text-red-600 hover:text-red-800 transition"
          >
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        </div>
      `
    }).join('')

    this.fileListTarget.querySelector('div').innerHTML = listHTML
  }

  removeFile(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.selectedFiles.splice(index, 1)
    this.updateFileInput()
    this.updateFileList()
    this.updateSubmitButton()
  }

  clearFiles() {
    this.selectedFiles = []
    this.updateFileInput()
    this.updateFileList()
    this.updateSubmitButton()
  }

  updateSubmitButton() {
    if (this.selectedFiles.length > 0) {
      this.submitButtonTarget.disabled = false
      this.clearButtonTarget.classList.remove("hidden")
    } else {
      this.submitButtonTarget.disabled = true
      this.clearButtonTarget.classList.add("hidden")
    }
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
  }

  getFileIcon(file) {
    const type = file.type

    if (type.startsWith('image/')) {
      return `
        <svg class="h-8 w-8 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
        </svg>
      `
    } else if (type === 'application/pdf') {
      return `
        <svg class="h-8 w-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
        </svg>
      `
    } else {
      return `
        <svg class="h-8 w-8 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
        </svg>
      `
    }
  }
}
