#!/bin/bash

set -ex

cmake -H. -B .build
cmake --build .build
