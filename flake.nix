{
  description = "Audit Report Latex Templates and Macros";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:

    flake-utils.lib.eachDefaultSystem (system: {

      # template files are included as a dummy package - available to the build
      # environment
      template-files = { src = ./.; };

      build-report = with import nixpkgs { inherit system; };
        { src ? "."
          # ^ source where the latex files can be found

        , file-name ? "audit-report"
          # ^ root file

        , location ? "."
          # ^ root folder

        , imported-files ? " $td/scripts $td/linked-files "
          # ^ files that get imported and are available to the environment - these
          # files also get symlinked in the dev environment

        , td ? self.template-files.${system}.src
          # ^ template-files dummy package

        , name ? "template audit report"
          # ^ name of derivation

        , localFlag ? false
          # ^ local flag means that we're building the derivation locally -
          # therefore no linking is needed.
        }:
        stdenv.mkDerivation {
          inherit td src name imported-files;

          buildInputs = with nixpkgs;
            [ markdown-pp pandoc ] # packages for latex and file processing
            ++ [
              graphviz
              zathura
              fd
              entr
              nixfmt
              aspell
              aspellDicts.en
              aspellDicts.en-computers
              aspellDicts.en-science
              nodePackages.prettier
            ] # packages for dev environment
          ;

          buildPhase = " cp -fr ${imported-files}  .  ";

          spellCheckOpts = with nixpkgs; ''
            --lang=en_US --mode=markdown --home-dir=./ --run-together --camel-case \\
            --dict-dir=${aspellDicts.en}/lib/aspell \\
            --lset-extra-dicts ${aspellDicts.en-computers}/lib/aspell/en-computers.rws:${aspellDicts.en-science}/lib/aspell/en_GB-science.rws:${aspellDicts.en-science}/lib/aspell/en_US-science.rws \\
          '';

          spellCheckInteractive = ''
            #!/bin/sh
            for f in \$(fd --extension md --exclude _build/); do
              aspell ${self.defaultPackage.${system}.spellCheckOpts} check \$f;
            done
          '';

          spellCheck = ''
            #!/bin/sh
            cat _build/${file-name}.md | aspell ${
              self.defaultPackage.${system}.spellCheckOpts
            } list
          '';

          formatMd = ''
            #!/bin/sh

            # \"prose-wrap never\" is necessary to avoid tables having a
            # bunch of extra whitespace added, which can mess up the
            # rendering. See https://github.com/prettier/prettier/issues/5651
            prettier --prose-wrap never --write \$(fd --extension md --exclude _build/)
          '';

          installPhase = ''
            mkdir _build
            ./scripts/compile-files.sh ${file-name}.mdpp _build/${file-name}.md _build/${file-name}.pdf
            mkdir $out
            cp ${location}/_build/${file-name}.pdf $out/$(date +%y%m%d)-${file-name}.pdf
          '';

          shellHook = (if localFlag then "" else ''
            echo "> linking template files:"
            ln -sf ${imported-files} .
          '') + ''
            mkdir -p $out
            echo "${
              self.defaultPackage.${system}.formatMd
            }" > $out/format-md.sh
            echo "${
              self.defaultPackage.${system}.spellCheck
            }" > $out/spell-check.sh
            echo "${
              self.defaultPackage.${system}.spellCheckInteractive
            }" > $out/spell-check-interactive.sh
            chmod +x $out/{format-md,spell-check{,-interactive}}.sh
            ln -sf $out/{format-md,spell-check{,-interactive}}.sh .
            echo "> Welcome to the audit-report shell."
          '';
        };

      defaultPackage = self.build-report.${system} {
        name = "audit report generator shell";
        localFlag = true;
      };
    });
}
