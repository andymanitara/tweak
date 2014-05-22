exports.config =
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/tweak.js': /^app(\/|\\)(?!(header|.*(_test)))/
        'javascripts/tests.js': /^app(\/|\\).*(?=_test)/
        'javascripts/header.js': /^app(\/|\\)(?=header)/
        'javascripts/vendor.js': /^(?!app)/
      order:
        before: [
          'app/tweak.coffee',
          'app/lib/common.coffee',
          'app/lib/helpers.coffee',
          'app/lib/events.coffee',
          'app/lib/model.coffee',
          'app/lib/component.coffee',
          'app/lib/collection.coffee',
          'app/lib/components.coffee',
          'app/lib/controller.coffee',
          'app/lib/view.coffee',
          'app/lib/router.coffee',
          'app/lib/sync.coffee'
        ]

    stylesheets:
      joinTo: 'stylesheets/vendor.css': /^(?!app)/

  plugins:
    autoReload:
      port: [1234, 2345, 3456]
      delay: 200 if require('os').platform() is 'win32'

  server:
    port: 3455
  
  modules:
    definition:false
    wrapper: (path, data) ->
      """
    ;\n(function(window){
    #{data}
    })(window); \n\n
      """    