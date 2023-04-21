{% set AvailabilityZones = "$AvailabilityZones" %}
{% set AvailabilityZone1 = "$AvailabilityZone1" %}
{% set AvailabilityZone2 = "$AvailabilityZone2" %}
{% set AvailabilityZone3 = "$AvailabilityZone3" %}
{% set PrivateSubnet1CIDR = "$PrivateSubnet1CIDR" %}
{% set PrivateSubnet2CIDR = "$PrivateSubnet2CIDR" %}
{% set PrivateSubnet3CIDR = "$PrivateSubnet3CIDR" %}
{% set PublicSubnet1CIDR = "$PublicSubnet1CIDR" %}
{% set PublicSubnet2CIDR = "$PublicSubnet2CIDR" %}
{% set PublicSubnet3CIDR = "$PublicSubnet3CIDR" %}
{% set VPCCIDR = "$VPCCIDR" %}

tap_vpc:
  aws.ec2.vpc.present:
  - tags:
      Name: tap_quickstart_vpc
      Stack: tap_quickstart_idem
      LandingZone: dev_cloud
  - cidr_block_association_set:
    - CidrBlock: {{VPCCIDR}}

tap_internet_gateway:
  aws.ec2.internet_gateway.present:
    - tags:
        Name: tap_internet_gateway
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud
    - vpc_id:
      - ${aws.ec2.vpc:tap_vpc:resource_id}

tap_dhcp_option:
  aws.ec2.dhcp_option.present:
    - dhcp_configurations:
        - Key: domain-name
          Values:
          - ec2.internal
        - Key: domain-name-servers
          Values:
          - AmazonProvidedDNS
    - vpc_id:
      - ${aws.ec2.vpc:tap_vpc:resource_id}
    - tags:
        Name: tap_dhcp_option
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

nat_1_eip:
  aws.ec2.elastic_ip.present:
    - name: "nat_1_eip"
    - domain: "vpc"
    - tags:
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud
nat_2_eip:
  aws.ec2.elastic_ip.present:
    - name: "nat_2_eip"
    - domain: "vpc"
    - tags:
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud
nat_3_eip:
  aws.ec2.elastic_ip.present:
    - name: "nat_3_eip"
    - domain: "vpc"
    - tags:
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud


private_subnet_1a:
  aws.ec2.subnet.present:
    - cidr_block: {{PrivateSubnet1CIDR}}
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - availability_zone: {{AvailabilityZone1}}
    - map_public_ip_on_launch: false
    - assign_ipv6_address_on_creation: false
    - map_customer_owned_ip_on_launch: false
    - enable_dns_64: false
    - private_dns_name_options_on_launch:
        EnableResourceNameDnsAAAARecord: false
        EnableResourceNameDnsARecord: false
        HostnameType: ip-name
    - tags:
        Name: private_subnet_1a
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

private_subnet_2a:
  aws.ec2.subnet.present:
    - cidr_block: {{PrivateSubnet2CIDR}}
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - availability_zone: {{AvailabilityZone2}}
    - map_public_ip_on_launch: false
    - assign_ipv6_address_on_creation: false
    - map_customer_owned_ip_on_launch: false
    - enable_dns_64: false
    - private_dns_name_options_on_launch:
        EnableResourceNameDnsAAAARecord: false
        EnableResourceNameDnsARecord: false
        HostnameType: ip-name
    - tags:
        Name: private_subnet_2a
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

private_subnet_3a:
  aws.ec2.subnet.present:
    - cidr_block: {{PrivateSubnet3CIDR}}
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - availability_zone: {{AvailabilityZone3}}
    - map_public_ip_on_launch: false
    - assign_ipv6_address_on_creation: false
    - map_customer_owned_ip_on_launch: false
    - enable_dns_64: false
    - private_dns_name_options_on_launch:
        EnableResourceNameDnsAAAARecord: false
        EnableResourceNameDnsARecord: false
        HostnameType: ip-name
    - tags:
        Name: private_subnet_3a
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

nat_gateway_1:
  aws.ec2.nat_gateway.present:
    - subnet_id: ${aws.ec2.subnet:private_subnet_1a:resource_id}
    - connectivity_type: public
    - allocation_id: ${aws.ec2.elastic_ip:nat_1_eip:allocation_id}
    - tags:
        Name: nat_gateway_1
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

nat_gateway_2:
  aws.ec2.nat_gateway.present:
    - subnet_id: ${aws.ec2.subnet:private_subnet_2a:resource_id}
    - connectivity_type: public
    - allocation_id: ${aws.ec2.elastic_ip:nat_2_eip:allocation_id}
    - tags:
        Name: nat_gateway_2
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

nat_gateway_3:
  aws.ec2.nat_gateway.present:
    - subnet_id: ${aws.ec2.subnet:private_subnet_3a:resource_id}
    - connectivity_type: public
    - allocation_id: ${aws.ec2.elastic_ip:nat_3_eip:allocation_id}
    - tags:
        Name: nat_gateway_3
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

private_subnet_1a_route_table:
  aws.ec2.route_table.present:
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - routes:
      - DestinationCidrBlock: {{VPCCIDR}}
        GatewayId: local
      - DestinationCidrBlock: 0.0.0.0/0
        NatGatewayId: ${aws.ec2.nat_gateway:nat_gateway_1:resource_id}
    - tags:
        Name: private_subnet_1a_route_table
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

private_subnet_2a_route_table:
  aws.ec2.route_table.present:
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - routes:
      - DestinationCidrBlock: {{VPCCIDR}}
        GatewayId: local
      - DestinationCidrBlock: 0.0.0.0/0
        NatGatewayId: ${aws.ec2.nat_gateway:nat_gateway_2:resource_id}
    - tags:
        Name: private_subnet_2a_route_table
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

private_subnet_3a_route_table:
  aws.ec2.route_table.present:
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - routes:
      - DestinationCidrBlock: {{VPCCIDR}}
        GatewayId: local
      - DestinationCidrBlock: 0.0.0.0/0
        NatGatewayId: ${aws.ec2.nat_gateway:nat_gateway_3:resource_id}
    - tags:
        Name: private_subnet_3a_route_table
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

public_subnet_1:
  aws.ec2.subnet.present:
    - cidr_block: {{PublicSubnet1CIDR}}
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - availability_zone: {{AvailabilityZone1}}
    - map_public_ip_on_launch: true
    - assign_ipv6_address_on_creation: false
    - map_customer_owned_ip_on_launch: false
    - enable_dns_64: false
    - private_dns_name_options_on_launch:
        EnableResourceNameDnsAAAARecord: false
        EnableResourceNameDnsARecord: false
        HostnameType: ip-name
    - tags:
        Name: public_subnet_1
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

public_subnet_2:
  aws.ec2.subnet.present:
    - cidr_block: {{PublicSubnet2CIDR}}
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - availability_zone: {{AvailabilityZone2}}
    - map_public_ip_on_launch: true
    - assign_ipv6_address_on_creation: false
    - map_customer_owned_ip_on_launch: false
    - enable_dns_64: false
    - private_dns_name_options_on_launch:
        EnableResourceNameDnsAAAARecord: false
        EnableResourceNameDnsARecord: false
        HostnameType: ip-name
    - tags:
        Name: public_subnet_2
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

public_subnet_3:
  aws.ec2.subnet.present:
    - cidr_block: {{PublicSubnet3CIDR}}
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - availability_zone: {{AvailabilityZone3}}
    - map_public_ip_on_launch: true
    - assign_ipv6_address_on_creation: false
    - map_customer_owned_ip_on_launch: false
    - enable_dns_64: false
    - private_dns_name_options_on_launch:
        EnableResourceNameDnsAAAARecord: false
        EnableResourceNameDnsARecord: false
        HostnameType: ip-name
    - tags:
        Name: public_subnet_3
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

public_subnet_route_table:
  aws.ec2.route_table.present:
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - routes:
      - DestinationCidrBlock: {{VPCCIDR}}
        GatewayId: local
      - DestinationCidrBlock: 0.0.0.0/0
        GatewayId: ${aws.ec2.internet_gateway:tap_internet_gateway:resource_id}
    - tags:
        Name: public_subnet_route_table
        Stack: tap_quickstart_idem
        LandingZone: dev_cloud

tap_vpc_dhcp_option_association:
  aws.ec2.dhcp_option_association.present:
    - vpc_id: ${aws.ec2.vpc:tap_vpc:resource_id}
    - dhcp_id: ${aws.ec2.dhcp_option:tap_dhcp_option:resource_id}
    - name: 'tap_vpc_dhcp_option_association'

private_subnet_1a_route_table_association:
  aws.ec2.route_table_association.present:
    - route_table_id: ${aws.ec2.route_table:private_subnet_1a_route_table:resource_id}
    - subnet_id: ${aws.ec2.subnet:private_subnet_1a:resource_id}

private_subnet_2a_route_table_association:
  aws.ec2.route_table_association.present:
    - route_table_id: ${aws.ec2.route_table:private_subnet_2a_route_table:resource_id}
    - subnet_id: ${aws.ec2.subnet:private_subnet_2a:resource_id}

private_subnet_3a_route_table_association:
  aws.ec2.route_table_association.present:
    - route_table_id: ${aws.ec2.route_table:private_subnet_3a_route_table:resource_id}
    - subnet_id: ${aws.ec2.subnet:private_subnet_3a:resource_id}

public_subnet_1_route_table_association:
  aws.ec2.route_table_association.present:
    - route_table_id: ${aws.ec2.route_table:public_subnet_route_table:resource_id}
    - subnet_id: ${aws.ec2.subnet:public_subnet_1:resource_id}

public_subnet_2_route_table_association:
  aws.ec2.route_table_association.present:
    - route_table_id: ${aws.ec2.route_table:public_subnet_route_table:resource_id}
    - subnet_id: ${aws.ec2.subnet:public_subnet_2:resource_id}

public_subnet_3_route_table_association:
  aws.ec2.route_table_association.present:
    - route_table_id: ${aws.ec2.route_table:public_subnet_route_table:resource_id}
    - subnet_id: ${aws.ec2.subnet:public_subnet_3:resource_id}

