exports.config =
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'scripts/tweak.js': /^app(\/|\\)(?!((lib(\/|\\)(view_))|header|.*(_test)))/
        'scripts/etc/tests.js': /^app(\/|\\).*(?=_test)/
        'scripts/etc/header.js': /^app(\/|\\)(?=header)/
        'scripts/etc/vendor.js': /^(?!app)/
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
          'app/lib/history.coffee',
          'app/lib/router.coffee',
          'app/lib/component.coffee',
          'app/lib/components.coffee'
        ]

    stylesheets:
      joinTo: 'styles/vendor.css': /^(?!app)/
  
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