#!/usr//bin/env guile
!#

;;; Guile OAuth client example.

;; Copyright (C) 2013 Aleix Conchillo Flaque <aconchillo@gmail.com>
;;
;; This file is part of guile-oauth.
;;
;; guile-oauth is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;;
;; guile-oauth is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public
;; License along with guile-oauth; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301 USA

;;; Commentary:

;; OAuth client sample

;;; Code:

(use-modules (json)
             (oauth oauth1)
             (ice-9 receive)
             (sxml simple)
             (rnrs bytevectors)
             (web server)
             (web request)
             (web response)
             (web uri))

(define title "guile-oauth twitter example")

(define xhtml-doctype
  (string-append
   "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" "
   "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"))

(define *twitter-request-url* "https://api.twitter.com/oauth/request_token")
(define *twitter-auth-url* "https://api.twitter.com/oauth/authorize")
(define *twitter-access-url* "https://api.twitter.com/oauth/access_token")
(define *twitter-client-key* "")
(define *twitter-client-secret* "")

(define *request-token* (oauth1-token "" ""))
(define *access-token* (oauth1-token "" ""))

(define* (parse-www-form-urlencoded str #:optional (charset "utf-8"))
  (map
   (lambda (piece)
     (let ((equals (string-index piece #\=)))
       (if equals
           (cons (uri-decode (substring piece 0 equals) #:encoding charset)
                 (uri-decode (substring piece (1+ equals)) #:encoding charset))
           (cons (uri-decode piece #:encoding charset) ""))))
   (string-split str #\&)))

(define (request-query-ref request param)
  (let ((query (uri-query (request-uri request))))
    (assoc-ref (parse-www-form-urlencoded query) param)))(define (twitter-main-editing-form)
  `(div
    (form (@ (method "POST")
             (action "http://localhost:8080/twitter/auth"))
          (p (label (@ (for "key")) "Consumer key: ")
             (input (@ (name "key") (type "text") (size "50")
                       (value ,*twitter-client-key*))))
          (p (label (@ (for "secret")) "Consumer secret: ")
             (input (@ (name "secret") (type "text") (size "50")
                       (value ,*twitter-client-secret*))))
          (p (label (@ (for "request")) "Request token URL: ")
             (input (@ (name "request") (type "text") (size "50")
                       (value ,*twitter-request-url*))))
          (p (label (@ (for "auth")) "Authorize token URL: ")
             (input (@ (name "auth") (type "text") (size "50")
                       (value ,*twitter-auth-url*))))
          (p (label (@ (for "access")) "Access token URL: ")
             (input (@ (name "access") (type "text") (size "50")
                       (value ,*twitter-access-url*))))
          (input (@ (type "submit") (name "status") (value "Home timeline"))))))

(define (twitter-main-form request body)
  `(html
    (head (title ,title))
    (body ,(twitter-main-editing-form))))

(define (twitter-main-form-handler request body)
  (values (build-response
           #:headers '((content-type . (text/html))))
          (lambda (port)
            (display xhtml-doctype port)
            (sxml->xml (twitter-main-form request body) port))))

(define (twitter-authenticate)
  (let* ((callback "http://localhost:8080/twitter/access")
         (request-params (oauth1-client-request-token *twitter-request-url*
                                                      *twitter-client-key*
                                                      *twitter-client-secret*
                                                      callback)))
    (set! *request-token* (oauth1-token-params->token request-params))
    (oauth1-client-authorize-token *twitter-auth-url* *request-token*)))

(define (twitter-auth request body)
  (let ((params (parse-www-form-urlencoded (utf8->string body))))
    (set! *twitter-client-key* (assoc-ref params "key"))
    (set! *twitter-client-secret* (assoc-ref params "secret"))
    (set! *twitter-request-url* (assoc-ref params "request"))
    (set! *twitter-auth-url* (assoc-ref params "auth"))
    (set! *twitter-access-url* (assoc-ref params "access"))
    (twitter-authenticate)))

(define (twitter-auth-handler request body)
  (values (build-response
           #:code 302
           #:headers `((content-type . (text/html))
                       (location . ,(string->uri (twitter-auth request body)))))
          (lambda (port) #nil)))

(define (twitter-access-handler request body)
  (let* ((location "http://localhost:8080/twitter/home_timeline")
         (verifier (request-query-ref request "oauth_verifier"))
         (access-params (oauth1-client-access-token *twitter-access-url*
                                                    *twitter-client-key*
                                                    *twitter-client-secret*
                                                    *request-token*
                                                    verifier)))
    (set! *access-token* (oauth1-token-params->token access-params))
    (values (build-response
           #:code 302
           #:headers `((content-type . (text/html))
                       (location . ,(string->uri location))))
          (lambda (port) #nil))))

(define (twitter-timeline-html json)
  (let ((tweets (json-string->scm json)))
    `(html
      (head (title ,title))
      (body
       "(" (a (@ (href "http://localhost:8080/twitter/home_timeline"))
              "Home timeline")
       ") "
       "(" (a (@ (href "http://localhost:8080/twitter/user_timeline"))
              "User timeline")
       ") "
       ,(map
         (lambda (tweet)
           (let ((user (hash-ref tweet "user")))
             `(p (img (@ (src ,(hash-ref user "profile_image_url"))))
                 ,(hash-ref tweet "text"))))
         tweets)))))

(define (twitter-timeline url request body)
  (let ((request (oauth1-request url #:method 'GET)))
    (oauth1-request-add-default-params request)
    (oauth1-request-add-param request
                              'oauth_token
                              (oauth1-token-token *access-token*))
    (oauth1-request-add-param request
                              'oauth_consumer_key
                              *twitter-client-key*)
    (oauth1-sign-request request *twitter-client-secret* *access-token*)
    (receive (response body)
        (oauth1-http-request request)
      (twitter-timeline-html (utf8->string body)))))

(define (twitter-tweets-handler timeline)
  (lambda (request body)
    (values
     (build-response #:headers '((content-type . (text/html))))
     (lambda (port)
       (display xhtml-doctype port)
       (sxml->xml (timeline request body) port)))))

(define (twitter-user-timeline request body)
  (twitter-timeline "http://api.twitter.com/1.1/statuses/user_timeline.json"
                    request body))

(define twitter-user-timeline-handler
  (twitter-tweets-handler twitter-user-timeline))

(define (twitter-home-timeline request body)
  (twitter-timeline "http://api.twitter.com/1.1/statuses/home_timeline.json"
                    request body))

(define twitter-home-timeline-handler
  (twitter-tweets-handler twitter-home-timeline))

;; Build a resource not found (404) response
(define (not-found request)
  (values (build-response #:code 404)
          (string-append "Resource not found: "
                         (uri->string (request-uri request)))))

(define (request-path-components request)
  (split-and-decode-uri-path (uri-path (request-uri request))))

;; This is the server main handler. It will check if the given request
;; is valid, and if so it will call the right handler.
(define (main-handler request body)
  (cond
   ;; /twitter
   ((equal? (request-path-components request) '("twitter"))
    (twitter-main-form-handler request body))
   ;; /twitter/auth
   ((equal? (request-path-components request) '("twitter" "auth"))
    (twitter-auth-handler request body))
   ;; /twitter/access
   ((equal? (request-path-components request) '("twitter" "access"))
    (twitter-access-handler request body))
   ;; /twitter/home_timeline
   ((equal? (request-path-components request) '("twitter" "home_timeline"))
    (twitter-home-timeline-handler request body))
   ;; /twitter/user_timeline
   ((equal? (request-path-components request) '("twitter" "user_timeline"))
    (twitter-user-timeline-handler request body))
   ;; Resource not found (404)
   (else (not-found request))))

(display "\nNow go to http://localhost:8080/twitter\n")

;; We start the server. (main-handler) will be called every time a
;; request is received.
(run-server main-handler)

;;; code ends here
