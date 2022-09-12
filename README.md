# Identity Matching RI Client
Reference implementation (RI) client for [Interoperable Identity and Patient Matching](http://build.fhir.org/ig/HL7/fhir-identity-matching-ig/) and [UDAP Security](https://build.fhir.org/ig/HL7/fhir-udap-security-ig/) implementation guides.

## Dependencies
 - [Ruby 3.1.2](https://www.ruby-lang.org/en/)
 - [Ruby Bundler](https://bundler.io)
 - [Postgresql](https://www.postgresql.org/)
 - [Sass](https://sass-lang.com/)
 - [Yarn](https://yarnpkg.com/)
 - [ESBuild](https://esbuild.github.io/)

## Quickstart
1. Install libraries
```bash
$ yarn install
$ bundle install
```

2. Setup database
```bash
$ rails db:create
$ rails db:migrate
```

3. Ensure Rails assets pipeline works
```
$ rails assets:precompile
```

4. Add security credentials if any
 - `export BEARER_TOKEN=[your token]` for hard coded token-based authorization OR
 - `export CLIENT_ID=[your app id] CLIENT_SECRET=[your secret]` as pre-registered OAuth2 client

Alternatively you can create a [.env](https://github.com/bkeepers/dotenv#usage) file and set the environment variables, for example:
```dotenv
# .env
CLIENT_ID=[your app id]
CLIENT_SECRET=[your secret]
```

5. Launch server
```bash
$ rails server
```

6. Go to <http://localhost:3000>

## License

Copyright 2022 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
