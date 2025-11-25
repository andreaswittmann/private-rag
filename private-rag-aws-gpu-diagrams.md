# Private RAG AWS GPU Deployment Diagrams

Based on `private-rag-aws-gpu.org`, the following diagrams illustrate the architecture, workflow, interaction sequence, and project timeline for the Private RAG GPU deployment.

## 1. System Architecture

This diagram illustrates the AWS infrastructure and the software stack running on the GPU-enabled EC2 instance.

```mermaid
graph TB
    %% Styles
    classDef user fill:#FFE4B5,stroke:#FFA500,stroke-width:3px,color:black;
    classDef cloud fill:#B1CFFC,stroke:#87CEEB,stroke-width:3px,color:darkblue;
    classDef infrastructure fill:#DFF5D0,stroke:#A3E278,stroke-width:3px,color:black;
    classDef hardware fill:#F5F5F5,stroke:darkgray,stroke-width:3px,color:black;
    classDef software fill:#E6E6FA,stroke:#DDA0DD,stroke-width:3px,color:black;
    classDef container fill:#FFB6C1,stroke:#FF69B4,stroke-width:3px,color:black;
    classDef security fill:#FFFACD,stroke:#FFD700,stroke-width:3px,color:black;

    subgraph User_Machine ["Local Machine"]
        User((User / Developer))
        Browser(["Web Browser"])
        Terminal(["Terminal / Emacs"])
        Terraform(["Terraform CLI"])
    end

    subgraph AWS_Cloud ["AWS Cloud (eu-north-1)"]
        direction TB

        subgraph VPC ["Default VPC"]

            subgraph Security_Group ["Security Group"]
                Ports(["Inbound Ports: 22, 80, 443"])
            end

            subgraph EC2_Instance [EC2 Instance: g4dn.xlarge]


                subgraph Hardware ["Hardware"]
                    GPU(["NVIDIA T4 GPU"])
                    vCPU(["4 vCPUs"])
                    RAM(["16 GB RAM"])
                end

                subgraph Software_Stack ["Software Stack"]
                    Drivers(["NVIDIA Drivers & CUDA 12.x"])
                    DockerEngine(["Docker Engine"])

                    subgraph Docker_Containers ["Docker Containers"]
                        Nginx(["Nginx Proxy (HTTPS)"])
                        RagFlow(["RagFlow Core (GPU)"])
                        Executor(["Executor (GPU Worker)"])
                        DBs(["ElasticSearch / Redis / MySQL"])

                    end
                end
            end
        end
    end


    %% Connections
    User --> Terminal
    User --> Browser
    Terminal -- "SSH (Port 22)" --> EC2_Instance
    Terminal -- "CLI Commands" --> Terraform
    Terraform -- "Terraform Apply" --> EC2_Instance
    Terraform -- "Terraform Apply" --> Security_Group
    Browser -- "HTTPS (Port 443)" --> Nginx
    Browser -- "SSH Tunnel (Port 9380)" --> Nginx

    Nginx --> RagFlow
    RagFlow --> Executor
    Executor --> GPU
    Drivers --- GPU
    DockerEngine --- Drivers

    %% Styling
    class User user;
    class AWS_Cloud cloud;
    class EC2_Instance infrastructure;
    class Hardware hardware;
    class Software_Stack,DockerEngine,Drivers software;
    class Docker_Containers container;
    class Security_Group security;

```

## Legend

```mermaid
graph LR
    %% Styles
    classDef user fill:#FFE4B5,stroke:#FFA500,stroke-width:3px,color:black;
    classDef cloud fill:#B1CFFC,stroke:#87CEEB,stroke-width:3px,color:darkblue;
    classDef infrastructure fill:#DFF5D0,stroke:#A3E278,stroke-width:3px,color:black;
    classDef hardware fill:#F5F5F5,stroke:darkgray,stroke-width:3px,color:black;
    classDef software fill:#E6E6FA,stroke:#DDA0DD,stroke-width:3px,color:black;
    classDef container fill:#FFB6C1,stroke:#FF69B4,stroke-width:3px,color:black;
    classDef security fill:#FFFACD,stroke:#FFD700,stroke-width:3px,color:black;

    subgraph Legend ["Legend"]
        UserLegend(["User/Developer"])
        CloudLegend(["Cloud Infrastructure"])
        InfraLegend(["Server Infrastructure"])
        HardwareLegend(["Hardware Components"])
        SoftwareLegend(["Software Stack"])
        ContainerLegend(["Containers"])
        SecurityLegend(["Security"])
    end

    %% Legend styling
    class UserLegend user;
    class CloudLegend cloud;
    class InfraLegend infrastructure;
    class HardwareLegend hardware;
    class SoftwareLegend software;
    class ContainerLegend container;
    class SecurityLegend security;
```

## 2. Deployment Flowchart

This flowchart shows the high-level process from environment setup to infrastructure cleanup.

```mermaid
flowchart TD
    Start([Start])

    %% Actions Stream (Left)
    Setup[Setup Environment<br/>Clone repo, check AWS creds]
    Infra[Provision Infrastructure<br/>Generate keys, Terraform apply]
    Config[Configure Instance<br/>SSH setup, install tools, verify GPU]
    Deploy[Deploy RagFlow<br/>Clone repo, configure GPU mode, launch]
    Security[Configure Security<br/>Generate SSL certs, setup HTTPS]
    Use[Use System<br/>Access UI, upload docs, RAG queries]
    Cleanup[Cleanup<br/>Stop services, destroy infrastructure]

    %% Results Stream (Right)
    SetupResult[Environment ready]
    InfraResult[EC2 GPU instance running]
    ConfigResult[GPU drivers & Docker ready]
    DeployResult[RagFlow services running]
    SecurityResult[HTTPS access enabled]
    UseResult[RAG functionality operational]
    CleanupResult[Resources terminated]

    End([End])

    %% Flow
    Start --> Setup
    Setup --> Infra
    Infra --> Config
    Config --> Deploy
    Deploy --> Security
    Security --> Use
    Use --> Cleanup
    Cleanup --> End

    %% Action to Result connections
    Setup -.-> SetupResult
    Infra -.-> InfraResult
    Config -.-> ConfigResult
    Deploy -.-> DeployResult
    Security -.-> SecurityResult
    Use -.-> UseResult
    Cleanup -.-> CleanupResult

    %% Result progression
    SetupResult --> InfraResult --> ConfigResult --> DeployResult --> SecurityResult --> UseResult --> CleanupResult

    %% Styling
    style Start fill:#f9f,stroke:#333,stroke-width:2px
    style End fill:#f9f,stroke:#333,stroke-width:2px
    style Deploy fill:#9f9,stroke:#333
    style Use fill:#9f9,stroke:#333
```

## 3. Sequence Diagram

This diagram shows the interactions between the user, the local environment, AWS, and the deployed instance.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Local as Local Terminal
    participant AWS as AWS Cloud API
    participant EC2 as EC2 Instance (GPU)
    participant Docker as Docker/RagFlow

    Note over User, Local: Foundation & IaC
    User->>Local: Clone Repo & Set Env Vars
    User->>Local: Generate SSH Keys
    User->>Local: terraform apply
    Local->>AWS: Request Resources (EC2 g4dn.xlarge)
    AWS-->>Local: Resources Created (IP Address)
    Local->>Local: Update SSH Config

    Note over User, EC2: Configuration
    User->>EC2: SSH Connection
    User->>EC2: Install Docker, nvitop, uv
    User->>EC2: Verify NVIDIA Drivers (nvidia-smi)
    EC2-->>User: GPU Status OK

    Note over User, Docker: Deployment
    User->>EC2: Clone RagFlow
    User->>EC2: Configure .env (GPU) & docker-compose.yml
    User->>EC2: docker compose up -d
    EC2->>Docker: Pull Images & Start Containers
    Docker-->>EC2: Services Running

    Note over User, Docker: HTTPS Setup
    User->>EC2: Generate Self-Signed SSL Certs
    User->>EC2: Configure Nginx & Mount Volumes
    User->>EC2: Restart Containers
    Docker-->>EC2: HTTPS Enabled

    Note over User, Docker: Usage
    User->>Docker: Access Web UI (HTTPS/Tunnel)
    User->>Docker: Upload Documents
    Docker->>EC2: Process Embeddings (GPU)
    User->>Docker: RAG Query
    Docker->>EC2: Inference (GPU)
    Docker-->>User: AI Response

    Note over User, AWS: Cleanup
    User->>EC2: Stop Services
    User->>Local: terraform destroy
    Local->>AWS: Terminate Resources
    AWS-->>Local: Confirmation
```

## 4. Project Timeline

This timeline visualizes the phases of the deployment project.

```mermaid
timeline
    title Private RAG GPU Deployment Timeline
    section Foundation
        Environment Setup : Clone Repository : Check Prerequisites : AWS Setup : Check Credentials 
    section Infrastructure
        Provisioning with Terraform : Generate SSH Keys : Terraform Plan : Terraform Apply : Verification  : Check Instance State
    section Configuration
        System Tools : Install Docker : Install nvitop/htop : GPU Check :  CUDA Verification
    section Deployment
        RagFlow Setup : Clone RagFlow : Configure GPU Mode :  Launch Docker Container :  Service Health Check
    section Security
        HTTPS Configuration : Generate SSL Certs : Nginx Configuration :  Restart Docker Container : Verify HTTP Access
    section Operation
        RAG Workflow : Document Upload : Knowledge Base Config : AI Chat Query
    section Cleanup
        Teardown : Stop Containers : Terraform Destroy : Clean Local Config

```

# RagFlow AWS GPU Deployment Architecture

```mermaid
graph LR
    %% Define styles for visual appeal
    classDef local fill:#e3f2fd,stroke:#1565c0,stroke-width:2px,color:#0d47a1;
    classDef aws fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#e65100;
    classDef instance fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#1b5e20;
    classDef container fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#4a148c;
    classDef gpu fill:#212121,stroke:#00e676,stroke-width:3px,color:#00e676;
    classDef storage fill:#fff9c4,stroke:#fbc02d,stroke-width:2px,color:#f57f17;

    subgraph Local ["💻 Local Workstation (Control Plane)"]
        direction TB
        User([User / Developer]):::local
        Emacs[Emacs Live-Scripting]:::local
        Terraform[Terraform IaC]:::local
        SSH_Client[SSH Client]:::local
    end

    subgraph Cloud ["☁️ AWS Cloud (eu-north-1)"]
        direction TB
        
        subgraph Network ["vpc-default"]
            IGW((Internet Gateway)):::aws
            SG[Security Group<br/>SSH, HTTP, HTTPS]:::aws
        end

        subgraph EC2 ["🖥️ EC2 Instance (g4dn.xlarge)"]
            direction TB
            AMI[Ubuntu 24.04<br/>Deep Learning AMI]:::instance
            
            subgraph Hardware ["GPU Acceleration"]
                T4[NVIDIA T4 GPU<br/>16GB VRAM]:::gpu
                CUDA[CUDA Toolkit]:::gpu
            end

            subgraph Docker ["🐳 Docker Platform"]
                direction TB
                Nginx[Nginx Proxy<br/>Self-Signed SSL]:::container
                
                subgraph App ["RagFlow Application"]
                    Server[RagFlow Server]:::container
                    Executor[Task Executor]:::container
                end
                
                subgraph Data ["Persistence Layer"]
                    ES[(Elasticsearch)]:::storage
                    Redis[(Redis)]:::storage
                    MySQL[(MySQL)]:::storage
                    MinIO[(MinIO)]:::storage
                end
            end
        end
    end

    %% Orchestration
    User -->|Writes| Emacs
    Emacs -->|Executes| Terraform
    Terraform -->|Provisions| EC2
    
    %% Network Access
    User -->|SSH / Tunnel| SSH_Client
    SSH_Client -->|Port 22| IGW
    User -->|HTTPS| IGW
    IGW --> SG
    SG --> AMI
    
    %% Internal Wiring
    AMI --> Docker
    Nginx --> Server
    Server <--> Executor
    Server <--> Data
    Executor <--> Data

    %% GPU Binding
    T4 -.->|Accelerates| Server
    T4 -.->|Accelerates| Executor
    CUDA --- T4

    %% SSH Tunnel Visualization
    SSH_Client -.->|Tunnel 9380:80| Nginx
```

## Architecture Components Overview

### Infrastructure Layer
- **AWS EC2 GPU Instance**: `g4dn.xlarge` providing a balance of compute and GPU performance.
- **Deep Learning AMI**: Ubuntu 24.04 pre-configured with NVIDIA drivers and CUDA, eliminating manual setup.
- **Networking**: Default VPC in `eu-north-1` with Security Groups allowing SSH (22), HTTP (80), and HTTPS (443).

### Container Platform
- **Docker Engine**: Runtime for containerized applications, configured with `nvidia-container-toolkit`.
- **RagFlow Stack**:
    - **Nginx**: Handles reverse proxying and SSL termination (Self-Signed).
    - **RagFlow Server**: Core application logic.
    - **Task Executor**: Handles background jobs like document parsing.
    - **Databases**: Elasticsearch (Vector DB), Redis (Caching), MySQL (Metadata), MinIO (Object Storage).

### GPU Acceleration
- **NVIDIA T4**: 16GB VRAM GPU dedicated to accelerating embeddings generation and vector search operations.
- **CUDA Integration**: Passed through to Docker containers via the `gpu` profile.

### Development Workflow
- **Live-Scripting**: The entire infrastructure and deployment is managed via executable code blocks in Emacs.
- **Terraform**: Infrastructure as Code (IaC) ensures reproducible environment creation and destruction.