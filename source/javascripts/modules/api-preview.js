(function($, Modules) {
  'use strict';

  Modules.ApiPreview = function ApiPreview() {
    this.start = function start() {
      $('.preview-button').click(function () {
        var $container = $(this).parent();
        var $output = $container.find('.api-output');

        var url = $container.find('.url-input').val();
        $.getJSON(url, function (data) {
          var prettyPrintedOutput = JSON.stringify(data, null, 2);
          $output.text(prettyPrintedOutput);
        }).fail(function (e) {
          $output.text("An error occurred. Check the browser console for more info.");
        })

        return false;
      })
    };
  }
})(jQuery, window.GOVUK.Modules);
