# Elvish Modules

Some utilities for life in [elvish](https://elv.sh).

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
