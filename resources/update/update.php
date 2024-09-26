<?php
require_once 'utils.php';

ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

ini_set('max_execution_time', 3*60);
set_time_limit(3*60);

setProgress('starting');

// Check if Atelier801 server can be accessed
$isA801ServerOnline = fetchUrlMetaData("http://www.transformice.com/images/x_deadmeat/bibliotheques/Pantalons_01.swf");
if(!$isA801ServerOnline['exists']) {
	setProgress('error', [ 'message' => "Update script cannot currently access the Atelier 801 servers - it may either be down, or script might be blocked/timed out" ]);
	exit;
}

$resources_base = array(
	"Hauts", "Pantalons", "Chapeaux",
	"Chaussures", "Visages", "Accessoires_visage",
	"Coiffures", "Accessoires", "Sacs", "Masques", "Gants", "Ceintures"
);
$resources = array();
foreach ($resources_base as $filebase) {
	setProgress('updating', [ 'message'=>"Resource: $filebase", 'value'=>1, 'max'=>1 ]);
	for ($i = 4; $i >= 1; $i--) {
		$filename = "{$filebase}_0{$i}.swf";
		$url = "http://www.transformice.com/images/x_deadmeat/bibliotheques/$filename";
		$file = "../$filename";
		downloadFileIfNewer($url, $file);
		
		// Check local file so that if there's a load issue the update script still uses the current saved version
		if(file_exists($file)) {
			if($filename == "Hauts_01.swf") { continue; } // Has old assets we don't want overriding new ones (isn't even loaded in anymore in the game)
			$resources[] = $filename;
		}
	}
}

setProgress('updating');

$json_path = "../config.json";
$json = json_decode(file_get_contents($json_path), true);
$json["packs"]["outfit"] = $resources;
$json["cachebreaker"] = time();//md5(time(), true);
file_put_contents($json_path, json_encode($json));//, JSON_PRETTY_PRINT

setProgress('completed');
echo "Update Successful!";

sleep(10);
setProgress('idle');
// echo "Update Successful! Redirecting...";
// echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';