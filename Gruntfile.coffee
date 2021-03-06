"use strict"
module.exports = (grunt) ->

  # Load all grunt tasks
  require("jit-grunt") grunt,
    "bump-commit": "grunt-bump"
    "bump-only": "grunt-bump"
    gitclean: "grunt-git"
    gitclone: "grunt-git"
    gitpull: "grunt-git"
    gitreset: "grunt-git"
    replace: "grunt-text-replace"
    usebanner: "grunt-banner"

  # Track tasks load time
  require("time-grunt") grunt

  # Project configurations
  grunt.initConfig
    config:
      cfg: grunt.file.readYAML("_config.yml")
      pkg: grunt.file.readJSON("package.json")
      honne: grunt.file.readYAML("_honne/_config.yml")
      deploy: grunt.file.readYAML("_deploy.yml")
      app: "<%= config.cfg.source %>"
      dist: "<%= config.cfg.destination %>"
      base: "<%= config.cfg.base %>"
      banner: do ->
        banner = "<!--\n"
        banner += " © <%= config.pkg.author %>.\n"
        banner += " <%= config.pkg.name %> - v<%= config.pkg.version %>\n"
        banner += " -->"
        banner

    honne:
      base: "_honne"
      core: "<%= honne.base %>/core"
      user:
        assets: "<%= config.app %>/assets"
      theme:
        assets: "<%= honne.user.assets %>/themes/<%= honne.theme.current %>"
        current: "<%= config.honne.theme %>"
        new_name: grunt.option("theme") or "<%= honne.theme.current %>"
        new_author: grunt.option("user") or "honne"

    coffeelint:
      options:
        indentation: 2
        no_stand_alone_at:
          level: "error"
        no_empty_param_list:
          level: "error"
        max_line_length:
          level: "ignore"

      gruntfile:
        src: ["Gruntfile.coffee"]

    lesslint:
      options:
        csslint:
          csslintrc: "<%= honne.theme.assets %>/_less/.csslintrc"

      test:
        src: ["<%= honne.theme.assets %>/_less/**/app*.less"]

    watch:
      options:
        spawn: false

      coffee:
        files: ["<%= coffeelint.gruntfile.src %>"]
        tasks: ["coffeelint:gruntfile"]

      js:
        files: ["<%= config.app %>/**/_js/*.js"]
        tasks: ["copy:serve"]
        options:
          interrupt: true

      less:
        files: ["<%= config.app %>/**/_less/*.less"]
        tasks: [
          "less:serve"
          "postcss:serve"
        ]
        options:
          interrupt: true

      jekyll:
        files: ["<%= config.app %>/**/*", "!_*", "_config*.yml"]
        tasks: [
          "jekyll:serve"
          "newer:leading_quotes"
        ]

    uglify:
      dist:
        options:
          report: "gzip"
          compress:
            drop_console: true

        files: [
          {
            expand: true
            cwd: "<%= honne.user.assets %>/_js/"
            src: ["**/*.js", "!*.min.js"]
            dest: "<%= honne.user.assets %>/js/"
          }
          {
            expand: true
            cwd: "<%= honne.theme.assets %>/_js/"
            src: ["**/*.js", "!*.min.js"]
            dest: "<%= honne.theme.assets %>/js/"
          }
        ]

    less:
      options:
        strictMath: true

      serve:
        options:
          sourceMap: true
          sourceMapFileInline: true
          outputSourceFiles: true

        files: [
          expand: true
          cwd: "<%= honne.theme.assets %>/_less/"
          src: ["**/app*.less"]
          dest: "<%= honne.theme.assets %>/css/"
          ext: ".css"
        ]

      dist:
        files: "<%= less.serve.files %>"

    postcss:
      serve:
        src: "<%= honne.theme.assets %>/css/*.css"
        options:
          map:
            inline: true
          processors: [
            require("autoprefixer")(browsers: "last 1 versions")
          ]

      dist:
        src: "<%= postcss.serve.src %>"
        options:
          processors: [
            require("autoprefixer")(browsers: "last 2 versions")
          ]

    csscomb:
      options:
        config: "<%= honne.theme.assets %>/_less/.csscomb.json"

      dist:
        files: [
          expand: true
          cwd: "<%= less.serve.files.0.dest %>"
          src: ["*.css"]
          dest: "<%= less.serve.files.0.dest %>"
          ext: ".css"
        ]

    htmlmin:
      dist:
        options:
          removeComments: true
          removeCommentsFromCDATA: true
          removeCDATASectionsFromCDATA: true
          collapseWhitespace: true
          conservativeCollapse: true
          collapseBooleanAttributes: true
          removeAttributeQuotes: true
          removeRedundantAttributes: true
          useShortDoctype: false
          removeEmptyAttributes: true
          removeOptionalTags: true
          removeEmptyElements: false
          lint: false
          keepClosingSlash: false
          caseSensitive: true
          minifyJS: true
          minifyCSS: true

        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: "**/*.html"
          dest: "<%= config.dist %>"
        ]

    xmlmin:
      dist:
        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: "**/*.xml"
          dest: "<%= config.dist %>"
        ]

    minjson:
      dist:
        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: "**/*.json"
          dest: "<%= config.dist %>"
        ]

    cssmin:
      dist:
        options:
          report: "gzip"

        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: ["**/*.css", "!*.min.css"]
          dest: "<%= config.dist %>"
        ]

      # html:
      #   expand: true
      #   cwd: "<%= config.dist %>"
      #   src: "**/*.html"
      #   dest: "<%= config.dist %>"

    assets_inline:
      options:
        jsDir: "<%= config.dist %>"
        cssDir: "<%= config.dist %>"
        assetsDir: "<%= config.dist %>"
        includeTag: "?assets-inline"
        inlineImg: false
        inlineSvg: true
        inlineSvgBase64: false
        assetsUrlPrefix: "<%= config.base %>/assets/"
        deleteOriginals: true

      dist:
        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: "**/*.html"
          dest: "<%= config.dist %>"
        ]

    leading_quotes:
      options:
        elements: "p, li, h1, h2, h3, h4, h5, h6"
        class: "leading-indent-fix"
        verbose: true

      main:
        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: "**/*.html"
          dest: "<%= config.dist %>"
        ]

    cacheBust:
      options:
        algorithm: "md5"
        assets: ["<%= honne.user.assets %>/**/*"]
        baseDir: "<%= config.dist %>"
        deleteOriginals: true
        encoding: "utf8"
        length: 8

      dist:
        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: "**/*.html"
        ]

    usebanner:
      options:
        position: "bottom"
        banner: "<%= config.banner %>"

      dist:
        files:
          src: ["<%= config.dist %>/**/*.html"]

    jekyll:
      options:
        bundleExec: true

      serve:
        options:
          config: "_config.yml,_honne/_config.yml,<%= config.app %>/_data/<%= honne.theme.current %>.yml,_config.dev.yml"
          drafts: true
          future: true

      dist:
        options:
          config: "_config.yml,_honne/_config.yml,<%= config.app %>/_data/<%= honne.theme.current %>.yml"
          dest: "<%= config.dist %><%= config.base %>"

    shell:
      options:
        stdout: true

      # Direct sync compiled static files to remote server
      sync_server:
        command: "rsync -avz -e 'ssh -p <%= config.deploy.sftp.port %>' --delete --progress <%= config.deploy.ignore_files %> <%= config.dist %>/ <%= config.deploy.sftp.user %>@<%= config.deploy.sftp.host %>:<%= config.deploy.sftp.dest %> > rsync-sftp.log"

      # Copy compiled static files to local directory for further post-process
      sync_local:
        command: "rsync -avz --delete --progress <%= config.deploy.ignore_files %> <%= jekyll.dist.options.dest %>/ <%= config.deploy.s3_website.dest %><%= config.base %> > rsync-s3_website.log"

      # Auto commit untracked files sync'ed from sync_local
      sync_commit:
        command: "sh <%= config.deploy.s3_website.dest %>/auto-commit '<%= config.pkg.name %>'"

      honne__core__update_deps:
        command: [
          "bundle update"
          "bundle install"
          "npm install"
        ].join("&&")

      honne__theme__to_app:
        command: [
          "rsync -avz --delete --progress <%= honne.base %>/themes/<%= honne.theme.new_name %>/config.yml <%= config.app %>/_data/<%= honne.theme.new_name %>.yml"
          "rsync -avz --delete --progress <%= honne.base %>/themes/<%= honne.theme.new_name %>/includes/  <%= config.app %>/_includes/themes/<%= honne.theme.new_name %>/includes/"
          "rsync -avz --delete --progress <%= honne.base %>/themes/<%= honne.theme.new_name %>/layouts/   <%= config.app %>/_includes/themes/<%= honne.theme.new_name %>/layouts/"
          "rsync -avz --delete --progress <%= honne.base %>/themes/<%= honne.theme.new_name %>/assets/    <%= config.app %>/assets/themes/<%= honne.theme.new_name %>/"
          "rsync -avz --delete --progress <%= honne.base %>/themes/<%= honne.theme.new_name %>/pages/     <%= config.app %>/_pages/themes/<%= honne.theme.new_name %>/"
        ].join("&&")

      honne__theme__to_cache:
        command: [
          "rsync -avz --delete --progress <%= config.app %>/_data/<%= honne.theme.current %>.yml                  <%= honne.base %>/themes/<%= honne.theme.current %>/config.yml"
          "rsync -avz --delete --progress <%= config.app %>/_includes/themes/<%= honne.theme.current %>/includes/ <%= honne.base %>/themes/<%= honne.theme.current %>/includes/"
          "rsync -avz --delete --progress <%= config.app %>/_includes/themes/<%= honne.theme.current %>/layouts/  <%= honne.base %>/themes/<%= honne.theme.current %>/layouts/"
          "rsync -avz --delete --progress <%= config.app %>/assets/themes/<%= honne.theme.current %>/             <%= honne.base %>/themes/<%= honne.theme.current %>/assets/"
          "rsync -avz --delete --progress <%= config.app %>/_pages/themes/<%= honne.theme.current %>/             <%= honne.base %>/themes/<%= honne.theme.current %>/pages/"
        ].join("&&")

      honne__theme__to_dev_repo:
        command: "rsync -avz --delete --progress --exclude=.git --exclude=node_modules <%= honne.base %>/themes/<%= honne.theme.current %>/ /Users/sparanoid/Git/honne-<%= honne.theme.current %> > rsync-theme-dev.log"

    concurrent:
      options:
        logConcurrentOutput: true

      dist:
        tasks: [
          "htmlmin"
          "xmlmin"
          "minjson"
        ]

    copy:
      serve:
        files: [
          {
            expand: true
            dot: true
            cwd: "<%= honne.user.assets %>/_js/"
            src: ["**/*.js"]
            dest: "<%= honne.user.assets %>/js/"
          }
          {
            expand: true
            dot: true
            cwd: "<%= honne.theme.assets %>/_js/"
            src: ["**/*.js"]
            dest: "<%= honne.theme.assets %>/js/"
          }
        ]

      honne__core__to_app:
        files: [
          {
            expand: true
            dot: true
            cwd: "<%= honne.core %>"
            src: [
              ".*"
              "*.json"
              "*.md"
              "*.yml"
              "Gemfile"
              "Gruntfile*" # Comment this when debugging this task
              "LICENSE"
              "package.json"
              "!.DS_Store"
              "!TODOS.md"
            ]
            dest: "./"
          }
          {
            expand: true
            dot: true
            cwd: "<%= honne.core %>/_app/"
            src: [
              "*.json"
              "*.txt"
              "*.xml"
            ]
            dest: "<%= config.app %>"
          }
          {
            expand: true
            dot: true
            cwd: "<%= honne.core %>/_app/_includes/"
            src: [
              "_honne.html"
            ]
            dest: "<%= config.app %>/_includes/"
          }
          {
            expand: true
            dot: true
            cwd: "<%= honne.core %>/_app/_layouts/"
            src: ["**"]
            dest: "<%= config.app %>/_layouts/"
          }
        ]

    gitclone:
      honne__core__add_remote:
        options:
          repository: "https://github.com/sparanoid/almace-scaffolding.git"
          branch: "master"
          directory: "<%= honne.base %>/core/"

      honne__theme__add_remote:
        options:
          repository: "https://github.com/<%= honne.theme.new_author %>/honne-<%= honne.theme.new_name %>.git"
          branch: "master"
          directory: "<%= honne.base %>/themes/<%= honne.theme.new_name %>/"

    gitpull:
      honne__core__update_remote:
        options:
          cwd: "<%= honne.base %>/core/"

      honne__theme__update_remote:
        options:
          cwd: "<%= honne.base %>/themes/<%= honne.theme.current %>/"

    gitclean:
      options:
        nonstandard: true
        directories: true

      honne__core__clean_git:
        options:
          cwd: "<%= gitpull.honne__core__update_remote.options.cwd %>"

      honne__theme__clean_git:
        options:
          cwd: "<%= gitpull.honne__theme__update_remote.options.cwd %>"

    gitreset:
      options:
        mode: "hard"

      honne__core__reset_git:
        options:
          cwd: "<%= gitpull.honne__core__update_remote.options.cwd %>"

      honne__theme__reset_git:
        options:
          cwd: "<%= gitpull.honne__theme__update_remote.options.cwd %>"

    clean:
      main:
        src: [
          ".tmp"
          "<%= config.dist %>"
          "<%= config.app %>/.jekyll-metadata"
          "<%= honne.theme.assets %>/css/"
          "<%= honne.theme.assets %>/js/"
          "<%= honne.user.assets %>/css/"
          "<%= honne.user.assets %>/js/"
        ]

    cleanempty:
      dist:
        src: ["<%= config.dist %>/**/*"]

    replace:
      honne__theme__update_config:
        src: ["<%= honne.base %>/_config.yml"]
        dest: "<%= honne.base %>/_config.yml"
        replacements: [
          {
            from: /(theme:)( +)(.+)/g
            to: "$1$2<%= honne.theme.new_name %>"
          }
        ]

      honne__site__update_version:
        src: ["<%= config.app %>/_pages/index.html"]
        dest: "<%= config.app %>/_pages/index.html"
        replacements: [
          {
            from: /("honne-version">)\d+\.\d+\.\d+/g
            to: "$1<%= config.pkg.version %>"
          }
        ]

    browserSync:
      bsFiles:
        src: ["<%= config.dist %>/**"]
      options:
        watchTask: true
        server:
          baseDir: "<%= config.dist %>"
        port: "<%= config.cfg.port %>"
        ghostMode:
          clicks: true
          scroll: true
          location: true
          forms: true
        logFileChanges: false
        snippetOptions:
          rule:
            match: /<!-- BS_INSERT -->/i
            fn: (snippet, match) ->
              match + snippet
        # Uncomment the following options for client presentation
        # tunnel: "<%= config.pkg.name %>"
        # online: true
        open: true
        browser: [
          "google chrome"
        ]
        notify: true

    conventionalChangelog:
      options:
        changelogOpts:
          preset: "angular"

      dist:
        src: "CHANGELOG.md"

    bump:
      options:
        files: ["package.json"]
        updateConfigs: ["config.pkg"]
        commitMessage: "chore: release v%VERSION%"
        commitFiles: ["-a"]
        tagMessage: "chore: create tag %VERSION%"
        push: false

  grunt.registerTask "theme-upgrade", "Upgrade specific theme from honne cache to app", [
    "shell:honne__theme__to_app"
  ]

  grunt.registerTask "theme-save", "Save current (previously activated) theme to honne cache", ->
    grunt.task.run [
      "shell:honne__theme__to_cache"
    ]
    if grunt.option("dev")
      grunt.task.run [
        "shell:honne__theme__to_dev_repo"
      ]

  grunt.registerTask "theme-activate", "Activate specific theme", [
    "theme-upgrade"
    "theme-save"
    "replace:honne__theme__update_config"
  ]

  grunt.registerTask "theme-add", "Add new theme from a GitHub repo", [
    "gitclone:honne__theme__add_remote"
    "theme-activate"
  ]

  grunt.registerTask "theme-update", "Update current theme from GitHub", [
    "gitreset:honne__theme__reset_git"
    "gitclean:honne__theme__clean_git"
    "gitpull:honne__theme__update_remote"
    "theme-upgrade"
  ]

  grunt.registerTask "honne-update", "Update ASMF", ->
    # TODO: need better implement
    if grunt.file.exists("_honne/core/")
      grunt.task.run [
        "gitreset:honne__core__reset_git"
        "gitclean:honne__core__clean_git"
        "gitpull:honne__core__update_remote"
      ]
    else
      grunt.task.run [
        "gitclone:honne__core__add_remote"
      ]
    grunt.task.run [
      "copy:honne__core__to_app"
      "shell:honne__core__update_deps"
    ]

  grunt.registerTask "init", "Initialize new project", [
    "theme-add"
  ]

  grunt.registerTask "update", "Update honne and the activated theme", [
    "honne-update"
    "theme-update"
  ]

  grunt.registerTask "serve", "Fire up a server on local machine for development", [
    "clean:main"
    "copy:serve"
    "less:serve"
    "postcss:serve"
    "jekyll:serve"
    "leading_quotes:main"
    "browserSync"
    "watch"
  ]

  grunt.registerTask "test", "Build test task", ->
    grunt.task.run [
      "build"
    ]
    if !grunt.option("local")
      grunt.task.run [
        "theme-add"
        "theme-update"
        "theme-save"
        "honne-update"
      ]

  grunt.registerTask "build", "Build site with jekyll", [
    "clean:main"
    "coffeelint"
    "uglify"
    "lesslint"
    "less:dist"
    "postcss:dist"
    "csscomb"
    "jekyll:dist"
    "leading_quotes:main"
    "cssmin"
    "assets_inline"
    "cacheBust"
    "concurrent:dist"
    "usebanner"
    "cleanempty"
  ]

  # Release new version
  grunt.registerTask "release", "Build, bump and commit", (type) ->
    grunt.task.run [
      "bump-only:#{type or 'patch'}"
      "conventionalChangelog"
      "replace:honne__site__update_version"
      "bump-commit"
    ]

  grunt.registerTask "sync", "Build site + rsync static files to remote server",  ->
    grunt.task.run [
      "build"
      "shell:sync_local"
    ]
    if grunt.option("deploy")
      grunt.task.run [
        "shell:sync_commit"
      ]

  grunt.registerTask "default", "Default task aka. build task", [
    "build"
  ]
