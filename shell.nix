with import <nixpkgs> { };

mkShell {
  nativeBuildInputs = [
  	gtk4.dev
	libadwaita.dev
	pkg-config
  	openssl.dev
	curl.dev
	simdutf
	xorg.libX11
	xorg.libXcursor.dev
	xorg.libXrender
	xorg.libXext
	libxkbcommon
	libGL.dev
	wayland
	wayland-protocols
	wayland-scanner.dev
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
