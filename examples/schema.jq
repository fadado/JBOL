#!/usr/local/bin/jq -f

include "fadado.github.io/types";

{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "Schema title",
    "description": "Schema description"
} + schema

# vim:ai:sw=4:ts=4:et:syntax=jq
