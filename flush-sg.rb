#!/usr/local/bin/ruby

# http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Client.html#describe_security_groups-instance_method

require 'aws-sdk'
# require 'pp'
require 'open-uri'

ec2 = Aws::EC2::Client.new(region:'sa-east-1', credentials: Aws::Credentials.new('AKIAJMC3VXFT3OFBD3HA', 'y7gFB8enJePm3iz72/X7oMEsGzxjM9104W7iAsia'))

remote_ip = open('http://whatismyip.akamai.com').read
security_groups = {'sg-540f9031'=>{'protocol' =>'tcp','from'=>22,'to'=>22}}
ips = [remote_ip]

begin

  resp = ec2.describe_security_groups({
    group_ids: security_groups.keys,
  })

  resp.security_groups.each do |group|
    puts group.group_id
      group.ip_permissions.each do |ip_permission|
        ip_permission.ip_ranges.each do |ip|
          ec2.revoke_security_group_ingress({
            # dry_run: true,
            group_id: group.group_id,
            ip_protocol: ip_permission.ip_protocol,
            from_port: ip_permission.from_port,
            to_port: ip_permission.to_port,
            cidr_ip: ip.cidr_ip,
          })
        end
      end
  end

  security_groups.each do |group_id, security_group|
    ips.each do |ip|
      ec2.authorize_security_group_ingress({
        # dry_run: true,
        group_id: group_id,
        ip_protocol: security_group['protocol'],
        from_port:  security_group['from'],
        to_port:  security_group['to'],
        cidr_ip:  "#{ip}/32",
      })
    end
  end

rescue Aws::EC2::Errors::ServiceError => e
  puts 'deu merda'
  puts e
end
