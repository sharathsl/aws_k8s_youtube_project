# Simple terraform project to create aws ec2 instance/subnet in public, create another ec2 instance/subnet in private. 
# Access private instance from public instance, through NAT gateway attached to public internet gateway
# Project involves
- Create an VPC
- Create an internet gateway and attach to vpc
- Create public and private subnets
- Create route tables
- Create NAT
- Final step:
   From private instance, should be able to ping google
   ```
   [root@ip-10-0-28-153 ~]# ping google.com
   PING google.com (142.250.69.206) 56(84) bytes of data.
   64 bytes from sea30s08-in-f14.1e100.net (142.250.69.206): icmp_seq=170 ttl=39 time=9.80 ms
   64 bytes from sea30s08-in-f14.1e100.net (142.250.69.206): icmp_seq=171 ttl=39 time=8.25 ms
  ```

