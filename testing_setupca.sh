#!/bin/bash

source ./common.sh

set -e
set -u

init

easyrsa_device_pki_doesntexist

easyrsa_pki_root_init
easyrsa_pki_server_init
easyrsa_device_pki_init

createsubca () {
	{
		$EASYRSA --pki-dir=$1 \
			 --batch \
		 	 --req-cn="$2" \
		 	 build-ca nopass subca
		$EASYRSA --pki-dir=$EASYRSA_PKI_ROOT \
			 --batch \
		 	import-req $1/reqs/ca.req $3
		$EASYRSA --pki-dir=$EASYRSA_PKI_ROOT \
			 --batch \
		 	sign-req ca $3
		cp $EASYRSA_PKI_ROOT/issued/$3.crt $1/ca.crt
		git_stamp $1 "created subca $3" 
	} &>> $LOGFILE
}

$EASYRSA --pki-dir=$EASYRSA_PKI_ROOT \
	 --batch \
	 --req-cn="thingy.jp root CA" \
	 build-ca nopass &>> $LOGFILE

createsubca $EASYRSA_PKI_SERVER "thingy.jp server CA" "serverca"
createsubca $EASYRSA_PKI_DEVICE "thingy.jp device CA" "deviceca"

ln -s $EASYRSA_PKI_ROOT/ca.crt $THINGYJP_ROOTCERT