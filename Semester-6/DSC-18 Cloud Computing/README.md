# DSC-18 Cloud Computing - Practicals

![Course](https://img.shields.io/badge/Course-DSC--18-blue.svg?style=for-the-badge)

Welcome to the collection of practical assignments for the **Cloud Computing** course. This repository contains implementations for various **cloud-based** problems solution.

---
## 📅 List of Practicals

1. [Introduction to Cloud Platforms](1.md)
- **Objective**: Familiarize students with cloud platforms and their interfaces.
Steps:
    1) Create free-tier accounts on AWS, Azure, and GCP.
    2) Explore dashboards and identify key services (compute, storage, networking).
    3) Understand pricing calculators on each platform.

2. [Launch Your First Amazon EC2 Instance](2.md)
- **Objective**: Deploy a virtual machine on AWS using Amazon EC2.
Steps:
    1) Launch an EC2 instance from the AWS Management Console.
    2) Use a pre-configured AMI (e.g., Amazon Linux 2).
    3) Configure security groups to allow SSH access.
    4) Connect to the instance using SSH.

3. [Set Up a VPC](3.md)
- **Objective**: Create and configure a Virtual Private Cloud (VPC).
Steps:
    1) Create a custom VPC with a public and private subnet.
    2) Launch an EC2 instance in the public subnet and another in the private subnet.
    3) Configure an Internet Gateway for Internet access in the public subnet.
    4) Use a NAT Gateway to provide internet access for instances in the private subnet.

4. [Configure Auto Scaling and Load Balancing](4.md)
- **Objective**: Set up an auto-scaling group and load balancer.
Steps:
    1) Create an Auto Scaling Group and define a launch template.
    2) Configure scaling policies (e.g., scale up when CPU utilization exceeds 70%).
    3) Deploy an Application Load Balancer (ALB) to distribute traffic.
    4) Test auto-scaling by simulating high traffic.

5. [Deploying a Static Website on the Cloud](5.md)
- **Objective**: Host a static website using cloud storage services.
Steps:
    1) Deploy a static website using any of the following:
        - AWS S3
        - Azure Blob Storage
        - GCP Cloud Storage
    2) Configure permissions and enable public access.

6. [Monitor Resources Using AWS CloudWatch](6.md)
- **Objective**: Use CloudWatch to monitor AWS resources.
Steps:
    1) Set up CloudWatch metrics for an EC2 instance (e.g., CPU utilization).
    2) Create a CloudWatch Alarm to send notifications when a threshold is exceeded.
    3) Configure an SNS topic for email notifications.
    4) Test the setup by simulating high CPU usage.

7. [Install OpenStack](7.md)
- **Objective**: Set up a local OpenStack environment for practice.

8. [Launch Your First Instance](8.md)
- **Objective**: Create a virtual machine (VM) using OpenStack.
Steps:
    1) Create a project and assign roles to users.
    2) Upload an image (e.g., Ubuntu cloud image) to the Glance service.
    3) Define a flavor to specify VM configurations.
    4) Launch an instance using the Horizon dashboard or CLI.
    * Resources Needed:
        - OpenStack Horizon access or CLI setup.
        - Sample Ubuntu or CentOS cloud image (from Ubuntu Cloud Images).

9. [Set Up Networking](9.md)
- **Objective**: Configure OpenStack Neutron to provide networking for instances.
Steps:
    1) Create a private network and a public network.
    2) Attach a router to connect the private network to the public network.
    3) Assign floating IPs to instances for external access.

10. [Cloud Security](10.md)
- **Objective**: Understand security practices in the cloud.
Steps:
    1) Implement IAM roles and policies for a cloud platform.
    2) Create and assign least-privilege roles to users.
    3) Configure data encryption for storage (e.g., S3 bucket encryption).
    4) Set up a firewall rule and test its functionality.
    
---
<p align="right">
  <i>Developed with ❤️ by <a href="https://github.com/16ratneshkumar">16ratneshkumar</a></i>
</p>
