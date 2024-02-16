#!/bin/bash

virsh list --inactive --name | xargs -r -n 1 virsh undefine
