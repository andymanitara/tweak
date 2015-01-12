exports.config =
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/tweak.js': /^app(\/|\\)(?!((lib(\/|\\)(view_advanced|component|components))|header|.*(_test)))/
        'javascripts/tweak.component.js': /^app(\/|\\)lib(\/|\\)(component|components)/
        'javascripts/tweak.view.advanced.js': /^app(\/|\\)lib(\/|\\)view_advanced/
        'javascripts/etc/tests.js': /^app(\/|\\).*(?=_test)/
        'javascripts/etc/header.js': /^app(\/|\\)(?=header)/
        'javascripts/etc/vendor.js': /^(?!app)/
      order:
        before: [
          'app/tweak.coffee',
          'app/lib/class.coffee',
          'app/lib/common.coffee',
          'app/lib/events.coffee',
          'app/lib/store.coffee',
          'app/lib/model.coffee',
          'app/lib/collection.coffee',
          'app/lib/controller.coffee',
          'app/lib/view.coffee',
          'app/lib/router.coffee',
          'app/lib/component.coffee',
          'app/lib/components.coffee',
          'app/lib/view_advanced.coffee'
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

  overrides:
    production:
      optimize: false
      sourceMaps: true
      plugins: autoReload: enabled: false