(define-module (guile-oauth)
#:use-module ((guix licenses) #:prefix license:)
#:use-module (gnu packages autotools)
#:use-module (gnu packages guile)
#:use-module (gnu packages bash)
#:use-module (gnu packages pkg-config)
#:use-module (gnu packages texinfo)
#:use-module (gnu packages linux)
#:use-module (guix packages)
#:use-module (guix download)
;;#:use-module (guix git-dowload)
#:use-module (guix utils)
#:use-module (gnu packages)
#:use-module (gnu packages tls)
#:use-module (guix packages)
#:use-module (guix download)
#:use-module (guix modules)
#:use-module (guix derivations)
#:use-module (guix store)
#:use-module (guix hg-download)
#:use-module (guix build-system gnu)
#:use-module (guix utils)
#:use-module (gnu packages gnupg)
#:use-module (gnu packages tls)
)

(define-public guile-oauth
  (package
   (name "guile-oauth")
   (version "1.3.0")
   (source (origin
	    (method url-fetch)
	    (uri (string-append "file:///home/mbc/projects/guile-oauth/guile-oauth-1.3.0.tar.gz"))
	    (sha256
	     (base32
	      "1ly1nvwyk7n0i8f2rpx78lx4jvfk5z9g4ng52wb1q56p96w21qz7"))))
;;   (properties
;;    ((upstream-name . "guile-oauth")))
   (build-system gnu-build-system)
   (inputs `(("guile" ,guile-3.0)
	     
	     ))
   (propagated-inputs
    `(("guile-json" ,guile-json)
     ("guile-gcrypt" ,guile-gcrypt)
     ("gnutls" ,gnutls)))
   (native-inputs `(("bash" ,bash) ;for the source' builtin
		   ("pkgconfig"  ,pkg-config)
		   ("autoconf" ,autoconf)
		   ("automake" ,automake)
		   ("texinfo" ,texinfo)
		   ("util-linux" ,util-linux))) ;for the script' command
   (home-page "https://github.com/aconchillo/guile-oauth")
   (synopsis "guile-oauth is an OAuth client module for Guile.")
   (description
    "guile-oauth is an OAuth client module for Guile.")
   (license license:gpl3)))

guile-oauth
