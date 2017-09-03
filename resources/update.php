<?php
$resources = array(
	"Hauts_01.swf", "Pantalons_01.swf", "Chapeaux_01.swf",
	"Chaussures_01.swf", "Visages_01.swf", "Accessoires_visage_01.swf",
	"Coiffures_01.swf", "Accessoires_01.swf"
);
foreach ($resources as $filename) {
	file_put_contents($filename, fopen("http://www.transformice.com/images/x_deadmeat/bibliotheques/$filename", 'r'));
}
echo "Update Successful! Redirecting...";
echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';
?>
