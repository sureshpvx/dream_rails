class UserTeamPlayer < ApplicationRecord
  belongs_to :user_team
  belongs_to :player

  validates :player_id, uniqueness: { scope: :user_team_id }
end
