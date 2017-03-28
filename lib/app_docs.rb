class AppDocs
  def self.pages
    YAML.load_file('data/applications.yml').map do |app_data|
      App.new(app_data)
    end
  end

  def self.app_data
    @publishing_app_data ||= AppData.new
  end

  class App
    attr_reader :app_data

    def initialize(app_data)
      @app_data = app_data
    end

    def retired?
      app_data["retired"]
    end

    def page_title
      if retired?
        "Application: #{app_name} (retired)"
      else
        "Application: #{app_name}"
      end
    end

    def app_name
      app_data["app_name"] || github_repo_name
    end

    def example_published_pages
      AppDocs.app_data.publishing_examples[app_name]
    end

    def example_rendered_pages
      AppDocs.app_data.rendering_examples[app_name]
    end

    def github_repo_name
      app_data.fetch("github_repo_name")
    end

    def repo_url
      app_data["repo_url"] || "https://github.com/alphagov/#{github_repo_name}"
    end

    def puppet_url
      "https://github.com/alphagov/govuk-puppet/blob/master/modules/govuk/manifests/apps/#{puppet_name}.pp"
    end

    def deploy_url
      "https://github.com/alphagov/govuk-app-deployment/blob/master/#{github_repo_name}/config/deploy.rb"
    end

    def type
      app_data.fetch("type")
    end

    def team
      app_data["team"]
    end

    def description
      app_data["description"] || description_from_github
    end

    def production_url
      app_data["production_url"] || (type.in?(["Publishing app", "Admin app"]) ? "https://#{app_name}.publishing.service.gov.uk" : nil)
    end

    def machine_classes
      all_apps_and_machines[puppet_name].to_a
    end

  private

    def puppet_name
      app_data["puppet_name"] || app_name.underscore
    end

    def description_from_github
      repo = GitHub.client.repo(github_repo_name)
      repo["description"]
    end

    # Look into the YAML configs in puppet for all the classes where our
    # applications live (this excludes machines that do databases only, like
    # redis or mysql).
    def all_apps_and_machines
      @@all_apps_and_machines ||= begin
        apps = {}
        %w[
          api
          backend
          cache
          calculators_frontend
          content_store
          draft_cache
          draft_content_store
          draft_frontend
          frontend
          mapit
          router_backend
          search
          whitehall_backend
          whitehall_frontend
        ].map do |klass|
          data = HTTP.get_yaml("https://raw.githubusercontent.com/alphagov/govuk-puppet/master/hieradata/class/#{klass}.yaml")

          data["govuk::node::s_base::apps"].each do |app|
            apps[app] ||= []
            apps[app] << klass.gsub("_", "-")
          end
        end
        apps
      end
    end
  end
end
