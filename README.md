Testing, will update when I have time

<h1>CachyNix</h1>

<p>We recommend integrating this repo using Flakes:</p>

<pre lang="nix"><code class="language-nix">
# flake.nix
{
  description = "My configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cachynix.url = "github:Mrn157/CachyNix"; # IMPORTANT
  };

  outputs = { nixpkgs, chaotic, ... }: {
    nixosConfigurations = {
      hostname = nixpkgs.lib.nixosSystem { # Replace "hostname" with your system's hostname
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          cachynix.nixosModules.default # IMPORTANT
        ];
      };
    };
  };
}
</code></pre>

<p>In your <code>configuration.nix</code> enable the kernel and options that you prefer:</p>

<pre lang="nix"><code class="language-nix">
boot = {
    kernelPackages = pkgs.linuxPackages_cachyos.cachyOverride { mArch = "GENERIC_V3"; };
    # ...
};
</code></pre>

<h3 id="on-home-manager">On Home-Manager</h3>

<p>This method is for home-manager setups <strong>without NixOS</strong>.</p>

<p>We recommend integrating this repo using Flakes:</p>

<pre lang="nix"><code class="language-nix">
# flake.nix
{
  description = "My configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cachynix.url = "github:Mrn157/CachyNix"; # IMPORTANT
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, chaotic, ... }: {
    # ... other outputs
    homeConfigurations = {
      # ... other configs
      configName = home-manager.lib.homeManagerConfiguration { # Replace "configName" with a significant unique name
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home-manager/default.nix
          cachynix.homeManagerModules.default # IMPORTANT
        ];
      };
    };
  };
}
</code></pre>

<h3>CachyOS kernels</h3>


<p>Cache MIGHT be available for latest x86_64 (not v2, v3, or v4) </p>

<p>You may install the CachyOS kernel directly using the default modules and overlays with <code>pkgs.linuxPackages_cachyos</code>. Alternatively, use <code>chaotic.legacyPackages.x86_64-linux.linuxPackages_cachyos</code> if you would like to use the package directly without using modules and overlay</p>

<h3>CachyOS x86-64 microarchitecture optimisations</h3>

<pre lang="nix"><code class="language-nix">
{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_cachyos.cachyOverride { mArch = "GENERIC_V4"; };
}
</code></pre>

<p>Use either <code>GENERIC_V2</code>, <code>GENERIC_V3</code>, <code>GENERIC_V4</code>, or <code>ZEN4</code>. We don't provide cache for these.</p>
