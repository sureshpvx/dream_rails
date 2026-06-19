import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "player",
    "toggleButton",
    "filterButton",
    "selectedInputs",
    "captainInput",
    "viceCaptainInput",
    "totalCount",
    "remaining",
    "wkCount",
    "batCount",
    "arCount",
    "bowCount",
    "teamSpread",
    "captainSummary",
    "validationMessage",
    "submitButton"
  ]

  connect() {
    this.selectedIds = new Set()
    this.captainId = null
    this.viceCaptainId = null
    this.activeRole = "all"
    this.update()
    this.updateFilters()
  }

  togglePlayer(event) {
    const card = this.cardFromEvent(event)
    const id = card.dataset.playerId

    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id)
      if (this.captainId === id) this.captainId = null
      if (this.viceCaptainId === id) this.viceCaptainId = null
    } else if (this.selectedIds.size < 11) {
      this.selectedIds.add(id)
    }

    this.update()
  }

  setCaptain(event) {
    const card = this.cardFromEvent(event)
    const id = card.dataset.playerId
    this.selectedIds.add(id)
    this.captainId = id
    if (this.viceCaptainId === id) this.viceCaptainId = null
    this.update()
  }

  setViceCaptain(event) {
    const card = this.cardFromEvent(event)
    const id = card.dataset.playerId
    this.selectedIds.add(id)
    this.viceCaptainId = id
    if (this.captainId === id) this.captainId = null
    this.update()
  }

  filter(event) {
    this.activeRole = event.currentTarget.dataset.role
    this.updateFilters()
  }

  update() {
    const stats = this.stats()
    const remaining = 100 - stats.budget
    const errors = this.validationErrors(stats, remaining)

    this.totalCountTarget.textContent = this.selectedIds.size
    this.remainingTarget.textContent = remaining.toFixed(1)
    this.wkCountTarget.textContent = `${stats.roles.wicket_keeper}/1-4`
    this.batCountTarget.textContent = `${stats.roles.batsman}/3-6`
    this.arCountTarget.textContent = `${stats.roles.all_rounder}/1-4`
    this.bowCountTarget.textContent = `${stats.roles.bowler}/3-6`
    this.teamSpreadTarget.textContent = this.teamSpreadText(stats.teams)
    this.captainSummaryTarget.textContent = this.captainText()
    this.validationMessageTarget.textContent = errors[0] || "Team is valid."
    this.submitButtonTarget.disabled = errors.length > 0
    this.captainInputTarget.value = this.captainId || ""
    this.viceCaptainInputTarget.value = this.viceCaptainId || ""

    this.syncHiddenInputs()
    this.updateCards()
  }

  updateCards() {
    this.playerTargets.forEach((card) => {
      const id = card.dataset.playerId
      const selected = this.selectedIds.has(id)
      const buttons = card.querySelectorAll(".icon-choice")

      card.classList.toggle("is-selected", selected)
      card.querySelector("[data-team-builder-target='toggleButton']").textContent = selected ? "Remove" : "Add"
      buttons[0].classList.toggle("is-active", this.captainId === id)
      buttons[1].classList.toggle("is-active", this.viceCaptainId === id)
    })
  }

  updateFilters() {
    this.playerTargets.forEach((card) => {
      const hidden = this.activeRole !== "all" && card.dataset.playerRole !== this.activeRole
      card.classList.toggle("is-filtered-out", hidden)
    })

    this.filterButtonTargets.forEach((button) => {
      button.classList.toggle("border-green-500", button.dataset.role === this.activeRole)
      button.classList.toggle("text-green-600", button.dataset.role === this.activeRole)
    })
  }

  syncHiddenInputs() {
    this.selectedInputsTarget.innerHTML = ""

    this.selectedIds.forEach((id) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "user_team[player_ids][]"
      input.value = id
      this.selectedInputsTarget.appendChild(input)
    })
  }

  stats() {
    const roles = { wicket_keeper: 0, batsman: 0, all_rounder: 0, bowler: 0 }
    const teams = {}
    let budget = 0

    this.playerTargets.forEach((card) => {
      if (!this.selectedIds.has(card.dataset.playerId)) return

      roles[card.dataset.playerRole] += 1
      teams[card.dataset.playerTeam] = (teams[card.dataset.playerTeam] || 0) + 1
      budget += Number.parseFloat(card.dataset.playerPrice)
    })

    return { roles, teams, budget }
  }

  validationErrors(stats, remaining) {
    const errors = []

    if (this.selectedIds.size !== 11) errors.push("Your team must have exactly 11 players")
    if (remaining < 0) errors.push("Team cost exceeds 100 credits")
    if (!this.captainId) errors.push("Please select a Captain")
    if (!this.viceCaptainId) errors.push("Please select a Vice-Captain")
    if (this.captainId && this.captainId === this.viceCaptainId) errors.push("Captain and Vice-Captain must be different")
    if (stats.roles.wicket_keeper < 1 || stats.roles.wicket_keeper > 4) errors.push("Select 1-4 Wicket-Keepers")
    if (stats.roles.batsman < 3 || stats.roles.batsman > 6) errors.push("Select 3-6 Batsmen")
    if (stats.roles.bowler < 3 || stats.roles.bowler > 6) errors.push("Select 3-6 Bowlers")
    if (stats.roles.all_rounder < 1 || stats.roles.all_rounder > 4) errors.push("Select 1-4 All-Rounders")
    if (Object.values(stats.teams).some((count) => count > 7)) errors.push("Maximum 7 players from one team")

    return errors
  }

  teamSpreadText(teams) {
    const names = Object.keys(teams)
    if (names.length === 0) return "No players selected"

    return names.map((team) => `${team}: ${teams[team]}`).join(" / ")
  }

  captainText() {
    const captain = this.playerName(this.captainId)
    const viceCaptain = this.playerName(this.viceCaptainId)

    if (!captain && !viceCaptain) return "Captain and Vice-Captain pending"
    return `C: ${captain || "-"} / VC: ${viceCaptain || "-"}`
  }

  playerName(id) {
    if (!id) return null

    const card = this.playerTargets.find((playerCard) => playerCard.dataset.playerId === id)
    return card?.querySelector("p")?.textContent.trim()
  }

  cardFromEvent(event) {
    return event.currentTarget.closest("[data-team-builder-target='player']")
  }
}
