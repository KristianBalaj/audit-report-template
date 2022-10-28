{
  description = "Audit Report Latex Templates and Macros";
  outputs = {self, nixpkgs,...}: 
  {
    defaultPackage.x86_64-linux = 
      with import nixpkgs {system = "x86_64-linux";};
        stdenv.mkDerivation{
          name = "audit-report-generation";
          src = ./.;
        };
  };
}
