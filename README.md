# README

This README would normally document whatever steps are necessary to get the
application up and running.

Set-up for Amp Nullset:
---
make sure `mysql` is installed.

set the password to user `root` in mysql listed in configs with command.

`mysqladmin -u root password _____`

login to mysql
> `CREATE DATABASE test; CREATE DATABASE development; CREATE DATABASE production;`
> 
> `\q` to quit

`bundle install` requires ruby 2.5.5

`rake db:migrate`

`rake db:seed`

`rails s`

you also might need to  `yarn install --check-files`