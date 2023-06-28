
![SailPoint](https://files.accessiq.sailpoint.com/modules/builds/static-assets/perpetual/sailpoint/logo/1.0/sailpoint_logo_color_228x50.png)

# IdentityNow VA Health-Check

Date: 2022-06-27

Author: Guillermo Fernández


## Overview

This is a simple bash script thought to be run into a IdentityNow virtual appliance instance which performs basic environmental checks and generate a report with the results. 

Currently supported: 

* OS Version
* Network settings
* Active service checks
* External connectivity checks
* Configuration options


## Release Notes

### Version 1.0

* Initial Release

### Version 1.1

* Updated for Flatcar

### Version 1.2

* Updated to include additional checks for primary AWS endpoints, port testing and enhanced error messaging

### Version 1.3

* Retrieves the network interface dynamically instead of hard-coded.
* Use resolv.conf resolver instead of static google DNS server for DNS port check.
* Adds udp port check for DNS.
* Removes the need to run toolbox (for DNS port check).
* Test DPI against the 3 IP addresses dynamically resolved, instead of a single hit to FQDN.
* Launches interactive mode if config.yaml file not found. (to be able to run Network connectivity tests before configuration).

### Support / Features

This utility has limited support from SailPoint.  If you have any issues, bugs, or feature requests, please submit an Expert Services request at https://support.sailpoint.com/.


## Configuration

There is no current configuration files required. All information is prompted for during runtime.


## Execution

To run or execute the IdentityNow VA Health Check Script, first copy the script to the virtual appliance using SCP:

- `scp va-healthcheck.sh`

Once the script is on the virtual appliance, you will need to allow execution privileges to the script from the `sailpoint` login:

- `chmod 755 ./va-healthcheck.sh`, or `chmod +x va-healthcheck.sh`

Finally, run the script using this command: `bash va-healthcheck.sh`

Execution looks something like this:


~~~
==================================
VA Healthcheck Report
==================================
Version: 1.3
==================================
OS Version
==================================
5.10.43-flatcar
==================================
Time on system  
----------------------------------
Sun Feb 20 11:22:56 UTC 2022
==================================
Checking Network Configuration
==================================
POD :  stg02-useast1
ORG :  css-223
----------------------------------
INTERFACE:  ens160
IP:         192.168.107.128
MASK:       255.255.255.0
DNS:        192.168.107.2
SUCCESS: Resolved sqs.us-east-1.amazonaws.com to an IP address.
----------------------------------
Static IP Config  
----------------------------------
WARNING: Static IP has NOT been configured; a static IP is recommended.
----------------------------------
Routing table  
----------------------------------
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.107.2   0.0.0.0         UG        0 0          0 ens160
10.255.255.240  0.0.0.0         255.255.255.240 U         0 0          0 docker0
192.168.107.0   0.0.0.0         255.255.255.0   U         0 0          0 ens160
192.168.107.2   0.0.0.0         255.255.255.255 UH        0 0          0 ens160
==================================
Services Check
==================================
SUCCESS: charon service is active as expected.
SUCCESS: esx_dhcp_bump service is inactive as expected.
SUCCESS: va_agent service is active as expected.
SUCCESS: fluent service is active as expected.
SUCCESS: ccg service is active as expected.
SUCCESS: docker service is active as expected.
SUCCESS: toolbox service is active as expected.
==================================
Current jobs
==================================
total 0
==================================
CCG Container Status
==================================
SUCCESS: CCG container and image exists.
==================================
VA Agent Status
==================================
SUCCESS: VA Agent is processing messages from the tenant.
==================================
Verifying Connectivity
==================================
SUCCESS: Connectivity verification tests passed.
==================================
config.yaml
==================================
SUCCESS: VA Passphrase matches cluster
==================================
External Connectivity Check
==================================
SUCCESS: Connection to https://api.ecr.us-east-1.amazonaws.com succeeded.
SUCCESS: Connection to https://aws.amazon.com/s3 succeeded.
SUCCESS: Connection to https://css-223.api.identitynow.com succeeded.
SUCCESS: Connection to https://ecr.us-east-1.amazonaws.com succeeded.
SUCCESS: Connection to https://ec2.us-east-1.amazonaws.com succeeded.
SUCCESS: Connection to https://sailpoint-va.s3.us-east-1.amazonaws.com succeeded.
SUCCESS: Connection to https://stable.release.flatcar-linux.net succeeded.
SUCCESS: Connection to https://spp-artifacts.s3.amazonaws.com succeeded.
SUCCESS: Connection to https://css-223.identitynow.com succeeded.
SUCCESS: Connection to https://sqs.us-east-1.amazonaws.com succeeded.
SUCCESS: Connection to https://stg02-useast1.accessiq.sailpoint.com succeeded.
SUCCESS: Connection to https://874540850173.dkr.ecr.us-east-1.amazonaws.com succeeded.
SUCCESS: Connection to https://app.datadoghq.com succeeded.
SUCCESS: Connection to https://dynamodb.us-east-1.amazonaws.com succeeded.
SUCCESS: Outbound access is available to nameservers on port 53.
==================================
Configuration Options
==================================
Standard configuration found
==================================
Connecting to useast1 gateway: va-gateway-useast1.identitynow.com...
SUCCESS: Connection made to primary gateway URL. No deep packet inspection found.
==================================
VA Healthcheck Complete
==================================
~~~

This will generate a report with the results in the same directory as the txt file named in this format: va_healthcheck_<YYYYmmdd_HHMMSS>.txt
