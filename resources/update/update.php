<?php
require_once 'utils.php';
define('URL_TO_CHECK_IF_SCRIPT_HAS_ACCESS_TO_ASSETS', "http://www.transformice.com/images/x_deadmeat/bibliotheques/Pantalons_01.swf");

setProgress('starting');

// Check if Atelier801 server can be accessed
$isA801ServerOnline = fetchHeadersOnly(URL_TO_CHECK_IF_SCRIPT_HAS_ACCESS_TO_ASSETS);
if(!$isA801ServerOnline['exists']) {
	setProgress('error', [ 'message' => "Update script cannot currently access the Atelier 801 servers - it may either be down, or script might be blocked/timed out" ]);
	exit;
}

////////////////////////////////////
// Core Logic
////////////////////////////////////

// Basic Resources

$resources = updateBasicResources();

setProgress('updating');
$json = getConfigJson();
$json["packs"]["outfit"] = $resources;
saveConfigJson($json);

// Finished

setProgress('completed');
echo "Update Successful!";

sleep(10);
setProgress('idle');

////////////////////////////////////
// Update Functions
////////////////////////////////////
function updateBasicResources() {
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
	
	return $resources;
}