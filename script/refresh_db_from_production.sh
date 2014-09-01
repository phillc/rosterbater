rake db:drop && heroku pg:pull DATABASE_URL kapsh_development --app=kapsh && rake db:migrate && rake db:test:prepare
