{
  description = "Audit Report Latex Templates and Macros";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {

      # template files are included as a dummy package - available to the build
      # environment
      template-files = { src = ./.; };

      build-report = with import nixpkgs { inherit system; };
        { src
        # ^ source where the latex files can be found

        , file-name ? "audit-report"
          # ^ root file

        , location ? "."
          # ^ root folder

        , imported-files ?
          " $td/style.tex $td/macros.tex  $td/Makefile $td/linked-files "
          # ^ files that get imported and are available to the environment - these
          # files also get symlinked in the dev environment

        , td ? self.template-files.${system}.src
          # ^ template-files dummy package 

        , name ? "template audit report"
          # ^ name of derivation
        }:
        stdenv.mkDerivation {
          inherit td src name;

          buildInputs = self.defaultPackage.${system}.buildInputs;

          buildPhase = " cp -fr ${imported-files}  .  ";

          installPhase = ''
            make 
            mkdir $out
            cp ${location}/_build/${file-name}.pdf $out/$(date +%y%m%d)-${file-name}.pdf
          '';

          shellHook = ''
            echo "> linking template files:"
            ln -sf ${imported-files} .
            echo "> Welcome to the audit-report shell."
          '';
        };

      defaultPackage = with import nixpkgs { inherit system; };
        mkShell {
          name = "audit report generator shell";
          buildInputs = with nixpkgs;
            [
              texlive.combined.scheme-full
              pandoc
            ] # packages for latex and file processing
            ++ [ graphviz zathura entr nixfmt ] # packages for  dev environment
          ;
        };
    });
}
