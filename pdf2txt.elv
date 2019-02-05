# extract text from pdf files using tesseract

-tesseract-bin = (external "tesseract")
-sqlite3-bin = (external "sqlite3")

fn extract-text [f]{
  print (styled "\rCreating images …" gray) >&2
  dir = (mktemp -d "/tmp/gstemp.XXXXX")
  gs -dNOPAUSE -dBATCH -sDEVICE=tiffscaled8 -sOutputFile=$dir"/out%03d.tiff" $f >/dev/null

  len = (put $dir/out*.tiff | count)
  index = 1
  put $dir/out*.tiff | each [tf]{
    try {
      print (styled "\rExtracting page "$index"/"$len gray) >&2
      $-tesseract-bin $tf stdout -l deu 2>/dev/null >>$dir/text
    } except ex {
      echo (styled "\rError in page "$index red) >&2
    } finally {
      index = (+ 1 $index)
    }
  }
  print "\r" >&2
  cat $dir/text
  rm -rf $dir
}

fn -insert-file [dbfile f]{
  echo "\rExtracting text from "$f >&2
  try {
    @text = (extract-text $f)
    text = (echo $@text)
    text = (str:trim-space (replaces "'" "''" $text))
    $-sqlite3-bin $dbfile "insert into pdftxt (file, extract) values ('"$f"', '"$text"')"
  } except ex {
    echo "Failed to extract text from "$f >&2
  }
}

fn -relative-path [dir file]{
  if (str:has-suffix $dir "/") {
    dir = (str:trim-right $dir "/")
  }
  if (str:has-prefix $file $dir) {
    rest = (str:trim-prefix $file $dir)
    put "."$rest
  } else {
    put $file
  }
}

fn rebuild-db [&wd=$pwd]{
  dbfile = $wd/".pdftxt.db"

  $-sqlite3-bin $dbfile 'create table if not exists pdftxt (file text, extract text)'
  sqlite3 $dbfile 'delete from pdftxt'

  for f [$wd/**.pdf] {
    file = (-relative-path $wd $f)
    -insert-file $dbfile $file
  }
}

fn update-db [&wd=$pwd]{
  dbfile = $wd/".pdftxt.db"

  $-sqlite3-bin $dbfile 'create table if not exists pdftxt (file text, extract text)'
  for f [$wd/**.pdf] {
    file = (-relative-path $wd $f)
    present = ($-sqlite3-bin $dbfile "SELECT count(*) FROM pdftxt WHERE file = '"$file"'")
    if (eq $present 0) {
      -insert-file $dbfile $file
    } else {
      echo (styled "File "$f" already indexed." yellow)
    }
  }
}

fn search [q &wd=$pwd]{
  dbfile = $wd/".pdftxt.db"
  $-sqlite3-bin $dbfile "SELECT file FROM pdftxt WHERE extract like '%"$q"%' OR file like '%"$q"%'" | each [f]{
    if ?(test $f) {
      put $f
    }
  }
}
