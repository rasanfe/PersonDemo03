﻿$PBExportHeader$w_dashboard.srw
forward
global type w_dashboard from window
end type
type wb_1 from webbrowser within w_dashboard
end type
end forward

shared variables

end variables

global type w_dashboard from window
integer y = 172
integer width = 4622
integer height = 3104
boolean titlebar = true
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
windowstate windowstate = maximized!
boolean center = true
windowanimationstyle closeanimation = fadeanimation!
wb_1 wb_1
end type
global w_dashboard w_dashboard

type variables
Boolean ib_RegisterEvent = FALSE
n_cst_dashboard_ventas in_dash

end variables

on w_dashboard.create
this.wb_1=create wb_1
this.Control[]={this.wb_1}
end on

on w_dashboard.destroy
destroy(this.wb_1)
end on

event resize;wb_1.height = newheight
wb_1.width = newwidth

end event

event open;String ls_html

If IsValid(w_frame) Then
	w_frame.iuo_web.Post of_set_visible(False)
End If

This.title="Dashboard Ventas"
ls_html = in_dash.of_get_html()
wb_1.NavigateToString(ls_html)




end event

event close;Long ll_OpenWindows

If IsValid(w_frame) Then
	ll_OpenWindows = gf_ventanas_abiertas(w_frame)
	
	If ll_OpenWindows = 1 Then
		w_frame.iuo_web.Post of_set_visible(True)
	End If
End If
end event

type wb_1 from webbrowser within w_dashboard
event ue_open ( string as_menu_name )
integer x = 18
integer y = 20
integer width = 4549
integer height = 2952
boolean border = false
end type

event ue_open(string as_menu_name);in_dash.of_open_sheet(as_menu_name)

end event

event navigationstart;Integer li_rc
IF ib_RegisterEvent = FALSE THEN                               
   li_rc = wb_1.RegisterEvent ( "ue_open" ) 
   IF li_rc =1 THEN
      ib_RegisterEvent =TRUE
   END IF
END IF


end event

event navigationcompleted;in_dash.of_Set_Zoom(wb_1)


end event

