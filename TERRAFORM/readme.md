# Q & A

## What is the difference between high availability and fault tolerance? Which is best to strive for?

* High availability is about building systems that stay up most of the time by minimizing downtime as much as possible. 

* Fault tolerance means the system is designed to keep working even when something breaks completely. Fault tolerant systems is more complex and cost more money.


---

## Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem?

* Autoscaling is when a system automatically chaanges the number of resources it uses based on demand. adding more when traffic increases and reducing them when it drops. Elasticity is the ability of an infrastructure to expand or contract as needed.

* Vertical scaling means upgrading a single machine by giving it more power. Horizontal scaling means adding more machines or instances to share the workload. 

* Both can be used on premise systems, but cloud platforms make scaling easier to automate and manage.

---

## Explain what the difference between managed and unmanaged instance groups is.

* Managed instance groups use an instance template to automatically create and manage VM instances. They also include features like autoscaling, autohealing.

* Unmanaged instance groups are more hands-on because each vm has to be configured and managed individually. There’s no built in automation for scaling or repairs.

* Because of that, managed instance groups are preferred in production environments. They reduce the amount of manual management required and make systems more reliable and easier to maintain.

---

## Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same?

* Health checks in managed instance groups are mostly there for autohealing. If a VM stops responding or starts acting unhealthy, the group can automatically replace it to keep things running.

* Load balancer health checks work a bit differently. Their main job is to decide which instances are healthy enough to receive traffic. So instead of repairing anything, they just help route traffic away from bad instances.

* Even though they can sometimes use the same endpoint or check the same application path, they serve different roles. In GCP, they’re still treated as separate resources, even if they overlap in what they’re checking.

---

## Explain in a few sentences what the 3 tier architecture is and how it relates to what you are learning.

* A 3-tier architecture splits an application into three separate layers: the frontend, the application layer, and the database layer.

* The frontend is what users interact with directly. The application layer is where the main processing and business logic happens. The database layer is responsible for storing and retrieving data.

* This connects to what we’re learning because cloud systems are often built around supporting these layers separately. In many setups, managed instance groups and load balancers are used in the application layer to help with scaling and keeping the application available even under heavy traffic.

---

# Runbook

## Goal  
* The goal of this runbook is to create a managed instance group in google cloud via clickops. The setup is designed so that the instance group can automatically scale based on demand, recover unhealthy instances without manual interference, and distribute virtual machines across multiple zones.

* This approach reduces day-to-day operational work while improving system reliability and consistency.

---

## Prerequisites  


• A working googel cloud project already created and accessible  
• Billing enabled on the project so resources can be provisioned without interruption  
• Compute Engine API enabled to allow VM and instance group operations  
• Proper IAM permissions assigned for managing Compute Engine resources  
• An existing VPC network available to attach the instances to the correct infrastructure layer  
• Firewall rules configured to allow HTTP traffic, or alternatively a usable http-server network tag applied  
• A startup script prepared in advance for automated instance configuration during boot  
• Basic understanding of the google cloud console

---

# Create the Instance Template

## Steps

1. Go to the GCP Console  
   • Compute Engine  
   • Instance Templates  

2. Select  
   • Create Instance Template  

3. Set up the basic VM configuration  
   • Choose an N-series machine type since it is meant for compute-heavy workloads  
   • Set the boot disk to CentOS Stream 10  
   • Set the root disk size to 100 GB so there is enough space for system and application use  
   • Enable an external IP so the VM can be reached if needed  
   • Add the network tag http-server. 
   This is used so firewall rules can apply correctly for HTTP traffic  

4. Go to  
   • Management → Automation  

5. Paste in the startup script  
   • This script runs automatically when the VM starts  
   • It is used to set up the machine without manual steps  

At this point, the template is basically a reusable VM setup that everything else will be built from.

---

# Create the Health Check

## Steps

1. Go to  
   • Network Services  
   • Load Balancing  
   • Health Checks  

2. Create a new health check  
   • Choose HTTP as the type  

3. Set the main settings  
   • Port: 80  
   • Keep interval and timeout at reasonable defaults or slightly adjusted values if needed  

This health check is what GCP uses later to see if the VM is working properly or not.

---

# Create the Managed Instance Group

## Steps

1. Go to  
   • Compute Engine  
   • Instance Groups  

2. Click  
   • Create Instance Group  

3. Choose  
   • New managed instance group  

4. Select regional instead of zonal  
   • This spreads the VMs across multiple zones automatically  
   • It helps if one zone goes down  

5. Pick the instance template created earlier  
   • This makes sure all VMs use the same setup  

6. Set the starting number of instances  
   • I used 2 so there is already some backup if one fails  

---

# Configure Autoscaling

## Steps

1. Turn on autoscaling for the group  

2. Set the basic limits  
   • Minimum instances: 2  
   • Maximum instances: 5  
   • CPU target: 60%  

This means the group can scale up when load increases and scale down when it is not needed.

---

# Configure Autohealing

## Steps

1. Open the autohealing section  

2. Attach the health check created earlier  

3. Set initial delay to 300 seconds  
   • This gives the VM time to fully start up  
   • It also allows the startup script to finish running  

If a VM is marked unhealthy after this, it will be replaced automatically.

---

# Verify Multi-Zone Deployment

## Steps

1. Open the managed instance group  

2. Go to the instances list  

3. Check the zones they are running in  

You should see them spread across different zones like  
• us-central1-a  
• us-central1-b  

*This confirms the setup is regional and not limited to a single zone.

---

# Terraform

## Explain the mandatory (required) arguments for a VM in Terraform

When creating a VM in Terraform, there are a few arguments that must be included for the resource to be valid and deploy correctly.

• name
This is the identifier of the VM. It is required so the instance can be created with a recognizable name inside the project.

• machine_type  
This defines the size and performance level of the VM (CPU and memory). Without it, Terraform does not know what compute resources to allocate.

• zone  
This tells GCP where the VM should physically run. It is required because resources in Compute Engine must exist in a specific zone.

• boot_disk  
This defines the operating system and disk settings for the VM. Without it, the instance would not know what to boot from.

• network_interface  
This connects the VM to a network. It is required so the instance can communicate internally and optionally externally.

* These are required because Terraform needs enough structure to fully define a working VM before deployment.

---

## Explain how to output the internal and external IP addresses of the provisioned VM and how you figured this out

* To display the IP addresses after deployment, Terraform outputs are used. These outputs reference specific attributes of the VM resource.
 * I figured this out by checking the Terraform documentation for the google_compute_instance resource and reviewing the available networking attributes.

---

## Choose 2 non-required arguments and give an explanation for both

### tags

The tags argument is used to assign labels to a VM that are mainly used for networking purposes. These tags do not change how the VM runs, but they are very important for controlling access.

---

### metadata_startup_script

The metadata_startup_script argument is not required because it is not needed for the VM to be created or to run. A VM will fully function without any startup script being provided.

---

## Explain how you would figure out the correct format for creating a VM with the “CentOS Stream 10” image

I would use the Google Cloud documentation and Terraform provider documentation to find the correct image project and image family format. I would also check examples from the documentation and verify that the image exists before running Terraform. Another option would be using the gcloud cli to list available images.

---

## Explain the difference between the name” argument and the computed id and self_link” attributes

The name argument is the readable name assigned to the VM during creation. The id attribute is automatically generated by GCP and uniquely identifies the resource internally. The self link attribute is the full api path for the resource and can be used when other resources need to reference the vm.

---

# Documentation & Resources Used

For this assignment, I only used the official documentation provided in the homework, along with the Google Cloud Terraform Registry documentation for the Google provider and Compute Engine resources.

Everything referenced came directly from official sources so the configuration matches what GCP expects.

---

## Instance Groups (Google Cloud Docs)

• https://docs.cloud.google.com/compute/docs/instance-groups#managed_instance_groups  
• https://cloud.google.com/instance-groups?hl=en  

These pages were used to understand how managed instance groups behave in Google Cloud.

What I took from this:
• instance groups are built using instance templates  
• they manage VM creation and replacement automatically  
• autoscaling changes the number of VMs based on demand  
• autohealing replaces unhealthy VMs without manual action  
• regional instance groups can spread VMs across multiple zones for higher availability  

---

## Load Balancing (Google Cloud Docs)

• https://cloud.google.com/load-balancing?hl=en  
• https://docs.cloud.google.com/load-balancing/docs/application-load-balancer  
• https://docs.cloud.google.com/load-balancing/docs/https  
• https://docs.cloud.google.com/load-balancing/docs/application-load-balancer#three-tier_web_services  

These resources were used to understand how traffic is handled in front of instance groups.

Key points learned:
• load balancers distribute incoming traffic across multiple VMs  
• only healthy instances are allowed to receive traffic  
• health checks are required to confirm instance status  
• this setup supports scalable and highly available architecture  
• multi-tier systems rely on load balancers to separate traffic layers  

---

## GCP Reliability / Architecture Guide

• https://docs.cloud.google.com/architecture/infra-reliability-guide/design  

This was used to understand why redundancy and multi-zone setups matter.

Main ideas:
• cloud systems should assume failures will happen  
• redundancy improves reliability and uptime  
• spreading resources across zones reduces risk of downtime  
• high availability is a standard design goal in cloud environments  

---

## Terraform Google Provider (Registry)

• https://registry.terraform.io/providers/hashicorp/google/latest/docs  

This was used for all Terraform implementation details.

What I focused on:
• google_compute_instance resource structure  
• required vs optional arguments  
• how networking blocks are written  
• how boot disks are configured  
• how Terraform outputs like self link, id, and IP addresses work  

This ensured the Terraform configuration matched the official provider requirements.

---

## Compute Engine Resource Documentation (Terraform Registry)

• https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance  
• https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference  

These helped with the VM configuration details.

What I used them for:
• confirming required fields for VM creation  
• verifying correct network interface structure  
• setting boot disk size to 100 GB  
• checking CentOS Stream 10 image formatting  
• understanding how metadata startup scripts are passed into VMs  

---

## Core GCP Concepts Used from Registry Knowledge

These concepts were applied throughout the assignment:

• managed instance groups  
• instance templates  
• autoscaling policies based on CPU usage  
• autohealing with health checks  
• difference between regional and zonal deployments  
• network tags and firewall rule behavior  
• startup scripts using metadata  
• external vs internal IP behavior  
• Terraform outputs including id, self link, and network IP values  

---

## How These Resources Were Used

These sources were not just read, but directly followed while building the configuration.

• instance group documentation guided autoscaling and autohealing setup  
• load balancing documentation helped define health check behavior  
• Terraform registry documentation ensured correct syntax and structure  
• provider reference confirmed all required arguments and output formats  

Everything was implemented using only official documentation and registry references, ensuring the configuration matches expected Google Cloud standards.