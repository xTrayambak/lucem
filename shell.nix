with import <nixpkgs> { };

mkShell {
  nativeBuildInputs = [
  	gtk4.dev
	libadwaita.dev
	pkg-config
  	openssl.dev
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [
  	gtk4.dev
	libadwaita.dev
	pkg-config
	simdutf
  	openssl.dev
  ];
}
