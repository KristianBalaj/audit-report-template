{
  description = "Indigo Audit-Report";
  inputs.audit-report-template.url = "github:mlabs-haskell/audit-report-template";
  inputs.nixpkgs.follows = "audit-report-template/nixpkgs";
  inputs.flake-utils.follows = "audit-report-template/flake-utils";

  outputs = inputs@{ self, nixpkgs, audit-report-template, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      defaultPackage = audit-report-template.build-report.${system} {
        src = ./.;
        name = "indigo audit report";
      };
    });
}
