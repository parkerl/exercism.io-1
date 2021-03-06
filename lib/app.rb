require 'exercism'
require 'sinatra/petroglyph'
require 'will_paginate'
require 'will_paginate/active_record'

require 'app/presenters/workload'
require 'app/presenters/profile'
require 'app/presenters/sharing'

require 'app/stats'
require 'app/site'
require 'app/account'
require 'app/auth'
require 'app/help'
require 'app/code'
require 'app/comments'
require 'app/nitpick'
require 'app/submissions'
require 'app/teams'

# Must be included at this point in order
require 'app/exercises'
require 'app/user'
require 'app/not_found'

require 'redesign/helpers/article'
require 'redesign/helpers/fuzzy_time'
require 'redesign/helpers/session'
require 'app/helpers/gravatar_helper'
require 'app/helpers/profile_helper'
require 'app/helpers/site_title_helper'
require 'app/helpers/submissions_helper'
require 'redesign/helpers/markdown'

require 'services'

class ExercismApp < Sinatra::Base

  set :environment, ENV.fetch('RACK_ENV') { :development }.to_sym
  set :root, 'lib/app'
  set :method_override, true

  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') { "Need to know only." }
  use Rack::Flash

  helpers ExercismIO::Helpers::FuzzyTime
  helpers ExercismIO::Helpers::Article
  helpers ExercismIO::Helpers::Markdown
  helpers WillPaginate::Sinatra::Helpers
  helpers Sinatra::SubmissionsHelper
  helpers Sinatra::SiteTitleHelper
  helpers Sinatra::GravatarHelper
  helpers Sinatra::ProfileHelper
  helpers ExercismIO::Helpers::Session

  helpers do
    def github_client_id
      ENV.fetch('EXERCISM_GITHUB_CLIENT_ID')
    end

    def github_client_secret
      ENV.fetch('EXERCISM_GITHUB_CLIENT_SECRET')
    end

    def host
      request.host_with_port + root_path
    end

    def site_root
      host
    end

    def root_path
      '/'
    end

    def link_to(path)
      File.join(root_path, path)
    end

    def language_icon(language,html={})
      %{<div class="language circle #{html[:class]} #{language}-icon">&nbsp;</div>}
    end

    def path_for(language=nil, section='nitpick')
      if language
        "/#{section}/#{language.downcase}"
      else
        "/"
      end
    end

    def language_path_for_slug(language, slug)
      path_for(language) + "/#{slug}"
    end

    def active_nav(path)
      if path == request.path_info
        "active"
      else
        ""
      end
    end

    def nav_text(slug)
      slug.split("-").map(&:capitalize).join(" ")
    end

    def dashboard_assignment_section_nav(language, slug)
      path = language_path_for_slug(language, slug)
      %{<li class="#{active_nav(path)}">
          <a href="#{path}">#{nav_text(slug)}</a>
        </li>}
    end

    def dashboard_assignment_nav(language, slug=nil, counts=nil)
      return if !counts || counts.zero?

      path = language_path_for_slug(language, slug)
      %{<li class="#{active_nav(path)}">
          <a href="#{path}">#{nav_text(slug)} (#{counts})</a>
        </li>}
    end

    def show_pending_submissions?(language)
      (!language && current_user.nitpicker?) || (language && current_user.nitpicks_trail?(language))
    end

    def nitpicker_languages
      Exercism::Config.languages.map(&:to_s) & current_user.nitpicker_languages
    end
  end
end
