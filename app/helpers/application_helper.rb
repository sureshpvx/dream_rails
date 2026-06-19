module ApplicationHelper
  def money(amount)
    number_to_currency(amount, unit: "Rs ", precision: 2)
  end

  def credits(amount)
    number_with_precision(amount, precision: 1, strip_insignificant_zeros: true)
  end

  def status_class(status)
    {
      "live" => "badge-live",
      "upcoming" => "badge-info",
      "completed" => "badge-success",
      "cancelled" => "badge-muted",
      "abandoned" => "badge-muted",
      "open" => "badge-info",
      "filling" => "badge-warning",
      "full" => "badge-muted"
    }.fetch(status.to_s, "badge-muted")
  end

  def contest_type_label(contest)
    contest.contest_type.humanize
  end

  def role_class(role)
    {
      "wicket_keeper" => "role-wk",
      "batsman" => "role-bat",
      "all_rounder" => "role-ar",
      "bowler" => "role-bow"
    }.fetch(role.to_s, "role-bat")
  end

  def initials(text)
    text.to_s.split.filter_map { |part| part[0] }.first(2).join.upcase
  end
end
