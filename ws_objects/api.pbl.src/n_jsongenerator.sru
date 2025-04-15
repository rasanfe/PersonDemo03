$PBExportHeader$n_jsongenerator.sru
forward
global type n_jsongenerator from jsongenerator
end type
end forward

global type n_jsongenerator from jsongenerator
end type
global n_jsongenerator n_jsongenerator

forward prototypes
public function string of_set_arguments (string as_argnames[], string as_argdatatypes[], any a_values[])
end prototypes

public function string of_set_arguments (string as_argnames[], string as_argdatatypes[], any a_values[]);String ls_json
String ls_argname, ls_argdatatype
Integer li_TotalArguments, li_argument
Long ll_RootObject, ll_Child
String ls_valuedatatype
Any la_value
Long ll_types, ll_Values
//Array List
Long ll_ChildArray
String ls_item
String ls_List[]
Integer li_TotalArrayList, li_List
  
li_TotalArguments = UpperBound(as_argnames[])
ll_types = UpperBound(as_argdatatypes[])
ll_Values = UpperBound(a_values[])

If ll_Values <> li_TotalArguments Or ll_Values <> ll_types Or  li_TotalArguments <> ll_types Then
	gf_mensaje("Error JsonGenerator", "¡El Numero de Párametros no coincide!")
	Return ""
End if	

ll_RootObject = CreateJsonObject()
	
if ll_RootObject = -1 then 
	gf_mensaje("Error JsonGenerator", "¡Error de Inicio Json!")
	RETURN ""
end if

FOR li_argument = 1 TO li_TotalArguments 
	
	ls_argname = as_argnames[li_argument]

	ls_argdatatype= as_argdatatypes[li_argument]
	
	IF isnull(ls_argdatatype) then ls_argdatatype = ""
	
	la_value = a_values[li_argument]
	
	//Limpio el Nombre de Los Agrumentos Para que sea mas elegante el Json
	IF gf_iin(left(ls_argname, 4), {"arg_", "adt_", "ada_"}) THEN
		ls_argname = Mid(ls_argname, 5, len(ls_argname) - 4)
	ELSE	
		IF gf_iin(left(ls_argname, 3), {"as_", "ai_", "ad_", "al_"}) THEN
			ls_argname = Mid(ls_argname, 4, len(ls_argname) - 3)
		END IF
	END IF
	
	CHOOSE CASE  lower(ls_argdatatype)
		CASE ""
			ll_Child = AddItemNull (ll_RootObject, ls_argname )	
		CASE "string",  "char"
				IF NOT isnull(la_value) THEN //--------------------------------------------------RAMON
					ll_Child = AddItemString(ll_RootObject, ls_argname, la_value)
				ELSE
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				END IF
		CASE "number", "integer","int", "double", "decimal" ,"dec", "longlong", "long", "real"
				IF NOT isnull(la_value) THEN 
					ll_Child = AddItemNumber(ll_RootObject, ls_argname, la_value)
				ELSE
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				END IF	
		CASE "datetime"
				IF NOT isnull(la_value) THEN 
					ll_Child = AddItemDatetime(ll_RootObject, ls_argname, la_value)
				ELSE
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				END IF
		CASE "date"
				IF NOT isnull(la_value) THEN 
					ll_Child = AddItemDate(ll_RootObject, ls_argname, la_value)
				ELSE
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				END IF	
		CASE "time"
				IF NOT isnull(la_value) THEN 
					ll_Child = AddItemTime(ll_RootObject, ls_argname, la_value)	
				ELSE
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				END IF	
		CASE "stringlist",  "decimallist", "numberlist", "datetimelist", "datelist", "timelist"   
							
			li_TotalArrayList = gf_parsetoarray(string(la_value), ",", ref ls_List[]) 
			
			ll_ChildArray =AddItemArray(ll_RootObject, ls_argname)
						
			For li_List = 1 to li_TotalArrayList
				ls_item = ls_List[li_List]
				ll_child = AddItemString(ll_ChildArray, ls_item)
			Next
			
		 CASE ELSE
			gf_mensaje("Error JsonGenerator", "Tipo de dato desconocido: " + ls_argdatatype)
			Return ""
	END CHOOSE		
NEXT

// Generar el JSON como string
 ls_Json = GetJsonString()
 
// Messagebox("ls_Json", ls_Json)
 
 If isnull(ls_Json) or trim(ls_Json) = "" Then
	gf_mensaje("Error JsonGenerator", "¡Error Generando Json String!")
 End IF

 // Retornar el JSON generado
 RETURN ls_Json
end function

on n_jsongenerator.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_jsongenerator.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

