// Copyright 2016 Yahoo Inc.
// Licensed under the terms of the Apache version 2.0 license. See LICENSE file for terms.

// Server is a program to demonstrate the use of ZMS Go client to implement
// Athenz centralized authorization support in a server.
package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"fmt"
	"io"
	"net/http"
	"log"
	"io/ioutil"
	"strings"

	"github.com/yahoo/athenz/clients/go/zms"
)

var (
	authHeader     string
	zmsURL         string
	providerDomain string
)

func authorizeRequest(ntoken, resource, action string) bool {
	// for our test example we're just going to skip
	// validating self-signed certificates
	tr := http.Transport{}
	config := &tls.Config{}
	config.InsecureSkipVerify = true

	tr.TLSClientConfig = config
	zmsClient := zms.ZMSClient{
		URL:       zmsURL,
		Transport: &tr,
	}
	zmsClient.AddCredentials(authHeader, ntoken)
	access, err := zmsClient.GetAccess(zms.ActionName(action), zms.ResourceName(resource), "", "")
	if err != nil {
		fmt.Println("Unable to verify access: %v", err)
		return false
	}
	return access.Granted
}

func movieHandler(w http.ResponseWriter, r *http.Request) {
/*
	// first let's verify that we have an ntoken
	if r.Header[authHeader] == nil {
		http.Error(w, "403 - Missing NToken", 403)
		return
	}
*/
	// let's generate our resource value which is the
	// <provider domain>:<entity value>
	resource := providerDomain + ":rec.movie"
	// finally check with ZMS if the principal is authorized
	if !authorizeRequest(r.Header[authHeader][0], resource, "read") {
		http.Error(w, "403 - Unauthorized access", 403)
		return
	}
	io.WriteString(w, "Name: Slap Shot; Director: George Roy Hill\n")
}

type TLSPrincipal struct {
	Cert *x509.Certificate
}

func (p *TLSPrincipal) String() string {
	return p.GetYRN()
}

func (p *TLSPrincipal) GetDomain() string {
	cn := p.Cert.Subject.CommonName
	i := strings.LastIndex(cn, ".")
	return cn[0:i]
}

func (p *TLSPrincipal) GetName() string {
	cn := p.Cert.Subject.CommonName
	i := strings.LastIndex(cn, ".")
	return cn[i+1:]
}

func (p *TLSPrincipal) GetYRN() string {
	return p.Cert.Subject.CommonName
}

func tvshowHandler(w http.ResponseWriter, r *http.Request) {
/*
	// first let's verify that we have an ntoken
	if r.Header[authHeader] == nil {
		http.Error(w, "403 - Missing NToken", 403)
		return
	}
*/
/*
	// let's generate our resource value which is the
	// <provider domain>:<entity value>
	// finally check with ZMS if the principal is authorized
	resource := providerDomain + ":rec.tvshow"
	if !authorizeRequest(r.Header[authHeader][0], resource, "read") {
		http.Error(w, "403 - Unauthorized access", 403)
		return
	}
*/
	certs := r.TLS.PeerCertificates
	for _, cert := range certs {
		fmt.Printf("[Authenticated '%s' from TLS client cert]\n", cert.Subject.CommonName)
		//Principal := &TLSPrincipal{cert}
	}
	io.WriteString(w, "Name: Middle; Channel: ABC\n")
}

func main() {
	flag.StringVar(&zmsURL, "zms", "https://localhost:4443/zms/v1", "url of the ZMS Service")
	flag.StringVar(&authHeader, "hdr", "Athenz-Principal-Auth", "The NToken header name")
	flag.StringVar(&providerDomain, "domain", "recommend", "The provider domain name")
	flag.Parse()

	http.HandleFunc("/rec/v1/movie", movieHandler)
	http.HandleFunc("/rec/v1/tvshow", tvshowHandler)
	//http.ListenAndServe(":30000", nil)
	config, err := TLSConfiguration()
	if err != nil {
		log.Fatal("Cannot set up TLS: " + err.Error())
	}
	listener, err := tls.Listen("tcp", "0.0.0.0:3443", config)
	if err != nil {
		panic(err)
	}
	log.Fatal(http.Serve(listener, nil))
	//http.ListenAndServeTLS(":3443", "certs/recommend.website.crt", "certs/private.key", nil);
	log.Output(0, "Server started.")
}

func TLSConfiguration() (*tls.Config, error) {
	capem, err := ioutil.ReadFile("certs/recommend-ca.crt")
	if err != nil {
		return nil, err
	}
	config := &tls.Config{}

	certPool := x509.NewCertPool()
	if !certPool.AppendCertsFromPEM(capem) {
		return nil, fmt.Errorf("Failed to append certs to pool")
	}
	config.RootCAs = certPool

	keypem, err := ioutil.ReadFile("certs/private.key")
	if err != nil {
		return nil, err
	}
	certpem, err := ioutil.ReadFile("certs/recommend.website.crt")
	if err != nil {
		return nil, err
	}
	if certpem != nil && keypem != nil {
		mycert, err := tls.X509KeyPair(certpem, keypem)
		if err != nil {
			return nil, err
		}
		config.Certificates = make([]tls.Certificate, 1)
		config.Certificates[0] = mycert

		config.ClientCAs = certPool

		//config.ClientAuth = tls.RequireAndVerifyClientCert
		config.ClientAuth = tls.VerifyClientCertIfGiven
	}

	//Use only modern ciphers
	config.CipherSuites = []uint16{tls.TLS_RSA_WITH_AES_128_CBC_SHA,
		tls.TLS_RSA_WITH_AES_256_CBC_SHA,
		tls.TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,
		tls.TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,
		tls.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,
		tls.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,
		tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
		tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256}

	//Use only TLS v1.2
	//config.MinVersion = tls.VersionTLS12

	//Don't allow session resumption
	config.SessionTicketsDisabled = true
	return config, nil

}
