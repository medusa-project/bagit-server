# REST API and examples

This document describes the REST API exposed by this server and
contains examples of some intended uses of the server.

## Examples

### Creating and populating a bag

    POST /bags with
    {"id" : "butter", "version" : "jam"}

    PUT /bags/butter/versions/jam/contents/bagit.txt

    PUT /bags/butter/versions/jam/contents/bag-info.txt

    PUT /bags/butter/versions/jam/contents/manifest-md5.txt

    PUT /bags/butter/versions/jam/contents/data/churn.txt

    ...

    POST /bags/butter/versions/jam/validate

    GET /bags/butter/versions/jam/validation

This can be polled until the validation is finished. Assuming it is valid:

    POST /bags/butter/versions/jam/commit

### Creating a bag and populating via fetch

    POST /bags with
    {"id" : "butter", "version" : "jam"}

    PUT /bags/butter/versions/jam/contents/bagit.txt

    PUT /bags/butter/versions/jam/contents/bag-info.txt

    PUT /bags/butter/versions/jam/contents/manifest-md5.txt

    PUT /bags/butter/versions/jam/contents/fetch.txt

    POST /bags/butter/versions/jam/fetch

    GET /bags/butter/versions/jam/validation

This can be polled until the fetch is complete.

    POST /bags/butter/versions/jam/validate

    GET /bags/butter/versions/jam/validation

This can be polled until the validation is complete.

    POST /bags/butter/versions/jam/commit


### Deleting a bag

    DELETE /bags/butter

## API

Here we present a list of all of the actions that can be done. For each we'll
start by identifying the verb and path for the action. Then we explain any necessary
arguments and what successful and failed results are. In the URLs a component
like :bag_id indicates a single path component and one like *path may have several.
Other parts of URLs are literal.


### Create a bag and version

    POST /bags

The body of the post should be a JSON object. The 'id' key is required and
identifies the bag that will be acted upon. This bag will be created if
it does not already exist. The 'version' key is optional and identifies
the version within the bag to create. If this is not supplied then a
version id will be created by the server.

On success 201 is returned with a location header giving the base url to
use for further operation on the version.

If the 'id' key is not given or is empty then 400 is returned.

If the version already exists then 409 is returned.

### Operate on a bag

For all of these operations 404 is returned unless the bag with the
supplied id exists.

    DELETE /bags/:bag_id

Deletes the bag and all of its associated versions. Returns 200 on success.

### Operate on a version

This is the core of the application. All of these operations will return 404
unless both the bag and version with the supplied ids exist.

At any given time a version will be in one of the following validation states:

* unvalidated - the bag has not yet had validation attempted or has undergone a change
which makes it advisable to reset it to that state
* valid - the bag has been validated and found valid
* invalid - the bag has had validation attempted and been found not valid
* validating - the bag is currently being validated
* uploading - the bag is currently being completed from a fetch.txt file
* committed - the bag was found valid and marked committed to signify that it may
be used

The validation state of a version can affect what operations are permitted on it.
A version is said to 'accept content' if it is in the unvalidated or invalid
states. If an action requires a version to be in such a state it will return
405 if it is attempted when it is not.

    GET /bags/:bag_id/versions/:version_id/validation

Returns 200 with the body a JSON object that describes the current
validation state of the version. This has two keys. The 'status' key is
one of the above statuses. The 'errors' key is an array or strings
describing validation errors from the most recent validation attempt.
The server might not report all validation problems in the error list - this is
to permit it to make easy checks first and if there are problems then report
them without doing harder checks. (E.g. in the current
implementation it will first check the presence of files and if there
is a problem is will only report such errors. If these are fixes then
another attempt at validation may produce errors arising from checksum
issues.)

Note that the absence of errors does not itself imply that the bag is valid -
the status must be valid or committed for this to be ensured.

    POST /bags/:bag_id/versions/:version_id/fetch

The version must be able to accept content. Returns 200 and starts fetching
as indicated by the fetch.txt file. When fetching is starting the version
validation enters state 'uploading' and when it is complete it becomes
'unvalidated'.

    POST /bags/:bag_id/versions/:version_id/validate

The version must be able to accept content. Returns 200 and starts validation.
When validation starts the version validation enters state 'validating'. When
it is complete it enters state 'invalid' or 'valid' depending on whether
the validation succeeded.

    POST /bags/:bag_id/versions/:version_id/commit

The version must be in validation state 'valid'. Returns 200 and makes the
version committed, i.e. not only is is valid, but is marked ready for
further use. This may affect, for example, whether the bag is displayed
publicly.

### Operate on version contents

These are the actions whereby one deals with contents in a bag, whether tag files
or data. For all of these actions the bag must be able to accept content and
 will return 405 if it is not. The bag and version must exist; 404 will
 be returned if not.

For all uploads the content is in the request body without any special
encoding. The octets that are received are stored as is.

The bagit.txt and bag-info.txt (collectively known hereafter as 'bag files')
must be uploaded before any other files. No other file may be uploaded
unless the bag files are present; 400 will be returned if this is
attempted.

A data file must be in at least one manifest to be accepted; this does
not hold for tag files. Any file that is in a manifest must have the
correct checksums for every manifest it is in. Note that currently you
can change a manifest file after files that it contains have been uploaded,
so the mere presence of these files is not a guarantee that they are
valid with the current manifests - the validation operation is the
final arbiter of this.

In fact, in general you are permitted to try to replace any existing file
as long as the bag is able to accept content. However, in most cases it will
not make sense to do so.

    PUT /bags/:bag_id/versions/:version_id/contents/bagit.txt
    PUT /bags/:bag_id/versions/:version_id/contents/bag-info.txt

Upload a bagit.txt or bag-info.txt file.
If the file is not valid then 400 will be returned. If it is valid a 201
will be returned.

    PUT /bags/:bag_id/versions/:version_id/contents/:tag_file

Upload a tag file. If the file is in one or more tag manifests then the
checksums are checked and a 400 is returned if they do not match.
If the file appears to be a manifest, tag manifest, or fetch file then
it is parsed; if it does not have the correct format then a 400 is returned.
If everything succeeds then 201 is returned and the file is written into
the bag.

    PUT /bags/:bag_id/versions/:version_id/contents/data/*path

Upload a data file. If the path is not specified in at least one manifest
or if the checksum is wrong for any manifest that it is in then a 400
is returned. Otherwise 201 is returned and the file is written into the bag.

    GET /bags/:bag_id/versions/:version_id/contents/*path

Get a file from the bag. 404 is returned if the path does not currently
exist in the bag. 200 is returned along with the contents as an
octet-stream if it does exist.

    DELETE /bags/:bag_id/versions/:version_id/contents/*path

Delete a file from the bag. This may only be done if the bag is in the
'invalid' or 'unvalidated' state; if not a 405 is returned. 404 is returned
if the file does not exist in the bag. Otherwise the file is deleted from
the bag and 204 returned.