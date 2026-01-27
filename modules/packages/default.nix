# System Packages Configuration Module
# Comprehensive development environment packages

{ config, pkgs, lib, ... }:

let
  # Use standard Rust from nixpkgs
  rustToolchain = pkgs.rustc;

  # ===== PYTHON DEVELOPMENT ENVIRONMENT =====
  pythonEnv = pkgs.python312.withPackages (ps: with ps; [
    # Web frameworks and API development
    fastapi
    flask
    django
    uvicorn
    gunicorn

    # Data science and analysis
    pandas
    numpy
    matplotlib
    seaborn
    jupyter

     # Database connectivity
     sqlalchemy
     alembic
     psycopg2
     redis
     asyncpg
     
     # ===== CUDA & COMPILER TOOLS =====
     # cudatext               # CUDA text processing (language models)
     # cudaPackages.cuda_cc     # CUDA compiler  
     # gcc_12                    # NVIDIA CUDA compiler

    # HTTP and API clients
    httpx
    aiohttp
    requests

    # Development and testing
    pytest
    pytest-asyncio
    black
    isort
    mypy
    flake8

    # Configuration and utilities
    python-dotenv
    pydantic
    pydantic-settings
    typer
    rich
    loguru

    # Optional AI/ML libraries (for users who need them)
    openai
    anthropic
    langchain
    langchain-community

    # Dataset libraries
    datasets

    # Deep learning frameworks
    torch
    torchvision
    torchaudio
  ]);
in

{
  environment.systemPackages = with pkgs; [
    # non-development applications
    steam
    prismlauncher
    gamemode
    mangohud
    
    # CUDA development tools
    # cudaPackages.cuda_cc
    # nsight-systems
    # nvtop
    (pkgs.writeShellScriptBin "modrinth-app-nvidia" ''
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __NV_PRIME_RENDER_OFFLOAD=1
      export DRI_PRIME=0
      export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
      export GDK_BACKEND=x11
      exec ${pkgs.modrinth-app}/bin/ModrinthApp "$@"
    '')
    blockbench
    gearlever
    waydroid

    ## audio synthesis
    # supercollider
    # libjack2
    # libsndfile
    # fftw
    # avahi
    # alsa-lib
    # ncurses
     udev.dev

    # ===== ESSENTIAL SYSTEM TOOLS =====
    vim neovim
    wget curl
    git
    htop
    tree file
    unzip zip
    # opencode

    # Networking tools
    inetutils
    nmap
    nettools
    iproute2
    iptables
    iputils
    dig

    # Security and monitoring
    gnupg
    openssh
    openssl
    wireguard-tools

     # System administration
     systemctl-tui
     nixos-rebuild

     # Graphics debugging tools
     mesa-demos
     vulkan-tools

     # GPU monitoring tools
     nvtopPackages.full       # GPU monitor for NVIDIA/AMD/Intel
     btop                     # System monitor with GPU support

    # Container runtime (system-level) - Podman for better NixOS integration
    podman
    podman-compose
    podman-tui
    kubectl

     # System dependencies for .NET Core and containers
     nix-ld
     stdenv.cc.cc
     glibc
     libffi.dev

     # SSL/TLS Certificate management
     cacert
     p11-kit

    # Windows Server Management Tools
    powershell                             # PowerShell Core for Windows remote management
    sshpass                               # SSH password authentication automation
    remmina                              # Remote desktop client for Windows RDP
    freerdp                              # FreeRDP for Windows remote desktop
    tigervnc                             # VNC client and server
    gnome-connections                    # GNOME VNC/RDP client
    expect                               # Automated interaction for command-line tools

    # File sharing tools
    samba                                # SMB/CIFS server for Windows file sharing
    cifs-utils                          # CIFS utilities for mounting Windows shares

    # System Process and Resource Management
    procps                                 # Process monitoring and management utilities
    util-linux                            # Essential Linux system utilities

    # ===== PROGRAMMING LANGUAGE RUNTIMES =====
    # Node.js ecosystem
    nodejs_20                   # Primary Node.js LTS
    yarn                        # Package manager
    pnpm                        # Fast package manager
    bun                         # Fast JavaScript runtime

    # Python environment (defined above)
    pythonEnv                   # Complete Python development stack
    pipx                        # Install Python applications in isolated environments

    # JVM languages
    jdk21                       # Java Development Kit
    maven                       # Java build tool
    gradle                      # Java/Kotlin build tool
    kotlin                      # Kotlin programming language
    scala                       # Scala programming language
    sbt                         # Scala build tool

    # Android development
    android-studio                # Android Studio IDE with SDK
    android-studio-tools          # Android platform tools (adb, fastboot, etc.)
    android-tools                 # Android platform tools (adb, fastboot, etc.)

     # X11 libraries for Android emulator
     xorg.libX11
     xorg.libXext
     xorg.libXrender
     xorg.libXrandr
     xorg.libXi
     xorg.libXcursor
     xorg.libXfixes
     libpulseaudio

           # Wayland and audio development libraries for Bevy games
           wayland
           wayland.dev
           wayland-protocols
           libxkbcommon
           libxkbcommon.dev
           alsa-lib.dev
          xorg.xkbcomp
          xorg.setxkbmap
          xorg.libxcb
          xorg.libX11
          xorg.libXext
         xorg.libXrandr
         xorg.libXi
         xorg.libXcursor

    # Go development
    go                         # Go programming language
    gopls                      # Go language server
    golangci-lint             # Go linting
    delve                     # Go debugger

    # Rust development
    rustc                     # Rust compiler
    cargo                     # Rust package manager
    rustfmt                   # Rust formatter
    clippy                    # Rust linting
    rust-analyzer            # Rust language server

    # Ruby development
    ruby_3_3                  # Ruby programming language

    # PHP development
    php83                     # PHP 8.3
    php83Packages.composer    # PHP dependency manager

    # C/C++ development
    gcc                       # GNU Compiler Collection
    clang                     # Clang compiler (required for LLD linker)
    cmake                     # Build system
    ninja                     # Build system
    gdb                       # GNU Debugger
    lldb                      # LLVM Debugger
    pkg-config               # Build system helper for library detection
    lld                       # LLVM linker for faster Rust/C++ builds
    mold                      # Ultra-fast linker (optional, even faster than lld)

    # System libraries for C/C++/Rust linking
    zlib                      # Compression library (libz.so.1)
    xz                        # XZ compression library
    bzip2                     # Bzip2 compression library
    openssl                   # SSL/TLS library
    libffi                    # Foreign function interface library
    xorg.libX11               # X11 library
    xorg.libX11.dev           # X11 headers and pkg-config
    xorg.libXcursor           # X11 cursor library
    xorg.libXi                # X11 input extension
    xorg.libXrandr            # X11 randr extension
    libxkbcommon             # Keyboard input library for Wayland/X11
    libxkbcommon.dev         # Keyboard input headers

    # ===== .NET 9 DEVELOPMENT ENVIRONMENT =====
    dotnet-sdk_9                           # Complete .NET 9 SDK with build tools, MSBuild, and NuGet
    dotnet-aspnetcore_9                    # ASP.NET Core 9 runtime for web applications
    dotnetCorePackages.runtime_9_0-bin     # .NET 9 runtime binary for application execution
    dotnetCorePackages.aspnetcore_9_0      # ASP.NET Core 9 runtime package
    dotnetCorePackages.sdk_9_0             # Additional .NET 9 SDK components and tools

    # ===== CLOUD DEVELOPMENT TOOLS =====
    # AWS ecosystem
    awscli2                   # AWS CLI
    aws-sam-cli              # AWS SAM CLI
    eksctl                    # Amazon EKS CLI
    aws-iam-authenticator    # AWS IAM Authenticator

    # Google Cloud Platform
    google-cloud-sdk         # Google Cloud SDK

    # Microsoft Azure
    azure-cli                # Azure CLI
    azurite                  # Azure Storage Emulator

    # Other cloud providers
    doctl                    # DigitalOcean CLI
    linode-cli               # Linode CLI

    # Cloud platform tools
    dapr-cli
    pulumi
    go-migrate
    wrangler
    grafana
    hcp

    # ===== INFRASTRUCTURE AS CODE =====
    terraform                # Infrastructure provisioning
    terragrunt              # Terraform wrapper
    terraform-docs          # Terraform documentation generator
    tflint                  # Terraform linter
    skaffold

    # Configuration management
    ansible                 # Configuration management
    ansible-lint           # Ansible linter

    # Alternative IaC tools
    pulumi-bin             # Modern infrastructure as code

    # ===== CONTAINER AND ORCHESTRATION =====
    # Kubernetes
    kubernetes-helm-wrapped # Kubernetes package manager
    kustomize              # Kubernetes configuration management
    k9s                    # Kubernetes TUI

    # Docker ecosystem
    docker-compose         # Multi-container orchestration

    # ===== DATABASE TOOLS (Container-First Development) =====
    # PostgreSQL tools
    pgcli                 # PostgreSQL interactive terminal
    minio

    # MySQL/MariaDB tools
    mysql-workbench      # MySQL GUI client

    # Database GUI clients
    dbeaver-bin          # Universal database tool

    # ===== VERSION CONTROL =====
    gh                   # GitHub CLI
    gitlab-runner        # GitLab CI runner
    git-lfs             # Git Large File Storage

    firebase-tools

    # ===== CODE EDITORS AND IDEs =====
    # Terminal editors
    emacs               # Emacs editor
    ghostty

    # GUI editors
    vscode              # Visual Studio Code
    zed-editor          # Modern collaborative editor

     # ===== WEB BROWSERS =====
     chromium            # Open-source browser (default)
     firefox             # Privacy-focused browser
     firefox-devedition  # Firefox Developer Edition
     microsoft-edge      # Professional browser

     # ===== CUDA & DEVELOPMENT TOOLS =====
     # cudatext               # CUDA text processing (language models)
     # cudaPackages.cuda-cc     # CUDA compiler
     # nsight-systems          # NVIDIA profiling tools
     # nvtop                   # NVIDIA GPU monitoring

     # ===== CUDA DEVELOPMENT PACKAGES =====
     # cudaPackages.cudnn     # Deep learning library
     # cudaPackages.cutlass     # NVIDIA template library  
     # cudaPackages.cublas     # CUDA linear algebra
     # nsight-systems          # NVIDIA profiling tools

    # ===== USER APPLICATIONS =====
    zoom-us

    # ===== API DEVELOPMENT =====
    httpie             # HTTP client
    postman           # API development platform
    insomnia          # REST/GraphQL client

    # ===== DATA FORMATS =====
    jq                 # JSON processor
    yq                 # YAML processor
    xmlstarlet         # XML processor

    # ===== MODERN CLI TOOLS =====
    # File operations
    bat                # Enhanced cat
    eza                # Enhanced ls
    fd                 # Enhanced find
    ripgrep            # Enhanced grep
    fzf                # Fuzzy finder
    zoxide             # Enhanced cd
    lsof

    # System monitoring
    btop               # Modern process monitor
    ncdu               # Disk usage analyzer

    # ===== DEVELOPMENT UTILITIES =====
    # Environment management
    direnv             # Environment variable manager

    # Shell and terminal
    tmux               # Terminal multiplexer
    starship           # Shell prompt

     # ===== BUILD TOOLS =====
     gnumake            # Universal build tool
     buck2              # High-performance build system
     just               # Modern command runner
    buf                # Protocol buffer toolkit
    protobuf           # Protocol buffer compiler
    protoc-gen-go      # Go protobuf plugin
    protoc-gen-connect-go # Connect RPC Go plugin

    # ===== SECURITY & QUALITY TOOLS =====
    trivy              # Container/code security scanner
    semgrep            # Static code analysis

    # ===== GIT WORKFLOW TOOLS =====
    lazygit            # Superior git TUI

    # ===== PERFORMANCE TOOLS =====
    hyperfine          # Command-line benchmarking
    wrk                # HTTP load testing

    # ===== CONTAINER MONITORING =====
    ctop               # Container monitoring TUI

    # Archive tools
    p7zip              # 7-Zip archiver

    # Image manipulation
    imagemagick        # ImageMagick CLI tools

    # File utilities
    rsync              # File synchronization

    # ===== OPTIONAL AI/ML TOOLS =====
    # Include Claude Code as requested but not prominently featured
    claude-code        # Claude Code CLI (available but not emphasized)

    # ===== DOCUMENTATION AND WRITING =====
    pandoc             # Document converter
    hugo               # Static site generator
    texlive.combined.scheme-full  # LaTeX distribution for professional typesetting

    # ===== VIRTUALIZATION TOOLS =====
    
    # Virtual Machine Management GUI
    virt-manager       # VM management GUI for libvirtd
    virt-viewer        # SPICE client for VM console viewing
    looking-glass-client # Low latency KVM FrameRelay
    qemu               # QEMU full system emulation
    spice-gtk          # GTK+ SPICE widget
    spice-protocol     # SPICE protocol headers
    
    # USB debugging and management
    usbutils           # USB utilities (lsusb, etc.)

    # Node.js global packages
    nodePackages.typescript
    nodePackages.eslint
    nodePackages.nodemon
    nodePackages.pm2
    nodePackages.serve

    # Tailwind/CSS tools
    nodePackages.tailwindcss      # Tailwind CSS
    nodePackages.postcss         # CSS processor
    nodePackages.autoprefixer    # CSS vendor prefixes
  ];

  # Dynamic linking support for native binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Core libraries for most applications
      stdenv.cc.cc
      stdenv.cc.cc.lib
      gcc.cc.lib
      openssl
      glib
      zlib
      libz
      ncurses
      libffi
      libxml2
      libxslt
      readline
      sqlite

      # Graphics and display libraries
      xorg.libX11
      xorg.libXext
      xorg.libXrandr
      xorg.libXi
      xorg.libXcursor
      xorg.libXfixes
      xorg.libXtst
      libpulseaudio
      mesa
      libGL

      # Browser and Electron specific libraries
      atk
      cairo
      cups
      dbus-glib
      expat
      fontconfig
      freetype
      gdk-pixbuf
      gtk3
      libappindicator-gtk3
      libdrm
      libnotify
      libsecret
      libuuid
      nspr
      nss
      pango

       # Additional image and compression libraries
       libjpeg
       libpng
       libtiff
       libwebp
       icu

       # Bevy game engine dependencies
       wayland
       alsa-lib
       udev
      ];
    };

     # Set PKG_CONFIG_PATH for development
    # Moved to modules/environment/default.nix for centralized management
    # PKG_CONFIG_PATH = "${pkgs.wayland.dev}/lib/pkgconfig:${pkgs.libxkbcommon.dev}/lib/pkgconfig:${pkgs.alsa-lib.dev}/lib/pkgconfig:${pkgs.udev.dev}/lib/pkgconfig";
}
