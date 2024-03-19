# Identity Matching RI Client - UDAP Tiered OAuth Supplemental

## Prerequisite
 - register as a developer on <https://udap.org>
 - preform UDAP Dynamic Client Registration with UDAP Test Tools


## UDAP Tiered OAuth2

UDAP requires valid HTTPS uses, which requires live deployment and SSL certificate. Heroku is essentially the last platform where we can deploy apps for free, but also masks IP addresses. UDAP Test Tools require IP addresses to return results. The convoluted steps below are a work around to resolve the situation. Furthermore, UDAP Tiered OAuth2 is only partially complete, but UDAP Dynamic Client Registration is fully functional.

 1. Go to the heroku deployment at <fhir-secid-client.herokuapp.com/>
 **Warning Heroku is ending free tier deployments by November 28th. Free apps may go down in October. See <https://blog.heroku.com/next-chapter>.**
 2. Go to [/welcome/ifconfig](fhir-secid-client.herokuapp.com/welcome/ifconfig) to get the IP address of the server (which Heroku dynos mask).
 3. On UDAP Test Tools -> Client App Tests enter the *obtained* IP address as Client IP and *your web browser's* IP address as the User IP. Start Test 7.
 4. On your web browser that is visiting the heroku app, disable javascript. The reason is explained [here](https://github.com/HL7-FAST/identity-matching-ri-client#rails-udap-sop-and-cors).
 5. Go to [index](fhir-secid-client.herokuapp.com), enter the UDAP Test Tools server, and run Tiered OAuth 2 once!
 6. Enter the username and password from UDAP Test Tools on the IDP Server login site.
 7. Returning to the Client site will then indicate a green notice if it succeeds, and an alert if it fails combined with diagnostic information.
 8. On the UDAP Test Tools website end test and view results.