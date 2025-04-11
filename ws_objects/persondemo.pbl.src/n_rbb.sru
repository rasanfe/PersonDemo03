$PBExportHeader$n_rbb.sru
forward
global type n_rbb from ribbonbar
end type
end forward

global type n_rbb from ribbonbar
integer width = 5381
integer height = 404
long backcolor = 15132390
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string pointer = "hyperlink!"
boolean hidepaneltext = true
event ue_largebuttonclicked ( long itemhandle )
event ue_mastermenuclicked ( long itemhandle,  long index,  long subindex )
event ue_recentmenuclicked ( long itemhandle,  long index,  long subindex )
event ue_smallbuttonclicked ( long itemhandle )
event ue_tabbuttonclicked ( long itemhandle )
event ue_menuitemclicked ( long itemhandle,  long index,  long subindex )
end type
global n_rbb n_rbb

type variables
w_frame iw_window
end variables

forward prototypes
public subroutine of_register (w_frame aw_window)
end prototypes

event ue_largebuttonclicked(long itemhandle);//messagebox("ue_largebuttonclicked", "itemhandle = "+string(itemhandle) )
if isvalid (iw_window) THEN 	iw_window.Event ue_rbm_largebuttonclicked(itemhandle)

	
end event

event ue_mastermenuclicked(long itemhandle, long index, long subindex);//•	ItemHandle. The handle of the button the menu associated with.
//•	Index.The index of the menu item clicked. 
//•	SubIndex. The index of the submenu item clicked. 0 
//ReturnValues
//Long.
//Return code choices (specify in a RETURN statement):
//0 -- Continue processing
//

//messagebox("ue_mastermenuclicked", "itemhandle = "+string(itemhandle) + " index="+string(index)+ "  subindex="+string( subindex))
if isvalid (iw_window) THEN iw_window.Event ue_rbm_mastermenuclicked( itemhandle, index,subindex)



end event

event ue_recentmenuclicked(long itemhandle, long index, long subindex);//•	ItemHandle. The handle of the button the menu associated with.
//•	Index.The index of the menu item clicked. 
//•	SubIndex. The index of the submenu item clicked. 0 
//ReturnValues
//Long.
//Return code choices (specify in a RETURN statement):
//0 -- Continue processing
//
//messagebox("ue_recentmenuclicked", "itemhandle = "+string(itemhandle) + " index="+string(index)+ "  subindex="+string( subindex))
if isvalid (iw_window) THEN iw_window.Event ue_rbm_recentmenuclicked( itemhandle, index,subindex)
end event

event ue_smallbuttonclicked(long itemhandle);
//messagebox("ue_smallbuttonclicked", "itemhandle = "+string(itemhandle))
//if isvalid (iw_window) THEN iw_window.wf_rbm_smallbuttonclicked(itemhandle)

end event

event ue_tabbuttonclicked(long itemhandle);if isvalid (iw_window) THEN iw_window.Event ue_rbm_tabbuttonclicked(itemhandle)

end event

event ue_menuitemclicked(long itemhandle, long index, long subindex);//•	ItemHandle. The handle of the button the menu associated with.
//•	Index.The index of the menu item clicked. 
//•	SubIndex. The index of the submenu item clicked. 0 
//ReturnValues
//Long.
//Return code choices (specify in a RETURN statement):
//0 -- Continue processing
//
//messagebox("ue_menuitemclicked", "itemhandle = "+string(itemhandle) + " index="+string(index)+ "  subindex="+string( subindex))
if isvalid (iw_window) THEN iw_window.Event ue_rbm_menuitemclicked( itemhandle, index,subindex)
end event

public subroutine of_register (w_frame aw_window);iw_window = aw_window


end subroutine

on n_rbb.create
end on

on n_rbb.destroy
end on

