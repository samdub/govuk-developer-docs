module ApiPreview
  def api_preview(url)
    partial 'partials/api_preview', locals: { url: url }
  end
end
