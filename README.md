# Elvish Modules

Some utilities for life in [elvish](https://elv.sh). I learned a lot
from looking [here](https://github.com/zzamboni/elvish-modules) –
thanks!

## list.elv

Here are some helpers when working with lists and maps.

### `get`

Get some value from a list or a map. When used with a map, allows to
recursively get a value from nested maps.

``` elv
m = [&a=[&b=[&c=42]]]
(list-get a.b.c) $m
42
```


### `with`

Takes a function and applies it to each element and returns the tuple
of argument and result (or adds the result to the list if the argument
is a list).

Can be useful to attach information to items:

``` elv
put *.elv | each (list:with (file:lines))
[csv.elv 138]
[file.elv 100]
[list.elv 184]
[util.elv 17]
```

### `contains`

Check whether a list contains an element.

``` elv
(contains [1 3 4 2]) 4
$true

(contains [1 3 4 2]) abc
$false
```

## csv.elv

Tried to implement a simple csv reader. It can transform csv into list
or maps, that are then easier to work with.


### `csv-to-list`

``` elv
echo 'aa,bb,"cc,dd",,,' | each (csv-to-list)
[aa bb 'cc,dd' '' '' '']
```

### `csv-to-map`

``` elv
echo "name,number,date\ntest 10,1,2018-11-29\ntest 20,2,2018-12-06"| each (csv-to-map)
[&date=2018-11-29 &name='test 10' &number=1 &index=1]
[&date=2018-12-06 &name='test 20' &number=2 &index=2]
```

### `list-to-csv`

``` elv
put [1 2 3] [a b c] | each (list-to-csv)
'1,2,3'
'a,b,c'
```

### `map-to-csv`

``` elv
put [&name=test &number=23 &date=2018-02-31] | each (map-to-csv)
'date,name,number'
'2018-02-31,test,23'
```

## file.elv

Some utilities for files and names.


### `stat`

Executes the external `stat` command and returns the result in a map.

``` elv
file:stat file.elv
[&last-access-sec=1.544128641e+09 &size=1718 &user=eike &last-mod='2018-12-06 21:37:13.763287004 +0100' &name=file.elv &type='regular file' &group-id=100 &last-mod-sec=1.544128633e+09 &group=users &last-access='2018-12-06 21:37:21.097246328 +0100' &user-id=1000]
```

## nix.elv

Utilities for working with [nix](https://nixos.org/nix)/[nixos](https://nixos.org/nixos).

### Searching packages

The `sqlite3` command is required.

First build a database, either using `nix-env` or a `packages.json` file on [nixos server](https://nixos.org).

```
update-db-from-nix-env
Creating statements: 20867/20867 ...
Updating database ...
Done.
```

Then search for packages:

```
search jdk
nixos.oraclejdk8psu oraclejdk-8u191 (unfree)
nixos.jdk11_headless openjdk-11.0.1-b13-headless (gpl2) The open-source Java Development Kit
nixos.oraclejdk8 oraclejdk-8u191 (unfree)
nixos.adoptopenjdk-jre-openj9-bin-11 adoptopenjdk-jre-openj9-bin-11.0.1 (gpl2Classpath) AdoptOpenJDK, prebuilt OpenJDK binary
nixos.bazel_jdk11 bazel-0.18.0 (asl20) Build tool that builds code quickly and reliably
nixos.jetbrains.jdk jetbrainsjdk-152b1248.6 (gpl2) An OpenJDK fork to better support Jetbrains's products.
nixos.adoptopenjdk-bin adoptopenjdk-hotspot-bin-11 (gpl2Classpath) AdoptOpenJDK, prebuilt OpenJDK binary
nixos.openjdk openjdk-8u192b26 (gpl2) The open-source Java Development Kit
nixos.openjdk11 openjdk-11.0.1-b13 (gpl2) The open-source Java Development Kit
nixos.bootjdk openjdk-bootstrap ()
nixos.oraclejdk oraclejdk-8u191 (unfree)
nixos.adoptopenjdk-jre-bin adoptopenjdk-jre-hotspot-bin-11 (gpl2Classpath) AdoptOpenJDK, prebuilt OpenJDK binary
nixos.jdk openjdk-8u192b26 (gpl2) The open-source Java Development Kit
nixos.adoptopenjdk-openj9-bin-11 adoptopenjdk-openj9-bin-11.0.1 (gpl2Classpath) AdoptOpenJDK, prebuilt OpenJDK binary
nixos.jdk11 openjdk-11.0.1-b13 (gpl2) The open-source Java Development Kit
```

## completer.elv

Argument completion for some commands:

- [pass](https://www.passwordstore.org/)
