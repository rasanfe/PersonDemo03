$PBExportHeader$w_setup.srw
forward
global type w_setup from window
end type
type sle_urlbaselocal from singlelineedit within w_setup
end type
type st_produccion from statictext within w_setup
end type
type st_desarrollo from statictext within w_setup
end type
type sle_urlbaseserver from singlelineedit within w_setup
end type
type rb_produccion from radiobutton within w_setup
end type
type rb_desarrollo from radiobutton within w_setup
end type
type ddlb_theme from dropdownlistbox within w_setup
end type
type ddlb_1 from dropdownlistbox within w_setup
end type
type st_theme from statictext within w_setup
end type
type cb_close from commandbutton within w_setup
end type
type cb_save from commandbutton within w_setup
end type
type gb_config_api from groupbox within w_setup
end type
end forward

global type w_setup from window
integer width = 3013
integer height = 1056
boolean titlebar = true
string title = "Configuración"
boolean controlmenu = true
boolean minbox = true
windowtype windowtype = popup!
long backcolor = 16777215
string icon = "AppIcon!"
boolean center = true
sle_urlbaselocal sle_urlbaselocal
st_produccion st_produccion
st_desarrollo st_desarrollo
sle_urlbaseserver sle_urlbaseserver
rb_produccion rb_produccion
rb_desarrollo rb_desarrollo
ddlb_theme ddlb_theme
ddlb_1 ddlb_1
st_theme st_theme
cb_close cb_close
cb_save cb_save
gb_config_api gb_config_api
end type
global w_setup w_setup

type variables
String is_theme
String is_theme_path //= "C:\Program Files (x86)\Appeon19\Shared\PowerBuilder\theme190\"
end variables

forward prototypes
public subroutine of_add_theme ()
end prototypes

public subroutine of_add_theme ();Int i
String ls_theme_name

is_theme_path = gs_dir + "\theme\"

ddlb_1.DirList(is_theme_path+'*.*', 32768+16) 

For i = 2 To ddlb_1.totalitems( )
	ls_theme_name = ddlb_1.text(i)
	IF Left(ls_theme_name,1) = "[" THEN ls_theme_name = Mid(ls_theme_name, 2)
	IF Right(ls_theme_name,1) = "]" THEN ls_theme_name = Left(ls_theme_name, Len(ls_theme_name) - 1)
	ls_theme_name = Trim(ls_theme_name)
	IF FileExists(is_theme_path + ls_theme_name + "\theme.json") THEN
		ddlb_theme.Additem(ls_theme_name)
	END IF
Next 
ddlb_theme.Additem("Do Not Use Themes")


end subroutine

on w_setup.create
this.sle_urlbaselocal=create sle_urlbaselocal
this.st_produccion=create st_produccion
this.st_desarrollo=create st_desarrollo
this.sle_urlbaseserver=create sle_urlbaseserver
this.rb_produccion=create rb_produccion
this.rb_desarrollo=create rb_desarrollo
this.ddlb_theme=create ddlb_theme
this.ddlb_1=create ddlb_1
this.st_theme=create st_theme
this.cb_close=create cb_close
this.cb_save=create cb_save
this.gb_config_api=create gb_config_api
this.Control[]={this.sle_urlbaselocal,&
this.st_produccion,&
this.st_desarrollo,&
this.sle_urlbaseserver,&
this.rb_produccion,&
this.rb_desarrollo,&
this.ddlb_theme,&
this.ddlb_1,&
this.st_theme,&
this.cb_close,&
this.cb_save,&
this.gb_config_api}
end on

on w_setup.destroy
destroy(this.sle_urlbaselocal)
destroy(this.st_produccion)
destroy(this.st_desarrollo)
destroy(this.sle_urlbaseserver)
destroy(this.rb_produccion)
destroy(this.rb_desarrollo)
destroy(this.ddlb_theme)
destroy(this.ddlb_1)
destroy(this.st_theme)
destroy(this.cb_close)
destroy(this.cb_save)
destroy(this.gb_config_api)
end on

event open;String ls_theme
String ls_envoirment, ls_urlBaseLocal, ls_urlBaseServer


//[Setup]
ls_theme=  ProFileString(gs_fichero_ini, "Setup", "Theme ", "Do Not Use Themes")


//[Api]
ls_envoirment=  ProFileString(gs_fichero_ini, "Api", "Envoirment", "Local")
ls_urlBaseLocal=  ProFileString(gs_fichero_ini, "Api", "UrlBaseLocal", "")
ls_urlBaseServer=  ProFileString(gs_fichero_ini, "Api", "UrlBaseServer", "")


of_add_theme()
ddlb_theme.Text = ls_theme
is_theme = ls_theme
ddlb_theme.SelectItem(ddlb_theme.FindItem(ls_theme , 1))

//[Api]
IF left(ls_envoirment, 1)= "L" Then
	rb_desarrollo.Checked=True
Else
	rb_produccion.Checked=True
End IF
sle_urlBaseLocal.text=  ls_urlBaseLocal
sle_urlBaseServer.text=  ls_urlBaseServer









end event

event closequery;//of_deactive()
end event

type sle_urlbaselocal from singlelineedit within w_setup
integer x = 539
integer y = 380
integer width = 1906
integer height = 104
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
end type

type st_produccion from statictext within w_setup
integer x = 101
integer y = 528
integer width = 425
integer height = 64
boolean bringtotop = true
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Url Producción:"
alignment alignment = right!
end type

type st_desarrollo from statictext within w_setup
integer x = 91
integer y = 396
integer width = 425
integer height = 64
boolean bringtotop = true
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Url Desarollo:"
alignment alignment = right!
end type

type sle_urlbaseserver from singlelineedit within w_setup
integer x = 539
integer y = 516
integer width = 1906
integer height = 104
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
end type

type rb_produccion from radiobutton within w_setup
integer x = 2487
integer y = 508
integer width = 402
integer height = 64
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Producción"
end type

type rb_desarrollo from radiobutton within w_setup
integer x = 2487
integer y = 408
integer width = 366
integer height = 64
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Desarollo"
boolean checked = true
end type

type ddlb_theme from dropdownlistbox within w_setup
integer x = 1029
integer y = 88
integer width = 1029
integer height = 504
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type ddlb_1 from dropdownlistbox within w_setup
boolean visible = false
integer x = 87
integer y = 100
integer width = 869
integer height = 476
integer taborder = 10
integer textsize = -12
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type st_theme from statictext within w_setup
integer x = 535
integer y = 100
integer width = 462
integer height = 96
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 553648127
string text = "Theme:"
alignment alignment = right!
long bordercolor = 1073741824
boolean focusrectangle = false
end type

type cb_close from commandbutton within w_setup
integer x = 1531
integer y = 776
integer width = 366
integer height = 100
integer taborder = 30
integer textsize = -10
string facename = "Segoe UI"
string text = "Cancelar"
end type

event clicked;close(parent)
end event

type cb_save from commandbutton within w_setup
integer x = 1125
integer y = 776
integer width = 366
integer height = 100
integer taborder = 20
integer textsize = -10
string facename = "Segoe UI"
string text = "Acepatr"
end type

event clicked;String  ls_theme
String ls_envoirment, ls_urlBaseLocal, ls_urlBaseServer

//[Setup]
ls_theme = Trim(ddlb_theme.Text )

//[Api]
IF rb_desarrollo.Checked=True Then
	ls_envoirment= "Local"
Else
	ls_envoirment= "Server"
End IF

ls_urlBaseLocal = trim(sle_urlBaseLocal.text)  
ls_urlBaseServer = trim(sle_urlBaseServer.text)


//Grabar Variables
//[Setup]
SetProFileString(gs_fichero_ini, "Setup", "Theme ", ls_theme)

//[Api]
SetProFileString(gs_fichero_ini, "Api", "Envoirment", ls_envoirment)
SetProFileString(gs_fichero_ini, "Api", "UrlBaseLocal", ls_urlBaseLocal)
SetProFileString(gs_fichero_ini, "Api", "UrlBaseServer", ls_urlBaseServer)


IF ls_theme = is_theme  AND  ls_theme <> "Do Not Use Themes" THEN
	close(parent)
ElseIF ls_theme <> is_theme  AND  ls_theme = "Do Not Use Themes" THEN
	MessageBox("Configuración Guardada", "Reinicie la aplicación para que los cambios tengan efecto.")
	close(parent)
ELSE
	ApplyTheme (is_theme_path + ls_theme)
	is_theme = ls_theme
END IF

//Trampa pàra refrescar el Tema:
If isvalid(w_mant_facturas) Then 
	w_mant_facturas.dw_lista.TriggerEvent(Constructor!)
	w_mant_facturas.dw_1.TriggerEvent(Constructor!)
End IF
If isvalid(w_con_facturas) Then w_con_facturas.dw_1.TriggerEvent(Constructor!)
If isvalid(w_con_sql) Then w_con_sql.dw_new.TriggerEvent(Constructor!)
If IsValid(w_frame) Then 	w_frame.iuo_web.TriggerEvent(Constructor!)
If IsValid(w_dashboard) Then 	
	w_dashboard.wb_1.NavigateToString(w_dashboard.in_dash.of_get_html())
End IF





end event

type gb_config_api from groupbox within w_setup
integer x = 50
integer y = 260
integer width = 2885
integer height = 448
integer taborder = 30
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Mi ~"PowerServer~". Porque las malas prácticas a veces molan!"
end type

