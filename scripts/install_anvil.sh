#!/bin/bash
set -e

# Build and install Anvil
cd /tmp
git clone https://github.com/jasonyu1996/anvil.git
cd anvil
git checkout d4241cb


opam init --disable-sandboxing -y
opam switch create 5.2.0 ocaml-base-compiler.5.2.0 -y
eval $(opam env)
opam install . --deps-only -y
opam install . -y

# Create global symlink so anvil is accessible to all users
ln -sf /root/.opam/5.2.0/bin/anvil /usr/local/bin/anvil

cd /
rm -rf /tmp/anvil

# Test anvil installation
anvil --help