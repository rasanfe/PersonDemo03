﻿$PBExportHeader$w_prueba.srw
forward
global type w_prueba from window
end type
type cb_consultar from commandbutton within w_prueba
end type
type dw_1 from vs_dw_api within w_prueba
end type
end forward

global type w_prueba from window
integer width = 5221
integer height = 2972
boolean titlebar = true
string title = "Venatana de Pruebas"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "AppIcon!"
cb_consultar cb_consultar
dw_1 dw_1
end type
global w_prueba w_prueba

type prototypes
//Funcion para tomar el directorio de la aplicacion  -64Bits 
FUNCTION	uLong	GetModuleFileName ( uLong lhModule, ref string sFileName, ulong nSize )  LIBRARY "Kernel32.dll" ALIAS FOR "GetModuleFileNameW"
end prototypes

on w_prueba.create
this.cb_consultar=create cb_consultar
this.dw_1=create dw_1
this.Control[]={this.cb_consultar,&
this.dw_1}
end on

on w_prueba.destroy
destroy(this.cb_consultar)
destroy(this.dw_1)
end on

event resize;dw_1.Width = Width - 200
dw_1.Height = Height -  560





end event

type cb_consultar from commandbutton within w_prueba
integer x = 101
integer y = 192
integer width = 585
integer height = 108
integer taborder = 40
integer textsize = -8
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Retrieve"
end type

event clicked;Any la_values[]

la_values[1]="1"
la_values[2]="2025"


dw_1.of_retrieve(la_values)
end event

type dw_1 from vs_dw_api within w_prueba
integer x = 50
integer y = 340
integer width = 5115
integer height = 2512
integer taborder = 60
boolean bringtotop = true
string dataobject = "dw_prueba"
boolean vscrollbar = true
end type

