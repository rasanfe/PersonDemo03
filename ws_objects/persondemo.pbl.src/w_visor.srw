$PBExportHeader$w_visor.srw
forward
global type w_visor from window
end type
type wb_1 from webbrowser within w_visor
end type
end forward

global type w_visor from window
integer width = 4101
integer height = 2572
boolean titlebar = true
string title = "Visor de Documentos"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
string icon = "AppIcon!"
wb_1 wb_1
end type
global w_visor w_visor

type variables
String is_fileName
end variables

on w_visor.create
this.wb_1=create wb_1
this.Control[]={this.wb_1}
end on

on w_visor.destroy
destroy(this.wb_1)
end on

event open;
is_fileName = Message.StringParm

If is_fileName <> "" Then
	This.Title = "Visor - ["+Mid(is_fileName, LastPos(is_fileName, "\") + 1)+"]"
	wb_1.Navigate(is_fileName)
End If


end event

event resize;wb_1.Width = NewWidth - 100
wb_1.Height = NewHeight - 20
end event

event closequery;
FileDelete(is_fileName)
end event

type wb_1 from webbrowser within w_visor
integer x = 23
integer y = 20
integer width = 4050
integer height = 2392
boolean bringtotop = true
end type

