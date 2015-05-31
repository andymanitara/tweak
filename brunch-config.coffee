exports.config =
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'scripts/tweak.js': /^app(\/|\\)(?!((lib(\/|\\)(view_))|header|.*(_test)))/
        'scripts/tweak.min.js': /^app(\/|\\)(?!((lib(\/|\\)(view_))|header|.*(_test)))/
        'scripts/etc/tests.js': /^app(\/|\\).*(?=_test)/
        'scripts/etc/header.js': /^app(\/|\\)(?=header)/
        'scripts/etc/vendor.js': /^(?!app)/
      order:
        before: [
          'app/tweak.coffee',
          'app/lib/class.coffee',
          'app/lib/events.coffee',
          'app/lib/common.coffee',
          'app/lib/store.coffee',
          'app/lib/collection.coffee',
          'app/lib/components.coffee'
        ]

    stylesheets:
      joinTo: 'styles/vendor.css': /^(?!app)/
  
  plugins:
    on: ['uglify-js-brunch']
    uglify:
      ignored: /tweak\.js|header\.js|tests\.js|vendor\.js/

  modules:
    definition: false
    wrapper: false
      
  overrides:
    production:
      sourceMaps: true