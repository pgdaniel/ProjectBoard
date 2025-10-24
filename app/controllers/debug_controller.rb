class DebugController < ApplicationController
  def tree
    @organizations = Organization.includes(
      teams: [
        { team_members: :user },
        { projects: [
          { epics: :stories },
          :stories
        ] }
      ],
      projects: [
        { epics: :stories },
        :stories
      ]
    ).all

    @users = User.includes(:teams, :stories).all
  end
end
