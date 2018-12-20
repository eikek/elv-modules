# Utilities working with nix and in nixos
#

-working-dir = ~/.nixelv
mkdir -p $-working-dir

-nixpkgs-json-file = $-working-dir'/nixpkgs.json'
-nixpkgs-db-file = $-working-dir'/db'
-nixpkgs-json-url = 'https://nixos.org/nixpkgs/packages.json.gz'

use str
use re
use ./csv
use ./util
use ./list

fn -loaddb [&keep-sql-file=$false]{
  sqlfile = $-working-dir"/sql"
  all = (cat $-nixpkgs-json-file | from-json | put (all)[packages])
  @keys = (keys $all)
  sqlite3 $-nixpkgs-db-file 'create table if not exists nixpkgs (key text, name text, license text, descr text, system text)'
  sqlite3 $-nixpkgs-db-file 'delete from nixpkgs'
  counter = 0
  echo "BEGIN TRANSACTION;" > $sqlfile
  each [k]{
    pkg = $all[$k]
    pkgname = ((list:getopt name) $pkg)
    pkgdescr = (replaces "\n" " " (replaces "'" "''" ((list:getopt meta description) $pkg)))
    license = (replaces "\n" " " (replaces "'" "''" ((list:getopt meta license shortName) $pkg)))
    system = ((list:getopt system) $pkg)
    echo "insert into nixpkgs (key,name,license,descr,system) values ('"$k"','"$pkgname"','"$license"','"$pkgdescr"','"$system"');" >> $sqlfile
    counter = (+ $counter 1)
    print "\rCreating statements: "$counter'/'(count $keys)' ...'
  } $keys
  echo "COMMIT;" >> $sqlfile
  echo "\nUpdating database ..."
  sqlite3 $-nixpkgs-db-file < $sqlfile
  if (not $keep-sql-file) {
    rm $sqlfile
  }
  echo "Done."
}

fn update-db-from-download []{
  curl $-nixpkgs-json-url | gzip -d >$-nixpkgs-json-file
  -loaddb
}

fn update-db-from-nix-env []{
  # make same structure as from download
  print '{"packages": ' >$-nixpkgs-json-file
  nix-env -qa --json >>$-nixpkgs-json-file
  print ' }' >>$-nixpkgs-json-file
  -loaddb
}

fn search [name &moreSql=""]{
  cond = "(key like '%"$name"%' or name like '%"$name"%') "$moreSql
  count = (sqlite3 $-nixpkgs-db-file "select count(*) from nixpkgs where "$cond | take 1)
  if (and (> $count 50) (not (util:y-or-n "Really display "$count" packages?"))) {
    return
  }
  sql = "select key,name,license,descr from nixpkgs where "$cond
  sqlite3 -csv $-nixpkgs-db-file $sql |
    each (csv:csv-to-list) |
    each [list]{
      echo (styled $list[0] white)' '(styled $list[1] blue)' '(styled "("$list[2]")" yellow)' '(styled $list[3] gray)
    }
}
