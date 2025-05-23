{
  lib,
  buildDunePackage,
  ocaml,
  coqPackages,
  version ? if lib.versionAtLeast ocaml.version "4.08" then "20240715" else "20231231",
}:

let
  fetched = coqPackages.metaFetch ({
    release."20231231".sha256 = "sha256-veB0ORHp6jdRwCyDDAfc7a7ov8sOeHUmiELdOFf/QYk=";
    release."20240715".sha256 = "sha256-9CSxAIm0aEXkwF+aj8u/bqLG30y5eDNz65EnohJPjzI=";
    releaseRev = v: "${v}";
    location = {
      domain = "gitlab.inria.fr";
      owner = "fpottier";
      repo = "menhir";
    };
  }) version;
in
buildDunePackage {
  pname = "menhirLib";
  inherit (fetched) version src;

  minimalOCamlVersion = "4.03";

  meta = with lib; {
    homepage = "http://pauillac.inria.fr/~fpottier/menhir/";
    description = "Runtime support library for parsers generated by Menhir";
    longDescription = ''
      Menhir is a LR(1) parser generator for the Objective Caml programming
      language.  That is, Menhir compiles LR(1) grammar specifications down
      to OCaml code.  Menhir was designed and implemented by François Pottier
      and Yann Régis-Gianas.
    '';
    license = with licenses; [ lgpl2Only ];
    maintainers = with maintainers; [ vbgl ];
  };
}
