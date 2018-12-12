fn complete-pass [@args]{
  dir = ~/.password-store
  len = (+ 1 (count $dir))
  put $dir/**.gpg | each [x]{ put $x[{$len}:-4] }
}

edit:completion:arg-completer[pass] = $complete-pass~
