# try to create a reader for csv

fn -csv-line-to-list [line &sep=, &strEncl='"']{
  result = []
  cell = ''
  ci = 0
  quoted = $false
  each [c]{
    if (and (eq $ci 0) (eq $c $strEncl)) {
      quoted = $true
      ci = (+ $ci 1)
    } elif (and (eq $ci 0) (eq $c $sep)) {
      result = [$@result '']
      ci = 0
      cell = ''
      quoted = $false
    } elif (eq $ci 0) {
      cell = $cell$c
      ci = (+ $ci 1)
      quoted = $false
    } elif (and $quoted (eq $c $sep) (eq $cell[-1] $strEncl)) {
      result = [$@result $cell[:-1]]
      ci = 0
      cell = ''
      quoted = $false
    } elif (and (eq $c $sep) (> $ci 0) (not $quoted)) {
      result = [$@result $cell]
      ci = 0
      cell = ''
      quoted = $false
    } else {
      ci = (+ $ci 1)
      cell = $cell$c
    }
  } $line
  if (and $quoted (eq $cell[-1] $strEncl)) {
    result = [$@result $cell[:-1]]
  } else {
    result = [$@result $cell]
  }
  put $result
}

# Convert a csv line to a list
# Example:
# ~> echo 'aa,bb,"cc,dd",,,' | each (csv-to-list)
# ▶ [aa bb 'cc,dd' '' '' '']
#
fn csv-to-list [&sep=, &strEncl='"']{
  put [str]{
    -csv-line-to-list $str &sep=$sep &strEncl=$strEncl
  }
}

# Convert csv lines into a map.
#
# The first line is used as the header. Every other line is converted
# into a map of values of that line paired with keys from the first
# line.
#
# Example:
# ─> echo "name,number,date\ntest 10,1,2018-11-29\ntest 20,2,2018-12-06"| each (csv-to-map)
# ▶ [&date=2018-11-29 &name='test 10' &number=1 &index=1]
# ▶ [&date=2018-12-06 &name='test 20' &number=2 &index=2]
#
fn csv-to-map [&sep=, &strEncl='"' &indexKey=index]{
  index = 0
  header = []
  mk-list = (csv-to-list &sep=$sep &strEncl=$strEncl)
  put [str]{
    list = ($mk-list $str)
    if (eq $index 0) {
      header = $list
    } else {
      use ./list
      m = [&]
      c = (list:min (count $header) (count $list))
      range $c | each [i]{
        m = (assoc $m $header[$i] $list[$i])
      }
      if (not-eq $indexKey "") {
        put (assoc $m $indexKey $index)
      } else {
        put $m
      }
    }
    index = (+ 1 $index)
  }
}

fn -escape-value [&sep=, &strEncl='"']{
  put [el]{
    if (or (str:contains $el $sep) (str:contains $el $strEncl) (str:contains $el "\n")) {
      put '"'(replaces $strEncl '\\'$strEncl $el)'"'
    } else {
      put $el
    }
  }
}

fn -list-to-csv-line [list &sep=, &strEncl='"']{
  use str
  @l = (each (-escape-value &sep=$sep &strEncl=$strEncl) $list)
  joins $sep $l
}

# Convert a map into csv.  The keys are turned into the first line to
# serve as the head. Use &withHead=$false to suppress this.
#
# Example:
# ─>  put [&name=test &number=23 &date=2018-02-31] | each (map-to-csv)
# ▶ 'date,name,number'
# ▶ '2018-02-31,test,23'
#
fn map-to-csv [&sep=, &strEncl='"' &withHead=$true]{
  headerPrinted = $false
  put [map]{
    @header = (keys $map)
    if (and $withHead (not $headerPrinted)) {
      put $header | each (list-to-csv &sep=$sep &strEncl=$strEncl)
      headerPrinted = $true
    }
    @line = (each [k]{ (-escape-value &sep=$sep &strEncl=$strEncl) $map[$k] } $header)
    joins $sep $line
  }
}

# Convert lists to csv lines
# Example:
# ~> put [1 2 3] [a b c] | each (list-to-csv)
# ▶ '1,2,3'
# ▶ 'a,b,c'
#
fn list-to-csv [&sep=, &strEncl='"']{
  put [list]{
    -list-to-csv-line &sep=$sep &strEncl=$strEncl $list
  }
}
