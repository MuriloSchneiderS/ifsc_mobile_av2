# 📚 bookshare

Plataforma mobile de publicação e compartilhamento de mídia (livros, PDFs, imagens).  
Projeto desenvolvido como Avaliação 2 da disciplina de Desenvolvimento Mobile — IFSC Campus Tubarão.

---

## 📱 Descrição

O **bookshare** é um app Flutter que permite aos usuários publicar e explorar arquivos de mídia (livros digitais, PDFs, imagens e outros). Funciona como uma rede social simples de conteúdo literário e cultural, inspirando um futuro TCC chamado **ALOCADORA**.

---

## 🗺️ Telas

| Tela | Descrição |
|------|-----------|
| **Login** (`/`) | Autenticação com e-mail e senha via Firebase Auth |
| **Cadastro** (`/cadastro`) | Registro de novo usuário com captura de localização GPS |
| **Home** (`/home`) | Feed com todas as publicações, pull-to-refresh |
| **Nova publicação** (`/publicacao`) | Formulário para publicar título, descrição, URL do arquivo e tipo |
| **Exibição** (`/exibicao`) | Detalhe da publicação com capa, autor e link do arquivo |

---

## 🛠️ Tecnologias e pacotes

- **Flutter 3 / Dart 3**
- **Provider** — gerenciamento de estado
- **Firebase Auth** — autenticação por e-mail/senha
- **Firebase Realtime Database** — armazenamento de dados na nuvem
- **Geolocator** — sensor de GPS (latitude/longitude no cadastro)
- **http** — requisições REST ao Firebase
- **intl** — formatação de datas
- **cached_network_image** — carregamento de imagens com cache

---

## 🏗️ Estrutura do projeto

```
lib/
├── main.dart               # Entry point, Firebase init, rotas, AuthGuard
├── util/
│   └── rotas.dart          # Constantes de rotas nomeadas
├── models/
│   ├── publicacao.dart     # Modelo de publicação
│   └── usuario.dart        # Modelo de usuário
├── providers/
│   ├── auth_provider.dart          # Firebase Auth state
│   ├── publicacao_provider.dart    # CRUD de publicações
│   └── usuario_provider.dart       # Perfil + GPS
├── telas/
│   ├── tela_inicial.dart    # Login
│   ├── tela_cadastro.dart   # Cadastro + GPS
│   ├── tela_home.dart       # Feed
│   ├── tela_publicacao.dart # Formulário de publicação
│   └── tela_exibicao.dart   # Detalhes da publicação
└── widgets/
    ├── campo_texto.dart     # Input reutilizável com validação
    ├── botao_primario.dart  # Botão com loading state
    ├── card_publicacao.dart # Card do feed
    └── mensagem_erro.dart   # Banner de erro
```

---

## ⚙️ Como rodar

### 1. Pré-requisitos
- Flutter SDK ≥ 3.11
- Conta no Firebase com projeto configurado

### 2. Configurar Firebase
```bash
# Instale o FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure o projeto (dentro da pasta raiz)
flutterfire configure 
```
Isso gera o arquivo `lib/firebase_options.dart`.  
Atualize o `main.dart` para usar `DefaultFirebaseOptions.currentPlatform`.

### 3. Instalar dependências
```bash
flutter pub get
```

### 4. Rodar
```bash
flutter run
```

---

## 📡 Sensor utilizado

**GPS (Geolocator)** — Na tela de cadastro, o usuário pode capturar sua localização geográfica (latitude/longitude) que é salva junto ao perfil no Firebase. Isso permite funcionalidades futuras como filtrar publicações por região ou exibir a bandeira do país do usuário.

---

## 🔒 Autenticação

Firebase Authentication com e-mail e senha.  
O app possui um `AuthGuard` que automaticamente redireciona para a tela correta (Login ou Home) com base no estado de autenticação em tempo real via `authStateChanges()`.

---

## 🗄️ Armazenamento

Firebase Realtime Database (REST API via `http`):
- `/usuarios/{uid}` — perfil do usuário
- `/publicacoes/{id}` — publicações

---

## 👥 Grupo

- Murilo Schneider S.

---

## 📆 Cronograma

| Etapa | Data | Entregável |
|-------|------|------------|
| 1ª etapa | 18/06/2026 | Ideia + protótipo + repositório inicializado |
| 2ª etapa | 25/06/2026 | Tela de login + outra tela |
| 3ª etapa | 02/07/2026 | Projeto completo + apresentação |
