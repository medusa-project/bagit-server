# Bagit Server

## Introduction

This is a ruby/sinatra application designed to accept and verify bagit bags.

Out first goal is to have a working implementation that meets our requirements, then to make
it more efficient.

## Todos

Flesh out this README file

Decide how to handle long running jobs. One option is running Event Machine directly with the Sinatra app inside
 it (which will expose EM.defer, for example). Another is to have another server running to handle those processes,
 perhaps communicating with AMQP.



