﻿$PBExportHeader$w_frame.srw
$PBExportComments$Frame window for Los Logos
forward
global type w_frame from window
end type
type mdi_1 from mdiclient within w_frame
end type
type mdirbb_1 from ribbonbar within w_frame
end type
type mditbb_1 from tabbedbar within w_frame
end type
type rbb_main from n_rbb within w_frame
end type
end forward

global type w_frame from window
integer width = 4366
integer height = 2496
boolean titlebar = true
string title = "RSRServer"
string menuname = "m_menu"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
windowtype windowtype = mdihelp!
windowstate windowstate = maximized!
string icon = "AppIcon!"
boolean tabbedview = true
boolean maximizealltabbedsheets = true
event ue_rbm_largebuttonclicked ( long itemhandle )
event ue_rbm_mastermenuclicked ( long itemhandle,  long index,  long subindex )
event ue_rbm_recentmenuclicked ( long itemhandle,  long index,  long subindex )
event ue_rbm_smallbuttonclicked ( long itemhandle )
event ue_rbm_tabbuttonclicked ( long itemhandle )
event ue_rbm_menuitemclicked ( long itemhandle,  long index,  long subindex )
mdi_1 mdi_1
mdirbb_1 mdirbb_1
mditbb_1 mditbb_1
rbb_main rbb_main
end type
global w_frame w_frame

type prototypes
//Para Bloquear Windows
FUNCTION boolean LockWorkStation() LIBRARY "User32.dll" alias for "LockWorkStation"
end prototypes

type variables
Private Boolean ib_expand=TRUE


 Public Constant Integer ii_Menu = 1
 Public Constant Integer ii_Category = 2
 Public Constant Integer ii_Panel = 3
 Public Constant Integer ii_Group = 4
 Public Constant Integer ii_LargeButton = 5
 Public Constant Integer ii_SmallButton = 6
 Public Constant Integer ii_ComboBox = 7
 Public Constant Integer ii_CheckBox = 8 
end variables

forward prototypes
private subroutine wf_open (string as_menu_name)
public subroutine wf_window_location ()
end prototypes

event ue_rbm_largebuttonclicked (long itemhandle);
RibbonLargeButtonItem			lr_largebuttonitem
Integer								li_return
String									ls_text, ls_menu_name
window lw_programa

li_return = rbb_main.GetLargebutton(itemhandle, lr_largebuttonitem)

if li_return  = 1 then
	ls_text = lr_largebuttonitem.text
	ls_menu_name = lr_largebuttonitem.tag
	wf_open(ls_menu_name)
end if 
end event

event ue_rbm_mastermenuclicked (long itemhandle, long index, long subindex);
RibbonApplicationMenu			lr_appmenu
RibbonMenu 						lr_Menu
RibbonMenuItem					lr_MenuItem
integer								li_return
string									ls_text, ls_menu_name

Integer li_item

li_return = rbb_main.getmenubybuttonhandle(itemhandle,lr_appmenu)

if li_return = 1 then
	if subindex > 0 then 
		li_return = lr_appmenu.getmasteritem(index, subindex, lr_MenuItem)
	else
		li_return = lr_appmenu.getmasteritem( index, lr_MenuItem)
	end if 
	ls_text = lr_MenuItem.text	
	ls_menu_name = lr_MenuItem.tag
	
	if li_return = 1 then	
		wf_open(ls_menu_name)
	end if 
end if 
end event

event ue_rbm_recentmenuclicked (long itemhandle, long index, long subindex);
end event

event ue_rbm_smallbuttonclicked (long itemhandle);
RibbonSmallButtonItem			lr_smallbuttonitem
integer								li_return
string									ls_menu_name

li_return = rbb_main.GetSmallbutton(itemhandle, lr_smallbuttonitem)

if li_return  = 1 then
	ls_menu_name = lr_smallbuttonitem.tag
	
end if 
end event

event ue_rbm_tabbuttonclicked(long itemhandle);
String 							ls_picturename, ls_menu_name
integer 							li_return
RibbonTabButtonItem 		lr_Tabbuttonitem


li_return = rbb_main.gettabbutton(itemhandle, lr_Tabbuttonitem)
if li_return  = 1 then 
	ls_menu_name = 	lr_Tabbuttonitem.tag	
	Choose case ls_menu_name
		case "m_minimize"
				If rbb_main.isminimized( ) Then
				rbb_main.setminimized( false)
				ls_picturename ="ArrowUpSmall!"
				ib_expand=TRUE
			Else
				rbb_main.setminimized( true)
				ls_picturename ="ArrowDownSmall!"
				ib_expand= FALSE
			End If
			lr_Tabbuttonitem.picturename = ls_picturename
			li_return = rbb_main.SetTabButton(lr_Tabbuttonitem.itemhandle, lr_Tabbuttonitem)	
			this.TriggerEvent(resize!)
	End Choose
End if 
end event

event ue_rbm_menuitemclicked (long itemhandle, long index, long subindex);
RibbonMenu 						lr_Menu
RibbonMenuItem					lr_MenuItem
integer								li_return
string									ls_text, ls_menu_name

li_return = rbb_main.getmenubybuttonhandle(itemhandle, lr_Menu)


if li_return  = 1 then
	
	li_return = lr_Menu.getitem(index, lr_MenuItem)
	
	if li_return = 1 then
		ls_text = lr_MenuItem.text 
		ls_menu_name = lr_MenuItem.tag
					
		IF right(ls_menu_name, 8)= "_submenu" THEN
			li_return = lr_Menu.getitem(index, subindex, lr_MenuItem)
			if li_return = 1 then
				ls_menu_name = lr_MenuItem.tag
				wf_open(ls_menu_name)
			end if	
		ELSE	
			wf_open(ls_menu_name)
		END IF

	end if
end if	
end event

private subroutine wf_open (string as_menu_name);Integer li_pos
LongLong  ll_job
window			lw_base
Boolean lb_active

mdi_1.SetRedraw(FALSE)  

lw_base  = this.getactivesheet( )
	
CHOOSE CASE as_menu_name
	//OPCIONES
	CASE "m_setupimpresora"
		PrintSetup()
	CASE "m_acerca" 
			open(w_about)
	CASE "m_ventanaactual"
		wf_window_location()
	CASE "m_imprimirpantalla"
		IF IsValid (lw_base) THEN
			ll_job = PrintOpen("Captura Pantalla", TRUE)
			//PrintScreen(ll_Spooler,500,500)
			PrintScreen(ll_job, 0,0)
			PrintClose(ll_job)
		END IF	
		//UTILIDADES
	CASE "m_mapadecaracteres"	
		run("charmap")
	CASE "m_notepad"	
		run("notepad")
	CASE "m_calculadora"	
		run("calc")
	CASE "m_bloquear"	
		LockWorkStation()
	CASE "m_setup"	
		Open(w_setup)	
	CASE "m_mant_facturas"
		str_venfac lstr_venfac
		OpenSheetWithParm(w_mant_facturas, lstr_venfac, this, 0, Layered!)
	CASE "m_facturas"
		OpenSheet(w_facturas, this, 0, Layered!)
	CASE "m_sqlasistido"
		OpenSheet(w_con_sql, this, 0, Layered!)
	CASE "m_prueba"
		OpenSheet(w_prueba, this, 0, Layered!)
	CASE "m_salir"
		Close(this)
		Return
END CHOOSE

mdi_1.SetRedraw(TRUE)




end subroutine

public subroutine wf_window_location ();//Muestra un mensaje en Pantalla con la Ubcicación de la Ventana Activa

String ls_className, ls_library
ClassDefinition Cd_ClassDef
Window lw_win

lw_win = GetActiveSheet()

If isvalid(lw_win) then
	ls_className = lw_win.classname()
	Cd_ClassDef = findclassdefinition(ls_className)
	ls_library = Cd_ClassDef.libraryname
	Messagebox("Ubicación", ls_className+ " a " +  ls_library )
end if	
end subroutine

on w_frame.create
if this.MenuName = "m_menu" then this.MenuID = create m_menu
this.mdi_1=create mdi_1
this.mditbb_1=create mditbb_1
this.mdirbb_1=create mdirbb_1
this.rbb_main=create rbb_main
this.Control[]={this.mdi_1,&
this.mditbb_1,&
this.mdirbb_1,&
this.rbb_main}
end on

on w_frame.destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.mdi_1)
destroy(this.mdirbb_1)
destroy(this.mditbb_1)
destroy(this.rbb_main)
end on

event open;String ls_ribbonName

ls_ribbonName = "ribbonbarmenu.xml"

rbb_main.importfromxmlfile(ls_ribbonName)	

rbb_main.of_register(this)

Timer(1)


end event

event timer;String ls_hora
Datetime ldt_hora

ldt_hora=datetime(today(), now())
ls_hora = String(ldt_hora, "dd/mm/yyyy  hh:mm:ss")

This.SetMicroHelp (ls_hora + "  ")

end event

event resize;rbb_main.width = this.workspaceWidth()
rbb_main.move(0, 0)

mdi_1.x = this.workspacex() 
mdi_1.y = this.workspacey()  +  rbb_main.height 		// + 4									 
mdi_1.height = this.workspaceHeight() - rbb_main.height  - 50	
mdi_1.width  = this.workspaceWidth() 
end event

type mdi_1 from mdiclient within w_frame
end type

type mdirbb_1 from ribbonbar within w_frame
int X=0
int Y=0
int Width=0
int Height=596
end type

type mditbb_1 from tabbedbar within w_frame
int X=0
int Y=0
int Width=0
int Height=104
end type

type rbb_main from n_rbb within w_frame
integer width = 4311
integer height = 540
boolean hidepaneltext = false
end type

