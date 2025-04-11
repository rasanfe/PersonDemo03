$PBExportHeader$w_login.srw
$PBExportComments$Login window
forward
global type w_login from window
end type
type cbx_recordar from checkbox within w_login
end type
type cb_cancel from commandbutton within w_login
end type
type sle_database from singlelineedit within w_login
end type
type cb_ok from commandbutton within w_login
end type
type sle_password from singlelineedit within w_login
end type
type sle_usuario from singlelineedit within w_login
end type
type p_logo from picture within w_login
end type
type st_db from statictext within w_login
end type
type st_password from statictext within w_login
end type
type st_userid from statictext within w_login
end type
type gb_login from groupbox within w_login
end type
end forward

global type w_login from window
integer x = 567
integer y = 272
integer width = 2062
integer height = 1652
boolean titlebar = true
string title = "PersonDemo - Login"
boolean controlmenu = true
windowtype windowtype = response!
string icon = "Key.ico"
toolbaralignment toolbaralignment = alignatleft!
boolean center = true
cbx_recordar cbx_recordar
cb_cancel cb_cancel
sle_database sle_database
cb_ok cb_ok
sle_password sle_password
sle_usuario sle_usuario
p_logo p_logo
st_db st_db
st_password st_password
st_userid st_userid
gb_login gb_login
end type
global w_login w_login

type variables
String is_key = "Test Key12345678"
String  is_Iv = "Test IV 12345678"
Encoding lEncoding = EncodingUTF8!
end variables

forward prototypes
public function string wf_encrypt (string as_source)
public function string wf_decrypt (string as_source)
public function boolean wf_login (string as_usuario, string as_password)
end prototypes

public function string wf_encrypt (string as_source);Blob lblb_data
Blob lblb_key
Blob lblb_iv
Blob lblb_encrypt
String ls_encoded

If trim(as_source)="" Then Return ""

lblb_data = Blob(as_source, lEncoding)
lblb_key = Blob(is_key, lEncoding)
lblb_iv = Blob(is_Iv, lEncoding)

CrypterObject lnv_CrypterObject
lnv_CrypterObject = Create CrypterObject
lblb_encrypt = lnv_CrypterObject.SymmetricEncrypt(AES!, lblb_data, lblb_key, OperationModeCBC!, lblb_iv, PKCSPadding!)
destroy lnv_CrypterObject
	
CoderObject ln_CoderObject
ln_CoderObject = Create coderobject
ls_encoded = ln_CoderObject.Base64URLEncode(lblb_encrypt)
destroy ln_CoderObject
	
Return ls_encoded
	

end function

public function string wf_decrypt (string as_source);Blob lblb_data
Blob lblb_key
Blob lblb_iv
Blob lblb_decrypt
String ls_decrypted

If trim(as_source)="" Then Return ""

lblb_key = Blob(is_key, lEncoding)
lblb_iv = Blob(is_Iv, lEncoding)

CoderObject ln_CoderObject
ln_CoderObject = Create coderobject
lblb_data = ln_CoderObject.Base64URLDecode(as_source)
destroy ln_CoderObject

CrypterObject lnv_CrypterObject
lnv_CrypterObject = Create CrypterObject
lblb_decrypt = lnv_CrypterObject.SymmetricDecrypt(AES!, lblb_data, lblb_key, 	OperationModeCBC!, lblb_iv, PKCSPadding!)
Destroy lnv_CrypterObject

ls_decrypted = String(lblb_decrypt, lEncoding)
	
Return ls_decrypted
	

end function

public function boolean wf_login (string as_usuario, string as_password);String ls_sql
Any l_values[], l_result[]
Long ll_cuantos
n_cst_sqlexecutor ln_cst_sqlexecutor
Boolean lb_login

ln_cst_sqlexecutor = Create n_cst_sqlexecutor

ls_sql = "SELECT Count(*)  "+&
			 "FROM usuarios "+&
			 "WHERE v_usuario = @usuario and v_password = @clave "		
			 
l_values[1] = as_usuario
l_values[2] = as_password

l_result[] = ln_cst_sqlexecutor.of_SelectInto(ls_sql, l_values[] )

If  IsNull(l_result[]) Then
		SetNull(lb_login)
Else
	ll_cuantos = l_result[1]
	If ll_Cuantos =1 Then lb_login = True	
End If

Destroy(ln_cst_sqlexecutor)

Return lb_login
end function

on w_login.create
this.cbx_recordar=create cbx_recordar
this.cb_cancel=create cb_cancel
this.sle_database=create sle_database
this.cb_ok=create cb_ok
this.sle_password=create sle_password
this.sle_usuario=create sle_usuario
this.p_logo=create p_logo
this.st_db=create st_db
this.st_password=create st_password
this.st_userid=create st_userid
this.gb_login=create gb_login
this.Control[]={this.cbx_recordar,&
this.cb_cancel,&
this.sle_database,&
this.cb_ok,&
this.sle_password,&
this.sle_usuario,&
this.p_logo,&
this.st_db,&
this.st_password,&
this.st_userid,&
this.gb_login}
end on

on w_login.destroy
destroy(this.cbx_recordar)
destroy(this.cb_cancel)
destroy(this.sle_database)
destroy(this.cb_ok)
destroy(this.sle_password)
destroy(this.sle_usuario)
destroy(this.p_logo)
destroy(this.st_db)
destroy(this.st_password)
destroy(this.st_userid)
destroy(this.gb_login)
end on

event open;String ls_recordar, ls_usuario, ls_password, ls_database

ls_recordar = ProFileString(gs_fichero_ini, "Setup", "Recordar", "N")

If ls_recordar="S" Then
	cbx_recordar.checked = True
	ls_usuario= ProFileString(gs_fichero_ini, "Setup", "Usuario", "N")
	ls_password= wf_decrypt(ProFileString(gs_fichero_ini, "Setup", "Password", ""))
	ls_database = ProFileString(gs_fichero_ini, "Setup", "DataBase", "")
Else
	cbx_recordar.checked = False
	ls_usuario= ""
	ls_password= ""
	ls_database = ""
End If

sle_usuario.text = ls_usuario
sle_password.text = ls_password
sle_database.text = ls_database


end event

type cbx_recordar from checkbox within w_login
integer x = 910
integer y = 1124
integer width = 402
integer height = 80
integer textsize = -10
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Recordar"
end type

type cb_cancel from commandbutton within w_login
integer x = 1143
integer y = 1400
integer width = 343
integer height = 96
integer taborder = 60
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Cancelar"
boolean cancel = true
end type

event clicked;Close (Parent)
end event

type sle_database from singlelineedit within w_login
integer x = 709
integer y = 940
integer width = 937
integer height = 80
integer taborder = 40
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "PersonDemo02"
end type

type cb_ok from commandbutton within w_login
integer x = 640
integer y = 1400
integer width = 343
integer height = 96
integer taborder = 50
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Acceptar"
boolean default = true
end type

event clicked;String ls_usuario, ls_password, ls_database, ls_recordar
Integer li_rtn
Boolean lb_login

ls_usuario = sle_usuario.text
ls_password = sle_password.text
ls_database = sle_database.text

// Set DataBase Profile
gn_Api.SetRequestHeader("profile", ls_database, True)

lb_login =  wf_login(ls_usuario, ls_password)

If lb_login = False Then
	Messagebox("Login",  "¡Usuario o Password Incorrecto!", StopSign!)
	Return
ElseIF isnull(lb_login) Then
	Return
End If

If cbx_recordar.checked=True Then
	ls_recordar = "S"
Else
	ls_recordar = "N"
	ls_usuario= ""
	ls_password= ""
	ls_database = ""
End If

SetProFileString(gs_fichero_ini, "Setup", "Usuario", ls_usuario)
SetProFileString(gs_fichero_ini, "Setup", "Password", wf_encrypt(ls_password))
SetProFileString(gs_fichero_ini, "Setup", "DataBase", ls_database)
SetProFileString(gs_fichero_ini, "Setup", "Recordar", ls_recordar)

Open(w_frame)
Close(Parent)


end event

type sle_password from singlelineedit within w_login
integer x = 704
integer y = 764
integer width = 937
integer height = 80
integer taborder = 20
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean password = true
end type

type sle_usuario from singlelineedit within w_login
integer x = 704
integer y = 584
integer width = 937
integer height = 80
integer taborder = 10
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
end type

type p_logo from picture within w_login
integer x = 128
integer y = 56
integer width = 1687
integer height = 280
string picturename = "imagenes\logo.png"
borderstyle borderstyle = stylelowered!
boolean focusrectangle = false
end type

type st_db from statictext within w_login
integer x = 283
integer y = 944
integer width = 407
integer height = 80
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Base de Datos:"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_password from statictext within w_login
integer x = 361
integer y = 764
integer width = 325
integer height = 80
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "&Password:"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_userid from statictext within w_login
integer x = 357
integer y = 584
integer width = 325
integer height = 80
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Usuario:"
alignment alignment = right!
boolean focusrectangle = false
end type

type gb_login from groupbox within w_login
integer x = 142
integer y = 396
integer width = 1714
integer height = 896
integer textsize = -10
integer weight = 700
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Login"
borderstyle borderstyle = styleraised!
end type

