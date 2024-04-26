{ pkgs }:
with pkgs;
let
  nodejs = nodejs-18_x;
  nodePackages = pkgs.nodePackages.override { inherit nodejs; };

  mkShell' = mkShell.override {
    # The current nix default sdk for macOS fails to compile go projects, so we use a newer one for now.
    stdenv = if stdenv.isDarwin then overrideSDK stdenv "11.0" else stdenv;
  };
in
mkShell' {
  nativeBuildInputs = [
    python3
    python3Packages.pip

    rust-bin.beta.latest.default
    curl
    nodejs
    nodePackages.pnpm
    foundry-bin
    # tooling
    github-cli
    jq

    # deployment
    awscli2
    devspace
    kubectl
    kubernetes-helm

    # cross-compiling, used in CRIB
    zig

    # gofuzz
  ] ++ lib.optionals stdenv.isLinux [
    # some dependencies needed for node-gyp on pnpm install
    pkg-config
    libudev-zero
    libusb1
  ];
  LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib64:$LD_LIBRARY_PATH";
  shellHook = ''
    # Find the root of the git repository
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
    export PATH=$PATH:$repo_root/crib/scripts
  '';
}
