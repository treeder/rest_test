A tiny web app for testing http libraries.

Features:

* Responds with whatever http status code you want
* Can simulate temporary error situations
* Can store and retrieve requests for review

Live version at: http://rest-test.iron.io , feel free to use it.

Endpoints and Parameters
===================

`/code/X` where X is the http status code you want returned.

params:

* switch_after with switch_to: will switch code to switch_to after switch_after times. Eg: /code/503?switch_after=3&switch_to=200
* store={key}: will store request so you can retrieve it after and analyze it. Retrieve a stored request at /stored/{key}

TODO:

* A way to validate headers
* A way to validate parameters

