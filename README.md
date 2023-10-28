# Identity Matching & UDAP Security RI Client
Reference implementation (RI) client for [Interoperable Identity and Patient Matching](http://build.fhir.org/ig/HL7/fhir-identity-matching-ig/) and [UDAP Security](https://build.fhir.org/ig/HL7/fhir-udap-security-ig/) implementation guides. The client's primary features are: patient matching requests, patient identity weighted score validation, UDAP dynamic client registration, and UDAP tiered OAuth2. You can try this app out at <https://fhir-secid-herokuapp.com> until [November 28th 2022](https://blog.heroku.com/next-chapter).

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
 - `export BEARER_TOKEN=[your token]` for hard coded token-based authorization

Alternatively you can create a [.env](https://github.com/bkeepers/dotenv#usage) file and set the environment variables, for example:
```dotenv
# .env
BEARER_TOKEN=[your token]
```

5. Launch server
```bash
$ rails server
```

6. Go to <http://localhost:3000>

## Miscellaneous
### Certificate Authorities
If you only want a client for patient identity matching you can disregard the authentication and UDAP security aspects of this RI. If your server only supports the minimal authorization framework with OAuth2, you can manually register this app and obtain an access token, and then upload the access token via the environment variable `BEARER_TOKEN`.

If you want to utilize the UDAP Security aspect of the client, this RI comes with one self-signed Certificate Authority, that you can download the digital certificate for and add to a UDAP server's trusted validation certificates. However, the recommended usage is to upload a PKCS#12 encoded file (*.p12 file) which provides this application with the private key and certificate chain needed for UDAP registration. This application encrypts all saves all (encrypted) private keys and certificates, lets you choose an Authority (which dictates private key and certificate chain), and signs the UDAP registration software statement with subjectAltName `https://test.healthtogo.me/udap-sandbox/mitre`. Attempting UDAP Dynamic Client registration with this app in a local dev environment may fail because the subjectAltName does not match.

Private keys should be handled with utmost secrecy. In practice an application may only utilize one authority (private key and x509 certificate chain), and any authorization/authentication controls should be behind secured access.

### Rails, UDAP, SOP, and CORS
Both Dynamic Client registration and Tiered OAuth work by taking the user to a "start" page where they may view/revise the relevant info and then initiate the protocol. Ruby on Rails may override form/button GET requests and POST requests with Fetch API javascript requests, which may make the protocol to due to [Single Origin Policy (SOP)](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy) (a.k.a. misfigured CORS). You can by pass this by either configure CORS properly on the UDAP server (both resource and identity provider server if necessary) or disabling JavaScript on your web browser (which will have Rails fallback to traditional HTTP requests). Old browsers may also fail if they do not implement the Fetch API, in which case you can try a [Fetch Polyfill](https://github.com/github/fetch).

### Environment Variables
 - BEARER_TOKEN
 - IDENTITY_PROVIDER (fallback default)
 - RAILS_ENV
 - RAILS_MASTER_KEY

### Rails Encryption
This RI stores private keys in AES-GCM 128-bit encryption, which requires secure random number generater seeding. The
[Rails guide](https://guides.rubyonrails.org/active_record_encryption.html) and [this blog article](https://blog.saeloun.com/2019/10/10/rails-6-adds-support-for-multi-environment-credentials.html)
explains how Rails handles this very well, but in essence track three things:
 - config/credentials.yml.enc contains the encrypted seeds
 - config/master.key **or** `RAILS_MASTER_KEY` environment variable contains the key for credentials.yml.enc, this should **never** be commited to git or posted publicly
 - Use the command `rails credentials:edit` to view and edit the seeds, which requires a master key (above) and may require `EDITOR` environment variable

### More Documentation
 - [Official Rails Guides](https://guides.rubyonrails.org/)
 - [Official Rails API](https://api.rubyonrails.org/)
 - [HL7 FHIR](https://build.fhir.org/documentation.html)

## License

Copyright 2022 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


## Questions and Contributions
Questions about the project can be asked in the [FAST Identity stream on the FHIR Zulip Chat](https://chat.fhir.org/#narrow/stream/294750-FHIR-at-Scale-Taskforce-.28FAST.29.3A-Identity).

This project welcomes Pull Requests. Any issues identified with the RI should be submitted via the [GitHub issue tracker](https://github.com/HL7-FAST/identity-matching-ri-client/issues).

As of October 1, 2022, The Lantana Consulting Group is responsible for the management and maintenance of this Reference Implementation.
In addition to posting on FHIR Zulip Chat channel mentioned above you can contact [Corey Spears](mailto:corey.spears@lantanagroup.com) for questions or requests.
