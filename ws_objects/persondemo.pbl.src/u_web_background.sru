$PBExportHeader$u_web_background.sru
forward
global type u_web_background from userobject
end type
type wb_1 from webbrowser within u_web_background
end type
end forward

global type u_web_background from userobject
integer width = 503
integer height = 864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
event ue_resice pbm_size
wb_1 wb_1
end type
global u_web_background u_web_background

type variables
Boolean lb_navigateCompleted=False
end variables

forward prototypes
public subroutine of_set_visible (boolean ab_visible)
end prototypes

event ue_resice;wb_1.height = This.Height
wb_1.Width = This.Width

end event

public subroutine of_set_visible (boolean ab_visible);If ab_visible=False Then
	wb_1.Visible=False
	This.visible=False
Else
	If lb_navigateCompleted = True Then
		This.BringToTop = True
		This.visible=True
		wb_1.Visible=True
	End IF	
End IF	


end subroutine

on u_web_background.create
this.wb_1=create wb_1
this.Control[]={this.wb_1}
end on

on u_web_background.destroy
destroy(this.wb_1)
end on

event constructor;String ls_html, ls_color_fondo, ls_themename
String ls_ruta
Long ll_Color_Fondo

ls_ruta = "https://www.rsrsystem.com/imagenes/person_demo_logo.png"


ls_themename = GetTheme()

//Parametrización de Colores
Choose Case ls_themename
	Case "Flat Design Blue"	
		ls_color_fondo="#bfbfbf"
		ll_Color_Fondo =12566463 
	Case "Flat Design Grey"
		ls_color_fondo="#999999"
		ll_Color_Fondo =10066329
	Case "Flat Design Silver"
		ls_color_fondo="#949AA5"
		ll_Color_Fondo =10853012
	Case "Flat Design Dark"
		ls_color_fondo="#141414"
		ll_Color_Fondo =1315860
	Case "Flat Design Lime"
		ls_color_fondo="#bfbfbf"
		ll_Color_Fondo =12566463
	Case "Flat Design Orange"	
		ls_color_fondo="#e5e5e5"
		ll_Color_Fondo =15066597
	Case Else
			ls_color_fondo="#FFFFFF"
			ll_Color_Fondo =16777215
End Choose

This.BackColor = ll_Color_Fondo

ls_html = "<!DOCTYPE html>" + "~r~n"+&
				"<html>" + "~r~n"+&
				"<head>" + "~r~n"+&
				"  <meta charset="+Char(34)+"UTF-8"+Char(34)+">" + "~r~n"+&
				"  <title>RSRSYSTEM</title>" + "~r~n"+&
				"  <style>" + "~r~n"+&
				"    body {" + "~r~n"+&
				"      font-family: Arial;" + "~r~n"+&
				"      background-color:  "+ls_color_fondo+";" + "~r~n"+&
				"      text-align: center;" + "~r~n"+&
				"      padding-top: 100px;" + "~r~n"+&
				"      transition: background-color 0.5s ease;" + "~r~n"+&
				"    }" + "~r~n"+&
				""+"~r~n"+&
				"    .mensaje {" + "~r~n"+&
				"      margin-top: 50px;" + "~r~n"+&
				"      opacity: 1;" + "~r~n"+&
				"      transition: opacity 1s ease-in-out;" + "~r~n"+&
				"      user-select: none;" + "~r~n"+&
				"      cursor: default;" + "~r~n"+&
				"    }" + "~r~n"+&
				""+"~r~n"+&
				"    .mensaje img {" + "~r~n"+&
				"      max-width: 100%;" + "~r~n"+&
				"      height: auto;" + "~r~n"+&
				"    }" + "~r~n"+&
				"  </style>" + "~r~n"+&
				"</head>" + "~r~n"+&
				"<body>" + "~r~n"+&
				""+"~r~n"+&
				"  <div id="+Char(34)+"mensaje"+Char(34)+" class="+Char(34)+"mensaje"+Char(34)+">" + "~r~n"+&
				"    <img src="+Char(34)+ls_ruta+Char(34)+" alt="+Char(34)+"Jobers"+Char(34)+" style="+Char(34)+"opacity: 0.1;"+Char(34)+"/>" + "~r~n"+&
				"  </div>" + "~r~n"+&
				""+"~r~n"+&
				"  <script>" + "~r~n"+&
				"    document.addEventListener("+Char(34)+"contextmenu"+Char(34)+", function (e) {" + "~r~n"+&
				"      e.preventDefault();" + "~r~n"+&
				"    });" + "~r~n"+&
				"  </script>" + "~r~n"+&
				""+"~r~n"+&
				"</body>" + "~r~n"+&
				"</html>" 

wb_1.NavigateToString(ls_html)


end event

type wb_1 from webbrowser within u_web_background
boolean visible = false
integer width = 517
integer height = 872
boolean enabled = false
boolean popupwindow = false
boolean contextmenu = false
boolean border = false
end type

event navigationcompleted;If lb_navigateCompleted = False Then
	lb_navigateCompleted=True
	Parent.of_set_visible(True)
End If
end event

