#!/usr/bin/php
<?php 
$arg = getopt("s:o:t:h");
$usage  = "Usage: php parse_magento_sitemap.php [-s <sitemap file>|<sitemap url>] [-t type,type,...]\n"; // -o urls.txt";
$usage .="Example: php parse_magento_sitemap -s sitemap.xml -t prod,cms > sitemap-urls.txt\n";
if (array_key_exists('h',$arg)) { echo $usage; exit; }
$source_file = (isset($arg['s'])) ? $arg['s'] : 'sitemap.xml';
if (preg_match("/^(http|https|ftp)\:\/\//",$source_file) != 0 || (file_exists($source_file) && is_readable($source_file))) 
	$source = file_get_contents($source_file);
else die ("File {$source_file} does not exist or is unreadable.\n".$usage);
$type = (isset($arg['t'])) ? $arg['t'] : 'cat,prod,cms';
$type = explode(',',$type);
$types = array('cat'=>'0.5','prod'=>'1.0','cms'=>'0.2');
$sitemap = new SimpleXMLElement($source);
$all=array('prod'=>array(),'cat'=>array(),'cms'=>array());
foreach($sitemap as $url) {
	switch ($url->priority) {
		case "0.2": if (in_array('cms',$type)) $all['cms'][] = (string)$url->loc; break;
		case "0.5": if (in_array('cat',$type)) $all['cat'][] = (string)$url->loc; break;
		case "1.0": if (in_array('prod',$type)) $all['prod'][] = (string)$url->loc; break;
	}
}
foreach ($all as $type)	foreach ($type as $url) echo $url."\n";
