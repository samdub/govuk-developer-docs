class StyleGuideDocs
  PAGES = {
    "api" => "API style guide",
    "basic-security" => "Basic security for web applications",
    "css" => "CSS Coding Style",
    "git" => "Git style guide",
    "go" => "Go style guide",
    "html" => "HTML coding style",
    "js" => "JavaScript coding style",
    "pull-requests" => "Pull requests",
    "puppet" => "Puppet style guide",
    "ruby" => "Ruby coding style",
    "rubygems" => "Rubygems",
    "testing" => "Ruby testing",
    "use-of-READMEs" => "READMEs for GOV.UK applications",
    "using-rubocop" => "Using Rubocop",
  }

  def self.pages
    PAGES.map { |k, v| Page.new(k, v) }
  end

  class Page
    attr_reader :filename, :title

    def initialize(filename, title)
      @filename = filename
      @title = title
    end

    def source_url
      "https://github.com/alphagov/styleguides/blob/master/#{filename}.md"
    end

    def edit_url
      "https://github.com/alphagov/styleguides/edit/master/#{filename}.md"
    end

    def raw_source
      "https://raw.githubusercontent.com/alphagov/styleguides/master/#{filename}.md"
    end
  end
end
