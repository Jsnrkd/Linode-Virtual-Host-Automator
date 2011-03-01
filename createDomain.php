<?php
$api_key = $argv[1];
$domain = $argv[2];
$admin_email = $argv[3];
$server_ip = $argv[4];

//Create domain record on linode
$jsonurl = "https://api.linode.com/?api_key=$api_key&api_action=domain.create&Domain=$domain&Type=master&SOA_Email=$admin_email";
$json = file_get_contents($jsonurl,0,null,null);
$json_output = json_decode($json);

//Get the domain ID for the new record so we can setup the domain resources
$domain_id = $json_output->DATA->DomainID;

//add WWW subdomain
$jsonurl = "https://api.linode.com/?api_key=$api_key&api_action=domain.resource.create&DomainID=$domain_id&Type=A&Name=WWW&Target=$server_ip";
$json = file_get_contents($jsonurl,0,null,null);
$json_output = json_decode($json);

//add AAAA for yourdomain without WWW
$jsonurl = "https://api.linode.com/?api_key=$api_key&api_action=domain.resource.create&DomainID=$domain_id&Type=AAAA&Name=&Target=$server_ip";
$json = file_get_contents($jsonurl,0,null,null);
$json_output = json_decode($json);

?>
