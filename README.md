Testing, will update when I have time

<h1>CachyNix</h1>

<h3>CachyOS kernels</h3>

Cache Status (extraModulePackages modules may not be cached):

✔️ = Cached/In Progress
❌ = Not Cached/Unknown
⚠️ I may make a mistake and make the status table incorrect

| Package | Status | Version | Architecture |
|--------|--------|--------| -------- |
| [pkgs.linuxPackages_cachyos-lto](https://github.com/Mrn157/nix-dotfiles/blob/4304c7fd94f687825d2a3f13082cb68b81b3dec6/hosts/hp/configuration.nix#L14C2-L21C8) | ✔️ | 6.18.8 | x86_64-v3 |
| pkgs.linuxPackages_cachyos-lto | ✔️ | 6.18.8  | x86_64 |
| pkgs.linuxPackages_cachyos-gcc | ✔️ | 6.18.8 | x86_64 |
| pkgs.linuxPackages_cachyos-server | ❌ | 6.18.8 | x86_64 |
| pkgs.linuxPackages_cachyos-rc | ❌ | 6.19-rc8 | x86_64 |
| pkgs.linuxPackages_cachyos-hardened | ❌ | 6.17.13 | x86_64 |
| pkgs.linuxPackages_cachyos-lts | ✔️ | 6.12.68 | x86_64 |

GCC kernel might have the most cached modules
The/Other kernels might be cached on Garnix by other people.

You can use [Garnix](https://app.garnix.io/) to build and cache a custom kernel (So you don't have to compile it on your own machine).
Simply give it access to a repo (like your dotfiles) that exposes your custom kernel configuration as a derivation.
Push a commit, and Garnix will build and cache it automatically. After it finishes building, it might take some time to getcached though.
[!](https://github.com/Mrn157/CachyNixBuilder)

`linuxPackages_cachyos{,-hardened,-lto,-gcc,-rc,-server,lts}`

<p>You may install the CachyOS kernel directly using the default modules and overlays with <code>pkgs.linuxPackages_cachyos</code>. Alternatively, use <code>chaotic.legacyPackages.x86_64-linux.linuxPackages_cachyos</code> if you would like to use the package directly without using modules and overlay</p>

<h3>CachyOS x86-64 microarchitecture optimisations</h3>

<pre lang="nix"><code class="language-nix">
{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto.cachyOverride { mArch = "GENERIC_V3"; };
}
</code></pre>

<p>Use either <code>GENERIC_V2</code>, <code>GENERIC_V3</code>, <code>GENERIC_V4</code>, or <code>ZEN4</code>.

<h3 id="on-flakes">Installing using flakes</h3>

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



