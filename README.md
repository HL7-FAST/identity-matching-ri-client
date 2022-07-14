# Identity Matching RI Client
Identity Matching Reference Implementation client web app as required by the HL7 FAST project (for healthcare interoperability scaling).

## Dependencies
 - [Ruby 3.1.2](https://www.ruby-lang.org/en/)
 - [Ruby Bundler](https://bundler.io)
 - [SQLite](https://www.sqlite.org/index.html)
 - [Sass](https://sass-lang.com/)
 - [Yarn](https://yarnpkg.com/)
 - [ESBuild](https://esbuild.github.io/)

## Quickstart
From in repo,
```
yarn install
bundle install
rails db:migrate
rails assets:precompile
./bin/dev
```

## License

Copyright 2022 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
