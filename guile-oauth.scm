(define-module (labsolns guile-oauth)
 #:use-module ((guix licenses) #:prefix license:)
 #:use-module (gnu packages autotools)
 #:use-module (gnu packages guile)
 #:use-module (gnu packages bash)
 #:use-module (gnu packages pkg-config)
 #:use-module (gnu packages texinfo)
 #:use-module (gnu packages linux)
 #:use-module (guix packages) 
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages tls)
   #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix modules)
    #:use-module (guix derivations)
  #:use-module (guix store)
  #:use-module (guix git-download)
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
             (uri "https://github.com/mbcladwell/guile-oauth/releases/download/1.3.0/guile-oauth-1.3.0.tar.gz")          
            (sha256
             (base32
              "05cvqbybxnsic0ibyrlxyrjkwsyvncb808kgl8vlxwqx8zmn1v9k"))))
   
  (properties `((upstream-name . "guile-oauth")))
  (build-system gnu-build-system)
   (inputs
    `(("guile" ,guile-3.0)))
   (propagated-inputs
    `(
      ("guile-json" ,guile-json-4)
      ("guile-gcrypt" ,guile-gcrypt)
      ("gnutls" ,gnutls)
  		))
    (native-inputs
     `(("bash"       ,bash)         ;for the `source' builtin
       ("pkgconfig"  ,pkg-config)
       ("autoconf" ,autoconf)
       ("automake" ,automake)
       ("texinfo" ,texinfo)
       ("util-linux" ,util-linux))) ;for the `script' command
  (home-page "https://github.com/aconchillo/guile-oauth")
  (synopsis "guile-oauth is an OAuth client module for Guile.")
  (description
    "guile-oauth is an OAuth client module for Guile.")
  (license license:gpl3)))



