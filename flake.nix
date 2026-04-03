{
  description = "lolcommits - capture git commit pictures on macOS";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.1.2.tar.gz";
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
          config.allowUnfree = true;
        };

        rubyEnv = pkgs.bundlerEnv {
          name = "lolcommits";
          gemdir = ./.;
          inherit (pkgs) bundler;
        };

        lolcommits-wrapped = pkgs.symlinkJoin {
          name = "lolcommits-wrapped";
          paths = [ rubyEnv ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            for bin in lolcommits lolcommits-clay lolcommits-config lolcommits-plugin-manager; do
              if [ -f "$out/bin/$bin" ]; then
                wrapProgram "$out/bin/$bin" \
                  --prefix PATH : ${pkgs.imagemagick}/bin \
                  --prefix PATH : ${pkgs.ffmpeg}/bin
              fi
            done
          '';
        };

      in
      {
        packages = {
          default = lolcommits-wrapped;
          lolcommits-bundle = rubyEnv;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            ruby_3_3
            bundler
            bundix
            imagemagick
            ffmpeg
          ];

          shellHook = ''
            export GEM_HOME="$PWD/.gems"
            export GEM_PATH="$GEM_HOME/ruby/3.3.0"
            export BUNDLE_PATH="$GEM_HOME"
            export PATH="$GEM_HOME/bin:$PATH"

            if [ ! -d ".gems" ]; then
              mkdir -p .gems
              bundle config set --local path '.gems'
              bundle config set --local gemfile "$PWD/Gemfile"
              bundle install
            fi

            for dir in "$GEM_HOME"/ruby/*/bin; do
              if [ -d "$dir" ]; then
                export PATH="$dir:$PATH"
              fi
            done

            echo "lolcommits dev shell ready"
            echo "Use 'lolcommits' to capture commits"
          '';
        };

        formatter = pkgs.nixfmt;
      }
    );
}
