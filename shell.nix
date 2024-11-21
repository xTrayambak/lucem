with import <nixpkgs> { };

mkShell {
  nativeBuildInputs = [
  	gtk4.dev
	libadwaita.dev
	pkg-config
  	openssl.dev
	curl.dev
	simdutf
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [
  	gtk4.dev
	libadwaita.dev
	pkg-config
	curl.dev
	simdutf
  	openssl.dev
  ];
}
