<CHANGE VIRTUAL BOX NETWORK TO BRIDGE ADAPTER>

***********************
osproject.com
ip 192.168.0.209
default 192.168.0.1
***********************
ip addr
ip route  //For get default gateway ip
sudo -i
# apt install bind9
named -v

cd /etc/bind
ls
hostnamectl status
gedit /etc/hosts

---------------------------------------------------------------------------
[After the command edit next]

192.168.0.209	ubuntu-VirtualBox.osproject.com	ubuntu-VirtualBox //this is your ip which you get from ip addr command

[save and exit]

-----------------------------------------------------------------------------

hostname
dnsdomainname
hostname --fqdn

cp named.conf.options named.conf.options.orig
nano named.conf.options

[After the command edit next]

	//========================================================================
	dnssec-validation auto;
	listen-on-v6 { any; };
	recursion yes;
	listen-on{192.168.0.209;};
	allow-transfer {none;};
	
	forwarders {
	192.168.0.1;

	};

[save and exit]

cp named.conf.local named.conf.local.orig
gedit named.conf.local

-------------------------------------------------------------------------------------
[After the command edit next]

//forward lookup zone
zone "osproject.com" IN{
	type master;
	file "/etc/bind/db.osproject.com";
};

//reverse lookup zone
zone "0.168.192.in-addr.arpa" IN {
	type master;
	file "/etc/bind/db.0.168.192";
};

[save and exit]
-------------------------------------------------------------------------------------

named-checkconf
ls
# cat named.conf.local
cp db.local db.osproject.com
gedit db.osproject.com

------------------------------------------------------------------------------------
[Replace full file with that text]

;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	ns1.osproject.com. root.osproject.com. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns1.osproject.com.
ns1	IN	A	192.168.0.209
www	IN	A	192.168.0.209
ftp	IN	A	192.168.0.209
@	IN	MX	10	mail
mail	IN	A	192.168.0.209
@	IN	AAAA	::1
[Save and exit]
-------------------------------------------------------------------------------------

named-checkzone genibarta.com db.genibarta.com
cp db.127 db.0.168.192
gedit db.0.168.192

-------------------------------------------------------------------------------------
[Replace full file with that text]
;
; BIND reverse data file for local loopback interface
;
$TTL	604800
@	IN	SOA	ns1.osproject.com. root.osproject.com. (
			      1			; Serial
			 604800			; Refresh
			  86400			; Retry
			2419200			; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns1.osproject.com.
24	IN	PTR	ns1.osproject.com.
24	IN	PTR	www.osproject.com.
24	IN	PTR	ftp.osproject.com.
24	IN	PTR	mail.osproject.com.

[Save and exit]
------------------------------------------------------------------------------------
// validation checking 

named-checkzone 0.168.192.in-addr.arpa db.0.168.192
named-checkconf
named-checkzone osproject.com db.osproject.com
named-checkzone 0.168.192.in-addr.arpa db.0.168.192

service bind9 restart
service bind9 status

nslookup www.osproject.com

# cat /etc/resolv.conf
rm /etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
gedit /etc/resolv.conf

-----------------------------------------
[Replace last line with that text]

nameserver 192.168.0.209
nameserver 192.168.0.1
search localdomain

[Save and exit]
-----------------------------------------

nslookup osproject.com
ping osproject.com
# ping ftp.osproject.com
# ping mail.osproject.com


Then configure your DNS from other os
example if windows host....

->Control Panel\Network and Internet\Network and Sharing Center
->Change adapter setting
->Select your internet connection and right click and go to properties
->Double click TCP/IPv4
->Change DNS with nameserver ip (192.168.0.209)




