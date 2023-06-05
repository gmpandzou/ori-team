Project's Title:
    This project Containerize a wordpress application and deploy it using Terraform into an AWS ECS cluster made up AWS FARGATE compute.

Project Description
    This project deploy a wordpress application. The Wordpress application is containerize before getting deployed into and ECS cluster. The infrastructure is build on AWS cloud using a Terrafom script and it leverages AWS resources for  high availability like multiple Availabilities Zones, Application Load Balancer and target group.

    Technologies used for this project are:
Terraform : to define the infrastructure as a Code
Docker : to containerize the wordpress application
AWS cloud : to leverage cloud resources
AWS special services: ECR, ECS, FARGATE, S3, IAM
AWS ECR: to remotely store our wordpress application docker image and pull it inside AWS services (like AWS ECS) whenever it requires.

AWS ECS: to deploy our wordpress docker image into a cluster and enable us via port 80 to view in the browser using Application Load Balancer

AWS Fargate: helps us to focus on building the applications without managing servers. It removes us the pain of operational overhead of scaling, patching, securing, and managing servers.

S3: To remotely store our statefiles and versioning \
AWS Networking services: VPC - Subnets - Availability zones, 

    Challenges faced in this project:
Writing the docker-compose.yml file with all the services runing together
Handling the networking between the different AWS resources 
Configuring the Wordpress application set-up and the MySQL database set-up

Table of Contents
How to Install and Run the Project
    To run the project, you need to install the following tools
VS Code
Terraform
AWS CLI
Docker and Docker-Compose pluging
    You will also need to create an AWS account and a DockerHub account

    a. Create an AWS EC2 or an Ubuntu Virtual /machine
        > Ubuntu 22.04 LTS free eligible tier
        > t2.micro
    
    b. Install Docker
        > ssh into your VMirtual Machine
            $ ssh -i <keypairfile>.pem <username>@<ec2-public-ip>
        
        > Update your server repo
            $ sudo apt update
        
        > Install certificates and softwares dependencies
            $ sudo apt install apt-transport-https ca-certificates curl software-properties-common
        
        > Download and Add GPG key to the official Docker Repository to your system
            $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        > Add docker repository to APT sources
            $ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        > Update the package list
            $ sudo apt update

        > Make sure you are about to install from the docker repo and not the default ubuntu repo
            $ sudo apt-cache policy docker-ce

        > Install Docker
            $ sudo apt install docker-ce

        > Check if Docker is active and running
            $ sudo systemctl status docker

        > Add user account to the docker group
            $ echo $USER
            $ sudo usermod -aG docker $USER
        
        > Close the current SSH session and open a new ssh session for the change to take effect

        > Open a new ssh session

        >  Install Docker Compose
	        $ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

	        $ sudo chmod +x /usr/local/bin/docker-compose   #to apply executable permissions to the library

            $ docker-compose --version

How to Use the Project
    a. Containerize the wordpress application
        > Create a directory to hold your compose file and move into it
            $ mkdir wp-app-image
            $ cd wp-app-image

        > Create your docker-compose.yml file and copy/paste the script in this repo.:
            $ touch docker-compose.yml
            $ nano docker-compose.yml
    
    b. Log in your AWS account via the management console
        > Create a IAM Group with the following policies/permission:
            # AdministratorAccess
            # IAMFullAccess
            # AmazonRDSFullAccess
            # AmazonVPCFullAccess
            # AmazonECS_FullAccess

        > Create an IAM user and attach him to the created Group 

        > Save the credentials (Access Key and Secret access key)file


    b. Create the S3 bucket
        > Move to the directory containing the terraform S3 script:
            $ cd CARD-220064-docker-wp-ecs/enivronments/s3-backend
            $ pwd

        > Log in your AWS account via CLI using the previuosly created user credentials
            $ aws configure
        
        > Run the terraform commands
            $ terraform init    #to initialise the working directory, downloading the provider plugings and the modules

            $ terrafomr plan    #to create an execution plan for 

            $ terraform apply   #to create the ressources on AWS

        > Go to AWS Management console and Check the created S3 bucket 

    b. Create the AWS ECR repo
        > Deploy the terraform script to create the correponding infra on AWS cloud
Move to the right directory containing your script
                $ cd CARD-220064-docker-wp-ecs/enivronments/vpc-subnets-ecr

                $ pwd

Run the terraform commands
                $ terraform init  
                $ terrafomr plan  
                $ terraform apply 

    c. Push the wordpress docker image to the repo
        > Login to AWS account 
            $ aws configure
        
        > Login to your DockerHub account
            $ docker login

        > Go to AWS Management Console and open ECR
Click on "View Push Command"
        
        > Move to the directory containing your docker compose file
            $ cd CARD-220064-docker-wp-ecs/wp-app-image
            $ pwd
        
        > Retrieve an authenticatoin token and authenticate your Docker client to your ECR registry
            $ aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <repository_uri>
        
        > Build your wordpress application docker image
            $ docker-compose build .
        
        > Tag your image so that you can push it to your repository
            $ docker tag wordpress:latest <repository_uri>
        
        > Push the image to your ECR repo
            $ docker push <repository_uri>


    d. Deploy the rest of the infrastructure
        > Move to the directory containing the terraform script for the rest of the infra
            $ cd CARD-220064-docker-wp-ecs/enivronments/sg-alb-ecs
        
        > Run the terraform commands
            $ terraform init
            $ terraform plan
            $ terraform apply

        > Check the created resources on AWS management console


    e. Set-up the Wordpress Application configuration
        > Open the wordpress site 
copy the public DNS of load balance and paste in a new browser tab
        
        > Choose a language
        

Considerations 
    Further modifications or enhancements can be done to get a fully automated, scalable and high available wordpress application. Here are some thoughts:
Write a bash script to automate the steps of creating and pushing the docker image and to deploy all the infrastructure on AWS. 
Use a shared storage to persit the application data like AWS EFS
Create replicas of the RDS to avoid a single point of failure
Create a RDS database