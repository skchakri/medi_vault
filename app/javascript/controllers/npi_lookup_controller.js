import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "npiInput",
    "lookupButton",
    "npiStatus",
    "statusMessage",
    "fieldsContainer",
    "firstNameInput",
    "lastNameInput",
    "phoneInput",
    "titleInput",
    "credentialsInput",
    "clearButton"
  ]

  connect() {
    this.isLookupSuccessful = false
    this.disableOtherFields()
  }

  async performLookup() {
    const npi = this.npiInputTarget.value.trim()

    if (!npi) {
      this.showError("Please enter an NPI number")
      return
    }

    if (!npi.match(/^\d{10}$/)) {
      this.showError("NPI must be exactly 10 digits")
      return
    }

    // Disable button and show loading state
    this.setButtonLoading(true)

    try {
      const response = await fetch("/api/npi_lookups/lookup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getCsrfToken()
        },
        body: JSON.stringify({ npi: npi })
      })

      const data = await response.json()

      if (data.success) {
        this.populateFields(data.data)
        this.showSuccess(data.data)
        this.isLookupSuccessful = true
        this.enableOtherFields()
      } else {
        this.showError(data.error)
        this.isLookupSuccessful = false
        this.disableOtherFields()
      }
    } catch (error) {
      console.error("NPI Lookup Error:", error)
      this.showError("An error occurred during NPI lookup. Please try again.")
      this.isLookupSuccessful = false
      this.disableOtherFields()
    } finally {
      this.setButtonLoading(false)
    }
  }

  clearLookup() {
    this.npiInputTarget.value = ""
    this.npiInputTarget.focus()
    this.isLookupSuccessful = false

    // Clear all fields
    if (this.hasFirstNameInputTarget) this.firstNameInputTarget.value = ""
    if (this.hasLastNameInputTarget) this.lastNameInputTarget.value = ""
    if (this.hasPhoneInputTarget) this.phoneInputTarget.value = ""
    if (this.hasTitleInputTarget) this.titleInputTarget.value = ""
    if (this.hasCredentialsInputTarget) this.credentialsInputTarget.value = ""

    // Clear status
    this.npiStatusTarget.innerHTML = ""
    this.statusMessageTarget.innerHTML = ""

    this.disableOtherFields()
  }

  populateFields(data) {
    if (this.hasFirstNameInputTarget && data.first_name) {
      this.firstNameInputTarget.value = data.first_name
    }
    if (this.hasLastNameInputTarget && data.last_name) {
      this.lastNameInputTarget.value = data.last_name
    }
    if (this.hasPhoneInputTarget && data.phone) {
      this.phoneInputTarget.value = data.phone
    }
    if (this.hasTitleInputTarget && data.title) {
      this.titleInputTarget.value = data.title
    }
    if (this.hasCredentialsInputTarget && data.official_credentials) {
      this.credentialsInputTarget.value = data.official_credentials
    }
  }

  showSuccess(data) {
    const npiType = data.npi_enumeration_type === "NPI-1" ? "Individual Provider" : "Organization"

    this.npiStatusTarget.innerHTML = `
      <div class="flex items-center gap-2 p-3 bg-green-50 border border-green-200 rounded-lg">
        <svg class="w-5 h-5 text-green-600" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
        </svg>
        <div>
          <p class="text-sm font-medium text-green-900">NPI Verified</p>
          <p class="text-xs text-green-700">${npiType}</p>
        </div>
      </div>
    `

    this.statusMessageTarget.innerHTML = `
      <p class="text-sm text-green-700 mt-2">Your profile has been pre-filled with NPI Registry data. Review and edit as needed.</p>
      <button type="button" data-action="click->npi-lookup#clearLookup" class="mt-2 text-xs text-green-600 hover:text-green-800 font-medium underline">
        Clear and lookup a different NPI
      </button>
    `
  }

  showError(message) {
    this.npiStatusTarget.innerHTML = `
      <div class="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
        <svg class="w-5 h-5 text-red-600" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
        </svg>
        <p class="text-sm font-medium text-red-900">${message}</p>
      </div>
    `

    this.statusMessageTarget.innerHTML = `
      <p class="text-sm text-red-700 mt-2">Please verify the NPI number and try again, or continue with manual entry.</p>
    `
  }

  disableOtherFields() {
    const fields = [
      this.firstNameInputTarget,
      this.lastNameInputTarget,
      this.phoneInputTarget,
      this.titleInputTarget,
      this.credentialsInputTarget
    ]

    fields.forEach(field => {
      if (field) {
        field.disabled = true
        field.classList.add("bg-gray-100", "cursor-not-allowed", "opacity-60")
      }
    })

    if (this.hasFieldsContainerTarget) {
      this.fieldsContainerTarget.classList.add("opacity-50", "pointer-events-none")
    }
  }

  enableOtherFields() {
    const fields = [
      this.firstNameInputTarget,
      this.lastNameInputTarget,
      this.phoneInputTarget,
      this.titleInputTarget,
      this.credentialsInputTarget
    ]

    fields.forEach(field => {
      if (field) {
        field.disabled = false
        field.classList.remove("bg-gray-100", "cursor-not-allowed", "opacity-60")
      }
    })

    if (this.hasFieldsContainerTarget) {
      this.fieldsContainerTarget.classList.remove("opacity-50", "pointer-events-none")
    }
  }

  setButtonLoading(isLoading) {
    if (isLoading) {
      this.lookupButtonTarget.disabled = true
      this.lookupButtonTarget.innerHTML = `
        <svg class="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 2v4m0 12v4M6.22 6.22l2.83 2.83m7.9 7.9l2.83 2.83M2 12h4m12 0h4M6.22 17.78l2.83-2.83m7.9-7.9l2.83-2.83"/>
        </svg>
        Verifying...
      `
    } else {
      this.lookupButtonTarget.disabled = false
      this.lookupButtonTarget.innerHTML = "Verify NPI"
    }
  }

  getCsrfToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute("content") : ""
  }
}
