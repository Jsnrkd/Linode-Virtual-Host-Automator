#!/bin/bash
#
# Author: Jason Rikard
# jsnrkd@gmail.com
#
# Date: 02/28/2011
#
# This script was created to automate domain creation on Ubuntu 10.04 for
# Apache2 on Linode
#
#WARNING: This script is optimistic and assumes correct input everywhere
#

#User Variables

#Server IP
server_ip='xxx.xxx.xxx.xxx';

#IP address for the vhost file. Either your server IP or *
vhost_ip='*';



#Virtual hosts folder location
vhost_location='/etc/apache2/sites-available'

#Linode API key
api_key=''



#
#Main entry point for creating a virtual host file for a new domain
#
function create_domain {
     #Get the name of the domain the user wants to create
     echo What domain do you want to enable? \(Example: example.com\)
     read domain

     #Get the server admin's email address
     read -p 'What is the administrative email address for this domain?' admin_email

     #Create Virtual Host File
     touch $vhost_location/$domain

     #Note: This assumes ServerAlias as WWW
cat>>$vhost_location/$domain<<EOF
          <VirtualHost $vhost_ip:80>
          ServerAdmin $admin_email
          ServerName $domain
          ServerAlias www.$domain
          DocumentRoot /srv/www/$domain/httpdocs/
          ErrorLog /srv/www/$domain/logs/error.log
          CustomLog /srv/www/$domain/logs/access.log combined
     </VirtualHost>
EOF

     #Call functions to finish the process
     make_directories $domain
     enable_site $domain
     set_domain_dns $domain $admin_email
     exit
}

#
#Creates a subdomain...
#
function create_subdomain {
     #Get the name of the sub domain the user wants to create
     echo 'What sub domain do you want to enable?'
     echo 'Note: If the domain must already exist.'
     echo 'Example: sub.example.com'
     echo 'subdomain: '
     read domain

     #Get the server admin's email address
     read -p 'What is the administrative email address for this subdomain?' admin_email

     #Create Virtual Host File
     touch $vhost_location/$domain

     #Write to the virtual host file
cat>>$vhost_location/$domain<<EOF
     <VirtualHost $vhost_ip:80>
          ServerAdmin $admin_email
          ServerName $domain
          DocumentRoot /srv/www/$domain/httpdocs/
          ErrorLog /srv/www/$domain/logs/error.log
          CustomLog /srv/www/$domain/logs/access.log combined
     </VirtualHost>
EOF

     #Call functions to finish the process
     make_directories $domain
     enable_site $domain
     set_subdomain_dns $domain $admin_email
     echo "Subdomain creation attempted"
     exit
}

#
#Param 1: domain;
#Make the directories for the new domain
#
function make_directories {
     mkdir -p /srv/www/$1/httpdocs
     mkdir /srv/www/$1/logs
}

#
#Param 1: domain;
#Enables the site and restarts Apache
#
function enable_site {

     #Create symboloic link for the new domain
     a2ensite $1

     #Restart Apache
     /etc/init.d/apache2 reload
}

#
#Param 1: domain; Param 2: Admin email address
#Sets up the DNS on Linode
#
function set_domain_dns {
     #Create Linode domain record through Linode API
     php createDomain.php $api_key $1 $2 $server_ip
}

#
#Uses the Linode API to add a subdomain to an existing domain
#
function set_subdomain_dns {
     #passes the api key, whole domain, isolated subdomain,
     #        domain minus the subdomain, admin email address, server ip
     php createSubdomain.php $api_key $1 ${1%%.*} ${domain#*.} $2 $server_ip
}


#Find out if the user wants to create a subdomain or not
while true; do
    read -p 'Are you creating a subdomain?' yn
    case $yn in
        [Yy]* ) create_subdomain;;
        [Nn]* ) create_domain;;
        * ) echo 'Please answer yes or no.';;
    esac
done


echo 'Attempted to create new virtual host: $domain'
