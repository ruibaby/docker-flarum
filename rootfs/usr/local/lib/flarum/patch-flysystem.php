<?php

// Backport GHSA-cxf4-7mrp-vvpr to Flysystem 1.x without changing its API.
// https://github.com/thephpleague/flysystem/commit/ef4a9a557d769b5d472c403125716706a0d9cc77
$file = '/flarum/app/vendor/league/flysystem/src/Util.php';
$source = file_get_contents($file);
$before = <<<'PHP'
if (preg_match('#\p{C}+#u', $path)) {
PHP;
$after = <<<'PHP'
if (preg_match('#\p{C}+#u', $path) !== 0) {
PHP;

if ($source === false) {
  throw new RuntimeException('Cannot read Flysystem path normalizer');
}

if (substr_count($source, $after) === 1 && substr_count($source, $before) === 0) {
  echo "Flysystem security patch already applied\n";
  return;
}

if (substr_count($source, $before) !== 1 || substr_count($source, $after) !== 0) {
  throw new RuntimeException('Unexpected Flysystem source; review the security backport');
}

$patched = str_replace($before, $after, $source);
if (file_put_contents($file, $patched) !== strlen($patched)) {
  throw new RuntimeException('Cannot apply Flysystem security patch');
}

echo "Applied Flysystem security patch GHSA-cxf4-7mrp-vvpr\n";
