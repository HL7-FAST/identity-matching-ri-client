# Identity Matching & UDAP Security RI Client
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
$ rails db:encryption:init
# copy the YML entry for active record encryption
$ rails credentials:edit # this opens an editor - paste the entry above here
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

## Certificate Authorities
If you only want a client for patient identity matching you can disregard the authentication and UDAP security aspects of this RI. If your server only supports the minimal authorization framework with OAuth2, you can manually register this app and obtain an access token, and then upload the access token via the environment variable `BEARER_TOKEN`.

If you want to utilize the UDAP Security aspect of the client, this RI comes with one self-signed Certificate Authority, that you can download the digital certificate for and add to a UDAP server's trusted validation certificates. However, the recommended usage is to upload a PKCS#12 encoded file (*.p12 file) which provides this application with the private key and certificate chain needed for UDAP registration. This application encrypts all saves all (encrypted) private keys and certificates, lets you choose an Authority (which dictates private key and certificate chain), and signs the UDAP registration software statement with subjectAltName `https://test.healthtogo.me/udap-sandbox/mitre`. Attempting UDAP Dynamic Client registration with this app in a local dev environment may fail because the subjectAltName does not match.

Private keys should be handled with utmost secrecy. In practice an application may only utilize one authority (private key and x509 certificate chain), and any authorization/authentication controls should be behind secured access.

## Environment Variables
 - BEARER_TOKEN
 - CLIENT_ID
 - CLIENT_SECRET
 - IDENTITY_PROVIDER
 - RAILS_MASTER_KEY

#### Rails Encryption
This RI stores private keys in AES-GCM 128-bit encryption, which requires secure random number generater seeding. The
[Rails guide](https://guides.rubyonrails.org/active_record_encryption.html) and [this blog article](https://blog.saeloun.com/2019/10/10/rails-6-adds-support-for-multi-environment-credentials.html)
explains how Rails handles this very well, but in essence track three things:
 - config/credentials.yml.enc contains the encrypted seeds
 - config/master.key **or** `RAILS_MASTER_KEY` environment variable contains the key for credentials.yml.enc, this should **never** be commited to git or posted publicly
 - Use the command `rails credentials:edit` to view and edit the seeds, which requires a master key (above) and may require `EDITOR` environment variable

## License

Copyright 2022 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

