import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "nameInput", "descriptionInput", "statusSelect"]
  static values = {
    tools: Object,
    workflow: Object
  }

  connect() {
    this.editor = null
    this.nodeMap = {} // uid => drawflow internal id
    this.currentWorkflowId = null
    this.initializeEditor()
    if (this.hasWorkflowValue && this.workflowValue) {
      this.load(this.workflowValue)
    }
  }

  initializeEditor() {
    if (!window.Drawflow) {
      console.error("Drawflow library not loaded")
      return
    }
    this.editor = new window.Drawflow(this.canvasTarget, { reroute: true })
    this.editor.reroute = true
    this.editor.start()
    this.bindEvents()
  }

  bindEvents() {
    this.editor.on("nodeSelected", (id) => {
      const node = this.editor.getNodeFromId(id)
      if (!node) return
      this.configureNode(id, node)
    })
  }

  addNode(event) {
    if (!this.editor) return
    const raw = event?.params?.tool
    if (!raw) {
      console.warn("No tool payload found on click")
      return
    }
    const payload = typeof raw === "string" ? JSON.parse(raw) : raw
    const uid = `node_${Date.now()}_${Math.floor(Math.random() * 9999)}`
    this.createNodeFromData({
      uid,
      tool_key: payload.key,
      name: payload.name,
      description: payload.description,
      config: {},
      ui: { x: 120 + Object.keys(this.nodeMap).length * 40, y: 120 + Object.keys(this.nodeMap).length * 20 }
    })
  }

  createNodeFromData(nodeData) {
    const spec = this.toolsValue[nodeData.tool_key]
    if (!spec) return
    const uid = nodeData.uid || nodeData.id || `node_${Date.now()}_${Math.floor(Math.random() * 9999)}`
    const html = this.buildNodeHtml(nodeData, spec)
    const internalId = this.editor.addNode(
      nodeData.tool_key,
      1,
      1,
      nodeData.ui?.x || 200,
      nodeData.ui?.y || 200,
      nodeData.tool_key,
      {
        uid: uid,
        tool_key: nodeData.tool_key,
        name: nodeData.name,
        description: nodeData.description,
        config: nodeData.config || {},
        ui: nodeData.ui || {}
      },
      html
    )
    this.nodeMap[uid] = internalId
    this.refreshNodeStatus(internalId)
  }

  buildNodeHtml(nodeData, spec) {
    const complete = this.nodeComplete(nodeData, spec)
    return `
      <div class="drawflow_node-content">
        <div class="flex items-center justify-between">
          <div>
            <div class="title">${nodeData.name}</div>
            <p class="subtitle">${nodeData.description || ''}</p>
          </div>
          <span class="badge ${complete ? 'ready' : 'missing'}">${complete ? 'Ready' : 'Missing'}</span>
        </div>
        <p class="meta mt-2">${Object.keys(nodeData.config || {}).length} fields configured</p>
      </div>
    `
  }

  loadWorkflow(event) {
    const payload = JSON.parse(event.params.workflow)
    this.load(payload)
  }

  clearEditor() {
    if (this.editor) {
      this.editor.clear()
      this.nodeMap = {}
    }
  }

  load(payload) {
    if (!this.editor) return
    this.clearEditor()
    this.currentWorkflowId = payload.id
    this.nameInputTarget.value = payload.name || ''
    this.descriptionInputTarget.value = payload.description || ''
    this.statusSelectTarget.value = payload.status || 'draft'

    const nodes = Array.isArray(payload.nodes) ? payload.nodes : []
    const edges = Array.isArray(payload.edges) ? payload.edges : []

    nodes.forEach((node) => this.createNodeFromData(node))

    // reconnect edges using stored uids
    edges.forEach((edge) => {
      const fromId = this.nodeMap[edge.from]
      const toId = this.nodeMap[edge.to]
      if (fromId && toId) {
        this.editor.addConnection(fromId, toId, "output_1", "input_1")
      }
    })
  }

  configureNode(internalId, node) {
    const spec = this.toolsValue[node.data.tool_key]
    if (!spec) return
    const requiredInputs = (spec.inputs || []).filter((input) => !input.endsWith('?'))
    const promptText = `Configure ${node.data.name}:\nProvide a JSON object with keys:\n${requiredInputs.join(', ') || 'any'}`
    const existing = JSON.stringify(node.data.config || {}, null, 2)
    const result = window.prompt(promptText, existing)
    if (!result) return
    try {
      const parsed = JSON.parse(result)
      node.data.config = parsed
      this.editor.updateNodeDataFromId(internalId, node.data)
      this.refreshNodeStatus(internalId)
    } catch (e) {
      alert("Invalid JSON")
    }
  }

  refreshNodeStatus(internalId) {
    const node = this.editor.getNodeFromId(internalId)
    const spec = this.toolsValue[node.data.tool_key]
    const complete = this.nodeComplete(node.data, spec)
    const el = this.canvasTarget.querySelector(`[data-nodeid="${internalId}"]`)
    if (!el) return

    el.classList.remove('ready', 'missing')
    el.classList.add(complete ? 'ready' : 'missing')

    const pill = el.querySelector('.text-[11px]')
    if (pill) {
      pill.textContent = complete ? 'Ready' : 'Missing'
      pill.className = `text-[11px] px-2 py-1 rounded-full ${complete ? 'bg-green-200 text-green-800' : 'bg-red-200 text-red-800'}`
    }
    const card = el.querySelector('.drawflow_node-content')
    if (card) {
      card.classList.toggle('ring-2', !complete)
      card.classList.toggle('ring-red-200', !complete)
    }
  }

  nodeComplete(nodeData, spec) {
    const requiredInputs = (spec?.inputs || []).filter((input) => !input.endsWith('?'))
    return requiredInputs.every((key) => (nodeData.config || {})[key.replace(/\?.*/, '')] !== undefined)
  }

  async save() {
    if (!this.editor) return
    const exported = this.editor.export()
    const flow = exported.drawflow?.Home?.data || {}
    const nodes = []
    const uidMap = {}
    Object.values(flow).forEach((node) => {
      uidMap[node.id] = node.data.uid
      nodes.push({
        uid: node.data.uid,
        tool_key: node.data.tool_key || node.name,
        name: node.data.name,
        description: node.data.description,
        config: node.data.config || {},
        ui: { x: node.pos_x, y: node.pos_y }
      })
    })

    const edges = []
    Object.values(flow).forEach((node) => {
      const outputs = node.outputs || {}
      Object.values(outputs).forEach((output) => {
        output.connections.forEach((conn) => {
          const fromUid = uidMap[node.id]
          const toUid = uidMap[conn.node]
          if (fromUid && toUid) {
            edges.push({ from: fromUid, to: toUid })
          }
        })
      })
    })

    const payload = {
      workflow: {
        name: this.nameInputTarget.value,
        description: this.descriptionInputTarget.value,
        status: this.statusSelectTarget.value,
        nodes: nodes,
        edges: edges
      }
    }

    const headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'X-CSRF-Token': this.csrfToken() }
    const url = this.currentWorkflowId ? `/admin/workflows/${this.currentWorkflowId}` : '/admin/workflows'
    const method = this.currentWorkflowId ? 'PUT' : 'POST'

    const response = await fetch(url, { method, headers, body: JSON.stringify(payload) })
    if (response.ok) {
      const data = await response.json()
      this.currentWorkflowId = data.id
      alert("Workflow saved")
    } else {
      const data = await response.json()
      alert(`Save failed: ${data.errors?.join(", ")}`)
    }
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta && meta.content
  }
}
