$PBExportHeader$n_cst_coderobject.sru
forward
global type n_cst_coderobject from nonvisualobject
end type
end forward

global type n_cst_coderobject from nonvisualobject
end type
global n_cst_coderobject n_cst_coderobject

type variables

end variables

forward prototypes
public function string of_decode (string as_source)
public function string of_encode (string as_source)
end prototypes

public function string of_decode (string as_source);coderobject ln_coderobject
String ls_decode
Encoding lEncoding = EncodingUTF8!
Blob lblb_data

If trim(as_source)="" then return ""

//1- Decode as_source to blob
ln_coderobject = Create coderobject
lblb_data = ln_coderobject.Base64URLDecode(as_source)
destroy ln_coderobject

//2- Blob to String

ls_decode = String(lblb_data, lEncoding)

RETURN ls_decode
end function

public function string of_encode (string as_source);coderobject ln_coderobject
String ls_encoded
Blob lblb_data
Encoding lEncoding = EncodingUTF8!

If trim(as_source)="" then return ""

//1- Get Blob Data
lblb_data = Blob(as_source, lEncoding)

//2- Encode Blob
ln_coderobject = Create coderobject
ls_encoded = ln_coderobject.Base64URLEncode(lblb_data)
destroy ln_coderobject


RETURN ls_encoded
end function

on n_cst_coderobject.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_coderobject.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

