<?php

require '/flarum/app/vendor/autoload.php';

use League\Flysystem\Adapter\Local;
use League\Flysystem\CorruptedPathDetected;
use League\Flysystem\Filesystem;
use League\Flysystem\Util;

$root = sys_get_temp_dir() . '/flysystem-path-test-' . bin2hex(random_bytes(8));
mkdir($root);
$filesystem = new Filesystem(new Local($root));

try {
  foreach (['normal.txt', '中文.txt', 'a file.txt'] as $path) {
    if (!$filesystem->write($path, 'test') || $filesystem->read($path) !== 'test') {
      throw new RuntimeException('Valid path failed: ' . $path);
    }
    $filesystem->delete($path);
  }

  foreach (["bad\x1b.txt", "bad\0.txt", "bad\x80\x1b.txt", "bad\x80.txt"] as $path) {
    try {
      $filesystem->write($path, 'must not be written');
    } catch (CorruptedPathDetected $e) {
      continue;
    }
    throw new RuntimeException('Corrupted path was accepted: ' . bin2hex($path));
  }

  if (Util::normalizePath('a\\b/../c.txt') !== 'a/c.txt') {
    throw new RuntimeException('Relative path normalization changed');
  }

  try {
    Util::normalizePath('../outside.txt');
    throw new RuntimeException('Path traversal was accepted');
  } catch (LogicException $e) {
    // Paths outside the filesystem root must remain rejected.
  }

  echo "Flysystem path regression checks passed\n";
} finally {
  foreach (new DirectoryIterator($root) as $file) {
    if (!$file->isDot()) {
      unlink($file->getPathname());
    }
  }
  rmdir($root);
}
