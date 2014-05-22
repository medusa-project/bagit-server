# Bagit Server

## Introduction

This is a ruby/sinatra application designed to accept and verify bagit bags.

Out first goal is to have a working implementation that meets our requirements, then to make
it more efficient.

For more details see README-API.md.

## To dos

Decide how to handle long running jobs. One option is running Event Machine directly with the Sinatra app inside
 it (which will expose EM.defer, for example). Another is to have another server running to handle those processes,
 communicating through the database. This would be simple to implement (we could load up the same code
 in an EM loop to pick jobs off the database and execute handlers for them), but we'd need to think about
 how to handle tests in this case.



