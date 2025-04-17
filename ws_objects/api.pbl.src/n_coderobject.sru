$PBExportHeader$n_coderobject.sru
forward
global type n_coderobject from coderobject
end type
end forward

global type n_coderobject from coderobject
end type
global n_coderobject n_coderobject

forward prototypes
public function string of_encode (string as_source)
public function string of_decode (string as_source)
end prototypes

public function string of_encode (string as_source);String ls_encoded
Blob lblb_data
Encoding lEncoding = EncodingUTF8!

If trim(as_source)="" Then Return ""

//1- Get Blob Data
lblb_data = Blob(as_source, lEncoding)

//2- Encode Blob
ls_encoded = Base64URLEncode(lblb_data)

Return ls_encoded
end function

public function string of_decode (string as_source);String ls_decode
Encoding lEncoding = EncodingUTF8!
Blob lblb_data

If trim(as_source)="" Then Return ""

//1- Decode as_source to blob
lblb_data = Base64URLDecode(as_source)

//2- Blob to String
ls_decode = String(lblb_data, lEncoding)

Return ls_decode
end function

on n_coderobject.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_coderobject.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

