<?php
$api_key = $argv[1];
$domain = $argv[2];
$subDomain = $argv[3];
$parent_domain = $argv[4];
$admin_email = $argv[5];
$server_ip = $argv[6];

//Check to see if the parent domain has been created before adding the subdomain

//Get a list of the domains to find the id for the domain
$jsonurl = "https://api.linode.com/?api_key=$api_key&api_action=domain.list";
$json = file_get_contents($jsonurl,0,null,null);
$json_output = json_decode($json);

//Find the domain ID from the result
foreach($json_output->DATA as $domain_record){
     if($domain_record->DOMAIN == $parent_domain){
          createSubdomain($domain_record->DOMAINID, $api_key, $subDomain, $server_ip);
     }
}

function createSubdomain($domain_id, $api_key, $subDomain, $server_ip){
     //add subdomain via Linode API
     $jsonurl = "https://api.linode.com/?api_key=$api_key&api_action=domain.resource.create&DomainID=$domain_id&Type=A&Name=$subDomain&Target=$server_ip";
     $json = file_get_contents($jsonurl,0,null,null);

//debug
//$json_output = json_decode($json);
//print_r($json_output);
}
?>
