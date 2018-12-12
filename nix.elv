# Utilities working with nix and in nixos

-working-dir = ~/.nixelv
mkdir -p $-working-dir

-nixpkgs-json-file = $-working-dir'/nixpkgs.json'
-nixpkgs-db-file = $-working-dir'/db'
-nixpkgs-json-url = 'https://nixos.org/nixpkgs/packages.json.gz'

use str
use re

fn -loaddb []{
  print "put " >$-nixpkgs-db-file
  cat $-nixpkgs-json-file | from-json | to-lines >>$-nixpkgs-db-file
}

fn db-from-download []{
  curl $-nixpkgs-json-url | gzip -d >$-nixpkgs-json-file
  -loaddb
}

fn db-from-nix-env []{
  nix-env -qa --json >$-nixpkgs-json-file
  -loaddb
}

fn search [name &aslist=$false]{
  db = (-source $-nixpkgs-db-file)
  put (keys $db) | each [pkgkey]{
    pkg = $db[$pkgkey]
    pkgname = $pkg[name]
    pkgdescr = ""
    try {
      pkgdescr = $pkg[meta][description]
    } except _ {
    }
    if (or (str:contains $pkgkey $name) (str:contains $pkgname $name)) {
      if $aslist {
        put [$pkgkey $pkgname $pkgdescr]
      } else {
        echo (styled $pkgkey white)' '(styled $pkgname blue)' '(styled $pkgdescr gray)
      }
    }
  }
}
