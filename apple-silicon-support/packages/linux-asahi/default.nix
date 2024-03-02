{ lib
, callPackage
, linuxPackagesFor
, _kernelPatches ? [ ]
}:

let
  linux-asahi-pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, buildLinux, ... } @ args:
    buildLinux rec {
      inherit stdenv lib;

      version = "6.8.9-asahi";
      modDirVersion = version;
      extraMeta.branch = "6.8";

      src = fetchFromGitHub {
        # tracking: https://github.com/AsahiLinux/linux/tree/asahi-wip (w/ fedora verification)
        owner = "AsahiLinux";
        repo = "linux";
        rev = "asahi-6.8.9-6";
        hash = "sha256-qDxO6gXHTNcUWfa1YnoqZz1/eOg26JLnTTvTrxSbDAc=";
      };

      kernelPatches = [
        {
          name = "Asahi config";
          patch = null;
          extraStructuredConfig = with lib.kernel; {
            RUST = yes;
            DRM = yes;
            ARCH_APPLE = yes;
            HID_APPLE = module;
            ARM64_16K_PAGES = yes;
            APPLE_WATCHDOG = yes;
            APPLE_PMGR_PWRSTATE = yes;
            APPLE_AIC = yes;
            APPLE_M1_CPU_PMU = yes;
            APPLE_MAILBOX = yes;
            APPLE_PLATFORMS = yes;
            APPLE_PMGR_MISC = yes;
            APPLE_RTKIT = yes;
            ARM_APPLE_CPUIDLE = yes;
            DRM_VGEM = no;
            DRM_SCHED = yes;
            DRM_GEM_SHMEM_HELPER = yes;
            DRM_APPLE_AUDIO = yes;
          };
          features.rust = true;
        }
        # speaker enablement; we assert on the relevant lsp-plugins patch
        # before installing speakersafetyd to let the speakers work
        { name = "speakers-1";
          patch = fetchpatch {
            url = "https://github.com/AsahiLinux/linux/commit/385ea7b5023486aba7919cec8b6b3f6a843a1013.patch";
            hash = "sha256-u7IzhJbUgBPfhJXAcpHw1I6OPzPHc1UKYjH91Ep3QHQ=";
          };
        }
        { name = "speakers-2";
          patch = fetchpatch {
            url = "https://github.com/AsahiLinux/linux/commit/6a24102c06c95951ab992e2d41336cc6d4bfdf23.patch";
            hash = "sha256-wn5x2hN42/kCp/XHBvLWeNLfwlOBB+T6UeeMt2tSg3o=";
          };
        }
      ] ++ _kernelPatches;
    };

  linux-asahi = (callPackage linux-asahi-pkg { });
in lib.recurseIntoAttrs (linuxPackagesFor linux-asahi)

