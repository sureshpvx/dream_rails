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

  def icon_for_notification(type)
    icon_class = case type
    when "contest_full"
      "text-green-600"
    when "match_live"
      "text-red-600"
    when "match_completed"
      "text-gray-600"
    when "prize_won"
      "text-amber-600"
    when "team_reminder"
      "text-blue-600"
    else
      "text-gray-500"
    end

    content_tag :span, class: "inline-block w-2 h-2 rounded-full #{icon_class.gsub('text-', 'bg-')}" do; end
  end

  def link_to_reference(reference)
    case reference
    when Contest
      link_to "View Contest", contest_path(reference), class: "text-sm text-green-600 font-medium hover:underline"
    when Match
      link_to "View Match", match_path(reference), class: "text-sm text-green-600 font-medium hover:underline"
    when UserTeam
      link_to "View Team", user_team_path(reference), class: "text-sm text-green-600 font-medium hover:underline"
    else
      ""
    end
  end

  def active_link_class(path, base_class = "")
    current_page?(path) ? "#{base_class} bg-green-50 text-green-700" : base_class
  end
end
