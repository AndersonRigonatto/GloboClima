# 🌍 GloboClima - Teste Técnico Fullstack .NET (AUVO)

Uma aplicação fullstack moderna para consulta de informações climáticas e dados de países, permitindo aos usuários salvar e gerenciar seus favoritos. Este projeto foi desenvolvido como parte do processo seletivo para Desenvolvedor Fullstack .NET na AUVO.

## 📸 Screenshots

<p align="center"\>
<img width="1918" height="987" alt="Captura de tela 2025-09-02 221723" src="https://github.com/user-attachments/assets/3bd84478-6f1b-4f44-a7a3-25d0d100d7b4" />
<br/\>
<em\>Página Inicial.\</em\>
</p\>

<p align="center"\>
<img width="1917" height="988" alt="Captura de tela 2025-09-02 221737" src="https://github.com/user-attachments/assets/402eacfa-3bf0-4d69-a479-597a39e5a45b" />
<br/\>
<em\>Página de consulta de clima das cidades\</em\>
</p\>

<p align="center"\>
<img width="1919" height="988" alt="Captura de tela 2025-09-02 221814" src="https://github.com/user-attachments/assets/b72e61a4-a181-46c1-a6aa-eadcfd52148f" />
<br/\>
<em\>Tela de consulta de países\</em\>
</p\>

<p align="center"\>
<img width="1919" height="987" alt="Captura de tela 2025-09-02 221824" src="https://github.com/user-attachments/assets/79f3613e-eb8e-46d8-b83b-5ab7faf6d477" />
<br/\>
<em\>Tela de autenticação para acesso às funcionalidades privadas.\</em\>
</p\>

<p align="center"\>
<img width="1919" height="990" alt="Captura de tela 2025-09-02 221957" src="https://github.com/user-attachments/assets/ee6bbaf6-7908-4cd6-83cc-2fea2315d362" />
<br/\>
<em\>Tela de favoritos.\</em\>
</p\>

## Demonstração Online

  * **Aplicação Frontend (Blazor WASM):** `https://globoclima.site` (Exemplo)
  * **Aplicação Frontend (Blazor WASM):** `https://www.globoclima.site` (Exemplo)
  * **API Gateway / Load Balancer:** `https://api.globoclima.site` (Exemplo)

## Documentação da API

A documentação interativa de cada microserviço está disponível via Swagger. Para acessá-la, execute os projetos de backend localmente.

<p align="center"\>
<img width="1471" height="388" alt="image" src="https://github.com/user-attachments/assets/310a4cd5-23d0-425b-9afa-e5d9ecb92749" />
<br/\>
<em\>Exemplo da documentação interativa de um dos microserviços.</em\>
</p\>

<img width="1458" height="614" alt="image" src="https://github.com/user-attachments/assets/1ce29c00-238a-4969-8b29-19ed9b3415f9" />

<img width="1472" height="391" alt="image" src="https://github.com/user-attachments/assets/2d9019b2-e7ff-4d8f-a871-50455321d360" />


## Checklist Completo dos Requisitos

### Backend - Microserviços .NET 8 ✓

  - [x] **Arquitetura de Microserviços** - Lógica de negócio dividida em serviços independentes (Auth, Data, Favorites).
  - [x] **Consumo de APIs Públicas** - Integração com OpenWeatherMap e REST Countries no serviço de Dados.
  - [x] **Gerenciamento de Favoritos** - CRUD completo para cidades e países.
  - [x] **Autenticação com JWT** - Rotas de favoritos protegidas com tokens Bearer.
  - [x] **Armazenamento com DynamoDB** - Tabelas separadas para usuários e favoritos, seguindo as melhores práticas.
  - [x] **Documentação com Swagger** - Cada microserviço possui sua própria documentação OpenAPI.
  - [x] **Segurança** - Senhas hasheadas com BCrypt e comunicação via HTTPS.
  - [x] **Containerização com Docker** - Cada microserviço é "containerizado" para deploy no ECS.
  - [x] **AWS ECS/EC2** - Orquestração de contêineres para uma arquitetura escalável.
  - [x] **CI/CD com GitHub Actions** - Pipeline configurado para build, teste e deploy automático dos serviços.
  - [x] **Infraestrutura como Código (IaC)** - Terraform para provisionar toda a infraestrutura na AWS.

### Frontend - Blazor WebAssembly ✓

  - [x] **Blazor WebAssembly** - Uma SPA (Single Page Application) moderna e desacoplada, rodando no navegador do cliente.
  - [x] **Interface Responsiva** - Layout adaptável para desktops e dispositivos móveis.
  - [x] **Consumo de Microserviços** - `HttpClient`s tipados para comunicação com cada API de backend.
  - [x] **Gerenciamento de Favoritos** - UI completa para adicionar, visualizar e remover favoritos.
  - [x] **Autenticação JWT** - Gerenciamento de sessão do usuário para acesso a rotas protegidas.
  - [x] **Hospedagem Estática (S3 + CloudFront)** - Deploy otimizado para performance e escalabilidade global.

## Arquitetura do Projeto

O projeto foi estruturado com uma abordagem de microserviços no backend e um frontend desacoplado (SPA).

```
.
├── backend/
│   ├── auth-service/      # Microserviço de Autenticação
│   ├── data-service/      # Microserviço para consulta de APIs externas
│   └── favorites-service/ # Microserviço para gerenciar favoritos
└── frontend_wasm/
    └── GloboClima.WebApp.Client/           # Aplicação Frontend Blazor WebAssembly
```

## Como Executar Localmente

**Pré-requisitos:**

  * .NET 8 SDK
  * Docker Desktop
  * AWS CLI (configurado)

**1. Backend (Microserviços):**

Cada microserviço precisa ser executado em seu próprio terminal.

```bash
# No terminal 1 (a partir da raiz do projeto)
cd backend/auth-service
dotnet run

# No terminal 2
cd backend/data-service
dotnet run

# No terminal 3
cd backend/favorites-service
dotnet run
```

**2. Frontend (Blazor):**

```bash
# No terminal 4
cd frontend_wasm/GloboClima.WebApp.Client/
dotnet run
```

## Deploy

O deploy da infraestrutura e das aplicações é automatizado.

### Infraestrutura (Terraform)

O Terraform provisiona o cluster ECS, Load Balancer, tabelas DynamoDB, etc.

```bash
# Na pasta com os arquivos .tf
terraform init
terraform apply
```

### Aplicação

O deploy é feito automaticamente via **GitHub Actions** ao realizar um `push` para a branch `main`. O workflow é responsável por:

1.  Construir as imagens Docker de cada microserviço.
2.  Enviar as imagens para o AWS ECR (Elastic Container Registry).
3.  Atualizar os serviços no AWS ECS para usar as novas imagens.
4.  Publicar os arquivos do Blazor no bucket S3.

## Decisões Técnicas Chave

1.  **Microserviços em vez de Monolito**: A arquitetura foi dividida para garantir o desacoplamento, a escalabilidade independente de cada serviço e para demonstrar um padrão de design moderno.
2.  **AWS ECS em vez de Lambda**: Escolhemos ECS/EC2 para hospedar os contêineres. Esta abordagem oferece mais controle sobre o ambiente de execução e é ideal para aplicações ASP.NET Core que se beneficiam de um estado "quente", evitando o "cold start" do Lambda para uma melhor performance percebida pelo usuário.
3.  **Blazor WebAssembly em vez de Blazor Server**: Para criar uma SPA verdadeiramente desacoplada, melhorando a escalabilidade e a performance ao servir o frontend a partir de uma CDN (CloudFront) e um S3.
4.  **Application Load Balancer em vez de API Gateway**: Como nossa lógica de autenticação JWT já está implementada dentro do microserviço de Auth, o ALB é a solução mais direta e eficiente para distribuir tráfego para os contêineres no ECS.
5.  **Duas Tabelas no DynamoDB**: Optamos por tabelas separadas para Usuários e Favoritos em vez de um design de tabela única. Essa decisão prioriza a simplicidade de implementação e a clareza do modelo de dados, sendo perfeitamente adequada para o escopo deste projeto.
