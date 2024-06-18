(define-module (labsolns guile-oauth2)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages guile)
  #:use-module (guix utils)
  #:use-module ((guix build utils) #:select (alist-replace))
  #:use-module (ice-9 match)
  #:use-module (guix gexp)
;;  #:use-module (guile-gcrypt)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages tls)
;;  #:use-module (guile-json)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((srfi srfi-1) #:select (alist-delete))
  )


(define-public guile-oauth2
  (package
    (name "guile-oauth2")
    (version "0.1.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mbcladwell/guile-oauth.git")
             (commit "a40a1641fd9e29bf78ec1bbd32535894c6edb513")))
       (sha256
             (base32 "002hgs4xfrrz0rqa6n1078cn7vz5f70azw1kpljvb4dmv228gfxq"))))
    (build-system guile-build-system)
    (native-inputs
     `(("guile" ,guile-3.0)))
    (propagated-inputs
     (list
        guile-json       
        guile-gcrypt
       ;;       ("gnutls" ,gnutls)
       ))
    (home-page "https://github.com/mbcladwell/guile-oauth")
    (synopsis "guile-oauth is an OAuth client module for Guile.")
    (description
     "guile-oauth is an OAuth client module for Guile.")
    (license license:gpl3+)))



