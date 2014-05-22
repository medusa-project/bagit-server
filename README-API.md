# REST API and examples

This document describes the REST API exposed by this server and
contains examples of some intended uses of the server.

## Examples

### Creating and populating a bag

### Creating a bag and populating via fetch

### Deleting a bag

## API

Here we present a list of all of the actions that can be done. For each we'll
start by identifying the verb and path for the action. Then we explain any necessary
arguments and what successful and failed results are.

### Create a bag and version

    POST '/bags'

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

    DELETE '/bags/:bag_id'

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

