# Conventions:
# - Sort packages in alphabetic order.
# - If the recipe uses `override` or `overrideAttrs`, then use callOverride,
#   otherwise use `final`.
# - Composed names are separated with minus: `lan-mouse`
# - Versions/patches are suffixed with an underline: `mesa_git`, `libei_0_5`, `linux_hdr`

# NOTE:
# - `*_next` packages will be removed once merged into nixpkgs-unstable.

{
  flakes,
  nixpkgs ? flakes.nixpkgs,
  self ? flakes.self,
  selfOverlay ? self.overlays.default,
  rust-overlay ? flakes.rust-overlay,
  nixpkgsExtraConfig ? { },
}:
final: prev:

let
  # Required to load version files.
  inherit (final.lib.trivial) importJSON;

  # Our utilities/helpers.
  nyxUtils = import ../shared/utils.nix {
    inherit (final) lib;
    nyxOverlay = selfOverlay;
  };
  inherit (nyxUtils) multiOverride overrideDescription drvDropUpdateScript;

  # Helps when calling .nix that will override packages.
  callOverride =
    path: attrs:
    import path (
      {
        inherit
          final
          flakes
          nyxUtils
          prev
          gitOverride
          rustPlatform_latest
          ;
      }
      // attrs
    );

  # Helps when calling .nix that will override i686-packages.
  callOverride32 =
    path: attrs:
    import path (
      {
        inherit flakes nyxUtils gitOverride;
        final = final.pkgsi686Linux;
        final64 = final;
        prev = prev.pkgsi686Linux;
      }
      // attrs
    );

  # Magic helper for _git packages.
  gitOverride = import ../shared/git-override.nix {
    inherit (final)
      lib
      callPackage
      fetchFromGitHub
      fetchFromGitLab
      fetchFromGitea
      ;
    inherit (final.rustPlatform) fetchCargoVendor;
    nyx = self;
    fetchRevFromGitHub = final.callPackage ../shared/github-rev-fetcher.nix { };
    fetchRevFromGitLab = final.callPackage ../shared/gitlab-rev-fetcher.nix { };
    fetchRevFromGitea = final.callPackage ../shared/gitea-rev-fetcher.nix { };
  };

  rustc_latest = rust-overlay.packages.${final.stdenv.hostPlatform.system}.rust;

  # Latest rust toolchain from Fenix
  rustPlatform_latest = final.makeRustPlatform {
    cargo = rustc_latest;
    rustc = rustc_latest;
  };

  # Too much variations
  cachyosPackages = callOverride ../linux-cachyos { };

  # Microarch stuff
  makeMicroarchPkgs = import ../shared/make-microarch.nix {
    inherit
      nixpkgs
      final
      selfOverlay
      nixpkgsExtraConfig
      ;
  };

  # Required for 32-bit packages
  has32 = final.stdenv.hostPlatform.isLinux && final.stdenv.hostPlatform.isx86;

  # Required for kernel packages
  inherit (final.stdenv) isLinux;

in
{
  inherit nyxUtils rustc_latest;

  linux_cachyos = drvDropUpdateScript cachyosPackages.cachyos-gcc.kernel;
  linux_cachyos-lto = drvDropUpdateScript cachyosPackages.cachyos-lto.kernel;
  linux_cachyos-lto-znver4 = drvDropUpdateScript cachyosPackages.cachyos-lto-znver4.kernel;
  linux_cachyos-gcc = drvDropUpdateScript cachyosPackages.cachyos-gcc.kernel;
  linux_cachyos-server = drvDropUpdateScript cachyosPackages.cachyos-server.kernel;
  linux_cachyos-hardened = drvDropUpdateScript cachyosPackages.cachyos-hardened.kernel;
  linux_cachyos-rc = cachyosPackages.cachyos-rc.kernel;
  linux_cachyos-lts = cachyosPackages.cachyos-lts.kernel;

  linuxPackages_cachyos-lto = cachyosPackages.cachyos-lto;
  linuxPackages_cachyos-lto-znver4 = cachyosPackages.cachyos-lto-znver4;
  linuxPackages_cachyos-gcc = cachyosPackages.cachyos-gcc;
  linuxPackages_cachyos-server = cachyosPackages.cachyos-server;
  linuxPackages_cachyos-hardened = cachyosPackages.cachyos-hardened;
  linuxPackages_cachyos-rc = cachyosPackages.cachyos-rc;
  linuxPackages_cachyos-lts = cachyosPackages.cachyos-lts;

  linuxPackages_cachyos = cachyosPackages.cachyos-gcc // {
    kernel = cachyosPackages.cachyos-gcc.kernel.overrideAttrs (_: {
      argsOverride = {
        mArch = "GENERIC_V3";
      };
    });
  };


  zfs_cachyos = cachyosPackages.zfs;
}
