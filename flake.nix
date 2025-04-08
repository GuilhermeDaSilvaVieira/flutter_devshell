{
  description = "Personal flutter devshell with android development support";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          toolsVersion = "26.1.1";
          platformToolsVersion = "34.0.5";
          buildToolsVersions = [ "33.0.1" ];
          includeEmulator = false;
          emulatorVersion = "34.1.9";
          platformVersions = [
            "28"
            "29"
            "30"
            "31"
            "32"
            "33"
            "34"
            "35"
          ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [
            "armeabi-v7a"
            "arm64-v8a"
          ];
          cmakeVersions = [ "3.10.2" ];
          includeNDK = true;
          ndkVersions = [ "22.0.7026061" ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
        };
        androidSdk = androidComposition.androidsdk;
      in
      {
        devShell =
          with pkgs;
          mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            JAVA_HOME = pkgs.jdk17;
            CHROME_EXECUTABLE = "${pkgs.ungoogled-chromium}/bin/chromium";
            buildInputs = [
              flutter
              firebase-tools
              python3 # web serve locally 'python -m http.server'
              androidSdk # The customized SDK that we've made above
              sqlite
              jdk17
            ];
            shellHook = ''
              export LD_LIBRARY_PATH
            '';
            LD_LIBRARY_PATH = "${pkgs.sqlite}/lib";
          };
      }
    );
}
