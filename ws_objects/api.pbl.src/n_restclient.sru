$PBExportHeader$n_restclient.sru
forward
global type n_restclient from restclient
end type
end forward

global type n_restclient from restclient
end type
global n_restclient n_restclient

type variables
Private String is_UrlBase 
Private String is_error_text
Private string is_JWTToken

//Token expiresin
Private Long il_Expiresin=3600 //60 minutos
//Refresh token clockskew 
Private Long il_ClockSkew =180 //3minutos
Private String is_user, is_password

Public Constant String is_TempLibrary="dwtemp.pbl"

end variables

forward prototypes
public function long of_retrieve (vs_dw_api adw, string as_url)
public function integer of_get (string as_url, ref string as_response)
public function integer of_post (string as_url, string as_data, ref string as_response)
public function integer of_delete (string as_url, string as_data, ref string as_response)
public function string of_get_url (string as_controller, string as_method)
public function integer of_patch (string as_url, string as_data, ref string as_response)
private function string of_restclienterrortext (integer ai_error_number)
public function string of_get_error_text ()
private function integer of_handleerror (string as_url, string as_response, integer al_return)
end prototypes

public function long of_retrieve (vs_dw_api adw, string as_url);// Send GET request
Long ll_RowCount
Integer li_Return

ll_RowCount = This.Retrieve(adw, as_url)

If ll_RowCount < 0 Then
	li_Return = of_HandleError(as_url, "", li_return)
	ll_RowCount = li_Return
End IF	

Return ll_RowCount
end function

public function integer of_get (string as_url, ref string as_response);// Send GET Request
Integer li_Return

li_Return = This.SendGetRequest(as_url, as_response)

li_Return = of_HandleError(as_url, as_response, li_return)

Return li_Return
end function

public function integer of_post (string as_url, string as_data, ref string as_response);// Send POST Request
Integer li_Return

li_return = This.SendPostRequest(as_url, as_data, as_response)

li_Return = of_HandleError(as_url, as_response, li_return)

Return li_Return

end function

public function integer of_delete (string as_url, string as_data, ref string as_response);// Send DELETE Request
Integer li_Return

If as_data = "" Then
	li_return = This.SendDeleteRequest(as_url, as_response)
Else
	li_return = This.SendDeleteRequest(as_url, as_data, as_response)
End if	

li_Return = of_HandleError(as_url, as_response, li_return)

Return li_Return
end function

public function string of_get_url (string as_controller, string as_method);String ls_url

ls_url = is_UrlBase + "/" + as_controller + "/" + as_method 

ls_url = gf_replaceall(ls_url, " ", "%20")  //Remplazamos caractes en blanco por %20

If IsValid(w_frame) Then w_frame.SetMicroHelp(ls_url)

Return ls_url 
end function

public function integer of_patch (string as_url, string as_data, ref string as_response);// Send PATCH Request
Integer li_Return

li_Return = This.SendPatchRequest(as_url, as_data, as_response)

li_Return = of_HandleError(as_url, as_response, li_return)

Return li_Return
end function

private function string of_restclienterrortext (integer ai_error_number);String ls_errorText

CHOOSE CASE ai_error_number
    CASE -1
       ls_errorText = "Error común"
    CASE -2
       ls_errorText = "URL inválida"
    CASE -3
       ls_errorText = "No se puede conectar a Internet"
    CASE -4
       ls_errorText = "Tiempo de espera agotado"
    CASE -5
       ls_errorText = "No se pudo obtener el token"
    CASE -6
       ls_errorText = "Fallo al exportar JSON"
    CASE -7
       ls_errorText = "Fallo al descomprimir los datos"
    CASE -10
       ls_errorText = "El token es inválido o ha expirado"
    CASE -11
       ls_errorText = "El parámetro es inválido"
    CASE -12
       ls_errorText = "Concesión inválida"
    CASE -13
       ls_errorText = "SCOPE inválido"
    CASE -14
       ls_errorText = "Fallo en la conversión de código"
    CASE -15
       ls_errorText = "Conjunto de caracteres no soportado"
    CASE -16
       ls_errorText = "El JSON no es un JSON plano con estructura de dos niveles"
    CASE -17
       ls_errorText = "No se insertaron datos en el DataWindow porque ninguna clave en el JSON coincide con algún nombre de columna"
    CASE -18
       ls_errorText = "Se ha habilitado la verificación de revocación de certificación, pero no se pudo verificar si un certificado ha sido revocado. El servidor utilizado para la verificación de revocación podría estar inalcanzable"
    CASE -19
       ls_errorText = "El certificado SSL es inválido"
    CASE -20
       ls_errorText = "El certificado SSL ha sido revocado"
    CASE -21
       ls_errorText = "La función no reconoce la Autoridad Certificadora que generó el certificado del servidor"
    CASE -22
       ls_errorText = "El nombre común del certificado SSL (campo nombre de host) es incorrecto. Por ejemplo, si ingresaste www.appeon.com y el nombre común en el certificado dice www.devmagic.com"
    CASE -23
       ls_errorText = "La fecha del certificado SSL recibido del servidor es incorrecta. El certificado ha expirado"
    CASE -24
       ls_errorText = "El certificado no fue emitido para la autenticación del servidor"
    CASE -25
       ls_errorText = "La aplicación experimentó un error interno al cargar las bibliotecas SSL"
    CASE -26
       ls_errorText = "Más de un tipo de errores al validar el certificado del servidor"
    CASE -27
       ls_errorText = "El servidor requiere que el cliente proporcione un certificado"
    CASE -28
       ls_errorText = "El certificado del cliente no ha sido asignado con una clave privada"
    CASE -29
       ls_errorText = "El certificado del cliente no tiene una clave privada accesible"
    CASE -30
       ls_errorText = "No se puede encontrar el certificado especificado"
    CASE -31
       ls_errorText = "Fallo al leer el certificado"
    CASE -32
       ls_errorText = "La contraseña del certificado es incorrecta"
    CASE -33
       ls_errorText = "Ha ocurrido un error de seguridad. Posible causa: El cliente no soporta la versión de SSL/TLS requerida por el servidor. Por ejemplo: El cliente no soporta TLS 1.3 cuando el servidor requiere TLS 1.3"
    CASE -34
       ls_errorText = "Respuesta no reconocible. Normalmente esto es porque la versión HTTP no coincide con la versión requerida por el servidor"
    CASE -35
       ls_errorText = "Error de TLS 1.3. El servidor no soporta TLS 1.3"
    CASE ELSE
       ls_errorText = "Código de error desconocido: " + string(ai_error_number)
END CHOOSE

Return ls_errorText

end function

public function string of_get_error_text ();Return is_error_text
end function

private function integer of_handleerror (string as_url, string as_response, integer al_return);Long ll_ResponseStatusCode
String ls_RequestErrorText, ls_RestClientError, ls_ResponseStatusText
Integer li_rtn, li_pos

// Obtener códigos de estado
ll_ResponseStatusCode = This.GetResponseStatusCode()
ls_ResponseStatusText = This.GetResponseStatusText()

If left(string(ll_ResponseStatusCode), 1) = "2"  Then al_return = 1 //Si la REspuesta es 200 no debe fallar El RestClient, es un bug
    
// Determinar mensaje de error
If ls_ResponseStatusText = "" Then
	 If as_response = "" Then
		  ls_RequestErrorText =  "Ocurrió un error en el servidor."
	 Else
		li_pos = Pos(as_response, "~r~n")
		If li_pos > 0 Then
			ls_RequestErrorText = Left(as_response, li_pos - 1)
		End if
	 End If
Else
     ls_RequestErrorText = ls_ResponseStatusText
End If
     
// Manejar diferentes casos de error
If al_return = 1 Then 
   // Éxito en la llamada
   If left(string(ll_ResponseStatusCode), 1) = "2" Then
      is_error_text = ""
		ls_RequestErrorText =""
       li_rtn = 1
    Else
		 If ll_ResponseStatusCode = 404 then 
			 ls_RequestErrorText = "Endpoint no encontrado."+"~r~n"+"~r~n"+as_url 
		 End If 
        is_error_text = "Error HTTP " + String(ll_ResponseStatusCode) + ": " + ls_RequestErrorText
        li_rtn = ll_ResponseStatusCode * -1
     End If
Else 
   // Error en el cliente REST
	ls_RestClientError = of_RestClientErrorText(al_return)
   is_error_text = "Error en cliente REST: " + ls_RestClientError
   li_rtn = -1
 End If
 
 // Logging
SetProfileString(gs_fichero_ini, "ApiLog", "LastUrl", as_url)
SetProfileString(gs_fichero_ini, "ApiLog", "LastResponseStatusCode", String(ll_ResponseStatusCode))
SetProfileString(gs_fichero_ini, "ApiLog", "LastError", ls_RequestErrorText)	
 
 Return li_rtn
end function

on n_restclient.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_restclient.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;String ls_envoirment, ls_UrlKey="UrlBase"

// Clear the Request Headers
ClearRequestHeaders()

// Set the Request Headers to tell the Web API you will send JSON data
SetRequestHeader ("Content-Type", "application/json;charset=UTF-8")

SetRequestHeader("Accept", "application/json, text/plain")

// Set the Request Headers to accept GZIP compression
SetRequestHeader("Accept-Encoding", "gzip")

ls_envoirment = Left(ProfileString(gs_fichero_ini, "Api", "Envoirment", "L"), 1)

If ls_envoirment  = "L" Then
	ls_UrlKey += "Local"
Else
	ls_UrlKey += "Server"
End IF	

is_UrlBase =  ProfileString(gs_fichero_ini, "Api", ls_UrlKey, "") 

//Necesario para Los Nested reports
If Not gb_isPBIDE Then
	LibraryCreate(is_TempLibrary)
	AddToLibraryList (is_TempLibrary )
End If

end event

