{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  jsonschema,
  networkx,
  numpy,
  scipy,
  watchdog,
  attrs,
  black,
  bump-my-version,
  compas-invocations2,
  invoke,
  pytest-cov,
  pythonnet,
  ruff,
  sphinx-compas2-theme,
  twine,
  wheel,
}:

buildPythonPackage rec {
  pname = "compas";
  version = "2.11.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9wlD0sNSLq1NHQoFik+WCvd1uuBDFma6jVi3jLXb3JI=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    jsonschema
    networkx
    numpy
    scipy
    watchdog
  ];

  optional-dependencies = {
    dev = [
      attrs
      black
      bump-my-version
      compas-invocations2
      invoke
      pytest-cov
      pythonnet
      ruff
      sphinx-compas2-theme
      twine
      wheel
    ];
  };

  pythonImportsCheck = [
    "compas"
  ];

  meta = {
    description = "The main COMPAS framework library";
    homepage = "https://pypi.org/project/compas/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
