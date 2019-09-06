#!/usr/bin/env bash

# Copyright 2019 SailPoint Technologies, Inc.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

clear

echo "------------------------------------------------------------------------"
echo "                                                                        "
echo "   _|_|_|            _|  _|  _|_|_|              _|              _|     "
echo " _|          _|_|_|      _|  _|    _|    _|_|        _|_|_|    _|_|_|_| "
echo "   _|_|    _|    _|  _|  _|  _|_|_|    _|    _|  _|  _|    _|    _|     "
echo "       _|  _|    _|  _|  _|  _|        _|    _|  _|  _|    _|    _|     "
echo " _|_|_|      _|_|_|  _|  _|  _|          _|_|    _|  _|    _|      _|_| "
echo "                                                                        " 
echo "------------------------------------------------------------------------"
echo "----------               VA  HEALTH CHECK                    -----------"
echo "------------------------------------------------------------------------"
# Configuration Files

HTTP_PROXY_FILE=/home/sailpoint/proxy.yaml
CONFIG_FILE=/home/sailpoint/config.yaml
# OS Version
echo "=================================="
echo "OS Version"
echo "=================================="
echo $(awk '{split($0, a, " "); print a[3]}' <<<  $(uname -a))
# Network 
echo "=================================="
echo "Checking Network Configuration"
echo "=================================="
IP=$(ifconfig ens160 | grep 'inet' | cut -d: -f2 | awk '{print $2}')
NET_MASK=$(ifconfig ens160 | grep 'inet' | cut -d: -f2 | awk '{print $4}')
DNS=$(cat /etc/resolv.conf  | grep -v '^#' | grep nameserver | awk '{print $2}')
echo "IP:   " $IP
echo "MASK: " $NET_MASK
echo "DNS:  " $DNS

echo "Cheking DNS Server ..."

if dig @"$DNS" -t ns sqs.us-east-1.amazonaws.com |grep -qai 'sqs.us-east-1' 
then 
    echo -e "\e[32mSUCCESS\e[0m: Resolving sqs.us-east-1.amazonaws.com" 
else 
    echo -e "\e[31m\e[5mERROR\e[0m: Resolving sqs.us-east-1.amazonaws.com"
fi

# Configuration Options
echo "=================================="
if test -f "$HTTP_PROXY_FILE"; 
then
    echo "HTTP Proxy configuration file found"
    echo "=================================="
else

	if grep -R "tunnelTraffic: true" "$CONFIG_FILE" > /dev/null
	then
    		echo "Secure Tunnel configuration found"
                echo "=================================="
	else
    		echo "Standard configuration found"
		echo "=================================="
		# Find connected pod
		POD=$(awk '/pod:/{print $NF}' "$CONFIG_FILE")
		POD=$(echo $POD|tr -d '\n\r')
		echo "pod : " $POD

		# Tenant Name
		TENANT=$(awk '/org:/{print $NF}' "$CONFIG_FILE")
		TENANT=$(echo $TENANT|tr -d '\n\r')
		echo "org : " $TENANT

		# Checking Active Services
		echo "=================================="
                echo "Services Check"
                echo "=================================="
		CCG_STATUS=$(systemctl is-active ccg)
		if [ $CCG_STATUS = "active" ]
		then
			echo -e "\e[32mSUCCESS\e[0m: ccg service is Active"
		else
			echo -e "\e[31m\e[5mERROR\e[0m: ccg service is not Active"
		fi

		CHARON_STATUS=$(systemctl is-active charon)
                if [ $CHARON_STATUS = "active" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: charon service is Active"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: charon service is not Active"
                fi

		ESX_STATUS=$(systemctl is-active esx_dhcp_bump)
                if [ $ESX_STATUS = "inactive" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: esx_dhcp_bump service is Inactive"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: esx_dhcp_bump service is Active"
                fi
			
		FLUENT_STATUS=$(systemctl is-active fluent)
                if [ $FLUENT_STATUS = "active" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: fluent service is Active"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: fluent service is not Active"
                fi

		TB_STATUS=$(systemctl is-active toolbox)
                if [ $TB_STATUS = "active" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: toolbox service is Active"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: toolbox service is not Active"
                fi

                VA_AGENT_STATUS=$(systemctl is-active va_agent)
                if [ $VA_AGENT_STATUS = "active" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: va_agent service is Active"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: va_agent service is not Active"
                fi

                DOCKER_STATUS=$(systemctl is-active docker)
                if [ $DOCKER_STATUS = "active" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: docker service is Active"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: docker service is not Active"
                fi

                WORKFLOW_STATUS=$(systemctl is-active workflow)
                if [ $CCG_STATUS = "active" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: workflow service is Active"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: workflow service is not Active"
                fi


		# Checking external connectivity
		echo "=================================="
		echo "External Connectivity Check"
		echo "=================================="
		STATUS_AWS=$(curl --write-out %{http_code} --silent --output /dev/null  https://sqs.us-east-1.amazonaws.com)
		if [ $STATUS_AWS = "404" ]
		then
			echo -e "\e[32mSUCCESS\e[0m: Connection to https://sqs.us-east-1.amazonaws.com"
		else
			echo -e "\e[31m\e[5mERROR\e[0m: VA cannot connect to https://sqs.us-east-1.amazonaws.com"
		fi
	        
		TENANT_URL="https://${TENANT}.identitynow.com" 	
		STATUS_IDN=$(curl --write-out %{http_code} --silent --output /dev/null  $TENANT_URL)
                if [ $STATUS_IDN = "302" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: Connection to $TENANT_URL"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: VA cannot connect to $TENANT_URL"
                fi

		API_URL="https://${TENANT}.api.identitynow.com"
		STATUS_API=$(curl --write-out %{http_code} --silent --output /dev/null $API_URL)
                if [ $STATUS_API = "404" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: Connection to $API_URL"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: VA cannot connect to $API_URL"
                fi

		POD_URL="https://${POD}.accessiq.sailpoint.com"
		STATUS_POD=$(curl --write-out %{http_code} --silent --output /dev/null $POD_URL)
                if [ $STATUS_POD = "302" ]
                then
                        echo -e "\e[32mSUCCESS\e[0m: Connection to $POD_URL"
                else
                        echo -e "\e[31m\e[5mERROR\e[0m: VA cannot connect to $POD_URL"
                fi 
		echo "=================================="


	fi
fi

