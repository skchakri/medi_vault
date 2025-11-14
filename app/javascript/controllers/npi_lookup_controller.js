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
    "namePrefixInput",
    "middleNameInput",
    "nameSuffixInput",
    "genderInput",
    "phoneInput",
    "titleInput",
    "credentialsInput",
    "clearButton",
    // Address sections
    "addressSection",
    "mailingAddressContainer",
    "mailingAddress",
    "practiceAddressContainer",
    "practiceAddress",
    "locationAddressContainer",
    "locationAddress",
    // NPI Details section
    "npiDetailsSection",
    "npiType",
    "npiStatusDisplay",
    "enumerationDate",
    "lastUpdated",
    // Taxonomies section
    "taxonomiesSection",
    "taxonomiesList",
    // Identifiers section
    "identifiersSection",
    "identifiersList"
  ]

  connect() {
    console.log("NPI Lookup Controller Connected!")
    this.isLookupSuccessful = false
    this.disableOtherFields()
  }

  async performLookup() {
    console.log("performLookup called!")
    const npi = this.npiInputTarget.value.trim()
    console.log("NPI value:", npi)

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

    // Clear all basic fields
    if (this.hasFirstNameInputTarget) this.firstNameInputTarget.value = ""
    if (this.hasLastNameInputTarget) this.lastNameInputTarget.value = ""
    if (this.hasNamePrefixInputTarget) this.namePrefixInputTarget.value = ""
    if (this.hasMiddleNameInputTarget) this.middleNameInputTarget.value = ""
    if (this.hasNameSuffixInputTarget) this.nameSuffixInputTarget.value = ""
    if (this.hasGenderInputTarget) this.genderInputTarget.value = ""
    if (this.hasPhoneInputTarget) this.phoneInputTarget.value = ""
    if (this.hasTitleInputTarget) this.titleInputTarget.value = ""
    if (this.hasCredentialsInputTarget) this.credentialsInputTarget.value = ""

    // Clear and hide address sections
    if (this.hasAddressSectionTarget) {
      this.addressSectionTarget.classList.add("hidden")
      if (this.hasMailingAddressContainerTarget) this.mailingAddressContainerTarget.classList.add("hidden")
      if (this.hasPracticeAddressContainerTarget) this.practiceAddressContainerTarget.classList.add("hidden")
      if (this.hasLocationAddressContainerTarget) this.locationAddressContainerTarget.classList.add("hidden")
    }

    // Clear and hide NPI details section
    if (this.hasNpiDetailsSectionTarget) {
      this.npiDetailsSectionTarget.classList.add("hidden")
    }

    // Clear and hide taxonomies section
    if (this.hasTaxonomiesSectionTarget) {
      this.taxonomiesSectionTarget.classList.add("hidden")
      if (this.hasTaxonomiesListTarget) this.taxonomiesListTarget.innerHTML = ""
    }

    // Clear and hide identifiers section
    if (this.hasIdentifiersSectionTarget) {
      this.identifiersSectionTarget.classList.add("hidden")
      if (this.hasIdentifiersListTarget) this.identifiersListTarget.innerHTML = ""
    }

    // Clear status
    this.npiStatusTarget.innerHTML = ""
    this.statusMessageTarget.innerHTML = ""

    this.disableOtherFields()
  }

  populateFields(data) {
    // Basic fields
    if (this.hasFirstNameInputTarget && data.first_name) {
      this.firstNameInputTarget.value = data.first_name
    }
    if (this.hasLastNameInputTarget && data.last_name) {
      this.lastNameInputTarget.value = data.last_name
    }
    if (this.hasNamePrefixInputTarget && data.name_prefix) {
      this.namePrefixInputTarget.value = data.name_prefix
    }
    if (this.hasMiddleNameInputTarget && data.middle_name) {
      this.middleNameInputTarget.value = data.middle_name
    }
    if (this.hasNameSuffixInputTarget && data.name_suffix) {
      this.nameSuffixInputTarget.value = data.name_suffix
    }
    if (this.hasGenderInputTarget && data.gender) {
      this.genderInputTarget.value = data.gender
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

    // Populate address information
    this.populateAddresses(data)

    // Populate NPI details
    this.populateNpiDetails(data)

    // Populate taxonomies
    this.populateTaxonomies(data)

    // Populate identifiers
    this.populateIdentifiers(data)
  }

  populateAddresses(data) {
    if (!this.hasAddressSectionTarget) return

    let hasAnyAddress = false

    // Mailing address
    if (data.formatted_mailing_address && this.hasMailingAddressTarget) {
      this.mailingAddressTarget.textContent = data.formatted_mailing_address
      this.mailingAddressContainerTarget.classList.remove("hidden")
      hasAnyAddress = true
    }

    // Practice address
    if (data.formatted_practice_address && this.hasPracticeAddressTarget) {
      this.practiceAddressTarget.textContent = data.formatted_practice_address
      this.practiceAddressContainerTarget.classList.remove("hidden")
      hasAnyAddress = true
    }

    // Location address
    if (data.formatted_location_address && this.hasLocationAddressTarget) {
      this.locationAddressTarget.textContent = data.formatted_location_address
      this.locationAddressContainerTarget.classList.remove("hidden")
      hasAnyAddress = true
    }

    // Show address section if any address is present
    if (hasAnyAddress) {
      this.addressSectionTarget.classList.remove("hidden")
    }
  }

  populateNpiDetails(data) {
    if (!this.hasNpiDetailsSectionTarget) return

    let hasAnyDetail = false

    // NPI Type
    if (data.npi_enumeration_type && this.hasNpiTypeTarget) {
      const npiTypeText = data.npi_enumeration_type === "NPI-1" ?
        "Individual Provider (NPI-1)" : "Organization (NPI-2)"
      this.npiTypeTarget.textContent = npiTypeText
      hasAnyDetail = true
    }

    // NPI Status
    if (data.npi_status && this.hasNpiStatusDisplayTarget) {
      const statusText = data.npi_status === "A" ? "Active" :
                        data.npi_status === "D" ? "Deactivated" : "Unknown"
      this.npiStatusDisplayTarget.textContent = statusText
      hasAnyDetail = true
    }

    // Enumeration Date
    if (data.enumeration_date && this.hasEnumerationDateTarget) {
      this.enumerationDateTarget.textContent = this.formatDate(data.enumeration_date)
      hasAnyDetail = true
    }

    // Last Updated
    if (data.last_updated && this.hasLastUpdatedTarget) {
      this.lastUpdatedTarget.textContent = this.formatDate(data.last_updated)
      hasAnyDetail = true
    }

    // Show NPI details section if any detail is present
    if (hasAnyDetail) {
      this.npiDetailsSectionTarget.classList.remove("hidden")
    }
  }

  populateTaxonomies(data) {
    if (!this.hasTaxonomiesSectionTarget || !this.hasTaxonomiesListTarget) return
    if (!data.taxonomies || data.taxonomies.length === 0) return

    const taxonomiesHtml = data.taxonomies.map((taxonomy, index) => {
      const isPrimary = taxonomy.primary === true
      return `
        <div class="border border-gray-200 rounded-lg p-3 ${isPrimary ? 'bg-purple-50 border-purple-300' : 'bg-gray-50'}">
          <div class="flex items-start justify-between mb-2">
            <div class="flex-1">
              <h4 class="text-sm font-semibold text-gray-900">
                ${taxonomy.desc || `Specialty ${index + 1}`}
              </h4>
              ${isPrimary ? '<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-purple-100 text-purple-800 mt-1">Primary</span>' : ''}
            </div>
          </div>
          <dl class="grid grid-cols-2 gap-2 text-xs mt-2">
            <div>
              <dt class="font-medium text-gray-500">Taxonomy Code</dt>
              <dd class="text-gray-900">${taxonomy.code || 'N/A'}</dd>
            </div>
            ${taxonomy.state ? `
              <div>
                <dt class="font-medium text-gray-500">State</dt>
                <dd class="text-gray-900">${taxonomy.state}</dd>
              </div>
            ` : ''}
            ${taxonomy.license ? `
              <div class="col-span-2">
                <dt class="font-medium text-gray-500">License Number</dt>
                <dd class="text-gray-900">${taxonomy.license}</dd>
              </div>
            ` : ''}
          </dl>
        </div>
      `
    }).join('')

    this.taxonomiesListTarget.innerHTML = taxonomiesHtml
    this.taxonomiesSectionTarget.classList.remove("hidden")
  }

  populateIdentifiers(data) {
    if (!this.hasIdentifiersSectionTarget || !this.hasIdentifiersListTarget) return
    if (!data.identifiers || data.identifiers.length === 0) return

    const identifiersHtml = data.identifiers.map((identifier, index) => {
      return `
        <div class="border border-gray-200 rounded-lg p-3 bg-gray-50">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
            <div>
              <span class="font-medium text-gray-700">Type:</span>
              <span class="text-gray-900 ml-2">${identifier.desc || `Identifier ${index + 1}`}</span>
            </div>
            <div>
              <span class="font-medium text-gray-700">Identifier:</span>
              <span class="text-gray-900 ml-2">${identifier.identifier || 'N/A'}</span>
            </div>
            ${identifier.code ? `
              <div>
                <span class="font-medium text-gray-700">Code:</span>
                <span class="text-gray-900 ml-2">${identifier.code}</span>
              </div>
            ` : ''}
            ${identifier.state ? `
              <div>
                <span class="font-medium text-gray-700">State:</span>
                <span class="text-gray-900 ml-2">${identifier.state}</span>
              </div>
            ` : ''}
            ${identifier.issuer ? `
              <div class="sm:col-span-2">
                <span class="font-medium text-gray-700">Issuer:</span>
                <span class="text-gray-900 ml-2">${identifier.issuer}</span>
              </div>
            ` : ''}
          </div>
        </div>
      `
    }).join('')

    this.identifiersListTarget.innerHTML = identifiersHtml
    this.identifiersSectionTarget.classList.remove("hidden")
  }

  formatDate(dateString) {
    if (!dateString) return ''
    const date = new Date(dateString)
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
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
      this.namePrefixInputTarget,
      this.middleNameInputTarget,
      this.nameSuffixInputTarget,
      this.genderInputTarget,
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
      this.namePrefixInputTarget,
      this.middleNameInputTarget,
      this.nameSuffixInputTarget,
      this.genderInputTarget,
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
